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

;;; jsonparse restituisce una lista, che può essere data in pasto a jsonaccess per produrre il singolo valore cercato. ATTENZIONE: La chiave cercata deve essere cercata ricorsivamente negli oggetti o array interni

;;; error: stampa una stringa contenente l'errore, se si può con il dettaglio o la riga dell'errore. FORSE ESISTE IN LISP

