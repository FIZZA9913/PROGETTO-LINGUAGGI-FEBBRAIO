;;;; jsonparse.lisp
;;;;
;;;; Gruppo formato da:
;;;; Fizzardi, Fabio, 844726
;;;; Pascone, Michele, 820633
;;;; Paulicelli, Sabino, 856111

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

;;inizio funzione jsonparse

(defun jsonparse (JSONString)
  (cond ((stringp JSONString) (jsonparse-ex (p-ws (conv-str-ls JSONString))))
        (t (error "L'input non è una stringa"))))

(defun jsonparse-ex (c-ls)
  (cond ((and (= (first c-ls) 123)
              (or (null (p-ws (car (cdr (p-obj c-ls)))))
                  (zerop (car (p-ws (car (cdr (p-obj c-ls)))))))) 
         (car (p-obj c-ls)))
        ;;object e array
        ((and (= (first c-ls) 91)
              (or (null (p-ws (car (cdr (p-array c-ls)))))
                  (zerop (car (p-ws (car (cdr (p-array c-ls)))))))) 
         (car (p-array c-ls)))
        (t (error "L'input non è un oggetto o un array"))))

;;fine funzione jsonparse

;;inizio funzione conv-str-ls per conversione
;;da stringa a lista di codici

(defun conv-str-ls (str)
  (cond ((stringp str) (conv-str-ls-ex (coerce str 'list) '()))
        (t (error "Errore di sintassi"))))

(defun conv-str-ls-ex (ch-ls c-ls)
  (cond ((null ch-ls) ch-ls)
        (t (append (append c-ls
                           (list (char-code (first ch-ls))))
                   (conv-str-ls-ex (rest ch-ls) c-ls)))))

;;fine funzione conv-str-ls per conversione
;;da stringa a lista di codici

;;inizio funzione conv-ls-str per conversione
;;da lista di codici a stringa

(defun conv-ls-str (c-ls)
  (cond ((listp c-ls) (conv-ls-str-ex c-ls ""))
        (t (error "Errore di sintassi"))))

(defun conv-ls-str-ex (c-ls str)
  (cond ((null c-ls) "")
        (t (concatenate 'string
                        (concatenate 'string
                                     str
                                     (string (code-char (first c-ls))))
                        (conv-ls-str-ex (rest c-ls) str)))))

;;fine funzione conv-ls-str per conversione
;;da lista di codici a stringa

;;inizio funzione p-value per riconoscere valori json

(defun p-vl (c-ls)
  (let ((vl (car (p-vl-ex (p-ws c-ls))))
        (lf (p-ws (car (cdr (p-vl-ex (p-ws c-ls)))))))
    (list vl lf)))

(defun p-vl-ex (c-ls)
  (cond ((= (first c-ls) 123) (p-obj c-ls))
        ((= (first c-ls) 91) (p-array c-ls))
        ((= (first c-ls) 116) (p-true c-ls))
        ((= (first c-ls) 102) (p-false c-ls))
        ((= (first c-ls) 110) (p-null c-ls))
        ((= (first c-ls) 34) (p-str c-ls))
        (t (p-num c-ls))))

;;fine funzione p-value per riconoscere valori json

;;inizio funzione p-obj per riconoscimento
;;oggetti json

(defun p-obj (c-ls)
  (cond ((listp c-ls) (p-obj-ex c-ls 'o0 '() '()))
        (t (error "Errore di sintassi"))))

(defun p-obj-ex (c-ls q p memb)
  (cond ((null c-ls) (error "Errore di sintassi"))
        ;;stato o0
        ((and (= (first c-ls) 123)
              (eql q 'o0)) 
         (p-obj-ex (p-ws (rest c-ls))
                   'o1
                   p
                   memb))
        ;;stato o1
        ((and (not (= (first c-ls) 125))
              (eql q 'o1)) 
         (let ((vl (car (p-str c-ls)))
               (lf (p-ws (car (cdr (p-str c-ls))))))
           (p-obj-ex lf
                     'o2
                     (append p
                             (list vl))
                     memb)))
        ;;stato o2
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
        ;;stato o3
        ((and (= (first c-ls) 44)
              (eql q 'o3)) 
         (let ((vl (car (p-str (p-ws (rest c-ls)))))
               (lf (p-ws (car (cdr (p-str (p-ws (rest c-ls))))))))
           (p-obj-ex lf
                     'o2
                     (append p
                             (list vl))
                     memb)))
        ;;stati finali
        ((and (= (first c-ls) 125)
              (or (eql q 'o1)
                  (eql q 'o3))) 
         (list (append '(jsonobj)
                       memb)
               (rest c-ls)))
        (t (error "Errore di sintassi"))))

;;fine funzione p-obj per riconoscimento
;;oggetti json

;;inizio funzione p-array per riconoscimento
;;array json

(defun p-array (c-ls)
  (cond ((listp c-ls) (p-array-ex c-ls 'a0 '()))
        (t (error "Errore di sintassi"))))

(defun p-array-ex (c-ls q elem)
  (cond ((null c-ls) (error "Errore di sintassi"))
        ;;stato a0
        ((and (= (first c-ls) 91)
              (eql q 'a0)) 
         (p-array-ex (p-ws (rest c-ls))
                     'a1
                     elem))
        ;;stato a1
        ((and (not (= (first c-ls) 93))
              (eql q 'a1)) 
         (let ((vl (car (p-vl c-ls)))
               (lf (car (cdr (p-vl c-ls)))))
           (p-array-ex lf
                       'a2
                       (append elem
                               (list vl)))))
        ;;stato a2
        ((and (= (first c-ls) 44)
              (eql q 'a2)) 
         (let ((vl (car (p-vl (rest c-ls))))
               (lf (car (cdr (p-vl (rest c-ls))))))
           (p-array-ex lf
                       'a2
                       (append elem
                               (list vl)))))
        ;;stati finali
        ((and (= (first c-ls) 93)
              (or (eql q 'a1)
                  (eql q 'a2))) 
         (list (append '(jsonarray)
                       elem)
               (rest c-ls)))
        (t (error "Errore di sintassi"))))

;;fine funzione p-array per riconoscimento
;;array json

;;inizio funzione p-ws per rimozione caratteri whitespace
;;da una lista di codici in input

(defun p-ws (c-ls)
  (cond ((listp c-ls) (p-ws-ex c-ls))
        (t (error "Errore di sintassi"))))

(defun p-ws-ex (c-ls)
  (cond ((null c-ls) c-ls)
        ((or (= (first c-ls) 9)
             (= (first c-ls) 10)
             (= (first c-ls) 13)
             (= (first c-ls) 32)) (p-ws (rest c-ls)))
        (t c-ls)))

;;fine funzione p-ws per rimozione caratteri whitespace
;;da una lista di codici in input

;;inizio funzione p-str per riconoscimento
;;stringhe json

(defun p-str (c-ls)
  (cond ((listp c-ls) (p-str-ex (conv-ls-str c-ls)))
        (t (error "Errore di sintassi"))))

(defun p-str-ex (str)
  (let ((start (position #\" str))
        (end (position #\" str :start 1)))
    (if (and (= start 0)
             (stringp (subseq str 1 end)))
        (list (subseq str 1 end)
              (conv-str-ls (subseq str (+ end 1))))
      (error "Errore di sintassi"))))

;;fine funzione p-str per riconoscimento
;;stringhe json

;;inizio funzione p-num per riconoscimento
;;numeri json

(defun p-num (c-ls)
  (cond ((listp c-ls) (p-num-ex c-ls "" "i"))
        (t (error "Errore di sintassi"))))

(defun p-num (c-ls t mod)
  (cond ((and (>= (first c-ls) 48)
              (=< (first c-ls) 57)))))

;;fine funzione p-num per riconoscimento
;;numeri json

;;inizio funzioni p-true, p-false e p-null per
;;riconoscimento dei valori elementari true, false e null

;;inizio p-true

(defun p-true (c-ls)
  (cond ((listp c-ls) (p-true-ex (conv-ls-str c-ls)))
        (t (error "Errore di sintassi"))))

(defun p-true-ex (str)
  (if (string= (subseq str 0 4)
               "true")
      (list 'true (conv-str-ls (subseq str 4)))
    (error "Errore di sintassi")))

;;fine p-true
;;inizio p-false

(defun p-false (c-ls)
  (cond ((listp c-ls) (p-false-ex (conv-ls-str c-ls)))
        (t (error "Errore di sintassi"))))

(defun p-false-ex (str)
  (if (string= (subseq str 0 5)
               "false")
      (list 'false (conv-str-ls (subseq str 5)))
    (error "Errore di sintassi")))

;;fine p-false
;;inizio p-null

(defun p-null (c-ls)
  (cond ((listp c-ls) (p-null-ex (conv-ls-str c-ls)))
        (t (error "Errore di sintassi"))))

(defun p-null-ex (str)
  (if (string= (subseq str 0 4)
               "null")
      (list 'null (conv-str-ls (subseq str 4)))
    (error "Errore di sintassi")))

;;fine p-null

;;fine funzioni p-true, p-false e p-null per 
;;riconoscimento valori elementari true, false e null
