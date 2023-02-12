Gruppo formato da:

Fizzardi, Fabio, 844726 
Pascone, Michele, 820633
Paulicelli, Sabino, 856111

PARTE AGGIUNTA IN SEGUITO ALLA COSTRUZIONE DI JSONACCESS

/*
* jsonaccess
*/

E' il secondo predicato principale citato nel testo del progetto.
Questo predicato può prendere in input un oggetto composto di tipo jsonobj(Members) oppure di tipo jsonarray(Elements), 
dopodiché un campo Field che può essere rappresentata in diverse forme: lista, stringa o numero.
Nel caso in cui l'input al predicato jsonaccess sia un jsonarray, il campo Field viene limitato al numero.
Quando invece l'input di jsonaccess è un jsonobject, allora Field potrà assumere il valore di una lista, stringa o numero. 
Il predicato jsonaccess permette, percorrendo il contenuto della variabile Field,  di ottenere il risultato della ricerca, Result.

/*
* jsonaccess(jsonarray(Elements), Field, Result)
*/

Nel caso in cui il valore in ingresso sia un jsonarray, il campo Field è rappresentato da un numero, che esprime l'indice 
attraverso il quale effettuare la ricerca della chiave desiderata.
Quando viene invocato questo predicato, si svolge una chiamata ricorsiva a "elemento_i_esimo" che prende in input un array,
  e restituisce  un Risultato in base al valore dell'indice (Field).
(Ciò significa che nel caso in cui venga passato un Field di tipo stringa o lista, viene restituito un errore).

/*
* elemento_i_esimo
*/

Questo predicato riceve in input una lista, un indice e restituisce un risultato.
Se l'indice è pari a zero, allora viene restituito il primo elemento della lista; altrimenti, si percorre ricorsivamente l'intera lista
fino al momento in cui l'indice non arriva a zero, ritornando il risultato.


/*
* jsonaccess(jsonobj(Members), Field, Result)
*/

Nel caso in cui si prenda in input un jsonobject, il campo Field può essere una lista, una stringa oppure un numero.
Il funzionamento di questo predicato non cambia dalla sua variante con jsonarray: il fine ultimo è quello di usare la variabile Field per ottenere il Result.
Prima di approfondire tutte le casistiche, è opportuno ricordare che jsonobject è un dato composto, formato da coppie di tipo (Attribute, Value), ossia delle
strutture che vengono riconosciute nel linguaggio Prolog.
(INSERIRE INFORMAZIONI SULLE COPPIE SE FABIO NON LE HA ANCORA MESSE).


/*
* Field è una lista del tipo : [Field | Fields]
*/

Come prima casistica, si osserva la struttura del campo Field quando esso è una lista. 
In questo frangente, Field può contenere una sequenza di stringhe e numeri, che possono unificare con l' Attribute delle coppie (Attributo, Valore) del jsonobject.
Quando la lista [Field | Fields] si esaurisce, viene restituito Result.
Come predicato utile ad alleggerire questa operazione, viene usato il predicato estrai_valore, il cui funzionamento e sintassi verranno mostrati più avanti.  

/*
* estrai_valore(Members, Field, Risultato)
*/

Questo predicato riceve in input una lista di coppie (Attributo, Valore),  e una lista o stringa Field, e ritorna il valore associato. 
Nel caso in cui Fields sia una lista, se il primo elemento di Field unifica con la chiave della coppia (Attributo, Valore), viene restituito come
 Risultato il valore della coppia.
Se questo non avviene, estrai_valore percorre l'intero jsonbject finché la chiave di una coppia non unifica con Field.
Quando nessuno di questi casi ha successo, viene restituito false.

/*
* jsonaccess(jsonobj(Members), [Field | Fields], RisultatoFinale) 
*/

Il predicato jsonaccess attraverso estrai_valore percorre la catena di [Field | Fields] restituendo dei valori.
Se il valore ritornato è un atomo (quindi una stringa, un numero oppure true, false o null), allora questi è il RisultatoFinale della mia ricerca.
Altrimenti, il valore pescato è un dato composto (quindi jsonobject oppure jsonarray). In questo caso, viene richiamato ricorsivamente il predicato
jsonaccess che continua la ricerca, risalendo il contenuto della lista [Field | Fields] fino a quando quest'ultima non viene svuotata.
Quando la variabile Fields non ha più alcun contenuto, viene restituito il RisultatoFinale.


/*
* Field è una stringa SWI-Prolog
*/

Nel caso in cui jsonaccess prenda in input un jsonobject e una variabile Field come stringa, il Risultato viene ottenuto secondo i meccanismi presentati precedentemente:
viene presa la prima coppia dell'oggetto json e comparata la chiave di quest'ultima con la stringa Field in ingresso; se l'unificazione ha successo, viene restituito
da estrai_valore il risultato (corrispondente al valore della coppia (Attributo, Valore)), altrimenti viene cercata ricorsivamente la coppia per la quale l'unificazione
è valida.
Se tale coppia non esiste all'interno dell'oggetto json, allora viene restituito false.

[QUESTA PARTE E' DA VERIFICARE CON UN E-MAIL AL PROF]
Una volta ottenuto il Risultato, si verifica se questi sia un atomo o un dato composto: nel caso in cui sia un atomo, il Risultato viene restituito così come dal predicato
estrai_valore; altrimenti, viene fatta una ricorsione sul dato composto richiamando ricorsivamente jsonaccess.
In quest'ultima istanza, la variabile Field contiene più di una chiave all'interno della stringa.
Per dividere i vari elementi appartenenti alla stringa Field viene usato il predicato suddividi_field.
[ANCORA IN ATTESA MA PROBABILE ELIMINAZIONE DI QUESTA PARTE DI TESTO]


/*
* valore_base
*/

valore_base è un predicato che restituisce TRUE se il valore in ingresso è una stringa, un numero, oppure vale true, false o null.

/*
* composto
*/

Questo predicato restituisce TRUE  se il valore in ingresso è una struttura del tipo jsonobj(Members) o jsonarray(Elements).












