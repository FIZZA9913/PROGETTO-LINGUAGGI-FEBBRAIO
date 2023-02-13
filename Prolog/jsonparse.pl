/*
 * Gruppo formato da:
 * Fizzardi, Fabio, 844726
 * Pascone, Michele, 820633
 * Paulicelli, Sabino, 856111
*/

/*
 * inizio predicato jsonparse
*/

jsonparse(JSONString, Object) :-
    atom(JSONString),
    var(Object),
    !,
    atom_codes(JSONString, Code_list),
    riconosci_e_traduci(Code_list, Object).

jsonparse(JSONString, Object) :-
    string(JSONString),
    var(Object),
    !,
    string_to_atom(JSONString, Atom),
    jsonparse(Atom, Object).

jsonparse(JSONString, Object) :-
    nonvar(JSONString),
    compound(Object),
    !,
    jsonparse(JSONString, Object1),
    Object1 = Object.

jsonparse(JSONString, Object) :-
    var(JSONString),
    compound(Object),
    !,
    Object =.. Temp,
    append(Temp, [''], Temp1),
    append(Temp1, [JSONString], Temp2),
    Temp2 = [X | _],
    chiamabile(X),
    Predicate =.. Temp2,
    call(Predicate).

/*
 * fine predicato jsonparse
*/

/*
 * inizio predicato riconosci_e_traduci
 * che va a simulare il predicato value
 * ma solo su oggetti e array
*/

riconosci_e_traduci(Code_list, Result) :-
    whitespace(Code_list, Codes_w_left),
    riconosci_e_traduci_execute(Codes_w_left, Result, Codes_left),
    whitespace(Codes_left, []).

riconosci_e_traduci_execute([C | Cs], Result, Codes_o_left) :-
    C = 123,
    !,
    object([C | Cs], Result, Codes_o_left).

riconosci_e_traduci_execute([C | Cs], Result, Codes_a_left) :-
    array([C | Cs], Result, Codes_a_left).

/*
 * fine predicato riconosci_e_traduci
*/

/*
 * inizio predicato value per riconoscimento
 * valori json
*/

value(Codes_in, Result, Codes_left) :-
    whitespace(Codes_in, Codes_w_left),
    value_execute(Codes_w_left, Result, Codes_left_a),
    whitespace(Codes_left_a, Codes_left).

value_execute([C | Cs], Result, Codes_o_left) :-
    C = 123,
    !,
    object([C | Cs], Result, Codes_o_left).

value_execute([C | Cs], Result, Codes_a_left) :-
    C = 91,
    !,
    array([C | Cs], Result, Codes_a_left).

value_execute([C | Cs], Result, Codes_t_left) :-
    C = 116,
    !,
    true([C | Cs], Result, Codes_t_left).

value_execute([C | Cs], Result, Codes_f_left) :-
    C = 102,
    !,
    false([C | Cs], Result, Codes_f_left).

value_execute([C | Cs], Result, Codes_n_left) :-
    C = 110,
    !,
    null([C | Cs], Result, Codes_n_left).

value_execute([C | Cs], Result, Codes_s_left) :-
    C = 34,
    !,
    stringa([C | Cs], Result, Codes_s_left).

value_execute(Codes_in, Result, Codes_nu_left) :-
    numero(Codes_in, Result, Codes_nu_left).

/*
 * fine predicato value
*/

/*
 * inizio predicato object per
 * riconoscimento oggetti json
*/

object(Codes_in, Result, Codes_left) :-
    object_execute(Codes_in, Result, [], [], o0, Codes_left).

object_execute([C | Cs], Result, Members, Temp, Q, Codes_left) :-
    Q = o0,
    C = 123,
    !,
    whitespace(Cs, Codes_w_left),
    object_execute(Codes_w_left, Result, Members, Temp, o1, Codes_left).

object_execute([C | Cs], Result, Members, Temp, Q, Codes_left) :-
    Q = o1,
    C \= 125,
    !,
    stringa([C | Cs], Result_stringa, Codes_s_left),
    append(Temp, [Result_stringa], Temp1),
    whitespace(Codes_s_left, Codes_w_left),
    object_execute(Codes_w_left, Result, Members, Temp1, o2, Codes_left).

object_execute([C | Cs], Result, Members, [S | []], Q, Codes_left) :-
    Q = o2,
    C = 58,
    !,
    value(Cs, Result_value, Codes_v_left),
    Pair = (S, Result_value),
    append(Members, [Pair], Members1),
    object_execute(Codes_v_left, Result, Members1, [], o3, Codes_left).

object_execute([C | Cs], Result, Members, Temp, Q, Codes_left) :-
    Q = o3,
    C = 44,
    !,
    whitespace(Cs, Codes_w_left),
    stringa(Codes_w_left, Result_stringa, Codes_s_left),
    append(Temp, [Result_stringa], Temp1),
    whitespace(Codes_s_left, Codes_w1_left),
    object_execute(Codes_w1_left, Result, Members, Temp1, o2, Codes_left).

object_execute([C | Cs], Result, Members, _Temp, Q, Cs) :-
    final_state_obj(Q),
    C = 125,
    !,
    Result =.. [jsonobj, Members].

/*
 * fine predicato object
*/

/*
 * inizio predicato array per
 * riconoscimento array json
*/

array(Codes_in, Result, Codes_left) :-
    array_execute(Codes_in, Result, [], a0, Codes_left).

array_execute([C | Cs], Result, Elements, Q, Codes_left) :-
    Q = a0,
    C = 91,
    !,
    whitespace(Cs, Codes_w_left),
    array_execute(Codes_w_left, Result, Elements, a1, Codes_left).

array_execute([C | Cs], Result, Elements, Q, Codes_left) :-
    Q = a1,
    C \= 93,
    !,
    value([C | Cs], Result_value, Codes_v_left),
    append(Elements, [Result_value], Elements1),
    array_execute(Codes_v_left, Result, Elements1, a2, Codes_left).

array_execute([C | Cs], Result, Elements, Q, Codes_left) :-
    Q = a2,
    C = 44,
    !,
    value(Cs, Result_value, Codes_v_left),
    append(Elements, [Result_value], Elements1),
    array_execute(Codes_v_left, Result, Elements1, a2, Codes_left).

array_execute([C | Cs], Result, Elements, Q, Cs) :-
    final_state_array(Q),
    C = 93,
    !,
    Result =.. [jsonarray, Elements].

/*
 * fine predicato array
*/

/*
 * inizio predicato whitespace per rimozione
 * caratteri di spaziatura da una lista
 * di codici di caratteri in input
*/

whitespace([], []).

whitespace([C | Cs], Codes_left) :-
    whitespace_acceptable(C),
    !,
    whitespace(Cs, Codes_left).

whitespace([C | Cs], [C | Cs]).

/*
 * fine predicato whitespace
*/

/*
 * inizio predicati per riconoscimento valori
 * elementari true, false e null
*/

true([116, 114, 117, 101 | Cs], true, Cs).

false([102, 97, 108, 115, 101 | Cs], false, Cs).

null([110, 117, 108, 108 | Cs], null, Cs).

/*
 * fine predicati per riconoscimento valori elementari
*/

/*
 * inizio predicato per riconoscimento numeri
*/

numero(Codes_in, Result, Codes_left) :-
    numero_execute(Codes_in, Result, '', Codes_left).

numero_execute([], Result, Temp, []) :-
    atom_to_term(Temp, Term, _),
    number(Term),
    Result = Term.

numero_execute([C | Cs], Result, Temp, Codes_left) :-
    number_acceptable(C),
    !,
    atom_codes(Atom, [C]),
    atom_concat(Temp, Atom, Temp1),
    numero_execute(Cs, Result, Temp1, Codes_left).

numero_execute([C | Cs], Result, Temp, [C | Cs]) :-
    atom_to_term(Temp, Term, _),
    number(Term),
    Result = Term.

/*
 * fine predicato per riconoscimento numeri
*/

/*
 * inizio predicato per riconoscimento stringhe
*/

stringa(Codes_in, Result, Codes_left) :-
    stringa_execute(Codes_in, Result, '', s0, Codes_left).

stringa_execute([C | Cs], Result, Temp, Q, Codes_left) :-
    Q = s0,
    C = 34,
    !,
    atom_concat(Temp, '"', Temp1),
    stringa_execute(Cs, Result, Temp1, s1, Codes_left).

stringa_execute([C | Cs], Result, Temp, Q, Codes_left) :-
    Q = s1,
    C \= 34,
    !,
    atom_codes(Atom, [C]),
    atom_concat(Temp, Atom, Temp1),
    stringa_execute(Cs, Result, Temp1, s1, Codes_left).

stringa_execute([C | Cs], Result, Temp, Q, Cs) :-
    Q = s1,
    C = 34,
    !,
    atom_concat(Temp, '"', Temp1),
    atom_to_term(Temp1, Term, _),
    string(Term),
    Result = Term.

/*
 * fine predicato per riconoscimento stringhe
*/

/*
 * inizio predicato jsonobj
*/

jsonobj(Members, Trad_in, Trad_out) :-
    atom(Trad_in),
    atom_concat(Trad_in, '{', Temp),
    jsonobj_execute(Members, Temp, Trad_out).

jsonobj_execute([P | Ps], Trad_in, Trad_out) :-
    traduzione_pair(P, Trad_in, Temp),
    verifica_virgola([P | Ps], Virgola),
    atom_concat(Temp, Virgola, Temp1),
    jsonobj_execute(Ps, Temp1, Trad_out).

jsonobj_execute([], Trad_in, Trad_out) :-
    atom_concat(Trad_in, '}', Trad_out).

/*
 * fine predicato jsonobj
*/

/*
 * inizio predicato jsonarray
*/

jsonarray(Elements, Trad_in, Trad_out) :-
    atom(Trad_in),
    atom_concat(Trad_in, '[', Temp),
    jsonarray_execute(Elements, Temp, Trad_out).

jsonarray_execute([E | Es], Trad_in, Trad_out) :-
    caso_base(E),
    !,
    term_to_atom(E, Atom),
    verifica_virgola([E | Es], Virgola),
    atom_concat(Trad_in, Atom, Temp),
    atom_concat(Temp, Virgola, Temp1),
    jsonarray_execute(Es, Temp1, Trad_out).

jsonarray_execute([E | Es], Trad_in, Trad_out) :-
    compound(E),
    !,
    E =.. Temp,
    append(Temp, [Trad_in], Temp1),
    append(Temp1, [Trad], Temp2),
    Temp2 = [X | _],
    chiamabile(X),
    Predicate =.. Temp2,
    call(Predicate),
    verifica_virgola([E | Es], Virgola),
    atom_concat(Trad, Virgola, Temp3),
    jsonarray_execute(Es, Temp3, Trad_out).

jsonarray_execute([], Trad_in, Trad_out) :-
    atom_concat(Trad_in, ']', Trad_out).

/*
 * fine predicato jsonarray
*/

/*
 * inizio predicato traduzione pair
*/

traduzione_pair((Key, Value), Trad_in, Trad_out) :-
    atom(Trad_in),
    string(Key),
    term_to_atom(Key, Atom),
    atom_concat(Trad_in, Atom, Temp),
    atom_concat(Temp, ' : ', Temp1),
    traduzione_pair_execute(Value, Temp1, Trad_out).

traduzione_pair_execute(Value, Trad_in, Trad_out) :-
    caso_base(Value),
    !,
    term_to_atom(Value, Atom),
    atom_concat(Trad_in, Atom, Trad_out).

traduzione_pair_execute(Value, Trad_in, Trad_out) :-
    compound(Value),
    !,
    Value =.. Temp,
    append(Temp, [Trad_in], Temp1),
    append(Temp1, [Trad_out], Temp2),
    Temp2 = [X | _],
    chiamabile(X),
    Predicate =.. Temp2,
    call(Predicate).

/*
 * fine predicato traduzione pair
*/

/*
 * inizio predicato jsondump per scrittura su file
*/

jsondump(JSON, FileName) :-
    atomo_o_stringa(FileName),
    jsonparse(JSONString, JSON),
    atom_string(JSONString, Stringa),
    open(FileName, write, Out),
    write(Out, Stringa),
    close(Out).

/*
 * fine predicato jsondump
*/

/*
 * inizio predicato jsonread per lettura da file
*/

jsonread(FileName, JSON) :-
    atomo_o_stringa(FileName),
    exists_file(FileName),
    read_file_to_string(FileName, Stringa, []),
    jsonparse(Stringa, JSON).

/*
 * fine predicato jsonread
*/

/*
 * inizio predicato elemento_i_esimo per
 * estrarre un valore a un dato indice di
 * una lista
*/

elemento_i_esimo(List, Index, Result) :-
    number(Index),
    elemento_i_esimo_execute(List, Index, Result).

elemento_i_esimo_execute([_ | Is], Index, Result) :-
    Index > 0,
    !,
    X is Index - 1,
    elemento_i_esimo_execute(Is, X, Result).

elemento_i_esimo_execute([I | _], 0, I).

/*
 * fine predicato elemento_i_esimo
*/

/*
 * inizio predicati utils
*/

%inizio

final_state_obj(o1).
final_state_obj(o3).

%fine
%inizio

final_state_array(a1).
final_state_array(a2).

%fine
%inizio

whitespace_acceptable(32). %spazio
whitespace_acceptable(10). %\n
whitespace_acceptable(13). %\r
whitespace_acceptable(9).  %\t

%fine
%inizio

number_acceptable(Code) :-
    Code >= 48,
    Code =< 57,
    !.

number_acceptable(43).  %+
number_acceptable(45).  %-
number_acceptable(46).  %.
number_acceptable(69).  %E
number_acceptable(101). %e

%fine
%inizio

chiamabile(jsonobj).
chiamabile(jsonarray).

%fine
%inizio

valore_base(true).
valore_base(false).
valore_base(null).

%fine
%inizio

verifica_virgola([_ | Xs], '') :-
    Xs = [],
    !.

verifica_virgola([_ | _], ', ').

%fine
%inizio

caso_base(X) :-
    not(caso_base_execute(X)).

caso_base_execute(X) :-
    not(valore_base(X)),
    not(string(X)),
    not(number(X)).

%fine
%inizio

atomo_o_stringa(X) :-
    not(atomo_o_stringa_execute(X)).

atomo_o_stringa_execute(X) :-
    not(atom(X)),
    not(string(X)).

%fine

/*
 * fine predicati utils
*/


/*
POSSIBILE ERRORE:
in jsonaccess(jsonarray......) prende solamente input del tipo: Field
[1], non quelli dove Field = 1.
Cos� come nel pdf.
Chiedere delucidazioni a Fabio.
*/


/*
CAMBIAMENTO: TOLTO SUDDIVIDI FIELD CHE, A PARTE DARMI ERRORE (NON HO
INDAGATO OLTRE) NON SERVIVA A NULLA IN QUANTO NEL CASO IN CUI
FIELD SIA UNA STRINGA SWI PROLOG CONTIENE UN SOLO ELEMENTO.
AD ESEMPIO: "nome".
E NON: "nome, cognome, arthur, 0, 2, ecc..."
DI CONSEGUENZA ANCHE SPLIT_CODICE E' UN PREDICATO INUTILE.
PER QUESTO SONO STATI ELIMINATI DA QUESTO FILE.
*/




/*

jsonaccess prende in input un jsonobject o un jsonarray e seguendo il
contenuto di Field (lista, stringa o numero) restituisce un risultato.

*/



%JSONACCESS CON ARRAY
% Se in input ho un jsonarray, Field pu� essere solo un numero che
% indica l'indice dell'array dal quale estrarre il valore.
% Nel caso iterativo, viene chiamato elemento_i_esimo per cercare dentro
% l'array.


jsonaccess(jsonarray(_), [], _) :- false.
jsonaccess(jsonarray(Elements), [Field], Risultato) :- elemento_i_esimo(jsonarray(Elements), Field, Risultato).


/*
jsonobject contiene una lista di coppie.
In questo caso Field � una stringa o una lista.
*/

%JSONACCESS CON OBJECT - FIELD E' UNA LISTA
% Quando Field � una lista, pu� contenere stringhe e/o numeri.
% Prendo il primo elemento della lista Field e lo metto a confronto con
% la chiave della prima coppia dell'ogetto json.
% Se si trova una coppia json che unifica con Field, il valore
% ritornato:
% 1 CASO: E' un valore atomico (numero, stringa, true/false/null).
% Allora questi viene restituito come risultato finale.
% 2 CASO: E' un valore composto (jsonobject, jsonarray). Applico a
% quest'ultimo il predicato jsonaccess (ricorsione).
% Quando la lista � vuota viene restituito il risultato (caso base).
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
% Se Field � una stringa complessa (ossia contiene pi� elementi, ad
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
% Quando la stringa � vuota viene restituito il risultato (caso base).


%Caso base:
jsonaccess(jsonobj(Members), "", jsonobj(Members)).
jsonaccess(jsonobj(Members), " ", jsonobj(Members)).


%Caso iterativo - 1 CASO:
%Field � una stringa che contiene una chiave sola
jsonaccess(jsonobj(Members), Field, Risultato) :-
    estrai_valore(Members, Field, ParaRisultato),
    valore_base(ParaRisultato),
    Risultato = ParaRisultato.



%  jsonobj([(�nome�, �Arthur�), (�cognome�, jsonarray[1, 2, 3])])
%  ObjectList = [(�nome�, �Arthur�), (�cognome�, jsonarray[1, 2, 3])]
%  Fields = ["cognome", 1].



%PARTE PREDICATI UTILS

% Composto restituisce true se il valore passato � un jsonobject o un
% jsonarray.
composto(jsonobj(_)).
composto(jsonarray(_)).

% valore_base restituisce true se il valore passato � una stringa, un
% numero o � un true/false/null.

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
% Il valore restituito � il valore della coppia (Chiave, Valore) quando
% Chiave = Field.
%Quando questo non succede, si passa alla coppia successiva.
estrai_valore([], _, _) :- fail.
estrai_valore([(Chiave, Valore) | _], Chiave, Valore) :- !.

estrai_valore([(Chiave, _) | AltreCoppie], Field, Valore) :-
    string(Field),
    Field \= Chiave,
    estrai_valore(AltreCoppie, Field, Valore).


%FINE PREDICATI UTILS




%AGGIORNAMENTO


/*

jsonaccess prende in input un jsonobject o un jsonarray e seguendo il
contenuto di Field (lista, stringa o numero) restituisce un risultato.

*/


jsonaccess(Jsonobj, Fields, Result) :-
    jsonaccess_execute(Jsonobj, [Fields], Result).

jsonaccess(Jsonobj, Field, Result) :-
    jsonaccess_execute(Jsonobj, [Field], Result).


%JSONACCESS CON ARRAY
% Se in input ho un jsonarray, Field pu� essere solo un numero che
% indica l'indice dell'array dal quale estrarre il valore.
% Nel caso iterativo, viene chiamato elemento_i_esimo per cercare dentro
% l'array.


jsonaccess_execute(jsonarray(_), [], _) :- false.
jsonaccess_execute(jsonarray(Elements), [Field], Risultato) :- elemento_i_esimo(jsonarray(Elements), Field, Risultato).


/*
jsonobject contiene una lista di coppie.
In questo caso Field � una stringa o una lista.
*/

%JSONACCESS CON OBJECT - FIELD E' UNA LISTA
% Quando Field � una lista, pu� contenere stringhe e/o numeri.
% Prendo il primo elemento della lista Field e lo metto a confronto con
% la chiave della prima coppia dell'ogetto json.
% Se si trova una coppia json che unifica con Field, il valore
% ritornato:
% 1 CASO: E' un valore atomico (numero, stringa, true/false/null).
% Allora questi viene restituito come risultato finale.
% 2 CASO: E' un valore composto (jsonobject, jsonarray). Applico a
% quest'ultimo il predicato jsonaccess (ricorsione).
% Quando la lista � vuota viene restituito il risultato (caso base).
%VEDERE MEGLIO IL CASO BASE E CAMBIARE IL MODELLO ITERATIVO NEL CASO.



%Caso base:
jsonaccess_execute(jsonobj(Members), [], jsonobj(Members)).


%Caso iterativo - 1 CASO:
jsonaccess_execute(jsonobj(Members), [Field | []], RisultatoFinale) :-
    estrai_valore(Members, Field, Risultato),
    caso_base(Risultato),
    !,
    RisultatoFinale = Risultato.


%Caso iterativo - 2 CASO:
jsonaccess_execute(jsonobj(Members), [Field | Fields], RisultatoFinale) :-
    estrai_valore(Members, Field, Risultato),
    compound(Risultato),
    !,
    jsonaccess(Risultato, Fields, RisultatoFinale).



%JSONACCESS CON OBJECT - FIELD E' UNA STRINGA
% Se Field � una stringa complessa (ossia contiene pi� elementi, ad
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
% Quando la stringa � vuota viene restituito il risultato (caso base).



%PARTE PREDICATI UTILS

% estrai_valore riceve in input una lista di coppie (Chiave,Valore)
% appartententi ad un jsonobject, e restituisce come risultato il valore
% della coppia.
% Il valore restituito � il valore della coppia (Chiave, Valore) quando
% Chiave = Field.
%Quando questo non succede, si passa alla coppia successiva.
estrai_valore([], _, _) :- fail.
estrai_valore([(Chiave, Valore) | _], Chiave, Valore) :- !.

estrai_valore([(Chiave, _) | AltreCoppie], Field, Valore) :-
    string(Field),
    Field \= Chiave,
    estrai_valore(AltreCoppie, Field, Valore).


%FINE PREDICATI UTILS
