/*

jsonaccess prende in input un jsonobject o un jsonarray e seguendo il
contenuto di Field (lista, stringa o numero) restituisce un risultato.

*/


%JSONACCESS CON ARRAY
% Se in input ho un jsonarray, Field può essere solo un numero che
% indica l'indice dell'array dal quale estrarre il valore.
% Nel caso iterativo, viene chiamato elemento_i_esimo per cercare dentro
% l'array.


jsonaccess(jsonarray(_), [], jsonarray(_)).
jsonaccess(jsonarray(Elements), Field, Risultato) :- elemento_i_esimo(jsonarray(Elements), Field, Risultato).


/*
jsonobject contiene una lista di coppie.
In questo caso Field è una stringa o una lista.
*/

%JSONACCESS CON OBJECT - FIELD E' UNA LISTA
% Quando Field è una lista, può contenere stringhe e/o numeri.
% Prendo il primo elemento della lista Field e lo metto a confronto con
% la chiave della prima coppia dell'ogetto json.
% Se si trova una coppia json che unifica con Field, il valore
% ritornato:
% 1 CASO: E' un valore atomico (numero, stringa, true/false/null).
% Allora questi viene restituito come risultato finale.
% 2 CASO: E' un valore composto (jsonobject, jsonarray). Applico a
% quest'ultimo il predicato jsonaccess (ricorsione).
% Quando la lista è vuota viene restituito il risultato (caso base).
%VEDERE MEGLIO IL CASO BASE E CAMBIARE IL MODELLO ITERATIVO NEL CASO.

%Caso base:
jsonaccess(jsonobj(Members), [], jsonobj(Members)).

%Caso iterativo - 1 CASO:
jsonaccess(jsonobj(Members), [Field | []], RisultatoFinale) :-
    estrai_valore(Members, Field, Risultato),
    valore_base(Risultato),
    !,
    RisultatoFinale = Risultato.

%Caso iterativo - 2 CASO:
jsonaccess(jsonobj(Members), [Field | Fields], RisultatoFinale) :-
    estrai_valore(Members, Field, Risultato),
    composto(Risultato),
    !,
    jsonaccess(Risultato, Fields, RisultatoFinale).



%JSONACCESS CON OBJECT - FIELD E' UNA STRINGA
% Se Field è una stringa complessa (ossia contiene più elementi, ad
% esempio: "nome, cognome, 0, ...") allora viene divisa da un
% predicato suddividi_field in due stringhe: la prima contenente il
% primo di questi elementi ("nome"), e la seconda contenente il resto
% della stringa. La prima stringa viene poi passata al predicato
% estrai_valore che cerca tra tutte le coppie del jsonobject quella che
% unifica con tale stringa, restituendo un risultato.
% Il valore ritornato:
% 1 CASO: E' un valore atomico (numero, stringa, true/false/null).
% Allora questi viene restituito come risultato finale.
% 2 CASO: E' un valore composto (jsonobject, jsonarray). Applico a
% quest'ultimo il predicato jsonaccess (ricorsione).
% Quando la stringa è vuota viene restituito il risultato (caso base).


%Caso base:
jsonaccess(jsonobj(Members), "", jsonobj(Members)).
jsonaccess(jsonobj(Members), " ", jsonobj(Members)).


%Caso iterativo - 1 CASO:
%Field è una stringa che contiene una chiave sola
jsonacces(jsonobj(Members), Field, Risultato) :-
    suddividi_field(Field, PrimoField, _),
    estrai_valore(Members, PrimoField, ParaRisultato),
    valore_base(ParaRisultato),
    Risultato = ParaRisultato.

%Caso iterativo - 2 CASO:
%Field è una stringa contenente più chiavi.
jsonacces(jsonobj(Members), Field, Risultato) :-
    suddividi_field(Field, PrimoField, AltriField),
    estrai_valore(Members, PrimoField, ParaRisultato),
    composto(ParaRisultato),
    jsonaccess(ParaRisultato, AltriField, Risultato).



%  jsonobj([(”nome”, ”Arthur”), (”cognome”, jsonarray[1, 2, 3])])
%  ObjectList = [(”nome”, ”Arthur”), (”cognome”, jsonarray[1, 2, 3])]
%  Fields = ["cognome", 1].



%PARTE PREDICATI UTILS

% Composto restituisce true se il valore passato è un jsonobject o un
% jsonarray.
composto(jsonobj(_)).
composto(jsonarray(_)).

% valore_base restituisce true se il valore passato è una stringa, un
% numero o è un true/false/null.

valore_base(true).
valore_base(null).
valore_base(false).
valore_base(number(_)).
valore_base(string(_)).

valore_base(X) :- not(composto(X)).

% Questo predicato prende in input un jsonarray e restituisce un
% risultato in base al valore dell'indice. Per trovare l'N-esimo
% elemento si utilizza il predicato elemento_i_esimo_execute che
% percorre ricorsivamente la lista.
elemento_i_esimo(jsonarray(Elements), Index, Result) :-
    number(Index),
    elemento_i_esimo_execute(Elements, Index, Result).

elemento_i_esimo_execute([I | _], Index, Result) :-
    Index = 0,
    !,
    Result = I.

elemento_i_esimo_execute([_ | Is], Index, Result) :-
    Index > 0,
    !,
    X is Index - 1,
    elemento_i_esimo_execute(Is, X, Result).



% estrai_valore riceve in input una lista di coppie (Chiave,Valore)
% appartententi ad un jsonobject, e restituisce come risultato il valore
% della coppia.
% Il valore restituito è il valore della coppia (Chiave, Valore) quando
% Chiave = Field.
%Quando questo non succede, si passa alla coppia successiva.
estrai_valore([], _, _) :- fail.
estrai_valore([(Chiave, Valore) | _], Chiave, Valore).

estrai_valore([(Chiave, _) | AltreCoppie], Field, Valore) :-
    string(Chiave),
    Field \= Chiave,
    estrai_valore(AltreCoppie, Field, Valore).


% suddividi_field separa la stringa ricevuta in input (caso in cui Field
% è una stringa), in stringa pre-carattere e stringa post-carattere,
% dove 'carattere'= 44, ossia il char che identifica la virgola ( ',' ).
% Questo predicato viene usato solo nel caso in cui la stringa è
% complessa, ossia formata da più elementi, ad esempio:
% Field = "nome, cognome, 0".
% Allora il predicato crea due stringhe:
% 1 stringa: "nome"
% 2 stringa: "cognome, 0".
% Che verranno usate all'interno di jsonaccess per la ricerca di un
% valore (Result).
suddividi_field(Stringa, PrimoField, SecondoField) :-
    string_codes(Stringa, ListaCodici),
    split_codice(ListaCodici, 44, PrimoCodice, SecondoCodice),
    string_codes(PrimoField, PrimoCodice),
    string_codes(SecondoField, SecondoCodice),
    !.


% split_codice separa una lista di caratteri al char desiderato creando
% due liste separate:
% 1 lista di codici pre-carattere
% 1 lista di codici post-carattere.
split_codice([X | Xs], T, [X | L1], L2) :-
               X\=T, split_codice(Xs, T, L1, L2), !.

split_codice([T | Xs], T, [], Xs).


%FINE PREDICATI UTILS
