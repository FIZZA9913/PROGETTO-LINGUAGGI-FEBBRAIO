(defun p-num (ls-cs)
  (if (null ls-cs) nil ;ver-ls-cod
      (p-num-ex ls-cs "")))

(defun p-num-ex (ls-cs str)
  (let ((num-as-code (car ls-cs)))
       (if (or (and (not (null num-as-code))
                    (>= num-as-code 48)
                    (<= num-as-code 57)) ; 0-9
               (eql num-as-code 43) ;+
               (eql num-as-code 45) ;-
               (eql num-as-code 46) ;.
               (eql num-as-code 101)) ;e
           (p-num-ex (rest ls-cs)
                     (concatenate 'string str
                                  (string (code-char num-as-code))))
         (cons (read-from-string str) (cons ls-cs nil)))))
