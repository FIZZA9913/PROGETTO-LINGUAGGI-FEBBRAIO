;; Gruppo formato da:
;; Fizzardi, Fabio, 844726
;; Pascone, Michele, 820633
;; Paulicelli, Sabino, 856111

;; START jsondump

(defun jsondump (JSON filename)
  (cond ((and (stringp (trad-inv JSON))
              (stringp filename))
         ;; scrive su file
         (with-open-file (out filename
                              :direction :output
                              :if-exists :supersede
                              :if-does-not-exist :create)
           (format out (trad-inv JSON)))
         filename)
        ;; errore
        (t (error "filename non e' una stringa"))))

;; END jsondump

;; START jsonread

(defun jsonread (filename)
  (cond ((string filename)
         ;; legge da file
         (with-open-file (in filename
                             :direction :input
                             :if-does-not-exist :error)
           (let ((stringa (make-string (file-length in))))
             (read-sequence stringa in)
             (jsonparse stringa))))
        ;; errore
        (t (error "filename non e' una stringa"))))

;; END jsonread

;; inizio funzione jsonparse

(defun jsonparse (JSONString)
  (if (stringp JSONString) 
      (jsonparse-ex (p-ws (conv-str-ls JSONString)))
      (error "L'input di jsonparse non e' una stringa")))

(defun jsonparse-ex (c-ls)
  (if (null c-ls) 
      (error "Nessun valore presente in input")
      (cond ((and (= (first c-ls) 123)
                  (null (p-ws (car (cdr (p-obj c-ls))))))
             (car (p-obj c-ls)))
            ;; sopra obj e sotto array
            ((and (= (first c-ls) 91)
                  (null (p-ws (car (cdr (p-arr c-ls))))))
             (car (p-arr c-ls)))
            ;; errore
            (t
             (error "L'input non e' un oggetto o un array")))))

;; fine funzione jsonparse

;; inizio funzione conv-str-ls per conversione
;; da stringa a lista di codici

(defun conv-str-ls (str)
  (if (stringp str) 
      (conv-str-ls-ex (coerce str 'list))
      (error "L'input di conv-str-ls non e' una stringa")))

(defun conv-str-ls-ex (ch-ls)
  (if (null ch-ls)
      NIL
      (cons (char-code (first ch-ls)) 
            (conv-str-ls-ex (rest ch-ls)))))

;; fine funzione conv-str-ls per conversione 
;; da stringa a lista di codici

;; inizio funzione conv-ls-str per conversione
;; da lista di codici a stringa

(defun conv-ls-str (c-ls)
  (if (ver-ls-cod c-ls) 
      (conv-ls-str-ex c-ls "")
      (error "L'input di conv-ls-str non e' una lista di codici")))

(defun conv-ls-str-ex (c-ls str)
  (if (null c-ls)
      ""
      (concatenate 'string
                   ;; primo carattere
                   (concatenate 'string
				str
				(string (code-char (first c-ls))))
                   ;; resto lista
                   (conv-ls-str-ex (rest c-ls) str))))

;; fine funzione conv-ls-str per conversione
;; da lista di codici a stringa

;; inizio funzione p-vl per riconoscimento valori json

(defun p-vl (c-ls)
  (let ((vl (car (p-vl-ex (p-ws c-ls))))
        ;; sopra value sotto codici rimanenti
        (lf (p-ws (car (cdr (p-vl-ex (p-ws c-ls)))))))
    (list vl lf)))

(defun p-vl-ex (c-ls)
  (cond ((null c-ls)
         (error "Nessun valore da poter riconoscere in p-vl"))
        ;; sopra errore sotto chiamate specifiche
        ((= (first c-ls) 123) (p-obj c-ls))
        ((= (first c-ls) 91) (p-arr c-ls))
        ((= (first c-ls) 116) (p-true c-ls))
        ((= (first c-ls) 102) (p-false c-ls))
        ((= (first c-ls) 110) (p-null c-ls))
        ((= (first c-ls) 34) (p-str c-ls))
        ((or (= (first c-ls) 43)
             (= (first c-ls) 45)
             (and (>= (first c-ls) 48)
                  (<= (first c-ls) 57)))
         (p-num c-ls))
        (t (error "Errore di sintassi in p-vl"))))

;; fine funzione p-vl per riconoscimento valori json

;; inizio funzione p-obj per riconoscimento
;; oggetti json

(defun p-obj (c-ls)
  (if (ver-ls-cod c-ls) 
      (p-obj-ex c-ls 'o0 '() '())
      (error "L'input di p-obj non e' una lista di codici")))

(defun p-obj-ex (c-ls q p memb)
  (cond ((null c-ls) (error "Errore di sintassi in p-obj"))
        ;; stato o0
        ((and (= (first c-ls) 123)
              (eql q 'o0))
         (p-obj-ex (p-ws (rest c-ls))
                   'o1
                   p
                   memb))
        ;; stato o1
        ((and (= (first c-ls) 34)
              (eql q 'o1))
         (let ((vl (car (p-str c-ls)))
               (lf (p-ws (car (cdr (p-str c-ls))))))
           (p-obj-ex lf
                     'o2
                     (append p
                             (list vl))
                     memb)))
        ;; stato o2
        ((and (= (first c-ls) 58)
              (eql q 'o2))
         (let ((vl (car (p-vl (rest c-ls))))
               (lf (car (cdr (p-vl (rest c-ls))))))
           (p-obj-ex lf
                     'o3
                     '()
                     (append memb
                             (list (append p
                                           (list vl)))))))
        ;; stato o3
        ((and (= (first c-ls) 44)
              (eql q 'o3))
         (let ((vl (car (p-str (p-ws (rest c-ls)))))
               (lf (p-ws (car (cdr (p-str (p-ws (rest c-ls))))))))
           (p-obj-ex lf
                     'o2
                     (append p
                             (list vl))
                     memb)))
        ;; stati finali
        ((and (= (first c-ls) 125)
              (or (eql q 'o1)
                  (eql q 'o3)))
         (list (append '(jsonobj)
                       memb)
               (rest c-ls)))
        ;; errore
        (t (error "Errore di sintassi in p-obj"))))

;; fine funzione p-obj per riconoscimento
;; oggetti json

;; inizio funzione p-arr per riconoscimento
;; array json

(defun p-arr (c-ls)
  (if (ver-ls-cod c-ls) 
      (p-arr-ex c-ls 'a0 '())
      (error "L'input di p-arr non e' una lista di codici")))

(defun p-arr-ex (c-ls q elem)
  (cond ((null c-ls) (error "Errore di sintassi in p-arr"))
        ;; stato a0
        ((and (= (first c-ls) 91)
              (eql q 'a0))
         (p-arr-ex (p-ws (rest c-ls))
                   'a1
                   elem))
        ;; stato a1
        ((and (not (= (first c-ls) 93))
              (eql q 'a1))
         (let ((vl (car (p-vl c-ls)))
               (lf (car (cdr (p-vl c-ls)))))
           (p-arr-ex lf
                     'a2
                     (append elem
                             (list vl)))))
        ;; stato a2
        ((and (= (first c-ls) 44)
              (eql q 'a2))
         (let ((vl (car (p-vl (rest c-ls))))
               (lf (car (cdr (p-vl (rest c-ls))))))
           (p-arr-ex lf
                     'a2
                     (append elem
                             (list vl)))))
        ;; stati finali
        ((and (= (first c-ls) 93)
              (or (eql q 'a1)
                  (eql q 'a2)))
         (list (append '(jsonarray)
                       elem)
               (rest c-ls)))
        ;; errore
        (t (error "Errore di sintassi in p-arr"))))

;; fine funzione p-arr per riconoscimento
;; array json

;; inizio funzione p-ws per rimozione caratteri whitespace
;; da una lista di codici in input

(defun p-ws (c-ls)
  (if (ver-ls-cod c-ls) 
      (p-ws-ex c-ls)
      (error "L'input di p-ws non e' una lista di codici")))

(defun p-ws-ex (c-ls)
  (cond ((null c-ls) c-ls)
        ;; chiamata ricorsiva
        ((or (= (first c-ls) 9)
             (= (first c-ls) 10)
             (= (first c-ls) 13)
             (= (first c-ls) 32)) (p-ws (rest c-ls)))
        ;; whitespace terminati
        (t c-ls)))

;; fine funzione p-ws per rimozione caratteri whitespace
;; da una lista di codici in input

;; inizio funzione p-str per riconoscimento
;; stringhe json

(defun p-str (c-ls)
  (if (ver-ls-cod c-ls) 
      (p-str-ex (conv-ls-str c-ls))
      (error "L'input di p-str non e' una lista di codici")))

(defun p-str-ex (str)
  (if (>= (length str) 2)
      (let ((start (position #\" str))
            (end (position #\" str :start 1)))
        ;; verifica stringa
        (if (and (eql start 0)
                 (not (eql end NIL))
                 (stringp (subseq str 1 end)))
            ;; ritorno stringa
            (list (subseq str 1 end)
                  (conv-str-ls (subseq str (+ end 1))))
            ;; errori
            (error "Errore di sintassi in p-str")))
      (error "La lunghezza della lista di p-str non e' sufficiente"))) 

;; fine funzione p-str per riconoscimento
;; stringhe json

;; inizio funzione p-num per riconoscimento
;; numeri json

(defun p-num (ls-cs)
  (if (ver-ls-cod ls-cs)
      (p-num-ex ls-cs "")
      (error "L'input di p-num non e' una lista di codici")))

(defun p-num-ex (ls-cs str)
  (let ((num-as-code (car ls-cs)))
    ;; verifica codice
    (if (or (and (not (null num-as-code))
                 (>= num-as-code 48)
                 (<= num-as-code 57)) ; 0-9
            (eql num-as-code 43) ; +
            (eql num-as-code 45) ; -
            (eql num-as-code 46) ; .
            (eql num-as-code 69) ; E
            (eql num-as-code 101)) ; e
        ;; chiamata ricorsiva
        (p-num-ex (rest ls-cs)
                  (concatenate 'string
                               str
                               (string (code-char num-as-code))))
	;; verifica e ritorno del numero
        (if (not (equal str ""))
            (let ((num (read-from-string str)))
              (if (or (integerp num)
                      (floatp num))
                  (list num
			ls-cs)
                ;; errori
                (error "Errore di sintassi in p-num")))
          (error "Errore di sintassi in p-num")))))

;; fine funzione p-num per riconoscimento
;; numeri json

;; inzio funzioni p-true, p-false e p-null per 
;; riconoscimento dei valori elementari true, false e null

;; inizio p-true

(defun p-true (c-ls)
  (if (ver-ls-cod c-ls) 
      (p-true-ex (conv-ls-str c-ls))
      (error "L'input di p-true non e' una lista di codici")))

(defun p-true-ex (str)
  (if (>= (length str) 4)
      ;; verifica true
      (if (string= (subseq str 0 4)
                   "true")
          ;; ritorno true
          (list 'true
                (conv-str-ls (subseq str 4)))
          ;; errori
          (error "Errore di sintassi in p-true"))
      (error "La lunghezza della lista di p-true non e' sufficiente")))

;; fine p-true
;; inizio p-false

(defun p-false (c-ls)
  (if (ver-ls-cod c-ls) 
      (p-false-ex (conv-ls-str c-ls))
      (error "L'input di p-false non e' una lista di codici")))

(defun p-false-ex (str)
  (if (>= (length str) 5)
      ;; verifica false
      (if (string= (subseq str 0 5)
                   "false")
          ;; ritorno false
          (list 'false
                (conv-str-ls (subseq str 5)))
          ;; errori
          (error "Errore di sintassi in p-false"))
      (error "La lunghezza dela lista di p-false non e' sufficiente")))

;; fine p-false
;; inizio p-null

(defun p-null (c-ls)
  (if (ver-ls-cod c-ls) 
      (p-null-ex (conv-ls-str c-ls))
      (error "L'input di p-null non e' una lista di codici")))

(defun p-null-ex (str)
  (if (>= (length str) 4)
      ;; verifica null
      (if (string= (subseq str 0 4)
                   "null")
          ;; ritorno null
          (list 'null
                (conv-str-ls (subseq str 4)))
          ;; errori
          (error "Errore di sintassi in p-null"))
      (error "La lunghezza della lista di p-null non e' sufficiente")))

;; fine p-null

;; fine funzioni p-true, p-false e p-null per
;; riconoscimento dei valori elementari true, false e null

;; inizio funzione trad_inv per traduzione da formato
;; object a stringa

(defun trad-inv (ls)
  (if (listp ls)
      (trad-inv-ex ls)
      (error "L'input di trad-inv non e' una lista")))

(defun trad-inv-ex (ls)
  (cond ((null ls)
         (error "Nessun valore presente in input"))
        ;; chiamata a sottofunzioni
        ((or (eql (first ls)
                  'jsonobj)
             (eql (first ls)
                  'jsonarray))
         (funcall (first ls) (rest ls)))
        ;; errore
        (t (error "Errore di sintassi in trad-inv"))))

;; fine funzione trad_inv per traduzione da formato
;; object a stringa

;; inizio funzione jsonobj per traduzione da formato
;; object a stringa

(defun jsonobj (memb)
  (if (ver-ls-pr memb)
      (jsonobj-ex memb "{")
      (error "L'input di jsonobj non e' una lista di coppie")))

(defun jsonobj-ex (memb trd)
  (if (null memb)
      ;; caso base
      (concatenate 'string
                   trd
                   "}")
      ;; caso ricorsivo
      (jsonobj-ex (rest memb)
                  (concatenate 'string
                               trd
                               (trad-pr (first memb))
                               (virgola memb)))))

;; fine funzione jsonobj per traduzione da formato
;; object a stringa

;; inizio funzione trad-pr per traduzione coppia da formato
;; object a stringa

(defun trad-pr (pr)
  (concatenate 'string
               "\""
               (first pr)
               "\" : "
               (trad-pr-ex (car (rest pr)))))

(defun trad-pr-ex (vl)
  (cond ((stringp vl)
         (concatenate 'string
                      "\""
                      vl
                      "\""))
        ;; sopra stringhe sotto numeri
        ((or (integerp vl)
             (floatp vl))
         (format NIL
                 "~E"
                 vl))
        ;; true, false e null
        ((or (eql vl 'true)
             (eql vl 'false)
             (eql vl 'null))
         (string-downcase vl))
        ;; jsonobj o jsonarray
        ((and (listp vl)
              (or (eql (first vl)
                       'jsonobj)
                  (eql (first vl)
                       'jsonarray)))
         (trad-inv vl))
        ;; errore 
        (t (error "Errore di sintassi in trad-pr"))))

;; fine funzione trad-pr per traduzione coppia da formato
;; object a stringa

;; inizio funzione jsonarray per traduzione array da formato
;; object a stringa

(defun jsonarray (elem)
  (if (listp elem)
      (jsonarray-ex elem "[")
      (error "L'input di jsonarray non e' una lista di elementi")))

(defun jsonarray-ex (elem trd)
  (cond ((null elem)
         (concatenate 'string
                      trd
                      "]"))
        ;; stringhe
        ((stringp (first elem))
         (jsonarray-ex (rest elem)
                       (concatenate 'string
                                    trd
                                    "\""
                                    (first elem)
                                    "\""
                                    (virgola elem))))
        ;; numeri
        ((or (integerp (first elem))
             (floatp (first elem)))
         (jsonarray-ex (rest elem)
                       (concatenate 'string
                                    trd
                                    (format NIL
                                            "~E"
                                            (first elem))
                                    (virgola elem))))
        ;; true, false e null
        ((or (eql (first elem) 'true)
             (eql (first elem) 'false)
             (eql (first elem) 'null))
         (jsonarray-ex (rest elem)
                       (concatenate 'string
                                    trd
                                    (string-downcase (first elem))
                                    (virgola elem))))
        ;; jsonobj o jsonarray
        ((and (listp (first elem))
              (or (eql (first (first elem))
                       'jsonobj)
                  (eql (first (first elem))
                       'jsonarray)))
         (jsonarray-ex (rest elem)
                       (concatenate 'string
                                    trd
                                    (trad-inv (first elem))
                                    (virgola elem))))
        ;; errore
        (t (error "Errore di sintassi in jsonarray"))))

;; fine funzione jsonarray per traduzione array da formato
;; object a stringa

;; inizio funzione jsonaccess per accesso ai dati di
;; jsonobj o jsonarray in formato object

(defun jsonaccess (JSON &rest fields)
  (cond ((and (stringp (trad-inv JSON))
              (eql (first JSON) 'jsonarray)
              (null fields))
         (error "Impossibile accedere ai dati"))
        ;; sopra array con fields vuota sotto caso normale
        ((and (stringp (trad-inv JSON))
              (ver-fields fields))
         (jsonaccess-ex JSON fields))
        ;; errore
        (t
         (error "fields e' scritta in formato scorretto"))))

(defun jsonaccess-ex (JSON fields)
  (cond ((null fields)
         JSON)
        ;; object
        ((and (listp JSON)
              (eql (first JSON)
                   'jsonobj)
              (stringp (first fields)))
         (let ((res (estr-vl (rest JSON)
                             (first fields))))
           (if (not (null res))
               (jsonaccess-ex res
                              (rest fields))
               (error "Impossibile accedere ai dati"))))
        ;; array
        ((and (listp JSON)
              (eql (first JSON)
                   'jsonarray)
              (integerp (first fields)))
         (let ((res (nth (first fields)
                         (rest JSON))))
           (if (not (null res))
               (jsonaccess-ex res
                              (rest fields))
               (error "Array out of bounds"))))
        ;; errore
        (t
         (error "Impossibile accedere ai dati"))))

;; fine funzione jsonaccess per accesso ai dati di
;; jsonobj o jsonarray in formato object

;; inizio funzione estr-vl per estrazione valore da una lista
;; di coppie in base ad una chiave

(defun estr-vl (memb key)
  (cond ((null memb) NIL)
        ;; trovata chiave
        ((equal (first (first memb))
                key)
         (car (cdr (first memb))))
        ;; chiamata ricorsiva
        (t (estr-vl (rest memb) key))))

;; fine funzione estr-vl per estrazione valore da una lista
;; di coppie in base ad una chiave

;; START UTILS

;; inizio ver-ls-cod

(defun ver-ls-cod (c-ls)
  (if (listp c-ls)
      (ver-ls-cod-ex c-ls)
      NIL))

(defun ver-ls-cod-ex (c-ls)
  (cond ((null c-ls) t)
        ((integerp (first c-ls)) (ver-ls-cod-ex (rest c-ls)))
        (t NIL)))

;; fine ver-ls-cod
;; inizio ver-ls-pr

(defun ver-ls-pr (ls)
  (if (listp ls) 
      (ver-ls-pr-ex ls)
      NIL))

(defun ver-ls-pr-ex (ls)
  (if (null ls)
      t
      (if (ver-pr (first ls))
          (ver-ls-pr-ex (rest ls))
	  NIL)))

;; fine ver-ls-pr
;; inizio ver-pr

(defun ver-pr (pr)
  (if (and (listp pr)
           (stringp (first pr))
           (not (null (second pr)))
           (null (third pr)))
      t
      NIL))

;; fine ver-pr
;; inizio virgola

(defun virgola (ls)
  (if (listp ls)
      ;; verifica
      (cond ((null (rest ls)) "")
            (t ", "))
      ;; errore
      (error "L'input di virgola non e' una lista")))

;; fine virgola
;; inizio ver-fields

(defun ver-fields (ls)
  (if (listp ls)
      (ver-fields-ex ls)
      NIL))

(defun ver-fields-ex (ls)
  (if (null ls)
      t
      (if (or (stringp (first ls))
              (integerp (first ls)))
          (ver-fields-ex (rest ls))
	  NIL)))

;; fine ver-fields

;; END UTILS
