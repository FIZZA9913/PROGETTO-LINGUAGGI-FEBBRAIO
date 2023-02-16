;;inizio funzione jsonparse

(defun jsonparse (stringa)
  (cond ((stringp stringa) (jsonparse-ex (conv-str-ls stringa)))
        (t (error "L'input non è una stringa"))))

(defun jsonparse-ex (c-list)
  (cond ((= (first c-list) 123) (p-obj c-list))
        ((= (first c-list) 91) (p-array c-list))))
;errore

;;fine funzione jsonparse

;;inizio funzione conv-str-ls per conversione
;;da stringa a lista di codici

(defun conv-str-ls (stringa)
  (conv-str-ls-ex (coerce stringa 'list) '()))

(defun conv-str-ls-ex (ch-list c-list)
  (cond ((null ch-list) ch-list)
        (t (append (append c-list
                           (list (char-code (first ch-list))))
                   (conv-str-ls-ex (rest ch-list) c-list)))))

;;fine funzione conv-str-ls per conversione
;;da stringa a lista di codici

;;inizio funzione conv-ls-str per conversione 
;;da lista di codici a stringa

(defun conv-ls-str (c-list)
  (conv-ls-str-ex c-list ""))

(defun conv-ls-str-ex (c-list stringa)
  (cond ((null c-list) "")
        (t (concatenate 'string
                        (concatenate 'string
                                     stringa
                                     (string (code-char (first c-list))))
                        (conv-ls-str-ex (rest c-list) stringa)))))

;;fine funzione conv-ls-str per conversione 
;;da lista di codici a stringa

;;inizio funzione p-value per riconoscere valori json

(defun p-value (c-list)
  (let ((vl (car (p-value-ex (p-ws c-list))))
        (lf (p-ws (car (cdr (p-value-ex (p-ws c-list)))))))
    (list vl lf)))

(defun p-value-ex (c-list)
  (cond ((= (first c-list) 123) (p-obj c-list))
        ((= (first c-list) 91) (p-array c-list))
        ((= (first c-list) 116) (p-true c-list))
        ((= (first c-list) 102) (p-false c-list))
        ((= (first c-list) 110) (p-null c-list))
        ((= (first c-list) 34) (p-str c-list))
        (t (p-numero c-list))))

;;fine funzione p-value per riconoscere valori json

;;inizio funzione p-obj per riconoscimento
;;oggetti json

(defun p-obj (c-ls)
  (p-obj-ex c-ls 'o0 '() '()))

(defun p-obj-ex (c-ls q p memb)
  (cond ((null c-ls) (error "Errore di sintassi"))
        ((and (= (first c-ls) 123)
              (eql q 'o0)) (p-obj-ex (p-ws (rest c-ls))
                                     'o1
                                     p
                                     memb))
        ((and (not (= (first c-ls) 125))
              (eql q 'o1)) (let ((vl (car (p-str c-ls)))
                                 (lf (p-ws (cdr (p-str c-ls)))))
                             (p-obj-ex lf
                                       'o2
                                       (append p
                                               (list vl))
                                       memb)))
        ((and (= (first c-ls) 58)
              (eql q 'o2)) (let ((vl (car (p-value (rest c-ls))))
                                 (lf (cdr (p-value (rest c-ls)))))
                             (p-obj-ex lf
                                       'o3
                                       '()
                                       (append memb
                                               (list (append p
                                                             (list vl)))))))
        ((and (= (first c-ls) 44)
              (eql q 'o3)) (let ((vl (car (p-str (p-ws (rest c-ls)))))
                                 (lf (p-ws (cdr (p-str (p-ws (rest c-ls)))))))
                             (p-obj-ex lf
                                       'o2
                                       (append p
                                               (list vl))
                                       memb)))
        ((and (= (first c-ls) 125)
              (or (eql q 'o1)
                  (eql q 'o3))) (list (append '(jsonobj)
                                              memb)
                                      (rest c-ls)))
        (t (error "Errore di sintassi"))))

;;fine funzione p-obj per riconoscimento
;;oggetti json

;;inizio funzione p-array per riconoscimento
;;array json

(defun p-array (c-list)
  (p-array-ex c-list 'a0 '()))

(defun p-array-ex (c-list q elements)
  (cond ((null c-list) (error "Errore di sintassi"))
        ((and (= (first c-list) 91)
              (eql q 'a0)) (p-array-ex (p-ws (rest c-list))
                                       'a1
                                       elements))
        ((and (not (= (first c-list) 93))
              (eql q 'a1)) (let ((vl (car (p-value c-list)))
                                 (lf (cdr (p-value c-list))))
                             (p-array-ex lf
                                         'a2
                                         (append elements
                                                 (list vl)))))
        ((and (= (first c-list) 44)
              (eql q 'a2)) (let ((vl (car (p-value (rest c-list))))
                                 (lf (cdr (p-value (rest c-list)))))
                             (p-array-ex lf
                                         'a2
                                         (append elements
                                                 (list vl)))))
        ((and (= (first c-list) 93)
              (or (eql q 'a1)
                  (eql q 'a2))) (list (append '(jsonarray)
                                              elements)
                                      (rest c-list)))
        (t (error "Errore di sintassi"))))

;;fine funzione p-array per riconoscimento
;;array json

;;inizio funzione p-ws per rimozione caratteri whitespace
;;da una lista di codici in input

(defun p-ws (c-list)
  (cond ((null c-list) c-list)
        ((or (= (first c-list) 9)
             (= (first c-list) 10)
             (= (first c-list) 13)
             (= (first c-list) 32)) (p-ws (rest c-list)))
        (t c-list)))

;;fine funzione p-ws per rimozione caratteri whitespace
;;da una lista di codici in input

;;inizio funzione p-stringa per riconoscimento
;;stringhe json

(defun p-str (c-list)
  (let ((stringa (conv-ls-str c-list)))
    (let ((start (position #\" stringa))
          (end (position #\" stringa :start 1)))
      (if (and (= start 0)
               (stringp (subseq stringa (+ start 1) end)))
          (list (subseq stringa (+ start 1) end)
                (conv-str-ls (subseq stringa (+ end 1))))
        (error "Errore di sintassi")))))

;;fine funzione p-stringa per riconoscimento
;;stringhe json

;;inizio funzioni p-true, p-false e p-null per
;;riconoscimento dei valori elementari true, false e null

(defun p-true (c-list)
  (let ((stringa (conv-ls-str c-list)))
    (if (string= (subseq stringa 0 4)
                 "true")
        (list 'true (conv-str-ls (subseq stringa 4)))
      (error "Errore di sintassi"))))

(defun p-false (c-list)
  (let ((stringa (conv-ls-str c-list)))
    (if (string= (subseq stringa 0 5)
                 "false")
        (list 'false (conv-str-ls (subseq stringa 5)))
      (error "Errore di sintassi"))))

(defun p-null (c-list)
  (let ((stringa (conv-ls-str c-list)))
    (if (string= (subseq stringa 0 4)
                 "null")
        (list 'null (conv-str-ls (subseq stringa 4)))
      (error "Errore di sintassi"))))

;;fine funzioni p-true, p-false e p-null per
;;riconoscimento dei valori elementari true, false e null


