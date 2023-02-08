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

(defun jsonparse (input-string)
        (let ((charlist (string-to-char-list input-string)))
            (cond ((char-equal (first charlist) #\{) (print "Parse an object"))
                  ((char-equal (first charlist) #\[) (print "Parse an array"))
                  (t (print "Syntax error in the JSON file.")))))

(defun string-to-char-list (input-string)
    "Return a list of all characters in the string"
    (assert (stringp input-string) (input-string) "string-to-char-list input error: not a valid string")
    (coerce s 'list))

(defun stream-to-char-list (in)
    "Return a list of all characters in the stream"
    (let ((c (read-char in nil 'eof)))
        (unless (eq c 'eof)
            (cons c (stream-to-char-list in)))))