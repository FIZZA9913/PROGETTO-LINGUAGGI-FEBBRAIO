;; Gruppo formato da:
;; Fizzardi Fabio 844726
;; Pascone Michele 820633
;; Paulicelli Sabino 856111

;; START jsonread

(defun jsonread (filename)
  "Return a string from file filename"
  (with-open-file (in filename
                      :direction :input
                      :if-does-not-exist :error)
    (let ((string (make-string (file-length in))))
      (read-sequence string in)
      (jsonparse string))))

;; END jsonread

;; inizio funzione jsonparse

(defun jsonparse (JSONString)
  (cond ((stringp JSONString) 
         (jsonparse-ex (p-ws (rem0 (conv-str-ls JSONString)))))
        (t (error "L'input di jsonparse non è una stringa"))))

(defun jsonparse-ex (c-ls)
  (cond ((null c-ls) (error "Nessun valore presente in input"))
        (t
         (cond ((and (= (first c-ls) 123)
                     (null (p-ws (car (cdr (p-obj c-ls))))))
                (car (p-obj c-ls)))
               ;; sopra obj e sotto array
               ((and (= (first c-ls) 91)
                     (null (p-ws (car (cdr (p-arr c-ls))))))
                (car (p-arr c-ls)))
               ;; errore
               (t
                (error "L'input non è un oggetto o un array"))))))

;; fine funzione jsonparse

;; inizio funzione conv-str-ls per conversione
;; da stringa a lista di codici

(defun conv-str-ls (str)
  (cond ((stringp str) (conv-str-ls-ex (coerce str 'list) '()))
        (t (error "L'input di conv-str-ls non è una stringa"))))

(defun conv-str-ls-ex (ch-ls c-ls)
  (cond ((null ch-ls) ch-ls)
        (t (append (append c-ls
                           (list (char-code (first ch-ls))))
                   (conv-str-ls-ex (rest ch-ls) c-ls)))))

;; fine funzione conv-str-ls per conversione 
;; da stringa a lista di codici

;; inizio funzione conv-ls-str per conversione
;; da lista di codici a stringa

(defun conv-ls-str (c-ls)
  (cond ((ver-ls-cod c-ls) (conv-ls-str-ex c-ls ""))
        (t (error "L'input di conv-ls-str non è una lista di codici"))))

(defun conv-ls-str-ex (c-ls str)
  (cond ((null c-ls) "")
        (t (concatenate 'string
                        (concatenate 'string
                                     str
                                     (string (code-char (first c-ls))))
                        (conv-ls-str-ex (rest c-ls) str)))))

;; fine funzione conv-ls-str per conversione
;; da lista di codici a stringa

;; inizio funzione p-vl per riconoscimento valori json

(defun p-vl (c-ls)
  (let ((vl (car (p-vl-ex (p-ws c-ls))))
        (lf (p-ws (car (cdr (p-vl-ex (p-ws c-ls)))))))
    (list vl lf)))

(defun p-vl-ex (c-ls)
  (cond ((null c-ls)
         (error "Nessun valore da poter riconoscere in p-vl"))
        ((= (first c-ls) 123) (p-obj c-ls))
        ((= (first c-ls) 91) (p-arr c-ls))
        ((= (first c-ls) 116) (p-true c-ls))
        ((= (first c-ls) 102) (p-false c-ls))
        ((= (first c-ls) 110) (p-null c-ls))
        ((= (first c-ls) 34) (p-str c-ls))
        (t (p-num c-ls))))

;; fine funzione p-vl per riconoscimento valori json

;; inizio funzione p-obj per riconoscimento
;; oggetti json

(defun p-obj (c-ls)
  (cond ((ver-ls-cod c-ls) (p-obj-ex c-ls 'o0 '() '()))
        (t (error "L'input di p-obj non è una lista di codici"))))

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
        ((and (not (= (first c-ls) 125))
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
  (cond ((ver-ls-cod c-ls) (p-arr-ex c-ls 'a0 '()))
        (t (error "L'input di p-arr non è una lista di codici"))))

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
  (cond ((ver-ls-cod c-ls) (p-ws-ex c-ls))
        (t (error "L'input di p-ws non è una lista di codici"))))

(defun p-ws-ex (c-ls)
  (cond ((null c-ls) c-ls)
        ((or (= (first c-ls) 9)
             (= (first c-ls) 10)
             (= (first c-ls) 13)
             (= (first c-ls) 32)) (p-ws (rest c-ls)))
        (t c-ls)))

;; fine funzione p-ws per rimozione caratteri whitespace
;; da una lista di codici in input

;; inizio funzione p-str per riconoscimento
;; stringhe json

(defun p-str (c-ls)
  (cond ((ver-ls-cod c-ls) (p-str-ex (conv-ls-str c-ls)))
        (t (error "L'input di p-str non è una lista di codici"))))

(defun p-str-ex (str)
  (cond ((>= (length str) 2) 
         (let ((start (position #\" str))
               (end (position #\" str :start 1)))
           (cond ((and (= start 0)
                       (stringp (subseq str 1 end)))
                  (list (subseq str 1 end)
                        (conv-str-ls (subseq str (+ end 1)))))
                 (t (error "Errore di sintassi p-str")))))
        (t (error "La lunghezza della lista di p-str non è sufficiente"))))

;; fine funzione p-str per riconoscimento
;; stringhe json

;; inizio funzione p-num per riconoscimento
;; numeri json



;; fine funzione p-num per riconoscimento
;; numeri json

;; inzio funzioni p-true, p-false e p-null per 
;; riconoscimento dei valori elementari true, false e null

;; inizio p-true

(defun p-true (c-ls)
  (cond ((ver-ls-cod c-ls) (p-true-ex (conv-ls-str c-ls)))
        (t (error "L'input di p-true non è una lista di codici"))))

(defun p-true-ex (str)
  (cond ((>= (length str) 4)
         (cond ((string= (subseq str 0 4)
                         "true")
                (list 'true
                      (conv-str-ls (subseq str 4))))
               (t (error "Errore di sintassi in p-true"))))
        (t (error "La lunghezza della lista di p-true non è sufficiente"))))

;; fine p-true
;; inizio p-false

(defun p-false (c-ls)
  (cond ((ver-ls-cod c-ls) (p-false-ex (conv-ls-str c-ls)))
        (t (error "L'input di p-false non è una lista di codici"))))

(defun p-false-ex (str)
  (cond ((>= (length str) 5)
         (cond ((string= (subseq str 0 5)
                         "false")
                (list 'false
                      (conv-str-ls (subseq str 5))))
               (t (error "Errore di sintassi in p-false"))))
        (t (error "La lunghezza della lista di p-false non è sufficiente"))))

;; fine p-false
;; inizio p-null

(defun p-null (c-ls)
  (cond ((ver-ls-cod c-ls) (p-null-ex (conv-ls-str c-ls)))
        (t (error "L'input di p-null non è una lista di codici"))))

(defun p-null-ex (str)
  (cond ((>= (length str) 4)
         (cond ((string= (subseq str 0 4)
                         "null")
                (list 'null
                      (conv-str-ls (subseq str 4))))
               (t (error "Errore di sintassi in p-null"))))
        (t (error "La lunghezza della lista di p-null non è sufficiente"))))

;; fine p-null

;; fine funzioni p-true, p-false e p-null per
;; riconoscimento dei valori elementari true, false e null

;; inizio funzione estr-vl per estrazione valore da una lista
;; di coppie in base ad una chiave

(defun estr-vl (memb key)
  (cond ((and (stringp key)
              (ver-ls-pr memb)) (estr-vl-ex memb key))
        (t (error "L'input di estr-vl è in formato scorretto"))))

(defun estr-vl-ex (memb key)
  (cond ((null memb) memb)
        ((equal (first (first memb))
                key) (car (cdr (first memb))))
        ((not (equal (first (first memb))
                     key)) (estr-vl-ex (rest memb) key))))

;; fine funzione estr-vl per estrazione valore da una lista
;; di coppie in base ad una chiave

;; START UTILS

(defun ver-ls-cod (c-ls)
  (cond ((listp c-ls) (ver-ls-cod-ex c-ls))
        (t NIL)))

(defun ver-ls-cod-ex (c-ls)
  (cond ((null c-ls) t)
        ((integerp (first c-ls)) (ver-ls-cod-ex (rest c-ls)))
        (t NIL)))

(defun ver-ls-pr (ls)
  (cond ((listp ls) (ver-ls-pr-ex ls))
        (t NIL)))

(defun ver-ls-pr-ex (ls)
  (cond ((null ls) t)
        ((listp (first ls))
         (cond ((and (stringp (first (first ls)))
                     (not (null (second (first ls))))
                     (null (third (first ls))))
                (ver-ls-pr-ex (rest ls)))
               (t NIL)))
        (t NIL)))

(defun rem0 (c-ls)
  (if (ver-ls-cod c-ls)
      (rem0-ex c-ls)
    (error "L'input di rem0 non è una lista di codici")))

(defun rem0-ex (c-ls)
  (cond ((null c-ls) c-ls)
        ((= (first c-ls) 0) (rem0-ex (rest c-ls)))
        (t c-ls)))

;; END UTILS