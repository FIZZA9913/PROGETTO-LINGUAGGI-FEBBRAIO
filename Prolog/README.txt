Gruppo formato da:

Fizzardi, Fabio, 844726 
Pascone, Michele, 820633
Paulicelli, Sabino, 856111

Premesse:

1)i vari predicati al di fuori di quelli richiesti dal testo del progetto sono
perfettamente utilizzabili e funzionanti anche singolarmente tranne:
-predicati _execute
-predicato traduzione_pair
-predicato estrai_valore
Un utilizzo dei predicati appena citati con parametri inaspettati potrebbe causare bug 
o eccezioni non controllate.
Ovviamente qualche predicato potrebbe restituire valori che non hanno senso nel contesto json, ad esempio
jsonarray([true], "a", X) restituisce X = "a[true]" perchè ovviamente sono pensati per lavorare in sintonia
per una traduzione in un contesto creato da jsonparse.
L'utilizzo con parametri particolari non genera comunque errori perchè ogni predicato verifica 
i suoi input e quindi al massimo fallisce.

2)I vari predicati si comportano in maniera ambigua di fronte a stringhe che presentano
i seguenti caratteri, generando errori o risultati inattesi:
-\/ in quanto non è riconosciuto come carattere di escape in prolog
-\" in quanto nell'ambiente SWI-prolog viene riconosciuto come apice doppio ("), 
rendendo di conseguenza questi due caratteri indistinguibili
-\\ in quanto \ è un carattere speciale in prolog e nell'ambiente SWI-prolog viene riconosciuto
come backslash (\) causando quindi gli stessi problemi di (\")

3)Il parser fa solo un'analisi sintattica degli oggetti/array json quindi nel caso in cui un oggetto abbia chiavi
duplicate il parser restituisce la traduzione corretta.
Il problema si presenta quando bisogna stampare la seguente traduzione su file .json che giustamente 
lo interpreta come errore di sintassi e lo stesso discorso vale per le stringhe che presentano al loro interno
ad esempio il carattere \n in quanto esso viene stampato letteralmente come a capo
e l'effetto è quello di avere una stringa stampata su 2 righe, cosa ovviamente sintatticamente scorretta.
Questo non inficia comunque la validità del programma in quanto la lettura dallo stesso file restituisce
la traduzione desiderata.

4)Se nel predicato jsondump viene passato un nome di un file con una estensione non esistente questo 
predicato procede comunque a creare il file e a scriverci sopra il risultato della traduzione senza
generare alcuna eccezione o errore e il risultato sarà inoltre leggibile senza problemi con jsonread.
L'unico problema è che ovviamente questo file non sarà apribile.

5)i vari predicati e i rispettivi ausiliari sono divisi in sezioni e il loro funzionamento è spiegato
qua sotto.

/*
 * jsonparse
*/

Questo è il predicato citato nel testo del progetto che ha 3 modalità d'uso diverse:

1) traduzione da atomo/stringa in formato object
2) traduzione da formato object a stringa scritta in formato json standard
3) verifica uguaglianza tra le 2 scritture anche con termini parzialmente istanziati
per il formato object

Per la modalità 1 jsonparse normalizza l'input sotto forma di atomo per poi andare a richiamare
il predicato della libreria standard atom_codes il quale traduce l'atomo in una lista
di codici di caratteri la quale sarà data in pasto al predicato riconosci_e_traduci che fornirà la traduzione
in formato object.

Per la modalità 2 jsonparse chiama il predicato applica, il quale una volta riconosciuto il tipo di dato
in input andrà a richiamare il predicato corrispondente con le opportune modifiche.

Per la modalità 3 jsonparse non fa altro che tradurre il formato json standard in formato object
e poi tutto il compito dell'uguaglianza è lasciato al principio di unificazione di prolog.

/* 
 * riconosci_e_traduci
*/

Questo predicato non è altro che il predicato value limitato a oggetti ed array.

/*
 * value
*/

Da ora in poi i seguenti predicati avranno un'interfaccia standard e non sono altro che la codifica
dei diagrammi della sintassi del linguaggio json presenti sul sito www.json.org
L'interfaccia è la seguente:
-Codes_in è la lista di codici di caratteri in ingresso
-Result è il risultato della traduzione in formato object
-Codes_left è la lista di codici di caratteri rimanenti che sono ancora da analizzare

Il predicato value cosi come presentato su www.json.org chiama il predicato whitespace e poi in base
al primo codice in ingresso va a richiamare i sotto-parser per riconoscere i valori più specifici.
Una volta che value_execute ha terminato la sua computazione value va a richiamare un'altra volta
whitespace sulla lista di codici rimanenti e poi restituisce il risultato.

/*
 * object
*/

Il predicato object non è altro che la codifica del diagramma presente sul sito www.json.org
in un automa a stati finiti e serve a riconoscere oggetti json.

Il funzionamento spiegato brevemente è il seguente:

1) inizia dallo stato o0 e se il primo carattere in input è la parentesi graffa aperta procede
a richiamare il predicato whitespace e poi effettua la chiamata ricorsiva sul resto della lista in input
e passa allo stato o1.

2) Una volta che si trova nello stato o1 e il codice in input è un apice doppio
procede a richiamare il predicato stringa per il riconoscimento della chiave e poi il predicato whitespace.
Successivamente effettua la chiamata ricorsiva sul resto della lista passandogli come input il nuovo
stato o2 e la chiave appena riconosciuta.

3) Una volta che si trova nello stato o2 dopo aver riconosciuto la chiave chiama il predicato value
per riconoscere il valore associato ad essa, costruisce la pair e la salva nella variabile con il medesimo nome.
Una volta effettuato ciò procede ad inserirla nella lista di coppie dell'oggetto ed effettua poi la chiamata
ricorsiva sul resto della lista in input passando allo stato o3 e resettando il valore temporaneo della chiave.

4) Arrivato nello stato o3 e avendo una virgola in input fa gli stessi passaggi dello stato o1, l'unica differenza
è la presenza di una chiamata a whitespace prima della chiamata a stringa come specificato dal diagramma presente
sul sito www.json.org

5) Gli stati finali sono o1 e o3 e se il codice in input è una parentesi graffa chiusa procede a creare il 
predicato jsonobj con i members costruiti precedentemente e ritorna la lista dei codici rimanenti.

/*
 * array
*/

Il funzionamento è il medesimo a quello di object, ovvero la codifica del diagramma sul sito www.json.org
in un automa a stati finiti e serve a riconoscere array json.

Le differenze da object sono ovviamente dovute alla sintassi da riconoscere e alla mancanza di una variabile
temporanea in quanto l'array non ha una struttura del tipo chiave-valore e può quindi procedere 
direttamente a posizionare il valore riconosciuto sulla lista elements.

/*
 * whitespace
*/

Il suo compito è semplicemente quello di rimuovere caratteri di spaziatura 
da una lista in input fino a quando non incontra un codice non compatibile con un carattere di spaziatura.
Se la lista è vuota oppure il primo codice non è un carattere di spaziatura ritorna la lista tale e quale.

/*
 * stringa
*/

Il seguente predicato è la codifica del diagramma presente sul sito www.json-org in un automa a stati finiti
e serve a riconoscere stringhe json.

Il funzionamento in breve è il seguente:

1) inizia dallo stato s0 e se il primo carattere in input è un apice doppio procede
a concatenare tale carattere su un atomo usato come variabile temporanea, effettua poi 
la chiamata ricorsiva sul resto della lista in input passa allo stato s1.

2) Una volta che si trova nello stato s1 e il codice in input non è un apice doppio
procede a concatenare tale carattere all'atomo usato come variabile temporanea.
Successivamente effettua la chiamata ricorsiva sul resto della lista passandogli come input il nuovo
stato s1 e l'atomo aggiornato.

3) Una volta che si trova nello stato s1 e il codice in input è un apice doppio effettua i seguenti passaggi:
-concatena l'apice doppio sull'atomo temporaneo
-trasforma l'atomo temporaneo in un termine
-verifica se tale termine è una stringa e se si ritorna la sua conversione in stringa, altrimenti fallisce

/*
 * numero
*/

Tale predicato serve a riconoscere numeri json da una lista di caratteri in input e lo fa avvalendosi di una
variabile temporanea, in questo caso un atomo vuoto.
Molto semplicemente fino a quando il primo carattere della lista in input è compatibile con un possibile numero,
overo caratteri come:
-cifre da zero a nove
-punto
-e oppure E
-+ o -
procede a trasformarlo in carattere e lo concatena alla variabile temporanea.
Una volta che la lista in input è vuota (caso in cui si decida di usare il predicato singolarmente) oppure il primo
carattere della lista non è più compatibile con un numero procede a convertire la variabile temporanea in un termine
prolog e verifica se è un numero chiamando il predicato della libreria standard number.
Se il risultato è true procede a ritornare tale valore e la lista di codici rimanenti.

/*
 * true, false e null
*/

Se la lista in input ha i primi 4 o 5 codici corrispondenti ai caratteri di true, false o null ritorna 
il corrispondente valore booleano e la lista di codici rimanenti.

/*
 * jsonobj
*/

Il seguente predicato serve a jsonparse per fare la traduzione da formato object a stringa ed è richiamato direttamente
da jsonparse con 2 parametri aggiuntivi:
-una traduzione in ingresso alla quale concatenare il risultato (Trad_in)
-il risultato della traduzione e concatenazione con Trad_in (Trad_out)

Una volta verificato che Trad_in è una stringa procede a concatenarla con la parentesi graffa
aperta, ovvero l'inizio di un oggetto json e richiama poi il predicato _execute.
Questo predicato svolge una funzione d'appoggio in quanto l'unico compito è quello di estrarre una coppia
dalla lista di coppie di jsonobj e passare il controllo a traduzione_pair che effettuerà la traduzione della coppia
vera e propria.
Una volta fatto ciò chiama il predicato verifica_virgola (spiegato più avanti), concatena il tutto ed effettua
la chiamata ricorsiva sul resto della lista.
Una volta che la lista è terminata concatena la parentesi graffa chiusa per terminare l'oggetto e restituisce il 
risultato.

/*
 * traduzione_pair
*/

Questo predicato serve a tradurre una coppia per oggetti json.
Riceve in input una coppia chiave-valore, una traduzione in ingresso e una variabile dove salvare la traduzione.

Una volta verificato che la chiave sia una stringa procede a trasformare tale termine in una stringa
e ad effettuare le varie concatenazioni, una di queste è con " : " che rappresenta la virgola nelle coppie
in formato json standard.
Una volta effettuato ciò richiama il predicato ausiliario _execute il quale ha il compito di tradurre il valore
associato alla chiave.
I due casi sono i seguenti:
-traduzione caso base (stringa, numero, booleano)
-traduzione oggetto o array innestato

Nel primo caso procede a tradurre tale termine in una stringa e a concatenarla con la traduzione in ingresso.
Nel secondo caso si passa il controllo al predicato applica il quale avrà il compito di richiamare
il predicato correttp relativo alla traduzione dell'oggetto o array innestato.

/*
 * jsonarray
*/

Molto simile al predicato jsonobj, questo predicato differisce nella sintassi del valore riconosciuto
in quanto non deve gestire più dati del tipo coppie chiave-valore ma una lista di elementi.

Il predicato d'appoggio che effettua la traduzione vera e propria ha 3 casistiche:
-traduzione di un caso base
-traduzione di un oggetto o array innestato
-lista vuota

Per caso base si intendono:
-booleani
-stringhe
-numeri

Se l'elemento rientra in questa casistica jsonarray_execute procede a tradurlo in stringa, chiamare il predicato
verifica_virgola e poi effettua la chiamata ricorsiva sul resto degli elementi ma non prima di aver fatto le
varie concatenazioni sulle traduzioni dell'elemento corrente.

Il secondo caso ha lo stesso comportamento di traduzione_pair nella traduzione da formato object a stringa, l'unica 
differenza sta nella chiamata al predicato verifica_virgola, nelle varie concatenazioni delle traduzioni e nella
chiamata ricorsiva sul resto degli elementi.

Il terzo è il caso più semplice in quanto se l'array non ha elementi procede a concatenare la parentesi quadra
chiusa e ritorna il risultato.

/*
 * jsondump
*/

Predicato citato nel testo del progetto, esso prende in input un oggetto/array json scritto in formato object
e un nome di un file scritto come atomo o stringa.

Scrive sul file passato come input la traduzione dell'oggetto/array json in formato json standard.
Se il file non è presente viene creato mentre se è gia presente viene sovrascritto.

I passaggi che fa il seguente predicato sono i seguenti:
-verifica se il nome del file è scritto come atomo o stringa
-trasforma l'input da formato object a stringa tramite jsonparse che ne verifica anche la correttezza sintattica
-scrive tale stringa sul file passato in input grazie ai metodi open e write della libreria standard

/*
 * jsonread
*/

Predicato citato nel testo del progetto, prende in input un nome di file scritto come atomo o stringa e una 
variabile dove salvare il risultato della lettura.

Quest'ultimo parametro può anche non essere una variabile in quanto questo predicato può rispondere anche a
query del tipo jsonread('foo.json', jsonarray([X]) oppure jsonread('foo.json', jsonarray(["mario"])).

Se il nome del file indica un nome di file non esistente il predicato fallisce.

I passaggi che fa il seguente predicato sono i seguenti:
-verifica se il nome del file è scritto come atomo o stringa e se esiste
-legge il contenuto del file in una stringa
-richiama jsonparse per verificare la correttezza sintattica del contenuto appena letto e lo ritorna

Ovviamente jsonparse è colui che si occupa di rispondere alla query oppure di ritornare il risultato
in quanto entrambe le versioni di jsonparse sono definite e perciò in automatico verrà richiamata la versione
opportuna.

/*
 * utils
*/

Questa è una sezione dedicata a predicati come dice il nome utils ovvero utili per verificare condizioni per altri
predicati oppure per svolgere compiti di minore importanza.

I predicati sono i seguenti:
-final_state_obj verifica se l'input è uno stato finale per l'automa di traduzione degli oggetti
-final_state_array ha un comportamento identico ma per gli array
-whitespace_acceptable indica i codici dei caratteri che sono uno spazio
-number_acceptable indica i codici dei caratteri che potrebbero essere presenti in un numero intero/float
-chiamabile serve a verificare se quel predicato è chiamabile (utile alle varie chiamate per oggetti/array 
innestati per evitare eccezioni potenzialmente fatali)
-valore_base indica i valori json true, false e null
-verifica_virgola restituisce "" se la lista ha un solo elemento mentre ", " se la lista ha più di un elemento
(molto utile per jsonobj e jsonarray per verificare la presenza di più coppie/elementi)
-caso_base verifica se l'input è un valore base, una stringa oppure un numero
(serve ai vari predicati di traduzione per distinguere tra valore elementare che può essere tradotto direttamente
e valori compound che necessitano di una chiamata apposita)
-atomo_o_stringa verifica se l'input è un atomo o una stringa (utile a jsonread e jsondump)
-verifica_lista è il predicato presentato a lezione e verifica se l'input è una lista
-applica chiama il predicato passatogli in input con le opportune modifiche e verifiche

PARTE AGGIUNTA IN SEGUITO ALLA COSTRUZIONE DI JSONACCESS

/*
* Field è una lista del tipo : [Field | Fields]
*/
Si osserva la struttura del campo Field quando esso è una lista. 
In questo frangente, Field può contenere una sequenza di stringhe e numeri 
che rappresentano la chiave delle coppie (Chiave, Valore) del jsonobject, oppure
la posizione di un elemento in un jsonarray.

/*
* jsonaccess
*/
E' il secondo predicato principale citato nel testo del progetto.
Questo predicato può prendere in input un oggetto composto di tipo jsonobj(Members) oppure di tipo jsonarray(Elements), 
dopodiché un campo Field che può essere rappresentata in due forme: lista o stringa.
Nel caso in cui l'input al predicato jsonaccess sia un jsonarray e 
il campo Field sia una lista vuota il predicato fallisce.
Quando invece l'input di jsonaccess è un jsonobject o un jsonarray, 
allora Field potrà essere una lista (non vuota per jsonarray) oppure una stringa SWI-prolog (caso speciale). 
Il predicato jsonaccess permette, percorrendo il contenuto del campo Field di ottenere il risultato della ricerca, Result.
Per eseguire quest'operazione il predicato jsonaccess si appoggia al predicato jsonaccess_execute. 

/*
* jsonaccess_execute(jsonarray(Elements), [Field], Risultato)
*/
Nel caso in cui il valore in ingresso sia un jsonarray il campo Field è rappresentato 
da una lista il cui primo elemento è un numero, il quale esprime l'indice 
attraverso cui effettuare la ricerca del valore.
Quando viene invocato questo predicato, si svolge una chiamata a "elemento_i_esimo" che prende in input un array
e restituisce un Risultato in base al valore dell'indice (Field).
(Ciò significa che nel caso in cui venga passato un Field di tipo stringa o lista, viene restituito un errore).
Una volta estrapolato tale valore grazie al predicato elemento_i_esimo
viene effettuata la chiamata ricorsiva sull'ultimo elemento trovato ed il
resto della lista Fields.
Nel caso in cui il campo Field sia una lista vuota viene ritornato tale valore.

/*
* jsonaccess_execute(jsonobj(Members), Field, RisultatoFinale)
*/
Il funzionamento di questo predicato non cambia dalla sua variante con jsonarray,
il fine ultimo è quello di usare la lista Field per ottenere il RisultatoFinale.
E' opportuno ricordare che jsonobject è un dato composto, 
formato da coppie di tipo (Chiave, Value), ossia delle strutture che vengono riconosciute nel linguaggio Prolog.
Le coppie sono strutture del tipo '(Chiave, Valore)' dove Chiave è una stringa SWI Prolog, 
mentre il Valore può essere a sua volta una stringa SWI Prolog,
un numero, true, false, null, oppure un oggetto json come jsonobject o jsonarray.
Tale valore viene estratto grazie al predicato estrai_valore quando la 
Chiave della coppia unifica con il primo elemento del campo field.
Anche in questo caso, una volta estrapolato il valore viene effettuata la chiamata ricorsiva
su di esso e sul resto della lista Fields.
Nel caso in cui il campo Field sia una lista vuota viene ritornato tale valore.

/*
* utils
*/

/*
* estrai_valore(Members, Field, Risultato)
*/
Questo predicato riceve in input una lista di coppie (Chiave, Valore), una stringa Field e ritorna il valore associato. 
Nel caso in cui Field unifichi con la chiave della prima coppia in input viene restituito il valore associato.
Se questo non avviene, estrai_valore percorre l'intera lista di coppie finché la chiave di una coppia non unifica con Field.
Quando nessuno di questi casi ha successo, viene restituito false.

/*
* elemento_i_esimo
*/
Questo predicato riceve in input una lista, un indice e restituisce un risultato.
Se l'indice è pari a zero, allora viene restituito il primo elemento della lista,
altrimenti si percorre ricorsivamente l'intera lista
fino al momento in cui l'indice non arriva a zero, ritornando il risultato.
Se l'indice in input è maggiore della lunghezza della lista il predicato fallisce.






