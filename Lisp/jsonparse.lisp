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