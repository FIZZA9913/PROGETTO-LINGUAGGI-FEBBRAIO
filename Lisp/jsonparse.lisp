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
    (cond ((char= #\} (first charlist)) (cons 'jsonobj (rest charlist)))
          ((char= #\" (first charlist)) (parseobj (parsemembers charlist)))
          (t (parseobj (parsews charlist)))))

(defun parsearray (charlist &optional partialresult)
    (cond ((char= #\] (first charlist)) (cons 'jsonarray (rest charlist)))
          ((or
            (char= #\{ (first charlist))
            (char= #\[ (first charlist))
            (char= #\" (first charlist))
            (char= #\0 (first charlist)) ;FIXME: non solo il numero zero ma un number
            (char= #\t (first charlist))
            (char= #\f (first charlist))
            (char= #\n (first charlist))) (parsearray (parseelements charlist)))
          (t (parsearray (parsews charlist)))))

(defun parsemembers (charlist)
    "Returns the rest of the parsed list and a list of members as partial result")

(defun parsews (charlist)
    (cond ((or
            (char= #\Space (first charlist))
            (char= #\Tab (first charlist))
            (char= #\Return (first charlist))
            (char= #\Newline (first charlist))) (rest charlist))
          (t (print "SYN ERROR"))))

(defun parseelements (charlist &optional partialresult)
    "Returns the rest of the parsed list and a list of elements as partial result")
