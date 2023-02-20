(defun p-num (ls-cs)
  (cond ((null ls-cs) nil)
        (t (let ((code (car ls-cs))
                 (number (lambda (x) 
                           (cond ((eql #\0 code) 0)
                                 ((eql #\1 code) 1)
                                 ((eql #\2 code) 2)
                                 ((eql #\3 code) 3)
                                 ((eql #\4 code) 4)
                                 ((eql #\5 code) 5)
                                 ((eql #\6 code) 6)
                                 ((eql #\7 code) 7)
                                 ((eql #\8 code) 8)
                                 ((eql #\9 code) 9)
                                 ((eql #\+ code) +)
                                 ((eql #\- code) -)
                                 ((eql #\e code) e)
                                 ((eql #\. code) .)
                                 (t (error "Errore nel numero")))
                           code))
                 (rest (p-num (cdr ls-cs)))))
           (if number 
               (cons number rest) rest))))

;; read from string per numeri

