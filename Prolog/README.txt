Gruppo formato da:

Fizzardi, Fabio, 844726 
Pascone, Michele, 820633
Paulicelli, Sabino, 856111

Premesse:
-Il predicato jsonparse non riconosce stringhe contenenti i caratteri '\"', '\\' e '\/' in quanto '\/'
non è un carattere di escape riconosciuto da prolog, '\\' lo interpreta come \ che in prolog è un 
carattere speciale mentre i caratteri '"' e '\"' hanno lo stesso codice e questo rende la fine di una
stringa indistinguibile dal carattere di escape
-jsonparse effettua solo un'analisi sintattica e non controlla quindi la semantica di ciò che gli viene
passato come input.
Questo significa che se l'oggetto json ha chiavi duplicate oppure stringhe come valori che contengono
ad esempio il carattere \n quando si va ad effettuare una stampa sul file .json esso segnalerà un
errore di sintassi per questi 2 motivi anche se sintatticamente non vi è nulla di sbagliato
-in caso di chaivi duplicate jsonaccess restituisce la prima occorrenza e non ritorna quindi termini
multipli

I vari predicati sono divisi in sezioni nel file .pl dai commenti di inizio e fine e di seguito ne 
spiegheremo brevemente il funzionamento

/*
 * jsonparse
*/

E' il predicato il cui funzionamento è citato nel testo del progetto.
Per la traduzione da formato json a formato object jsonparse trasforma l'input in una lista di codici
di caratteri e poi richiama il predicato riconosci_e_traduci il cui funzionamento è spiegato qua
sotto.
Per la traduzione da formato object a json standard richiama il predicato passato in input, ovvero
jsonobj oppure jsonarray ma con dei parametri in più spiegati più avanti.
Il predicato jsonparse dà una risposta anche nel caso in cui non ci sia una traduzione da fare e 
verifica quindi se i 2 parametri sono lo stesso oggetto/array nei due formati diversi.
Il tutto funziona anche con termini parzialmente instanziati, molto semplicemente traduce JSONString in
formato Object e prova a fare l'unificazione con il secondo Object, il resto è svolto interamente da
prolog.

/*
 * riconosci_e_traduci
*/

Questo predicato non fa altro che simulare il comportamento di value visibile sul sito www.json.org ma
solo su oggetti ed array, in poche parole dopo aver chiamato whitespace (predicato per eliminare
gli spazi) in base al codice del carattere presente in testa alla lista chiama object o array che
sono i predicati per riconoscere oggetti e array json

/*
 * value
*/

Predicato il cui comportamento è quello sintetizzato su www.json.org, come per riconosci_e_traduci in
base al codice del carattere presente in cima alla lista di ingresso richiama i vari predicati 
per riconoscere specifici valori json, una volta riconosciuti li restituisce assieme ai codici
rimanenti

/*
 * object e array
*/

Predicati per riconoscere oggetti e array json, sono la codifica in codice di un automa a stati finiti il
cui funzionamento è quello ispirato alla sintassi presentata su www.json.org
Come per value anche essi una volta riconosciuto il valore lo restituiscono assieme ai codici rimanenti

/*
 * whitespace
*/

Predicato ispirato alle slide del corso riguardante il parsing di numeri interi, non fa altro che
eliminare gli spazi da una lista di codici di caratteri fino a quando il carattere successivo non
è più uno spazio

/*
 * true, false e null
*/

Predicati per riconoscere i valori true, false e null.
Non fanno altro che prendere i primi 4/5 codici di caratteri dalla lista in input e se essi corrispondono
agli atomi 'true', 'false' e 'null' allora restituiscono questi valori e i codici rimanenti 

/*
 * numero
*/

Stesso comportamento di whitespace, da una lista di codici in input continua ad incrementare 
l'accumulatore fino a quando i codici in input sono compatibili con un numero, quando la condizione
non è più soddisfatta verifica se l'accumulatore opportunamente convertito è un numero e se si lo
ritorna assieme ai codici rimanenti

/*
 * stringa
*/

Anche questo è un automa a stati finiti ispirato alla sintassi presentata su www.json.org,
come per object e array una volta riconosciuta la stringa la ritorna assieme ai codici rimanenti

/*
 * jsonobj
*/ 




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


*
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


/*
* suddividi_field
*/

Suddividi_field prende in ingresso una stringa e ritorna due risultati: il primo rappresenta la prima chiave all'interno della stringa; l'altro risultato è il resto della
stringa. Questa divisione viene svolta da un predicato chiamato split_codice che verrà presentato tra poco.
 Prima di eseguire questa suddivisione è importante però riscrivere la stringa come lista di codici, operazione possibile attraverso il predicato string_codes
 interno a Prolog. 
Una volta che tale lista di codici sarà divisa in due parti dal predicato split_codice, verranno restituite, sottoforma di stringa, la prima e la seconda chiave chiamate
PrimoField e SecondoField.

/*
* split_codice
*/

Questo predicato riceve in input una lista di codici ed un carattere attraverso il quale decidere in che punto tagliare la stringa, restituendo due risultati: una prima
stringa che precede il carattere ed una seconda stringa che segue il carattere.
Questa operazione viene svolta in modo ricorsivo andando a cercare all'interno della lista di caratteri, il codice che identifica sia la testa della lista che il carattere
dato in input.
Quando il carattere viene raggiunto, questo viene eliminato dalla stringa originale dividendola in due parti, stringa pre-carattere e stringa post-carattere.
Questi due risultati vengono poi passati al predicato suddividi_field.

/*
* valore_base
*/

valore_base è un predicato che restituisce TRUE se il valore in ingresso è una stringa, un numero, oppure vale true, false o null.

/*
* composto
*/

Questo predicato restituisce TRUE  se il valore in ingresso è una struttura del tipo jsonobj(Members) o jsonarray(Elements).












