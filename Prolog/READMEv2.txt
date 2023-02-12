Gruppo formato da:

Fizzardi, Fabio, 844726 
Pascone, Michele, 820633
Paulicelli, Sabino, 856111

Premesse:
-i vari predicati al di fuori di quelli richiesti dal testo del progetto sono
perfettamente utilizzabili e funzionanti anche singolarmente a patto ovviamente
di non utilizzare i predicati ausiliari con l'abbreviazione _execute perchè 
hanno bisogno di specifici parametri passati precedentemente.
Un utilizzo con parametri diversi potrebbe causare bug o eccezioni non controllate
-Il predicato jsonparse non riconosce stringhe che presentano al loro interno i caratteri di escape
\", \\ e \/ in quanto atom_codes('"', 34) e atom_codes('\"', 34) restituiscono entrambi
true rendendo questi due caratteri indistinguibili.
Stesso discorso vale per \\ che viene interpretato giustamente come \ che però essendo 
un carattere speciale di prolog genera errore così come \/ che non è un carattere di escape presente in prolog
-Il parser fa solo un'analisi sintattica degli oggetti/array json quindi nel caso in cui un oggetto abbia chiavi
duplicate il parser restituisce la traduzione corretta, il problema si presenta quando
bisogna stampare la seguente traduzione su file .json che giustamente lo interpreta come errore 
di sintassi e lo stesso discorso vale per le stringhe che presentano al loro interno
ad esempio il carattere \n in quanto esso viene stampato letteralmente come a capo
e l'effetto è quello di avere una stringa stampata su 2 righe, cosa ovviamente sintatticamente scorretta.
Questo non inficia comunque la validità del programma in quanto la lettura dallo stesso file restituisce
la traduzione desiderata
-i vari predicati e i rispettivi ausiliari sono divisi in sezioni e il loro funzionamento è spiegato
qua sotto

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
in formato object

Per la modalità 2 jsonparse scompone con il predicato univ l'input e aggiunge alla lista di parametri
un atomo vuoto il quale rappresenta la traduzione di partenza e una variabile dove verrà salvata
la traduzione sotto forma di atomo in formato json standard.
Una volta effettuato questo passaggio verifica se tale predicato è richiamabile per evitare eccezioni
e se si lo richiama tramite il predicato call

Per la modalità 3 jsonparse non fa altro che tradurre il formato json standard in formato object
e poi tutto il compito dell'uguaglianza è lasciato al principio di unificazione di prolog

/* 
 * riconosci_e_traduci
*/

Questo predicato non è altro che il predicato value limitato ad oggetti e array

/*
 * value
*/

Da ora in poi i seguenti predicati avranno un'interfaccia standard e non sono altro che la codifica
dei diagrammi della sintassi del linguaggio json presenti sul sito www.json.org
L'interfaccia è la seguente:
-Codes_in è la lista di codici di caratteri in ingresso
-Result è il risultato della traduzione in fromato object
-Codes_left è la lista di codici di caratteri rimanenti che sono ancora da analizzare

Il predicato value cosi come presentato su www.json.org chiama il predicato whitespace e poi in base
al primo codice in ingresso va a richiamare i sotto-parser per riconoscere i valori più specifici.
Una volta che value_execute ha terminato la sua computazione value va a richiamare un'altra volta
whitespace sulla lista di codici rimanenti e poi restituisce il risultato

/*
 * object
*/

Il predicato object non è altro che la codifica del diagramma presente sul sito www.json.org
in un automa a stati finiti e serve a riconoscere oggetti json.

Il funzionamento spiegato brevemente è il seguente:
1) inizia dallo stato o0 e se il primo carattere in input è la parentesi graffa aperta procede
a richiamare il predicato whitespace e poi effettua la chiamata ricorsiva sul resto della lista in input
e passa allo stato o1
2) Una volta che si trova nello stato o1 e il codice in input non è una parentesi graffa chiusa
procede a richiamare il predicato stringa per il riconoscimento della chiave e poi il predicato whitespace.
Una volta effettuato ciò inserisce la chiave riconosciuta in una lista che svolge la funzione di variabile
temporanea ed effettua la chiamata ricorsiva sul resto della lista in input e passa allo stato o2
3) Una volta che si trova nello stato o2 dopo aver riconosciuto la chiave chiama il predicato value
per riconoscere il valore associato ad essa, costruisce la pair e la salva nella variabile con il medesimo nome.
Una volta effettuato ciò procede ad inserirla nella lista di coppie dell'oggetto e poi effettua la chiamata
ricorsiva sul resto della lista in input passando allo stato o3 e resettando la lista temporanea
4) Arrivato nello stato o3 e avendo una virgola in input fa gli stessi passaggi dello stato o1, l'unica differenza
è la presenza di una chiamata a whitespace prima della chiamata a stringa come specificato dal diagramma presente
sul sito www.json.org
5) Gli stati finali sono o1 e o3 e se il codice in input è una parentesi graffa chiusa procede a creare il 
predicato jsonobj con i members costruiti precedentemente grazie al predicato univ e ritorna la lista dei codici rimanenti

/*
 * array
*/

Il funzionamento è il medesimo a quello di object, ovvero la codifica del diagramma sul sito www.json.org
in un automa a stati finiti e serve a riconoscere array json

Le differenze da object sono ovviamente dovute alla sintassi da riconoscere e alla mancanza di una variabile
temporanea in quanto l'array non ha una chiave e può quindi procedere direttamente a posizionare il valore
riconosciuto sulla lista elements.

/*
 * whitespace
*/

Non ha 3 parametri come i predicati precedenti in quanto non deve riconoscere un valore e il suo compito è semplicemente
quello di rimuovere caratteri di spaziatura da una lista in input fino a quando non incontra un codice non compatibile
con un carattere di spaziatura.
Se la lista è vuota oppure il primo codice non è un carattere di spaziatura ritorna la lista tale e quale

/*
 * true, false e null
*/

Ritorniamo alla sintassi vista in precedenza con 3 parametri e il loro funzionamento è molto semplice.
Se la lista in input ha i primi 4 o 5 codici corrispondenti ai caratteri di true, false o null ritorna tale valore
e la lista di codici rimanenti

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
Se il risultato è true procede a ritornare tale valore e la lista di codici rimanenti

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
Se si ritorna tale valore assieme alla lista dei codici rimanenti

/*
 * jsonobj
*/



