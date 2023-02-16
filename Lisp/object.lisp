(defun jsonobj (&rest memb)
  (jsonobj-ex memb "{"))

(defun jsonobj-ex (memb tdr)
  (cond ((null memb)
         (concatenate 'string
                      tdr
                      "}"))
        (t (jsonobj-ex (rest memb)
                       (concatenate 'string
                                    tdr
                                    (trad-pr (first memb))
                                    (virgola memb))))))

(defun trad-pr (pair)
  (if (listp pair)
      (if (stringp (first pair))
          (concatenate 'string
                       "\""
                       (first pair)
                       "\""
                       (trad-pr-ex (car (cdr pair)))))))

(defun trad-pr-ex (value)
  (cond ((stringp value)
         (concatenate 'string
                      "\""
                      value
                      "\""))
        ((integerp value) (write-to-string value))
        ((floatp value) (format NIl
                                "~E"
                                value))
        ((or (eql value 'true)
             (eql value 'false)
             (eql value 'null)) (string value))
        ((not (atom value))
         (if (or (eql (car value)
                      'jsonarray)
                 (eql (car value)
                      'jsonobj))
             value
           (error "Scrittura errata di jsonobj o jsonarray")))
        (t (error "Valore non esistente"))))