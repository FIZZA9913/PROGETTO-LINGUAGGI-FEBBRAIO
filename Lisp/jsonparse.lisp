; Gruppo formato da:
;
; Fizzardi Fabio 844726
; Pascone Michele 820633
; Paulicelli Sabino 856111

(defun parsews (charlist)
  (cond ((null charlist) charlist)
        ((or (= (first charlist) 10)
             (= (first charlist) 13)
             (= (first charlist) 9)
             (= (first charlist) 32)) (parsews (rest charlist)))
        (t charlist)))


(defun parsebool_true (stcharlist)
  (cond (= (first stcharlist) 116)
        (cond (= (second stcharlist) 114)
              (cond (= (third stcharlist) 117)
                    (cond (= (fourth stcharlist) 101) (cons 'true rest(charlist))))))
  (t (error "TRUE non è stato riconosciuto correttamente"))))
                    

(defun parsebool_false (stcharlist)
  (cond (= (first stcharlist) #\f)
        (cond (= (second stcharlist) #\a)
              (cond (= (third stcharlist) #\l)
                    (cond (= (fourth stcharlist) #\s) 
                          (cond (= (fifth stcharlist) #\e) (return 'false'))))))
  (t (error "~S non è un valore valido" (first stcharlist))))



(defun parsebool_null (stcharlist)
  (cond (= (first stcharlist) #\n)
        (cond (= (second stcharlist) #\u)
              (cond (= (third stcharlist) #\l)
                    (cond (= (fourth stcharlist) #\l) (return 'null')))))
  (t (error "~S non è un valore valido" (first stcharlist))))