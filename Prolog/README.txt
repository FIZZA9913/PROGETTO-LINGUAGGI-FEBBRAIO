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