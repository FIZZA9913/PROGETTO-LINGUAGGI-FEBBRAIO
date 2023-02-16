(defun jsonarray (&rest elem)
  (jsonarray-ex elem "["))

(defun jsonarray-ex (elem tdr)
  (cond ((null elem)
         (concatenate 'string
                      tdr
                      "]"))
        ((stringp (first elem))
         (jsonarray-ex (rest elem)
                       (concatenate 'string
                                    tdr
                                    "\""
                                    (first elem)
                                    "\""
                                    (virgola elem))))
        ((and (or (eql (first elem) 'true)
                  (eql (first elem) 'false)
                  (eql (first elem) 'null)))
         (jsonarray-ex (rest elem)
                       (concatenate 'string
                                    tdr
                                    (string (first elem))
                                    (virgola elem))))
        ((not (atom (first elem)))
         (jsonarray-ex (rest elem)
                       (concatenate 'string
                                    tdr
                                    (if (or (eql (car (first elem)) 
                                                 'jsonarray)
                                            (eql (car (first elem))
                                                 'jsonobj))
                                        (first elem)
                                      (error "Errore di sintassi")))))
        (t (error "Errore di sintassi"))))

(defun virgola (list)
  (cond ((null (rest list)) "")
        (t ", ")))

