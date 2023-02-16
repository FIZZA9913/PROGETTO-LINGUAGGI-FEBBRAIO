Gruppo formato da:

Fizzardi, Fabio, 844726 
Pascone, Michele, 820633
Paulicelli, Sabino, 856111

Premesse:
-le varie funzioni al di fuori di quelle richieste dal testo del progetto sono perfettamente
utilizzabili e funzionanti anche singolarmente a patto ovviamente di non utilizzare i 
predicati ausiliari con l'abbreviazione -ex perchè hanno bisongo di specifici parametri
passati precedentemente.
Un utilizzo delle funzioni -ex con parametri diversi da quelli aspettati potrebbe causare 
errori o eccezioni non controllate.
Ovviamente qualche funzione potrebbe restituire valori che non hanno senso nel contesto json
perchè ovviamente sono pensate per lavorare in sintonia per una traduzione in un contesto
creato da jsonparse.
L'utilizzo di parametri particolari comunque non genera eccezioni in quanto ogni funzione
verifica i suoi input e se non è quello desiderato procede a richiamare la funzione error.
-Le varie funzioni non riconoscono stringhe che presentano al loro interno caratteri di escape
in quanto lisp li interpreta correttamente (ad esempio \") ma non fornisce meccanismi per 
distinguerli dai caratteri non di escape (ad esempio n e \n per lisp sono il carattere #\n).
-Il parser fa solo un'analisi sintattica degli oggetti/array json quindi nel caso in cui un 
oggetto abbia chiavi duplicate il parser restituisce la traduzione corretta.
Il problema si presenta quando bisogna stampare su file .json che giustamente lo interpreta
come errore di sintassi e lo stesso discorso vale per le stringhe che presentano al loro
interno ad esempio il carattere \n in quanto esso viene stampato letteralmente come a capo
e l'effetto è quello di avere una stringa stampata su 2 righe, cosa ovviamente
sintatticamente scorretta.
Questo non inficia comunque la validità del programma in quanto la lettura dallo stesso file 
restituisce la traduzione desiderata.
-Se nella funzione jsondump viene passato un nome di un file con una estensione non esistente
questa funzione procede comunque a creare il file e a scriverci sopra il risultato della
traduzione senza generare alcuna eccezione o errore e il risultato sarà inoltre leggibile
senza problemi con jsonread.
L'unico problema è che ovviamente questo file non sarà apribile.
-Le varie funzioni e le rispettive ausiliarie sono divise in sezioni e il loro funzionamento
è spiegato qua sotto.

;; jsonparse

E' la funzione citata nel testo del progetto

