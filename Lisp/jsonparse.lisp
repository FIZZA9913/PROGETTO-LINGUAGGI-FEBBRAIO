;;;; jsonparse.pl
;;;;
;;;; Gruppo formato da:
;;;; Fizzardi, Fabio, 844726
;;;; Pascone, Michele, 820633
;;;; Paulicelli, Sabino, 856111

;;; jsonparse: prende un file trasformato in stringa e la analizza char per char. SCRIVERE anche jsonread e jsondump: legge da un file e return una stringa
;;; parser object: viene chiamato quando incontriamo una {
;;; parser array: chiamato quando incontriamo una [
;;; parser string: quando incontriamo "

;;; altri parser non ricorsivi...

;;; jsonparse restituisce una lista, che puo' essere data in pasto a jsonaccess per produrre il singolo valore cercato. ATTENZIONE: La chiave cercata deve essere cercata ricorsivamente negli oggetti o array interni

;;; error: stampa una stringa contenente l'errore, se possibile con il dettaglio o la riga dell'errore. FORSE ESISTE IN LISP

;; FIXME: jsondump scrive una lista Lisp, deve scrivere un oggetto in sintassi JSON.
(defun jsondump (JSON filename)
    (with-open-file (out filename
                         :direction :output
                         :if-exists :supersede
                         :if-does-not-exist :create)
        (mapcar (lambda (e)
                (format out "~S" e))
                '((1 . A) (2 . B) (42 . QD) (3 . D)))))

;; SCRIVERE UNA STRINGA SU FILE (FORSE)
;(defun write-file (string outfile &key (action-if-exists :error))
;   (check-type action-if-exists (member nil :error :new-version :rename :rename-and-delete 
;                                        :overwrite :append :supersede))
;   (with-open-file (outstream outfile :direction :output :if-exists action-if-exists)
;     (write-sequence string outstream)))

(defun jsonread (filename)
    "Return a string from file filename"
    (with-open-file (in filename
                        :direction :input
                        :if-does-not-exist :error)
        (let ((string (make-string (file-length in))))
            (read-sequence string in)
            (jsonparse string))))

(defun jsonparse (inputstring)
    "Parse a string starting with { or [ or syntax error, returns the return value of parseobj or parsearray"
    (let ((charlist (coerce inputstring 'list))) ; valutare l'uso di (char string 0) e (subseq string 1) per mantenere la stringa, senza convertirla in lista
        (cond ((char= #\{ (first charlist))
               (parseobj (rest charlist)))
              ((char= #\[ (first charlist))
               (parsearray (rest charlist)))
              (t (print "Syntax error in the JSON file.")))))

;; potrebbe diventare una lambda, forse verrà usata solo da jsonparse
;(defun string-to-char-list (input-string)
;    "Return a list of all characters in the string"
;    (assert (stringp input-string) (input-string) "string-to-char-list input error: not a valid string")
;    (coerce input-string 'list))
;
;; probabilmente non serve
;(defun stream-to-char-list (in)
;    "Return a list of all characters in the stream"
;    (let ((c (read-char in nil 'eof)))
;        (unless (eq c 'eof)
;            (cons c (stream-to-char-list in)))))
;
;(defun removelast (inputlist)
;    (reverse (cdr (reverse inputlist))))

(defun parseobj (charlist &optional partialresult)
    (let ((stcharlist (parsews charlist)))
         (cond ((char= #\} (first stcharlist)) (cons 'jsonobj (rest stcharlist)))
               ((char= #\" (first stcharlist)) (parseobj (parsemembers stcharlist)))
               (t (print "Syntax Error")))))

(defun parsearray (charlist &optional partialresult)
    (let ((stcharlist (parsews charlist)))
         (cond ((char= #\] (first stcharlist)) (cons 'jsonarray (rest stcharlist)))
               (t (parsearray (parseelements stcharlist))))))

(defun parsemembers (charlist &optional partialresult)
    "Returns the rest of the parsed list and a list of members as partial result")

(defun parsews (charlist)
    "Erase the first sequence of blank chars from charlist"
    (cond ((null (first charlist)) charlist)
           ((or
            (char= #\Space (first charlist))
            (char= #\Tab (first charlist))
            (char= #\Newline (first charlist))) (parsews (rest charlist)))
          (t charlist)))

(defun parseelements (charlist &optional partialresult) ; INCOMPLETE
    "Returns the rest of the parsed list and a list of elements as partial result"
    (let (stcharlist (parsews charlist))
         (cond ((char= #\{ (first stcharlist)) (parseobj stcharlist))
               ((char= #\[ (first stcharlist)) (parsearray stcharlist))
               ((char= #\" (first stcharlist)) (parsestring stcharlist))
               ((char= #\0 (first stcharlist)) (parsenumber stcharlist)) ;FIXME: this finds only 0 as number
               ((char= #\t (first stcharlist)) (parsebool stcharlist))
               ((char= #\f (first stcharlist)) (parsebool stcharlist))
               ((char= #\{ (first stcharlist)) (parsebool stcharlist)))
      ))
