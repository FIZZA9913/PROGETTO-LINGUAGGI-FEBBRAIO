Gruppo formato da:

Fizzardi, Fabio, 844726 
Pascone, Michele, 820633
Paulicelli, Sabino, 856111

Premesse:
-i vari predicati al di fuori di quelli richiesti dal testo del progetto sono
perfettamente utilizzabili e funzionanti anche singolarmente a patto ovviamente
di non utilizzare i predicati ausiliari con l'abbreviazione _execute perchè 
hanno bisogno di specifici parametri passati precedentemente.
Un utilizzo dei predicati _execute con parametri diversi da quelli aspettati potrebbe causare bug 
o eccezioni non controllate.
Ovviamente qualche predicato potrebbe restituire valori che non hanno senso nel contesto json, ad esempio
jsonarray([true], 'a', X) restituisce X = 'a[true]' perchè ovviamente sono pensati per lavorare in sintonia
per una traduzione in un contesto creato da jsonparse.
L'utilizzo con parametri particolari comunque non genera errori perchè ogni predicato verifica 
i suoi input e quindi al massimo ritorna false.
-Il vari predicati non riconoscono stringhe che presentano al loro interno i caratteri di escape
\", \\ e \/ in quanto atom_codes('"', 34) e atom_codes('\"', 34) restituiscono entrambi
true rendendo questi due caratteri indistinguibili.
Stesso discorso vale per \\ che viene interpretato giustamente come \ che però essendo 
un carattere speciale di prolog genera errore così come \/ che non è un carattere di escape presente in prolog.
-Il parser fa solo un'analisi sintattica degli oggetti/array json quindi nel caso in cui un oggetto abbia chiavi
duplicate il parser restituisce la traduzione corretta, il problema si presenta quando
bisogna stampare la seguente traduzione su file .json che giustamente lo interpreta come errore 
di sintassi e lo stesso discorso vale per le stringhe che presentano al loro interno
ad esempio il carattere \n in quanto esso viene stampato letteralmente come a capo
e l'effetto è quello di avere una stringa stampata su 2 righe, cosa ovviamente sintatticamente scorretta.
Questo non inficia comunque la validità del programma in quanto la lettura dallo stesso file restituisce
la traduzione desiderata.
-Se nel predicato jsondump viene passato un nome di un file con una estensione non esistente questo 
predicato procede comunque a creare il file e a scriverci sopra il risultato della traduzione senza
generare alcuna eccezione e il risultato sarà inoltre leggibile senza problemi con jsonread.
L'unico problema è che ovviamente questo file non sarà apribile.
-i vari predicati e i rispettivi ausiliari sono divisi in sezioni e il loro funzionamento è spiegato
qua sotto.

/*
 * jsonparse
*/

Questo è il predicato citato nel testo del progetto che ha 3 modalità d'uso diverse:
1) traduzione da atomo/stringa in formato object
2) traduzione da formato object a atomo scritto in formato json
3) verifica uguaglianza tra le 2 scritture anche con termini parzialmente istanziati
per il formato object

Per la modalità 1 jsonparse normalizza l'input sotto forma di atomo per poi andare a richiamare
il predicato della libreria standard atom_codes il quale traduce l'atomo in una lista
di codici di caratteri la quale sarà data in pasto al predicato riconosci_e_traduci che fornirà la traduzione
in formato object.

Per la modalità 2 jsonparse scompone con il predicato univ l'input e aggiunge alla lista di parametri
un atomo vuoto il quale rappresenta la traduzione di partenza e una variabile dove verrà salvata
la traduzione sotto forma di atomo in formato json standard.
Una volta effettuato questo passaggio verifica se tale predicato è richiamabile per evitare eccezioni
e se si lo richiama tramite il predicato call.

Per la modalità 3 jsonparse non fa altro che tradurre il formato json standard in formato object
e poi tutto il compito dell'uguaglianza è lasciato al principio di unificazione di prolog.

/* 
 * riconosci_e_traduci
*/

Questo predicato non è altro che il predicato value limitato ad oggetti e array.

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
2) Una volta che si trova nello stato o1 e il codice in input non è una parentesi graffa chiusa
procede a richiamare il predicato stringa per il riconoscimento della chiave e poi il predicato whitespace.
Successivamente effettua la chiamata ricorsiva sul resto della lista passandogli come input il nuovo
stato o2 e la chiave appena riconosciuta.
3) Una volta che si trova nello stato o2 dopo aver riconosciuto la chiave chiama il predicato value
per riconoscere il valore associato ad essa, costruisce la pair e la salva nella variabile con il medesimo nome.
Una volta effettuato ciò procede ad inserirla nella lista di coppie dell'oggetto e poi effettua la chiamata
ricorsiva sul resto della lista in input passando allo stato o3 e resettando la lista temporanea.
4) Arrivato nello stato o3 e avendo una virgola in input fa gli stessi passaggi dello stato o1, l'unica differenza
è la presenza di una chiamata a whitespace prima della chiamata a stringa come specificato dal diagramma presente
sul sito www.json.org.
5) Gli stati finali sono o1 e o3 e se il codice in input è una parentesi graffa chiusa procede a creare il 
predicato jsonobj con i members costruiti precedentemente grazie al predicato univ e ritorna la lista dei codici rimanenti.

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

Non ha 3 parametri come i predicati precedenti in quanto non deve riconoscere un valore e il suo compito è semplicemente
quello di rimuovere caratteri di spaziatura da una lista in input fino a quando non incontra un codice non compatibile
con un carattere di spaziatura.
Se la lista è vuota oppure il primo codice non è un carattere di spaziatura ritorna la lista tale e quale.

/*
 * true, false e null
*/

Ritorniamo alla sintassi vista in precedenza con 3 parametri e il loro funzionamento è molto semplice.
Se la lista in input ha i primi 4 o 5 codici corrispondenti ai caratteri di true, false o null ritorna tale valore
e la lista di codici rimanenti.

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
 * stringa
*/

Il seguente predicato è una fusione del funzionamento di object/array e quello di numero in quanto è la codifica
di un automa a stati finiti che usa una variabile temporanea (atomo vuoto) come incremento.
Il primo passaggio è verificare se il primo codice in input è ", se si procede a cambiare stato e passare da
s0 a s1.
Una volta arrivato in s1 ci sono 2 strade possibili, effettuare cicli ricorsivi fino a quando il primo carattere della lista
non è " procedendo a trasformare il codice in carattere e concatenandolo alla variabile temporanea oppure se il primo
codice della lista è " procede a trasformare la variabile temporanea in termine e verificare se esso è una stringa
chiamando il predicato della libreria standard string.
Se il risultato è true procede a ritornare tale valore e la lista di codici rimanenti.

/*
 * jsonobj
*/

Il seguente predicato serve a jsonparse per fare la traduzione da formato object ad atomo ed  è richiamato direttamente
da jsonparse con 2 parametri aggiuntivi:
-una traduzione in ingresso alla quale concatenare il risultato (Trad_in)
-il risultato della traduzione e concatenazione con Trad_in (Trad_out)

Molto semplicemente una volta verificato che Trad_in è un atomo procede a concatenarlo con la parentesi graffa
aperta, ovvero l'inizio di un oggetto json e richiama poi il predicato _execute.
Questo predicato svolge una funzione d'appoggio in quanto l'unico compito è quello di estrarre una coppia
dalla lista di coppie di jsonobj e passare il controllo a traduzione pair che effettuerà la traduzione della coppia
vera e propria.
Una volta fatto ciò chiama il predicato verifica_virgola (spiegato più avanti), concatena il tutto ed effettua
la chiamata ricorsiva sul resto della lista.
Una volta che la lista è terminata concatena la parentesi graffa chiusa per terminare l'oggetto e restituisce il 
risultato.

/*
 * jsonarray
*/

Medesimi parametri di jsonobj, cambia ovviamente il comportamento in quanto la lista in input è fatta da elementi e
non da coppie e la traduzione è quella di un array e non di un oggetto.
Come per jsonobj questo predicato effettua le verifiche su Trad_in, concatena la parentesi quadra aperta e procede
a richiamare il predicato d'appoggio _execute.

Il predicato d'appoggio ha 3 casi:
-traduzione di un caso base
-traduzione di un oggetto o array innestato
-lista vuota

Il terzo è il caso più semplice in quanto se l'array non ha elementi procede a concatenare la parentesi quadra
chiusa e ritorna il risultato.

Per caso base si intendono:
-true
-false
-null
-stringhe
-numeri

Se l'elemento rientra in questa casistica jsonarray_execute procede a tradurlo in atomo, chiamare il predicato
verifica_virgola e poi effettua la chiamata ricorsiva sul resto degli elementi ma non prima di aver fatto le
varie concatenazioni sulle traduzioni dell'elemento corrente.

Il secondo caso ha lo stesso comportamento di jsonparse nella traduzione da formato object ad atomo, l'unica 
differenza sta nella chiamata al predicato verifica_virgola, nelle varie concatenazioni delle traduzioni e nella
chiamata ricorsiva sul resto degli elementi, cosa non presente in jsonparse in quanto il suo input era nella forma
jsonobj/jsonarray([_]) e non una lista di elementi da analizzare.

/*
 * traduzione_pair
*/

Questo predicato serve a tradurre una coppia per oggetti json.

I parametri sono gli stessi di jsonobj e jsonarray con la differenza che l'input non è una lista ma una coppia
con chiave e valore.

Una volta verificato che Trad_in sia un atomo e che la chiave sia una stringa procede a trasformalra in atomo
e ad effettuare le varie concatenazioni, una di queste è con ' : ' che rappresenta la virgola nelle coppie
ma tradotta in formato json.
Una volta effettuato ciò richiama il predicato ausiliario il quale ha il compito di tradurre il valore
associato alla chiave ed il suo comportamento è il medesimo di jsonarray, differisce soltanto nell'assenza
di una chiamata ricorsiva in quanto il valore è uno solo e non una lista e nell'assenza del predicato 
verifica_virgola per i medesimi motivi.

/*
 * jsondump
*/

Predicato citato nel testo del progetto, esso prende in input un oggetto/array json scritto in formato object
e un nome di un file scritto come atomo o stringa.

Scrive sul file passato come input la traduzione dell'oggetto/array json in formato json.
Se il file non è presente viene creato mentre se è gia presente viene sovrascritto.

I passaggi che fa il seguente predicato sono i seguenti:
-verifica se il nome del file è scritto come atomo o stringa
-trasforma l'input da formato oggetto ad atomo tramite jsonparse che ne verifica anche la correttezza sintattica
-converte tale risultato in una stringa che sarà scritta poi su file grazie ai metodi open e write della libreria standard

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
-verifica_virgola restituisce '' se la lista ha un solo elemento mentre ', ' se la lista ha più di un elemento
(molto utile per jsonobj e jsonarray per verificare la presenza di più coppie/elementi)
-caso_base verifica se l'input è un valore base, una stringa oppure un numero
(serve ai vari predicati di traduzione per distinguere tra valore elementare che può essere tradotto direttamente
e valori compound che necessitano di una chiamata apposita)
-atomo_o_stringa verifica se l'input è un atomo o una stringa (utile a jsonread e jsondump)
-verifica_lista è il predicato presentato a lezione e verifica se l'input è una lista


