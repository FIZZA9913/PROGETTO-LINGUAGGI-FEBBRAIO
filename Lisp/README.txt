Gruppo formato da:

Fizzardi, Fabio, 844726 
Pascone, Michele, 820633
Paulicelli, Sabino, 856111

Premesse:

- Le varie funzioni al di fuori di quelle richieste dal testo del progetto sono perfettamente
utilizzabili e funzionanti anche singolarmente a patto ovviamente di non utilizzare i 
predicati ausiliari con l'abbreviazione -ex perché hanno bisogno di specifici parametri
passati precedentemente, oltre che jsonobj, jsonarray, trad-pr, estr-vl.
Un utilizzo delle funzioni -ex con parametri diversi da quelli aspettati potrebbe causare 
errori o eccezioni non controllate.
Ovviamente qualche funzione potrebbe restituire valori che non hanno senso nel contesto json
perché ovviamente sono pensate per lavorare in sintonia per una traduzione in un contesto
creato da jsonparse.
L'utilizzo di parametri particolari comunque non genera eccezioni in quanto ogni funzione
verifica i suoi input e se non è quello desiderato procede a richiamare la funzione error.

- Le varie funzioni non riconoscono stringhe che presentano al loro interno caratteri di escape
in quanto lisp li interpreta correttamente (ad esempio \") ma non fornisce meccanismi per 
distinguerli dai caratteri non di escape (ad esempio n e \n per lisp sono il carattere #\n).

- Il parser fa solo un'analisi sintattica degli oggetti/array json quindi nel caso in cui un 
oggetto abbia chiavi duplicate il parser restituisce la traduzione corretta.
Il problema si presenta quando bisogna stampare su file .json che giustamente lo interpreta
come errore di sintassi e lo stesso discorso vale per le stringhe che presentano al loro
interno ad esempio il carattere \n in quanto esso viene stampato letteralmente come a capo
e l'effetto è quello di avere una stringa stampata su 2 righe, cosa ovviamente
sintatticamente scorretta.
Questo non inficia comunque la validità del programma in quanto la lettura dallo stesso file 
restituisce la traduzione desiderata.

- Se nella funzione jsondump viene passato un nome di un file con una estensione non esistente
questa funzione procede comunque a creare il file e a scriverci sopra il risultato della
traduzione senza generare alcuna eccezione o errore e il risultato sarà inoltre leggibile
senza problemi con jsonread.
L'unico problema è che ovviamente questo file non sarà apribile con un semplice doppio click.

- Su Windows abbiamo notato che in certe condizioni vengono aggiunti dei caratteri alla fine del file,
anche in modo casuale reiterando la traduzione del file.

- Poiché la gestione dei numeri varia da sistema a sistema, preferiamo usare la forma esponenziale
nella produzione inversa della stringa.

- Le varie funzioni e le rispettive ausiliarie sono divise in sezioni e il loro funzionamento
è spiegato qua sotto.

;; jsondump 
La funzione prende in input una struttura json, risultato della funzione 'jsonparse', e filename.
La funzione richiama 'trad-inv' sulla struttura JSON, convertendolo in formato stringa
 e successivamente lo stampa su filename. Dopodiché ritorna il nome di filename.
Se filename non è una stringa, o l'oggetto JSON non è stato costruito correttamente,
viene ritornato errore.

;; jsonread 
La funzione prende in input un filename e ritorna una lista, risultato della funzione 'jsonparse'. 

;; jsonparse 
La funzione controlla se ciò che ha ricevuto in input sia una stringa (il contenuto di un file json);
se tale condizione è soddisfatta l'input viene trasformato in una lista di caratteri, ingnorando leading e trailing whitespaces,
poi passata alla funzione di supporto 'jsonparse-ex', che si occuperà del riconoscimento
del tipo di dato in input - jsonobj o jsonarray.
Nel caso in cui il dato in ingresso non rappresenti una stringa, viene ritornato errore.

;; jsonparse-ex
La funzione riceve in input una lista di caratteri e gestisce una serie di casistiche diverse:
- Se il primo carattere della lista è una parentesi graffa aperta viene riconosciuto un jsonobject e 
la lista viene passata alla funzione 'p-obj' che fa il parsing dell'oggetto.
- Se il primo carattere della lista è una parentesi quadrata aperta viene riconosciuto un jsonarray
e la lista viene passata alla funzione 'p-arr' che fa il parsing dell'array.
- Se non si presenta nessuna di queste due casistiche viene ritornato un errore.

;; conv-str-ls
La funzione controlla che l'input sia una stringa,
dopodiché converte tale stringa in una lista di caratteri chiama la funzione 'conv-str-ls-ex'.
Altrimenti, se il parametro in input non è una stringa, viene ritornato 'nil'.

;; conv-str-ls-ex
La funzione accetta una lista di caratteri e produce una lista di codici in modo ricorsivo,
usando la macro char-code.
Se la lista di caratteri in input è vuota, ritorna 'nil'.

;; conv-ls-str
Verifica che l'input sia una lista di codici, produce una stringa invocando 'conv-ls-str-ex',
una funzione di appoggio a cui viene passata una stringa vuota da riempire.
 
;; conv-ls-str-ex
Accetta in input una lista di caratteri e una stringa, produce una stringa dalla lista di caratteri ricorsivamente,
con l'ausilio della macro code-char.
Se la lista di codici di caratteri è vuota, la funzione ritorna "".

;; p-vl
La funzione riceve in input una lista di caratteri, e crea una nuova lista attraverso
l'uso di una funzione di appoggio 'p-vl-ex' che restituisce il valore riconosciuto e
la lista di codici rimanenti.

;; p-vl-ex
Valuta il primo elemento della lista e richiama la funzione di parsing corrispondente.
Se il primo codice non ha corrispondenze, viene ritornato errore.

;; p-obj
Accetta in input una lista di codici e richiama la funzione ausiliaria p-obj-ex
passando gli argomenti necessari preparare lo stato iniziale dell'automa a stati finiti.
Se la lista di caratteri è vuota restituisce errore.

;; p-obj-ex
Automa a stati finiti:
Input: Lista di codici di caratteri
Stati:
	o0: Stato iniziale (con { ignora i whitespaces e passa in o1). 
	o1: Stato finale (con } riconosce un oggetto vuoto, altrimenti va in o2).
	o2: Stato intermedio (con : riconosce la chiave di un oggetto, la appende alla lista p e va in o3).
	o3: Stato intermedio (con , riconosce il valore di un oggetto, la appende alla lista p e va in o2).
Se la lista di codici di caratteri in input è vuota o se nessuna delle condizioni è verificata, viene ritornato errore.

;; p-arr
Accetta in input una lista di codici di carattere, richiama la funzione ausiliaria p-arr-ex
e configura l'automa a stati finiti.

;; p-arr-ex
Automa a stati finiti:
Input: Lista di codici di caratteri
Stati:
	a0: Stato iniziale (con [ ignora i whitespaces e passa in a1).
	a1: Stato intermedio (riconosce value e passa in a2).
	a2: Stato finale (con ] restituisce l'array e la lista di codici rimanenti, altrimenti riconosce value).
Se la lista di codici in input è vuota o non viene rispettata la sintassi riconosciuta dall'automa a
stati finiti, o nessuna condizione è verificata, viene ritornato errore.

;; p-ws
Valuta l'input con ver-ls-cod e richiama la funzione ausiliaria p-ws-ex.

;; p-ws-ex
Elimina ricorsivamente tutti i whitespace iniziali nella lista di codici.
Ritorna la lista di codici rimanenti.

;; p-str
Valuta l'input con ver-ls-cod, richiama l'ausiliaria p-str-ex passando come argomento
l'input trasformato da conv-ls-str.

;; p-str-ex
Accetta una stringa di lunghezza maggiore o uguale a 2 in input,
ritorna la sotto-stringa contenuta tra i primi due apici doppi;
dopodiché cerca ricorsivamente altre sotto-stringhe.
Se non è più possibile estrarre sotto-stringhe o la stringa ricevuta in input
ha una lunghezza minore di 2, viene ritornato un errore.

;; p-num
Riceve in input una lista di codici di caratteri; 
richiama l'ausiliaria p-num-ex.

;; p-num-ex 
La funzione riceve in input una lista ed una stringa, e ritorna il numero json e
la lista di codici rimanenti.

;; p-true (p-false, p-null)
Accetta in input è una lista di caratteri e richiama la funzione aux p-true-ex.

;; p-true-ex (p-false-ex, p-null-ex)
La funzione riceve in input una stringa. Se all'interno della stringa è presente 'true' 
estrae la sotto-stringa e la converte in una lista di caratteri.
Se all'interno della stringa non è presente 'true' o la stringa non è lunga almeno 4 caratteri, viene
ritornato un errore.

;; trad-inv 
La funzione controlla se l'input è una lista di codici di caratteri; richiama la funzione 'trad-inv-ex'.
Altrimenti, viene ritornato errore.

;; trad-inv-ex 
La funzione controlla due possibili scenari:
1) il primo elemento della lista è un jsonobject - viene invocato la funzione 'jsonobj'
2) il primo elemento della lista è un jsonarray - viene invocato la funzione 'jsonarray'
Se la lista in input è vuota, o il primo elemento della lista non appartiene alle casistiche cui sopra,
 viene ritornato errore.

;; jsonobj
La funzione controlla se ciò che ha ricevuto in input  è una lista di coppie; 
se tale condizione è verificata la lista viene passata alla funzione di appoggio 'jsonobj-ex' assieme alla
stringa di inizio jsonobject "{" .
Altrimenti, viene ritornato un errore.

;; jsonobj-ex
La funzione riceve in input una lista di coppie e traduce il jsonobject in formato stringa.
Produce ricorsivamente le coppie, inserisce la virgola dove richiesto con la funzione virgola, richiama la funzione ausiliaria.
Quando la funzione viene invece eseguita su una lista di coppie vuota, concatena ciò che è stato tradotto
 sino a quel momento con la stringa "}" . 

;; trad-pr
Riceve in input una coppia di un oggetto JSON, concatena la key con :, richiama l'ausiliaria trad-pr-ex.

;; trad-pr-ex
La funzione controlla che tipo di valore è presente nella coppia:
- Se il valore è una stringa, viene uniformata al formato json con apici doppi.
- Se il valore è un numero - un intero o float - viene scritto in rappresentazione esponenziale.
- Se il valore è un booleano - true, false o null - viene restituito il valore booleano corrispondente.
- Se il valore è un jsonobject o jsonarray chiama la funzione trad-inv che gestirà il caso specifico.
Altrimenti restituisce un errore.

;; jsonarray
Acceta in input una lista, richiama l'ausiliaria jsonarray-ex.
Altrimenti, viene ritornato un errore.

;; jsonarray-ex
La funzione riconosce il jsonarray.
Per questo motivo, quando la funzione viene eseguita su una lista di elementi, svolge la traduzione di questi ultimi
gestendo le diverse casistiche:
- Elemento = stringa : la stringa 'trd' risultante conterrà l'elemento uniformato alle stringhe dello standard json 
attraverso l'implementazione di apici doppi, a cui seguirà la virgola.
- Elemento = numero : la stringa 'trd' risultante conterrà l'elemento in formato esponenziale.
- Elemento = true/false/null : la stringa 'trd' risultante conterrà il valore booleano corrispondente, 
seguito da una virgola.
- Elemento = jsonobj/jsonarray : la stringa 'trd' risultante viene ottenuta attraverso l' applicazione della funzione
'trad-inv' che riconosce l'intero jsonobj/jsonarray.
Una volta gestita una di queste casistiche, la funzione esegue ricorsivamente il riconoscimento degli elementi successivi
e ritorna la stringa finale che è il risultato della concatenazione di tutte le traduzioni.
Quando la funzione viene eseguita su una lista di elementi vuota,  concatena tale stringa composta con la stringa "]".

;;;;;; PARTE JSONACCESS

;; jsonaccess 
La funzione riceve in input un dato di tipo json e un numero variabile di argomenti fields, che viene 
utilizzato per derivare il valore se possibile.
Questa funzione gestisce due tipi di casistiche:
- l'input è un jsonobject: ritorna il valore cercato se esiste con la funzione ausiliaria jsonaccess-ex.
- l'input è un jsonarray: ritorna il valore cercato con la funzione ausiliaria jsonaccess-ex.
Con lista vuota ritorna un errore.

;; jsonaccess-ex
A second adell'input, jsonobject o jsonarray, richiama i predicati per estrarre il valore cercato.
Nel caso in cui sia impossibile accedere ai dati o si cerchi di accedere ad un indice che supera i limiti dell'array
viene ritornato un errore.

;; estr-vl 
La funzione serve per estrarre un valore da una lista di coppie in base ad una chiave
che viene passata in input.

;; ver-ls-cod
La funzione controlla se l'input è una lista (in particolare viene passata una lista di codici) 
e se questa condizione è verificata, tale lista viene passata alla funzione di appoggio 'ver-ls-cod-ex'.
In altri casi, la funzione ritorna 'nil'.

;; ver-ls-cod-ex
La funzione controlla se la lista in input è vuota; se tale condizione è verificata viene ritornato 'true'.
Se la lista non è vuota viene verificato, partendo dal primo elemento della lista 
e continuando ricorsivamente che la lista contenga codici numerici.
Nel caso in cui siano presenti degli elementi all'interno della lista che non siano numeri, viene ritornato 'nil'.

;; ver-ls-pr
La funzione controlla se l'input è una lista; se è così, chiama la funzione 'ver-ls-pr-ex'.
Altrimenti, restituisce 'nil'.

;; ver-ls-pr-ex
Verifica ricorsivamente se ogni elemento della lista è una coppia JSON.

;; ver-pr
La funzione controlla prima di tutto se ciò che ha ricevuto in input è una lista.
Dopodiché verifica se tale lista è una coppia 'Chiave Valore', ossia una sequenza  formata da soli due elementi.
Se l'input in ingresso è effettivamente una lista, viene restituito 'true', altrimenti viene ritornato il valore 'nil'.

;; virgola
La funzione controlla prima di tutto se ciò che ha ricevuto in input è una lista.
Se il dato in ingresso è una lista, viene verificato se è formata da un solo elemento (ossia il resto della lista è vuota);
 in questo caso viene restituito "", altrimenti viene inserita una virgola ",".
Nel caso in cui l'input non fosse una lista viene restituito errore. 

;; ver-fields
La funzione controlla se ciò che ha ricevuto in input è una lista; se tale condizione è verificata la lista viene passata
 alla funzione di appoggio 'ver-fields-ex' , descritta di seguito.

;; ver-fields-ex
La funzione verifica ricorsivamente se il primo elemento della lista ricevuta in input sia una stringa o un numero. 
Quando uno dei campi di fields non è né una stringa né un numero, viene ritornato nil.

