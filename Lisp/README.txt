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

;; jsondump 
La funzione prende in input una struttura json, risultato della funzione 'jsonparse', e filename.
La funzione richiama 'trad-inv' sulla struttura JSON, convertendolo in formato stringa e successivamente
lo stampa su filename. Dopodiché ritorna il nome di filename.
Se filename non è una stringa, o l'oggetto JSON non è stato costruito correttamente,
viene ritornato errore.

;;jsonread 
La funzione prende in input un filename e ritorna una lista, risultato della funzione 'jsonparse'. 


;;trad-inv 
Nome esteso: traduction-inverse
La funzione controlla se l'input è una lista di caratteri; se tale condizione è verificata viene chiamata la
funzione 'trad-inv-ex'.
Altrimenti, viene ritornato errore.


;;trad-inv-ex 
Nome esteso: traduction-inverse-execute
La funzione controlla due possibili scenari:
1) il primo elemento della lista è un jsonobject - viene invocato la funzione 'jsonobj'
2) il primo elemento della lista è un jsonarray - viene invocato la funzione 'jsonarray'
Se la lista in input è vuota, o il primo elemento della lista non appartiene alle casistiche di cui sopra,
 viene ritornato errore.


;;jsonobj
La funzione controlla se ciò che ha ricevuto in input  è una lista di coppie; se tale condizione è verificata
la lista viene passata alla funzione di appoggio 'jsonobj-ex'.
Altrimenti, viene ritornato un errore.

;;jsonobj-ex  trd = traduzione
Nome esteso: jsonobject-execute
La funzione traduce il jsonobject in formato stringa.
Per questo motivo, quando la funzione viene eseguita su una lista di coppie vuota, concatena tale
lista di caratteri con il carattere '}' . 
Altrimenti, esegue ricorsivamente sul resto della lista separando una coppia dalle altre attraverso
 la funzione 'virgola'.

;;trad-pr
Nome esteso: traduzione-pair
La funzione riceve in input una coppia e le concatena diversi caratteri per uniformarla al formato
richiesto json. Dopodiché chiama sul resto della coppia (ossia un valore) la funzione 
di appoggio 'trad-pr-ex'.

;;trad-pr-ex
Nome esteso: traduzione-pair-execute
La funzione controlla che tipo di valore è presente nella coppia:
- Se il valore è una stringa, viene uniformata al formato json con apici doppi.
- Se il valore è un numero - un intero - viene scritto così com'è.
- Se il valore è un numero - un float - viene scritto così com'è.
- Se il valore è un booleano - true, false o null - viene restituito il valore booleano corrispondente.
- Se il valore è un jsonobject chiama la funzione d'appoggio 'trad-inv'.
- Se il valore è un jsonarray chiama la funzione di'appoggio 'trad-inv'.
Altrimenti restituisce un errore.


;;jsonarray
La funzione controlla se il valore in input è una lista; se tale condizione è verificata viene chiamata
la funzione di appoggio 'jsonarray-ex'.
Altrimenti, viene ritornato errore.

;;jsonarray-ex
Nome esteso: jsonarray-execute
La funzione traduce il jsonarray in formato stringa.
Per questo motivo, quando la funzione viene eseguita su una lista di elementi vuota, concatena tale
stringa con la stringa " ] " . 
Altrimenti, esegue ricorsivamente sul resto della lista separando un elemento dagli altri attraverso
 la funzione 'virgola'.
Nel caso in cui il primo elemento della lista in input sia un numero intero o float, viene ritornato
in formato esponenziale.
Nel caso in cui il primo elemento della lista in input sia un valore booleano
 viene ritornato così com'è.
Nel caso in cui il primo elemento della lista in input sia un jsonobject o un jsonarray, questi viene
tradotto per intero  attraverso la funzione 'trad-inv'.
Dopodiché la funzione jsonarray viene eseguita sul resto della lista in maniera ricorsiva.


;;jsonparse (descrizione del metodo)


;;jsonparse-ex(descrizione dell'implementazione)


;;p-vl (modifica)
Nome esteso: parse-value
La funzione riceve in input una lista di codici di caratteri, elimina i whitespace presenti e crea una 
lista nuova, dopo aver riconosciuto i valori json. Quest' ultima operazione viene svolta dalla funzione
d' appoggio 'p-vl-ex'.

;;p-vl-ex 8 (modifica)
Nome esteso: parse-value-execute
La funzione controlla qual'è il primo elemento della lista e chiama il corrispondente 
parser - object, array, true, false, null, string o number.

;;p-obj (modifica)
Nome esteso: parse-object
La funzione riceve in input una lista di codici e passa alla funzione di appoggio 'p-obj-ex' i seguenti parametri:
- la lista di codici di caratteri ricevuta in input
- uno stato di partenza
- 
-
Se la lista di codici di caratteri è vuota restituisce errore.

;;p-obj-ex (modifica)
Nome esteso: parse-object-execute
La funzione riceve in input una lista, uno stato e due parametri vuoti, ed è gestita come se
fosse un automa, i cui stati e il loro funzionamento sono elencati qui di seguito:
1) Viene innanzitutto verificato se il primo elemento di tale lista è una parentesi graffa; se 
tale condizione è verificata, vengono eliminati possibili whitespace dal resto della lista e si 
passa allo stato successivo.
2) Se il resto della lista è una parentesi graffa chiusa, il json-object si chiude e il parsing è terminato.
Prendo il primo e il secondo elemento e dopo aver effettuato la conversione da codici di caratteri a char,
 li unisco in unica lista e passo allo stato successivo.
3) 

Altrimenti, se la lista di codici di caratteri è vuota, viene ritornato errore.

;;p-arr


;;p-arr-ex

;;p-ws
Nome esteso: parse-whitespace
Se la lista ricevuta in input è una lista di codici (il ché è controllato dalla funzione 'ver-ls-cod'), 
allora viene passata alla funzione 'p-ws-ex' descritta qui sotto.


;;p-ws-ex
Nome esteso: parse-whitespace-execute
La funzione elimina, attraverso una ricerca ricorsiva elemento dopo elemento, tutti i whitespace presenti 
nella lista di codici.
Una volta che tutti i whitespace sono stati cancellati, viene ritornata la lista di codici.


;;ver-ls-cod
Nome esteso: verifica-lista-codici
La funzione controlla se l'input è una lista (in particolare viene passata una lista di codici) e se questa condizione
è verificata, tale lista viene passata al funzione 'ver-ls-cod-ex'.
In altri casi, la funzione ritorna 'nil'.

;;ver-ls-cod-ex
Nome esteso: verifica-lista-codici-execute
La funzione controlla se la lista in input è vuota; se tale condizione è verificata viene ritornato 'true'.
Se la lista non è vuota viene verificato, partendo dal primo elemento della lista e continuando ricorsivamente sul suo resto,
che la lista contenga codici numerici.
Nel caso in cui siano presenti degli elementi all'interno della lista che non siano numeri, viene ritornato 'nil'.


;;p-str
Se la lista ricevuta in input è una lista di codici (il ché è controllato dalla funzione 'ver-ls-cod'), 
questa viene prima trasformata in stringa attraverso il funzione 'conv-ls-str', e poi passata alla  
funzione 'p-str-ex' descritta qui sotto.

;;p-str-ex
La funzione riceve in input una stringa.
Tale stringa viene accettata solamente se ha una lunghezza maggiore o uguale a 2.
La funzione ritorna la sotto-stringa contenuta tra i primi due apici doppi; dopodiché cerca ricorsivamente
altre sotto-stringhe.
Se non è più possibile estrarre sotto-stringhe o la stringa ricevuta in input ha una lunghezza minore di 2, viene 
ritornato un errore.


;;conv-str-ls
Nome esteso: convert-string-list
La funzione controlla se ciò che ha ricevuto in input sia una stringa, dopodiché converte tale stringa
in una lista di caratteri e la passa al funzione 'conv-str-ls-ex'.
Altrimenti, se il parametro in input non è una stringa, viene ritornato 'nil'.

;;conv-str-ls-ex
Nome esteso: convert-string-list-execute
La funzione crea, partendo da una lista di caratteri, la lista di codici di caratteri attraverso la funzione 
'char-code' di Lisp.
Se la lista di caratteri in input è vuota, ritorna 'nil'.


;;conv-ls-str
Nome esteso: convert-list-string
Funzione che dopo aver verificato che ciò che ha ricevuto in input è una lista di codici, la trasforma in una stringa
invocando la funzione di appoggio 'conv-ls-str-ex'.

;;conv-ls-str-ex
Nome esteso: convert-list-string-execute
La funzione crea, partendo da una lista di codici di caratteri, una lista di caratteri (ossia una stringa Lisp) attraverso
la funzione 'code-char' di Lisp, che viene usata ricorsivamente sull'intera lista partendo dal primo elemento fino all'
ultimo.
Se la lista di codici di caratteri è vuota, la funzione ritorna " ".



;;p-true
Nome esteso: parse-true
La funzione controlla se ciò che ha ricevuto in input è una lista di codici di caratteri; se tale condizione è verificata
converte la lista di codici di caratteri in una stringa e la passa alla funzione di appoggio 'p-true-ex'.

;;p-true-ex
Nome esteso: parse-true-execute
La funzione riceve in input una stringa. Se all'interno della stringa è presente 'true' 
estrae la sotto-stringa e la converte in una lista di codici di caratteri.
Se all'interno della stringa non è presente 'true' o la stringa non è lunga almeno 4 caratteri, viene
ritornato un errore.

;;p-false
Nome esteso: parse-false
La funzione controlla se ciò che ha ricevuto in input è una lista di codici di caratteri; se tale condizione è verificata
converte la lista di codici di caratteri in una stringa e la passa alla funzione di appoggio 'p-false-ex'.

;;p-false-ex
Nome esteso: parse-false-execute
La funzione riceve in input una stringa. Se all'interno della stringa è presente 'false' 
estrae la sotto-stringa e la converte in una lista di codici di caratteri.
Se all'interno della stringa non è presente 'false' o la stringa non è lunga almeno 5 caratteri, viene
ritornato un errore.

;;p-null 
Nome esteso: parse-null
La funzione controlla se ciò che ha ricevuto in input è una lista di codici di caratteri; se tale condizione è verificata
converte la lista di codici di caratteri in una stringa e la passa alla funzione di appoggio 'p-null-ex'.

;;p-null-ex
Nome esteso: parse-null-execute
La funzione riceve in input una stringa. Se all'interno della stringa è presente 'null' 
estrae la sotto-stringa e la converte in una lista di codici di caratteri.
Se all'interno della stringa non è presente 'null' o la stringa non è lunga almeno 4 caratteri, viene
ritornato un errore.

;;p-num
Nome esteso: parse-number
La funzione controlla se ciò che ha ricevuto in input è una lista di codici di caratteri; se tale condizione è verificata
passa tale lista alla funzione 'p-num-ex', insieme alla stringa vuota.

;;p-num-ex
Nome esteso: parse-number-execute
La funzione riceve in input una lista ed una stringa, e ritorna una stringa che identifica un numero json.
La funzione prende il primo elemento di tale lista e controlla se è un numero json; 


;;estr-vl (da aggiungere)
Nome esteso: estrai-valore
La funzione serve per estrarre un valore da una lista di coppie in base ad una chiave.


;;estr-vl-ex 
Nome esteso: estrai-valore-execute


;;ver-ls-pr
Nome esteso: verifica-lista-pair
La funzione controlla se l'input è una lista; se è così, chiama la funzione 'ver-ls-pr-ex'.
Altrimenti, restituisce 'nil'.

;;ver-ls-pr-ex
Nome esteso: verifica-lista-pair-execute
Se la lista è vuota, viene restituito 'true'.
Se la lista contiene degli elementi, viene passata la prima coppia alla funzione 'ver-pr' descritta poco più avanti,
e viene effettuata una chiamata ricorsiva sul resto della lista alla funzione 'ver-ls-pr-ex'.
Nel caso in cui la lista non sia vuota e allo stesso tempo non contenga coppie 'Chiave Valore' al suo interno, viene 
restituito 'nil'.


;;ver-pr 
Nome esteso: verifica-pair
La funzione controlla prima di tutto se ciò che ha ricevuto in input è una lista.
Dopodiché verifica se tale lista è una coppia 'Chiave Valore', ossia una sequenza formata da soli due elementi.
Se l'input in ingresso è effettivamente una lista, viene restituito 'true', altrimenti viene ritornato il valore 'nil'.


;;virgola
La funzione controlla prima di tutto se ciò che ha ricevuto in input è una lista.
Se il dato in ingresso è una lista, viene verificato se è formata da un solo elemento (ossia il resto della lista è vuota); in questo caso
viene restituito " ", altrimenti viene inserita una virgola ' , '.
Nel caso in cui l'input non fosse una lista viene restituito errore. 


;;;;;; PARTE JSONACCESS
