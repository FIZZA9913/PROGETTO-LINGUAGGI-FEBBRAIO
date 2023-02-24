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
La funzione richiama 'trad-inv' sulla struttura JSON, convertendolo in formato stringa
 e successivamente lo stampa su filename. Dopodiché ritorna il nome di filename.
Se filename non è una stringa, o l'oggetto JSON non è stato costruito correttamente,
viene ritornato errore.

;;jsonread 
La funzione prende in input un filename e ritorna una lista, risultato della funzione 'jsonparse'. 

;;jsonparse 
La funzione controlla se ciò che ha ricevuto in input sia una stringa che identifica una struttura json;
se tale condizione è soddisfatta l'input viene trasformato in una lista di caratteri senza whitespace,
la quale viene passata alla funzione di supporto 'jsonparse-ex'.
Nel caso in cui il dato in ingresso non rappresenti una stringa, viene ritornato errore.

;;jsonparse-ex (da modificare)
Nome esteso: jsonparse-execute
La funzione riceve in input una lista di caratteri e gestisce una serie di casistiche diverse:
- Se il primo carattere della lista è una parentesi graffa aperta, viene riconosciuto un jsonobject e 
la lista viene passata alla funzione 'p-obj' che fa il parsing dell'oggetto.
- Se il primo carattere della lista è una parentesi quadrata aperta, viene riconosciuto un jsonarray
e la lista viene passata alla funzione 'p-arr' che fa il parsing dell'array.
- Se non si presenta nessuna di queste due casistiche viene ritornato un errore.


;;conv-str-ls
Nome esteso: convert-string-list
La funzione controlla se ciò che ha ricevuto in input sia una stringa, dopodiché converte
 tale stringa in una lista di caratteri e la passa al funzione 'conv-str-ls-ex'.
Altrimenti, se il parametro in input non è una stringa, viene ritornato 'nil'.

;;conv-str-ls-ex
Nome esteso: convert-string-list-execute
La funzione crea, partendo da una lista di caratteri, la lista di codici di caratteri
 attraverso la funzione 'char-code' di Lisp.
Se la lista di caratteri in input è vuota, ritorna 'nil'.


;;conv-ls-str
Nome esteso: convert-list-string
Funzione che dopo aver verificato che ciò che ha ricevuto in input è una lista di codici,
 la trasforma in una stringa invocando la funzione
di appoggio  'conv-ls-str-ex'.

;;conv-ls-str-ex
Nome esteso: convert-list-string-execute
La funzione crea, partendo da una lista di codici di caratteri,
 una lista di caratteri (ossia una stringa Lisp) attraverso la funzione
l 'code-char' di Lisp, che viene usata ricorsivamente sull'intera lista 
partendo dal primo elemento fino all' ultimo.
Se la lista di codici di caratteri è vuota, la funzione ritorna " ".


;;p-vl 
Nome esteso: parse-value
La funzione riceve in input una lista di caratteri, e crea una nuova lista attraverso
l'uso di una funzione di appoggio 'p-vl-ex' applicata prima alla testa e poi al corpo 
della lista di caratteri in ingresso.
che intercetta il tipo di valore e ne fa il parsing.

;;p-vl-ex  
Nome esteso: parse-value-execute
La funzione controlla qual'è il primo elemento della lista e, una volta intercettato il tipo di valore,
ne fa il parsing andando a chiamare la funzione di gestione corrispondente - object, array, true, 
false, null, string o number.
Se il valore passato non presenta la sintassi corretta, viene ritornato errore.


;;p-obj (modifica)
Nome esteso: parse-object
La funzione riceve in input una lista di codici e passa alla funzione di appoggio 'p-obj-ex'
 i seguenti parametri:
- la lista di caratteri ricevuta in input
- uno stato di partenza
- un template relativo ad una coppia
- un contenitore per le coppie parsate
Se la lista di caratteri è vuota restituisce errore.

;;p-obj-ex (modifica)
Nome esteso: parse-object-execute
La funzione riceve in input una lista, uno stato e due contenitori vuoti, ed è gestita come se
fosse un automa, ll cui funzionamento viene elencato di seguito:
0) Viene innanzitutto verificato se il primo elemento di tale lista è una parentesi graffa aperta; se 
tale condizione è verificata, vengono eliminati possibili whitespace dal resto della lista e si 
passa allo stato successivo.
1) Se il resto della lista è una parentesi graffa chiusa, il json-object si chiude e il parsing è terminato.
Quando questo avviene, vengono presi il primo elemento e il resto della lista e convertiti in stringa
attraverso la funzione di appoggio 'p-str'.
Il primo elemento viene inserito all'interno del primo contenitore (p)relativo a .......
 e il resto della lista viene passato come argomento all'interno della stessa funzione 'p-obj-ex'.
2) Solamente quando viene incontrato (solitamente dopo una Chiave della coppia chiave-valore),
il carattere relativo ai due punti ( : ), si passa allo stato successivo 2, dove viene fatto il parsing
 del secondo elemento in lista (della posizione corrispondente ad un valore) e di ciò che 
rimane nella lista attraverso la funzione 'p-vl'.
Dopodiché, i caratteri rimanenti vengono passati ricorsivamente all'automa.
3) Quando il primo elemento della lista di caratteri è una virgola viene svolto il parsing del secondo
elemento in lista (alla quale sono stati rimossi whitespace).
Ciò che rimane della lista viene trasformato in stringa e passato ricorsivamente all'automa,
seguendo le indicazioni degli stati precedenti.
4) Quando il primo elemento della lista di caratteri è una parentesi graffa chiusa, viene ritornata
la stringa finale introdotta dalla dicitura 'jsonobj' e seguita dall'insieme di coppie che l'oggetto
json contiene.
Questo stato dell' automa è raggiungibile solamente dal primo o dal terzo stato: in questo modo
la macchina a stati finiti riconosce oggetti di tipo jsonobj vuoti ( {} ) o oggetti di tipo jsonob
che contengono coppie chiave-valore.
Se la lista di codici di caratteri in input è vuota, viene ritornato errore.


;;p-arr
Nome esteso: parse-array
La funzione controlla se ciò che ha ricevuto in input è una lista di caratteri; se tale condizione
è soddisfatta, viene passata tale lista alla funzione di appoggio 'p-arr-ex', insieme ad uno stato
iniziale, ed un contenitore vuoto.

;;p-arr-ex
Nome esteso: parse-array-execute
La funzione descrive il comportamento di un automa a stati finiti che riconosce un array json 
attraverso i seguenti stati:
0) Se il primo carattere è una parentesi quadrata aperta, viene passato il resto della lista senza
whitespace allo stato successivo.
1) Fino a quando non si incontra il carattere parentesi quadrata chiusa, viene fatto il parsing del
elemento in testa alla lista e del primo elemento del resto della lista.
Dopodiché viene chiamata ricorsivamente la funzione sul resto della lista e si passa allo stato 
successivo.
Se il carattere incontrato è una parentesi quadrata chiusa, il parsing del jsonarray termina, e si passa
allo stato finale.
2) Quando l'elemento in testa alla lista è un carattere virgola ( , ) viene fatto il parsing del secondo
elemento in lista, mentre tutto ciò che rimane viene usato per richiamare nuovamente l' automa
e continuare il parsing.
3) Nel momento in cui la funzione raggiunge il carattere parentesi quadrata chiusa, viene 
creata la lista composta dalla dicitura 'jsonarray seguito dall' insieme di tutti gli elementi 
salvati nel contenitore 'elem'. Viene inoltre ritornato il resto della lista.
Se la lista di codici in input è vuota o non viene rispettata la sintassi riconosciuta dall'automa a
stati finiti, viene ritornato errore.


;;p-ws
Nome esteso: parse-whitespace
Se la lista ricevuta in input è una lista di codici (il ché è controllato dalla funzione 'ver-ls-cod'), 
allora viene passata alla funzione 'p-ws-ex' descritta qui sotto.

;;p-ws-ex
Nome esteso: parse-whitespace-execute
La funzione elimina, attraverso una ricerca ricorsiva elemento dopo elemento, 
tutti i whitespace presenti nella lista di codici.
Una volta che tutti i whitespace sono stati cancellati, viene ritornata la lista di codici.


;;p-str
Se la lista ricevuta in input è una lista di codici (il ché è controllato dalla funzione 'ver-ls-cod'), 
questa viene prima trasformata in stringa attraverso il funzione 'conv-ls-str', e poi passata alla  
funzione 'p-str-ex' descritta qui sotto.

;;p-str-ex
La funzione riceve in input una stringa.
Tale stringa viene accettata solamente se ha una lunghezza maggiore o uguale a 2.
La funzione ritorna la sotto-stringa contenuta tra i primi due apici doppi;
 dopodiché cerca ricorsivamente altre sotto-stringhe.
Se non è più possibile estrarre sotto-stringhe o la stringa ricevuta in input
 ha una lunghezza minore di 2, viene ritornato un errore.


;;p-num
Nome esteso: parse-number
La funzione controlla se ciò che ha ricevuto in input è una lista di codici di caratteri; 
se tale condizione è verificata passa tale lista alla funzione
 'p-num-ex', insieme alla stringa vuota.

;;p-num-ex (ATTENZIONE!)
Nome esteso: parse-number-execute
La funzione riceve in input una lista ed una stringa, e ritorna una stringa
 che identifica un numero json.
La funzione prende il primo elemento di tale lista e controlla se è un numero json; 


;;p-true
Nome esteso: parse-true
La funzione controlla se ciò che ha ricevuto in input è una lista di codici di caratteri; 
se tale condizione è verificata converte la lista di codici di caratteri 
in una stringa e la passa alla funzione di appoggio 'p-true-ex'.

;;p-true-ex
Nome esteso: parse-true-execute
La funzione riceve in input una stringa. Se all'interno della stringa è presente 'true' 
estrae la sotto-stringa e la converte in una lista di codici di caratteri.
Se all'interno della stringa non è presente 'true' o la stringa non è lunga almeno 4 caratteri, viene
ritornato un errore.


;;p-false
Nome esteso: parse-false
La funzione controlla se ciò che ha ricevuto in input è una lista di codici di caratteri; 
se tale condizione è verificata converte la lista di codici di caratteri
 in una stringa e la passa alla funzione di appoggio 'p-false-ex'.

;;p-false-ex
Nome esteso: parse-false-execute
La funzione riceve in input una stringa. Se all'interno della stringa è presente 'false',
estrae la sotto-stringa e la converte in una lista di codici di caratteri.
Se all'interno della stringa non è presente 'false' o la stringa non è lunga
 almeno 5 caratteri, viene ritornato un errore.


;;p-null 
Nome esteso: parse-null
La funzione controlla se ciò che ha ricevuto in input è una lista di codici di caratteri; 
se tale condizione è verificata converte la lista di codici di caratteri
in una stringa e la passa alla funzione di appoggio 'p-null-ex'.

;;p-null-ex
Nome esteso: parse-null-execute
La funzione riceve in input una stringa. Se all'interno della stringa è presente 'null' 
estrae la sotto-stringa e la converte in una lista di codici di caratteri.
Se all'interno della stringa non è presente 'null' o la stringa non è lunga almeno 4 caratteri, viene
ritornato un errore.


;;trad-inv 
Nome esteso: traduction-inverse
La funzione controlla se l'input è una lista di caratteri; se tale condizione è verificata
 viene chiamata la funzione 'trad-inv-ex'.
Altrimenti, viene ritornato errore.

;;trad-inv-ex 
Nome esteso: traduction-inverse-execute
La funzione controlla due possibili scenari:
1) il primo elemento della lista è un jsonobject - viene invocato la funzione 'jsonobj'
2) il primo elemento della lista è un jsonarray - viene invocato la funzione 'jsonarray'
Se la lista in input è vuota, o il primo elemento della lista non appartiene alle casistiche di cui sopra,
 viene ritornato errore.


;;jsonobj
La funzione controlla se ciò che ha ricevuto in input  è una lista di coppie; 
se tale condizione è verificata la lista viene passata alla funzione di appoggio 'jsonobj-ex'.
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
- Se il valore è un numero - un intero - viene scritto in raprresentazione esponenziale.
- Se il valore è un numero - un float - viene scritto in rappresentazione esponenziale.
- Se il valore è un booleano - true, false o null - viene restituito il valore booleano corrispondente.
- Se il valore è un jsonobject chiama la funzione d'appoggio 'trad-inv'.
- Se il valore è un jsonarray chiama la funzione di'appoggio 'trad-inv'.
Altrimenti restituisce un errore.


;;jsonarray
La funzione controlla se il valore in input è una lista; se tale condizione
 è verificata viene chiamata la funzione di appoggio 'jsonarray-ex'.
Altrimenti, viene ritornato errore.

;;jsonarray-ex
Nome esteso: jsonarray-execute
La funzione traduce il jsonarray in formato stringa.
Per questo motivo, quando la funzione viene eseguita su una lista di elementi vuota,
 concatena tale stringa con la stringa " ] " . 
Altrimenti, esegue ricorsivamente sul resto della lista separando 
un elemento dagli altri attraverso  la funzione 'virgola'.
Nel caso in cui il primo elemento della lista in input sia un numero intero o float,
 viene ritornato in formato esponenziale.
Nel caso in cui il primo elemento della lista in input sia un valore booleano
 viene ritornato così com'è.
Nel caso in cui il primo elemento della lista in input sia un jsonobject o un jsonarray, 
questi viene tradotto per intero  attraverso la funzione 'trad-inv'.
Dopodiché la funzione jsonarray viene eseguita sul resto della lista in maniera ricorsiva.




;;;;;; PARTE JSONACCESS


;;jsonaccess (da modificare)
La funzione riceve in input un dato di tipo json e un campo fields, che viene 
utilizzato per cercare il valore all'interno del dato.
Questa funzione gestisce due tipi di casistiche:
- il dato passato in input è un jsonobject
- il dato passato in input è un jsonarray
In qualsiasi caso viene utilizzata la funzione 'trad-inv' per trasformare JSON 
in formato object in una stringa.
Se il campo fields è vuoto, viene ritornato errore; altrimenti, la nuova stringa
viene passata alla funzione di appoggio 'jsonaccess-ex' che svolge l'attività
di accesso alla stringa attraverso il termine fields.
(aggiungere caso jsonobj? se non viene verificata la condizione speciale
relativa al jsonarray con fields vuoto)

;;jsonaccess-ex
Nome esteso: jsonaccess-execute
La funzione controlla che tipo di dato ha di fronte - jsonobject o jsonarray - 
dopodiché esamina l'intera lista ricorsivamente per controllare se la
variabile fields unifica con la chiave di una coppia chiave-valore 
(nel caso di jsonobj), oppure con un elemento del jsonarray.
Dopo la prima unificazione, la funzione viene eseguita in maniera ricorsiva
per unificare, nel caso ci siano, altri valori del campo fields con la stringa in input.
Quando il campo fields è vuoto, viene ritornata la lista costruita dalla funzione.
Nel caso in cui sia impossibile accedere ai dati, o si cerchi di accedere 
ad un indice che supera i limiti dell'array, viene ritornato errore.


;;estr-vl 
Nome esteso: estrai-valore
La funzione serve per estrarre un valore da una lista di coppie in base ad una chiave
che viene passata in input.


;;ver-ls-cod
Nome esteso: verifica-lista-codici
La funzione controlla se l'input è una lista (in particolare viene passata una lista di codici) 
e se questa condizione è verificata, tale lista viene passata
alla funzione 'ver-ls-cod-ex'.
In altri casi, la funzione ritorna 'nil'.

;;ver-ls-cod-ex
Nome esteso: verifica-lista-codici-execute
La funzione controlla se la lista in input è vuota; se tale condizione è verificata
 viene ritornato 'true'.
Se la lista non è vuota viene verificato, partendo dal primo elemento della lista 
e continuando ricorsivamente sul suo resto, che la lista contenga
codici numerici.
Nel caso in cui siano presenti degli elementi all'interno della lista 
che non siano numeri, viene ritornato 'nil'.


;;ver-ls-pr
Nome esteso: verifica-lista-pair
La funzione controlla se l'input è una lista; se è così, 
chiama la funzione 'ver-ls-pr-ex'.
Altrimenti, restituisce 'nil'.

;;ver-ls-pr-ex
Nome esteso: verifica-lista-pair-execute
Se la lista è vuota, viene restituito 'true'.
Se la lista contiene degli elementi, viene passata la prima coppia 
alla funzione 'ver-pr' descritta poco più avanti,
e viene effettuata una chiamata ricorsiva sul resto della lista 
alla funzione 'ver-ls-pr-ex'.
Nel caso in cui la lista non sia vuota e allo stesso tempo non contenga
 coppie 'Chiave Valore' al suo interno, viene restituito 'nil'.


;;ver-pr 
Nome esteso: verifica-pair
La funzione controlla prima di tutto se ciò che ha ricevuto in input è una lista.
Dopodiché verifica se tale lista è una coppia 'Chiave Valore', ossia una sequenza
 formata da soli due elementi.
Se l'input in ingresso è effettivamente una lista, viene restituito 'true', 
altrimenti viene ritornato il valore 'nil'.


;;virgola
La funzione controlla prima di tutto se ciò che ha ricevuto in input è una lista.
Se il dato in ingresso è una lista, viene verificato se è formata da
 un solo elemento (ossia il resto della lista è vuota); in questo caso
viene restituito " ", altrimenti viene inserita una virgola ' , '.
Nel caso in cui l'input non fosse una lista viene restituito errore. 


;;ver-fields
Nome esteso: verify-fields
La funzione controlla se ciò che ha ricevuto in input è una lista; se tale condizione
è verificata la lista viene passata alla funzione di appoggio 'ver-fields-ex' che si
occupa d

;;ver-fields-ex
Nome esteso: verify-fields-execute
La funzione verifica ricorsivamente se il primo elemento della lista ricevuta in input
 sia una stringa o un numero. 
Quando uno dei campi di fields non è né una stringa né un numero,
viene ritornato nil.


