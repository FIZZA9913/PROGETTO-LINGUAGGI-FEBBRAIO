;inizio funzione conv-string-list per converisone
;da stringa a lista di codici di caratteri

(defun conv-string-list (i-string)
  (conv-string-list-ex (coerce i-string 'list) '()))

(defun conv-string-list-ex (ch-list c-list)
  (cond ((null ch-list) ch-list)
        (t (append (append c-list (list (char-code (first ch-list))))
                   (conv-string-list-ex (rest ch-list) c-list)))))

;fine funzione conv-string-list per conversione
;da stringa a lista di codici di caratteri

;inzio funzione p-value per riconoscimento
;valori json

(defun p-value (c-list)
  (let ((vl (car (p-value-ex (p-ws c-list))))
        (lf (p-ws (cdr (p-value-ex (p-ws c-list))))))
    (list vl lf)))

(defun p-value-ex (c-list)
  (cond ((= (first c-list) 123) (p-obj c-list))
        ((= (first c-list) 91) (p-array c-list))
        ((= (first c-list) 116) (p-true c-list))
        ((= (first c-list) 102) (p-false c-list))
        ((= (first c-list) 110) (p-null c-list))
        ((= (first c-list) 34) (p-stringa c-list))
        (t (p-numero c-list))))

;fine funzione p-value per riconoscimento
;valori json

;inizio funzione p-obj per riconoscimento
;oggetti json



;fine funzione p-obj per riconoscimento
;oggetti json

;inizio funzione p-array per riconoscimento
;array json

(defun p-array (c-list)
  (p-array-ex c-list 'a0 '()))

(defun p-array-ex (c-list q elements)
  (cond ((null c-list) (error "Errore di sintassi"))
        ((and (= (first c-list) 91)
              (equal q 'a0)) (p-array-ex (p-ws (rest c-list))
                                         'a1
                                         elements))
        ((and (= (first c-list) 93)
              (equal q 'a1)) (list (append '(jsonarray)
                                           elements)
                                   (rest c-list)))
        ((and (not (= (first c-list) 93))
              (equal q 'a1)) (let ((vl (car (p-value c-list)))
                                   (lf (cdr (p-value c-list))))
                               (p-array-ex lf 'a2 (append elements
                                                          vl))))
        ((and (= (first c-list) 93)
              (equal q 'a2)) (list (append '(jsonarray)
                                           elements)
                                   (rest c-list)))
        ((and (= (first c-list) 44)
              (equal q 'a2)) (let ((vl (car (p-value (rest c-list))))
                                   (lf (cdr (p-value (rest c-list)))))
                               (p-array-ex lf 'a2 (append elements
                                                          vl))))
        (t (error "Errore di sintassi"))))

;fine funzione p-array per riconoscimento
;array json

;inizio funzione p-ws per rimozione caratteri whitespace
;da una lista di codici in input

(defun p-ws (c-list)
  (cond ((null c-list) c-list)
        ((or (= (first c-list) 10)
             (= (first c-list) 13)
             (= (first c-list) 9)
             (= (first c-list) 32)) (p-ws (rest c-list)))
        (t c-list)))

;fine funzione p-ws per rimozione caratteri whitespace
;da una lista di codici in input

;inizio funzioni p-true, p-false, p-null per riconoscimento
;valori elementari

(defun p-true (c-list)
  (p-true-ex c-list 't0))

(defun p-true-ex (c-list q)
  (cond ((null c-list) (error "Errore di sintassi"))
        ((and (= (first c-list) 116)
              (equal q 't0)) (p-true-ex (rest c-list) 't1))
        ((and (= (first c-list) 114)
              (equal q 't1)) (p-true-ex (rest c-list) 't2))
        ((and (= (first c-list) 117)
              (equal q 't2)) (p-true-ex (rest c-list) 't3))
        ((and (= (first c-list) 101)
              (equal q 't3)) (list 'true (rest c-list)))
        (t (error "Errore di sintassi"))))

(defun p-false (c-list)
  (p-false-ex c-list 'f0))

(defun p-false-ex (c-list q)
  (cond ((null c-list) (error "Errore di sintassi"))
        ((and (= (first c-list) 102)
              (equal q 'f0)) (p-false-ex (rest c-list) 'f1))
        ((and (= (first c-list) 97)
              (equal q 'f1)) (p-false-ex (rest c-list) 'f2))
        ((and (= (first c-list) 108)
              (equal q 'f2)) (p-false-ex (rest c-list) 'f3))
        ((and (= (first c-list) 115)
              (equal q 'f3)) (p-false-ex (rest c-list) 'f4))
        ((and (= (first c-list) 101)
              (equal q 'f4)) (list 'false (rest c-list)))
        (t (error "Errore di sintassi"))))

(defun p-null (c-list)
  (p-null-ex c-list 'n0))

(defun p-null-ex (c-list q)
  (cond ((null c-list) (error "Errore di sintassi"))
        ((and (= (first c-list) 110)
              (equal q 'n0)) (p-null-ex (rest c-list) 'n1))
        ((and (= (first c-list) 117)
              (equal q 'n1)) (p-null-ex (rest c-list) 'n2))
        ((and (= (first c-list) 108)
              (equal q 'n2)) (p-null-ex (rest c-list) 'n3))
        ((and (= (first c-list) 108)
              (equal q 'n3)) (list 'null (rest c-list)))
        (t (error "Errore di sintassi"))))

;fine funzioni p-true, p-false, p-null per riconoscimento
;valori elementari