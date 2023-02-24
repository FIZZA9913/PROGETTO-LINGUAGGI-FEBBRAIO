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
La funzione controlla se ciò che ha ricevuto in input è una lista di caratteri; se tale condizione
è soddisfatta, viene passata tale lista alla funzione di appoggio 'p-arr-ex', insieme ad uno stato
iniziale, e ad un contenitore vuoto.

;; p-arr-ex
La funzione descrive il comportamento di un automa a stati finiti che riconosce un array json 
attraverso i seguenti stati:
0) Se il primo carattere è una parentesi quadrata aperta, viene passato il resto della lista senza
whitespace allo stato successivo.
1) Fino a quando non si incontra il carattere di parentesi quadrata chiusa, viene fatto il parsing dell'
elemento in testa alla lista e del primo elemento del resto della lista.
Dopodiché viene chiamata ricorsivamente la funzione su ciò che rimane della lista e si passa allo stato 
successivo.
Se il carattere incontrato è una parentesi quadrata chiusa, il parsing del jsonarray termina, e si passa
allo stato finale.
2) Quando l'elemento in testa alla lista è un carattere di virgola ( , ) viene fatto il parsing del secondo
elemento in lista, mentre tutto ciò che rimane viene usato per richiamare nuovamente l' automa
e continuare il parsing.
3) Nel momento in cui la funzione raggiunge il carattere parentesi quadrata chiusa, viene 
creata la lista composta dalla dicitura 'jsonarray seguito dall' insieme di tutti gli elementi 
salvati nel contenitore 'elem'. 
Se la lista di codici in input è vuota o non viene rispettata la sintassi riconosciuta dall'automa a
stati finiti, viene ritornato errore.

;; p-ws
Se la lista ricevuta in input è una lista di codici (il ché è controllato dalla funzione 'ver-ls-cod'), 
allora viene passata alla funzione di appoggio 'p-ws-ex' descritta di seguito.

;; p-ws-ex
La funzione elimina, attraverso una ricerca ricorsiva elemento dopo elemento, 
tutti i whitespace presenti nella lista di codici.
Una volta che tutti i whitespace sono stati cancellati, viene ritornata la lista di codici.

;;p-str
Se la lista ricevuta in input è una lista di codici (il ché è controllato dalla funzione 'ver-ls-cod'), 
questa viene prima trasformata in stringa attraverso la funzione 'conv-ls-str', e poi passata alla  
funzione 'p-str-ex' descritta qui di seguito.

;;p-str-ex
La funzione riceve in input una stringa.
Tale stringa viene accettata solamente se ha una lunghezza maggiore o uguale a 2.
La funzione ritorna la sotto-stringa contenuta tra i primi due apici doppi;
 dopodiché cerca ricorsivamente altre sotto-stringhe.
Se non è più possibile estrarre sotto-stringhe o la stringa ricevuta in input
 ha una lunghezza minore di 2, viene ritornato un errore.

;;p-num
Nome esteso: parse-number
La funzione controlla se ciò che ha ricevuto in input è una lista di caratteri; 
se tale condizione è verificata passa tale lista alla funzione
 'p-num-ex', insieme alla stringa vuota.

;;p-num-ex 
Nome esteso: parse-number-execute
La funzione riceve in input una lista ed una stringa, e ritorna una stringa
 che identifica un numero json.
La funzione prende il primo elemento di tale lista e controlla se è un numero, un segno
positivo o negativo, oppure il simbolo e/E per la notazione esponenziale.
Il numero finale viene costruito applicando ricorsivamente questa funzione alla lista in input.
Una volta ottenuto tale numero, questo viene riscritto in formato esponenziale e ritornato. 

;;p-true
Nome esteso: parse-true
La funzione controlla se ciò che ha ricevuto in input è una lista di caratteri; 
se tale condizione è verificata converte la lista di caratteri in una stringa e 
la passa alla funzione di appoggio 'p-true-ex', descritta di seguito.

;;p-true-ex
Nome esteso: parse-true-execute
La funzione riceve in input una stringa. Se all'interno della stringa è presente 'true' 
estrae la sotto-stringa e la converte in una lista di caratteri.
Se all'interno della stringa non è presente 'true' o la stringa non è lunga almeno 4 caratteri, viene
ritornato un errore.

;;p-false
Nome esteso: parse-false
La funzione controlla se ciò che ha ricevuto in input è una lista di caratteri; 
se tale condizione è verificata converte la lista di caratteri in una stringa e
la passa alla funzione di appoggio 'p-false-ex', descritta di seguito.

;;p-false-ex
Nome esteso: parse-false-execute
La funzione riceve in input una stringa. Se all'interno della stringa è presente 'false',
estrae la sotto-stringa e la converte in una lista di caratteri.
Se all'interno della stringa non è presente 'false' o la stringa non è lunga  almeno 5 caratteri, 
viene ritornato un errore.

;;p-null 
Nome esteso: parse-null
La funzione controlla se ciò che ha ricevuto in input è una lista di caratteri; 
se tale condizione è verificata converte la lista di caratteri in una stringa e
la passa alla funzione di appoggio 'p-null-ex', descritta di seguito.

;;p-null-ex
Nome esteso: parse-null-execute
La funzione riceve in input una stringa. Se all'interno della stringa è presente 'null', 
estrae la sotto-stringa e la converte in una lista di caratteri.
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
se tale condizione è verificata la lista viene passata alla funzione di appoggio 'jsonobj-ex' assieme alla
stringa di inizio jsonobject " { " .
Altrimenti, viene ritornato un errore.

;;jsonobj-ex  
Nome esteso: jsonobject-execute
La funzione riceve in input una lista di coppie e traduce il jsonobject in formato stringa.
Per questo motivo, quando la funzione viene eseguita su una lista di coppie, effettua una traduzione delle
coppie in maniera ricorsiva, prima separandole attraverso la virgola - grazie alla funzione 'virgola' - e 
successivamente le concatena.
Quando la funzione viene invece eseguita su una lista di coppie vuota, concatena ciò che è stato tradotto
 sino a quel momento con la stringa " } " . 

;;trad-pr
Nome esteso: traduzione-pair
La funzione riceve in input una coppia e le concatena diversi caratteri per uniformarla al formato
richiesto json. Dopodiché chiama sul resto della coppia (ossia un valore) la funzione 
di appoggio 'trad-pr-ex'.

;;trad-pr-ex
Nome esteso: traduzione-pair-execute
La funzione controlla che tipo di valore è presente nella coppia:
- Se il valore è una stringa, viene uniformata al formato json con apici doppi.
- Se il valore è un numero - un intero o float - viene scritto in rappresentazione esponenziale.
- Se il valore è un booleano - true, false o null - viene restituito il valore booleano corrispondente.
- Se il valore è un jsonobject chiama la funzione d'appoggio 'trad-inv', che gestirà il caso specifico.
- Se il valore è un jsonarray chiama la funzione di'appoggio 'trad-inv', che gestirà il caso specifico.
Altrimenti restituisce un errore.

;;jsonarray
La funzione controlla se il valore in input è una lista; se tale condizione  è verificata viene chiamata la funzione
 di appoggio 'jsonarray-ex'. 
Altrimenti, viene ritornato un errore.

;;jsonarray-ex
Nome esteso: jsonarray-execute
La funzione traduce il jsonarray in formato stringa.
Per questo motivo, quando la funzione viene eseguita su una lista di elementi, svolge la traduzione di quest' ultimi
gestendo le diverse casistiche:
- Elemento = stringa : la stringa 'trd' risultante conterrà l'elemento uniformato alle stringhe dello standard json 
attraverso l'implementazione di apici doppi, a cui seguirà la virgola.
- Elemento = numero : la stringa 'trd' risultante conterrà l'elemento in formato esponenziale solamente se 
tale elemento è un float o un integer.
- Elemento = true/false/null : la stringa 'trd' risultante conterrà il valore booleano corrispondente, 
seguito da una virgola.
- Elemento = jsonobj/jsonarray : la stringa 'trd' risultante viene ottenuta attraverso l' applicazione della funzione
'trad-inv' che traduce l'intero jsonobj/jsonarray in una stringa.
Una volta gestita una di queste casistiche, la funzione esegue ricorsivamente la traduzione degli elementi successivi
e ritorna la stringa finale che è il risultato della concatenazione di tutte le traduzioni.
Quando la funzione viene eseguita su una lista di elementi vuota,  concatena tale stringa composta con la stringa " ] " . 



;;;;;; PARTE JSONACCESS

;;jsonaccess 
La funzione riceve in input un dato di tipo json e un campo fields, che viene 
utilizzato per cercare il valore all'interno del dato.
Questa funzione gestisce due tipi di casistiche:
- il dato passato in input è un jsonobject
- il dato passato in input è un jsonarray
In qualsiasi caso viene utilizzata la funzione 'trad-inv' per trasformare il dato JSON  in input
dal formato object in una stringa.
Se il dato passato è un jsonarray e il campo fields è vuoto, viene ritornato errore; 
altrimenti, se il campo field presenta una corretta sintassi (verificata dalla funzione 'ver-field' descritta più avanti),
la nuova stringa viene passata alla funzione di appoggio 'jsonaccess-ex' che svolge l'attività
di accesso alla stringa attraverso il termine fields.
(aggiungere caso jsonobj? se non viene verificata la condizione speciale
relativa al jsonarray con fields vuoto)

;;jsonaccess-ex
Nome esteso: jsonaccess-execute
La funzione controlla che tipo di dato ha di fronte - jsonobject o jsonarray - dopodiché esamina l'intera lista 
ricorsivamente per controllare se la variabile fields unifica con la chiave di una coppia chiave-valore (nel caso di jsonobj),
 oppure con un elemento del jsonarray.
Dopo la prima unificazione, la funzione viene eseguita in maniera ricorsiva per controllare se esistono altri valori
 del campo fields che unifichino con il resto della stringa in input.
Quando il campo fields è vuoto, viene ritornato il risultato della ricerca eseguita fino a quel momento dalla funzione.
Nel caso in cui sia impossibile accedere ai dati, o si cerchi di accedere ad un indice che supera i limiti dell'array, 
viene ritornato un errore.

;;estr-vl 
Nome esteso: estrai-valore
La funzione serve per estrarre un valore da una lista di coppie in base ad una chiave
che viene passata in input.

;;ver-ls-cod
Nome esteso: verifica-lista-codici
La funzione controlla se l'input è una lista (in particolare viene passata una lista di codici) 
e se questa condizione è verificata, tale lista viene passata alla funzione di appoggio 'ver-ls-cod-ex'.
In altri casi, la funzione ritorna 'nil'.

;;ver-ls-cod-ex
Nome esteso: verify-list-codes-execute
La funzione controlla se la lista in input è vuota; se tale condizione è verificata viene ritornato 'true'.
Se la lista non è vuota viene verificato, partendo dal primo elemento della lista 
e continuando ricorsivamente sul suo resto, che la lista contenga codici numerici.
Nel caso in cui siano presenti degli elementi all'interno della lista che non siano numeri, viene ritornato 'nil'.

;;ver-ls-pr
Nome esteso: verify-list-pair
La funzione controlla se l'input è una lista; se è così, chiama la funzione 'ver-ls-pr-ex'.
Altrimenti, restituisce 'nil'.

;;ver-ls-pr-ex
Nome esteso: verifiy-list-pair-execute
Se la lista è vuota, viene restituito 'true'.
Se la lista contiene degli elementi, viene passata la prima coppia alla funzione 'ver-pr' descritta poco più avanti,
e viene effettuata una chiamata ricorsiva sul resto della lista alla funzione 'ver-ls-pr-ex'.
Nel caso in cui la lista non sia vuota e allo stesso tempo non contenga  coppie 'Chiave Valore' al suo interno, 
viene restituito 'nil'.

;;ver-pr 
Nome esteso: verify-pair
La funzione controlla prima di tutto se ciò che ha ricevuto in input è una lista.
Dopodiché verifica se tale lista è una coppia 'Chiave Valore', ossia una sequenza  formata da soli due elementi.
Se l'input in ingresso è effettivamente una lista, viene restituito 'true', altrimenti viene ritornato il valore 'nil'.

;;virgola
La funzione controlla prima di tutto se ciò che ha ricevuto in input è una lista.
Se il dato in ingresso è una lista, viene verificato se è formata da  un solo elemento (ossia il resto della lista è vuota);
 in questo caso viene restituito " ", altrimenti viene inserita una virgola ' , '.
Nel caso in cui l'input non fosse una lista viene restituito errore. 

;;ver-fields
Nome esteso: verify-fields
La funzione controlla se ciò che ha ricevuto in input è una lista; se tale condizione è verificata la lista viene passata
 alla funzione di appoggio 'ver-fields-ex' , descritta di seguito.

;;ver-fields-ex
Nome esteso: verify-fields-execute
La funzione verifica ricorsivamente se il primo elemento della lista ricevuta in input sia una stringa o un numero. 
Quando uno dei campi di fields non è né una stringa né un numero, viene ritornato nil.


