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
    applica(Object, "", JSONString).

/*
 * fine predicato jsonparse
*/

/*
 * inizio predicato riconosci_e_traduci per riconoscimento
 * oggetti o array json
*/

riconosci_e_traduci(Code_list, Result) :-
    whitespace(Code_list, Codes_w_left),
    riconosci_e_traduci_execute(Codes_w_left, Result, Codes_left),
    whitespace(Codes_left, []).

riconosci_e_traduci_execute([C | Cs], Result, Codes_left) :-
    C = 123,
    !,
    object([C | Cs], Result, Codes_left).

riconosci_e_traduci_execute([C | Cs], Result, Codes_left) :-
    array([C | Cs], Result, Codes_left).

/*
 * fine predicato riconosci_e_traduci per riconoscimento
 * oggetti o array json
*/

/*
 * inizio predicato value per riconoscimento
 * valori json
*/

value(Codes_in, Result, Codes_left) :-
    whitespace(Codes_in, Codes_w_left),
    value_execute(Codes_w_left, Result, Codes_v_left),
    whitespace(Codes_v_left, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 123,
    !,
    object([C | Cs], Result, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 91,
    !,
    array([C | Cs], Result, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 116,
    !,
    true([C | Cs], Result, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 102,
    !,
    false([C | Cs], Result, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 110,
    !,
    null([C | Cs], Result, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 34,
    !,
    stringa([C | Cs], Result, Codes_left).

value_execute(Codes_in, Result, Codes_left) :-
    numero(Codes_in, Result, Codes_left).

/*
 * fine predicato value per riconoscimento
 * valori json
*/

/*
 * inizio predicato object per
 * riconoscimento oggetti json
*/

object(Codes_in, Result, Codes_left) :-
    object_execute(Codes_in, Result, [], "", o0, Codes_left).

object_execute([C | Cs], Result, Members, Temp, Q, Codes_left) :-
    Q = o0,
    C = 123,
    !,
    whitespace(Cs, Codes_w_left),
    object_execute(Codes_w_left, Result, Members, Temp, o1, Codes_left).

object_execute([C | Cs], Result, Members, _Temp, Q, Codes_left) :-
    Q = o1,
    C = 34,
    !,
    stringa([C | Cs], Result_s, Codes_s_left),
    whitespace(Codes_s_left, Codes_w_left),
    object_execute(Codes_w_left, Result, Members, Result_s, o2, Codes_left).

object_execute([C | Cs], Result, Members, Temp, Q, Codes_left) :-
    Q = o2,
    C = 58,
    !,
    value(Cs, Result_v, Codes_v_left),
    Pair = (Temp, Result_v),
    append(Members, [Pair], Members1),
    object_execute(Codes_v_left, Result, Members1, "", o3, Codes_left).

object_execute([C | Cs], Result, Members, _Temp, Q, Codes_left) :-
    Q = o3,
    C = 44,
    !,
    whitespace(Cs, Codes_w_left),
    stringa(Codes_w_left, Result_s, Codes_s_left),
    whitespace(Codes_s_left, Codes_w1_left),
    object_execute(Codes_w1_left, Result, Members, Result_s, o2, Codes_left).

object_execute([C | Cs], Result, Members, _Temp, Q, Cs) :-
    final_state_obj(Q),
    C = 125,
    !,
    Result =.. [jsonobj, Members].

/*
 * fine predicato object per
 * riconoscimento oggetti json
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
    value([C | Cs], Result_v, Codes_v_left),
    append(Elements, [Result_v], Elements1),
    array_execute(Codes_v_left, Result, Elements1, a2, Codes_left).

array_execute([C | Cs], Result, Elements, Q, Codes_left) :-
    Q = a2,
    C = 44,
    !,
    value(Cs, Result_v, Codes_v_left),
    append(Elements, [Result_v], Elements1),
    array_execute(Codes_v_left, Result, Elements1, a2, Codes_left).

array_execute([C | Cs], Result, Elements, Q, Cs) :-
    final_state_array(Q),
    C = 93,
    !,
    Result =.. [jsonarray, Elements].

/*
 * fine predicato array per
 * riconoscimento array json
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
 * fine predicato whitespace per rimozione
 * caratteri di spaziatura da una lista
 * di codici di caratteri in input
*/

/*
 * inizio predicato stringa per
 * riconoscimento stringhe json
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
 * fine predicato stringa per
 * riconoscimento stringhe json
*/

/*
 * inizio predicato numero per
 * riconoscimento numeri json
*/

numero(Codes_in, Result, Codes_left) :-
    numero_execute(Codes_in, Result, '', nu0, Codes_left).

numero_execute([C | Cs], Result, Temp, Q, Codes_left) :-
    delta_numero(Q, C, N),
    !,
    atom_codes(Atom, [C]),
    atom_concat(Temp, Atom, Temp1),
    numero_execute(Cs, Result, Temp1, N, Codes_left).

numero_execute(Codes, Result, Temp, Q, Codes) :-
    verifica_lista(Codes),
    final_state_number(Q),
    !,
    atom_to_term(Temp, Result, _).

/*
 * fine predicato numero per
 * riconoscimento numeri json
*/

/*
 * inizio predicati true, false e null
 * per riconoscimento valori
 * elementari true, false e null
*/

true([116, 114, 117, 101 | Cs], true, Cs).

false([102, 97, 108, 115, 101 | Cs], false, Cs).

null([110, 117, 108, 108 | Cs], null, Cs).

/*
 * fine predicati true, false e null
 * per riconoscimento valori
 * elementari true, false e null
*/

/*
 * inizio predicato jsonobj per conversione
 * oggetto json da formato object a stringa
*/

jsonobj(Members, Trad_in, Trad_out) :-
    string(Trad_in),
    string_concat(Trad_in, "{", Temp),
    jsonobj_execute(Members, Temp, Trad_out).

jsonobj_execute([P | Ps], Trad_in, Trad_out) :-
    traduzione_pair(P, Trad_in, Temp),
    verifica_virgola([P | Ps], Virgola),
    string_concat(Temp, Virgola, Temp1),
    jsonobj_execute(Ps, Temp1, Trad_out).

jsonobj_execute([], Trad_in, Trad_out) :-
    string_concat(Trad_in, "}", Trad_out).

/*
 * fine predicato jsonobj per conversione
 * oggetto json da formato object a stringa
*/

/*
 * inizio predicato traduzione_pair per
 * conversione coppia di elementi di un
 * jsonobj in una stringa
*/

traduzione_pair((Key, Value), Trad_in, Trad_out) :-
    string(Key),
    term_string(Key, String),
    string_concat(Trad_in, String, Temp),
    string_concat(Temp, " : ", Temp1),
    traduzione_pair_execute(Value, Temp1, Trad_out).

traduzione_pair_execute(Value, Trad_in, Trad_out) :-
    caso_base(Value),
    !,
    term_string(Value, String),
    string_concat(Trad_in, String, Trad_out).

traduzione_pair_execute(Value, Trad_in, Trad_out) :-
    compound(Value),
    !,
    applica(Value, Trad_in, Trad_out).

/*
 * fine predicato traduzione_pair per
 * conversione coppia di elementi di un
 * jsonobj in una stringa
*/

/*
 * inizio predicato jsonarray per conversione
 * array json da formato object a stringa
*/

jsonarray(Elements, Trad_in, Trad_out) :-
    string(Trad_in),
    string_concat(Trad_in, "[", Temp),
    jsonarray_execute(Elements, Temp, Trad_out).

jsonarray_execute([E | Es], Trad_in, Trad_out) :-
    caso_base(E),
    !,
    term_string(E, String),
    verifica_virgola([E | Es], Virgola),
    string_concat(Trad_in, String, Temp),
    string_concat(Temp, Virgola, Temp1),
    jsonarray_execute(Es, Temp1, Trad_out).

jsonarray_execute([E | Es], Trad_in, Trad_out) :-
    compound(E),
    !,
    applica(E, Trad_in, Trad),
    verifica_virgola([E | Es], Virgola),
    string_concat(Trad, Virgola, Temp),
    jsonarray_execute(Es, Temp, Trad_out).

jsonarray_execute([], Trad_in, Trad_out) :-
    string_concat(Trad_in, "]", Trad_out).

/*
 * fine predicato jsonarray per conversione
 * array json da formato object a stringa
*/

/*
 * inizio predicato jsondump per scrittura su file
*/

jsondump(JSON, FileName) :-
    atomo_o_stringa(FileName),
    jsonparse(JSONString, JSON),
    open(FileName, write, Out),
    write(Out, JSONString),
    close(Out).

/*
 * fine predicato jsondump per scrittura su file
*/

/*
 * inizio predicato jsonread per lettura da file
*/

jsonread(FileName, JSON) :-
    atomo_o_stringa(FileName),
    exists_file(FileName),
    read_file_to_string(FileName, JSONString, []),
    jsonparse(JSONString, JSON).

/*
 * fine predicato jsonread per lettura da file
*/

/*
 * inizio predicati utils
*/

% inizio final_state_obj

final_state_obj(o1).
final_state_obj(o3).

% fine final_state_obj
% inizio final_state_array

final_state_array(a1).
final_state_array(a2).

% fine final_state_array
% inizio final_state_number

final_state_number(nu2).
final_state_number(nu4).
final_state_number(nu6).

% fine final_state_number
% inizio delta_numero

delta_numero(nu0, X, nu1) :-
    plus_or_minus(X),
    !.
delta_numero(nu0, X, nu2) :-
    single_digit(X),
    !.
delta_numero(nu1, X, nu2) :-
    single_digit(X),
    !.
delta_numero(nu2, X, nu3) :-
    X = 46,
    !.
delta_numero(nu2, X, nu5) :-
    e_or_E(X),
    !.
delta_numero(nu3, X, nu4) :-
    single_digit(X),
    !.
delta_numero(nu4, X, nu5) :-
    e_or_E(X),
    !.
delta_numero(nu5, X, nu6) :-
    single_digit(X),
    !.
delta_numero(nu5, X, nu7) :-
    plus_or_minus(X),
    !.
delta_numero(nu7, X, nu6) :-
    single_digit(X),
    !.
delta_numero(Q, X, Q) :-
    single_digit(X),
    final_state_number(Q),
    !.

% fine delta_numero
% inizio whitespace_acceptable

whitespace_acceptable(9).  %\t
whitespace_acceptable(10). %\n
whitespace_acceptable(13). %\r
whitespace_acceptable(32). %spazio

% fine whitespace_acceptable
% inizio plus_or_minus

plus_or_minus(43). % +
plus_or_minus(45). % -

% fine plus_or_minus
% inizio e_or_E

e_or_E(69).  % E
e_or_E(101). % e

% fine e_or_E
% inizio single_digit

single_digit(Code) :-
    Code >= 48,
    Code =< 57.

% fine single_digit
% inizio chiamabile

chiamabile(jsonobj).
chiamabile(jsonarray).

% fine chiamabile
% inizio valore_base

valore_base(true).
valore_base(false).
valore_base(null).

% fine valore_base
% inizio verifica_virgola

verifica_virgola([_ | Xs], "") :-
    Xs = [],
    !.

verifica_virgola([_ | _], ", ").

% fine verifica_virgola
% inizio caso_base

caso_base(X) :-
    not(caso_base_execute(X)).

caso_base_execute(X) :-
    not(valore_base(X)),
    not(string(X)),
    not(number(X)).

% fine caso_base
% inizio atomo_o_stringa

atomo_o_stringa(X) :-
    not(atomo_o_stringa_execute(X)).

atomo_o_stringa_execute(X) :-
    not(atom(X)),
    not(string(X)).

% fine atomo_o_stringa
% inizio verifica_lista

verifica_lista([]).
verifica_lista([_ | _]).

% fine verifica_lista
% inizio applica

applica(Jsonobj, Trad_in, Trad_out) :-
    string(Trad_in),
    Jsonobj =.. [X, Y | []],
    chiamabile(X),
    Chiamabile =.. [X, Y, Trad_in, Trad_out],
    call(Chiamabile).

% fine applica

/*
 * fine predicati utils
*/

% AGGIORNAMENTO

/*

jsonaccess prende in input un jsonobject o un jsonarray e seguendo il
contenuto di Fields (lista di stringhe e numeri) o Field (stringa)
restituisce un risultato.

*/

jsonaccess(Jsonobj, Fields, Result) :-
    jsonparse(_JSONString, Jsonobj),
    Jsonobj = jsonarray(_Elements),
    Fields = [],
    !,
    Result = fail,
    fail.

jsonaccess(Jsonobj, Fields, Result) :-
    jsonparse(_JSONString, Jsonobj),
    verifica_lista(Fields),
    !,
    jsonaccess_execute(Jsonobj, Fields, Result).

jsonaccess(Jsonobj, Field, Result) :-
    jsonparse(_JSONString, Jsonobj),
    string(Field),
    !,
    jsonaccess_execute(Jsonobj, [Field], Result).

%JSONACCESS CON ARRAY
% Se in input ho un jsonarray il primo elemento di Fields deve
% essere un intero che corrisponde alla posizione dell'elemento
% da estrarre

jsonaccess_execute(jsonarray(Elements), [Field | Fields], Risultato) :-
    elemento_i_esimo(Elements, Field, Result),
    !,
    jsonaccess_execute(Result, Fields, Risultato).

%JSONACCESS CON OBJECT
% Se in input ho un jsonobj il primo elemento di Fields deve
% essere una stringa che corrisponde alla chiave del valore
% da estrarre nella lista di coppie

jsonaccess_execute(jsonobj(Members), [Field | Fields], RisultatoFinale) :-
    estrai_valore(Members, Field, Risultato),
    !,
    jsonaccess_execute(Risultato, Fields, RisultatoFinale).

%CASO BASE
% Se in input ho un valore e una lista vuota ritorno quel valore

jsonaccess_execute(Jsonobj, [], Jsonobj).

%PARTE PREDICATI UTILS

% estrai_valore riceve in input una lista di coppie (Chiave,Valore)
% appartententi ad un jsonobject e restituisce come risultato il valore
% della coppia.
% Il valore restituito e' il valore della coppia (Chiave, Valore) quando
% Chiave = Field.
% Quando questo non succede, si passa alla coppia successiva.

estrai_valore(Members, Chiave, Valore) :-
    string(Chiave),
    estrai_valore_execute(Members, Chiave, Valore).

estrai_valore_execute([(Chiave, Valore) | _], Chiave, Valore) :-
    !.

estrai_valore_execute([(_Chiave, _Valore) | AltreCoppie], Field, Valore) :-
    estrai_valore_execute(AltreCoppie, Field, Valore).

% elemento_i_esimo riceve in input una lista di valori appartenenti
% ad un jsonarray e restituisce come risultato l'elemento in posizione
% i_esima indicato da Index
% Se Index ha un valore maggiore della dimensione della lista il
% predicato fallisce

elemento_i_esimo(List, Index, Result) :-
    integer(Index),
    Index >= 0,
    elemento_i_esimo_execute(List, Index, Result).

elemento_i_esimo_execute([E | _], 0, E) :-
    !.

elemento_i_esimo_execute([_ | Es], Index, Result) :-
    X is Index - 1,
    elemento_i_esimo_execute(Es, X, Result).

%FINE PREDICATI UTILS
