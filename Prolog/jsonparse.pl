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
    nonvar(Object),
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
    riconosci_e_traduci_execute(Codes_w_left, Result).

riconosci_e_traduci_execute([C | Cs], Result) :-
    C = 123,
    !,
    object([C | Cs], Result, Codes_o_left),
    whitespace(Codes_o_left, []).

riconosci_e_traduci_execute([C | Cs], Result) :-
    C = 91,
    !,
    array([C | Cs], Result, Codes_a_left),
    whitespace(Codes_a_left, []).

/*
 * fine predicato riconosci_e_traduci
*/

/*
 * inizio predicato value per riconoscimento
 * valori json
*/

value(Codes_in, Result, Codes_left) :-
    whitespace(Codes_in, Codes_w_left),
    value_execute(Codes_w_left, Result, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 123,
    !,
    object([C | Cs], Result, Codes_o_left),
    whitespace(Codes_o_left, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 91,
    !,
    array([C | Cs], Result, Codes_a_left),
    whitespace(Codes_a_left, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 116,
    !,
    true([C | Cs], Result, Codes_t_left),
    whitespace(Codes_t_left, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 102,
    !,
    false([C | Cs], Result, Codes_f_left),
    whitespace(Codes_f_left, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 110,
    !,
    null([C | Cs], Result, Codes_n_left),
    whitespace(Codes_n_left, Codes_left).

value_execute([C | Cs], Result, Codes_left) :-
    C = 34,
    !,
    stringa([C | Cs], Result, Codes_s_left),
    whitespace(Codes_s_left, Codes_left).

value_execute(Codes_in, Result, Codes_left) :-
    numero(Codes_in, Result, Codes_nu_left),
    whitespace(Codes_nu_left, Codes_left).

/*
 * fine predicato value
*/

/*
 * inizio predicato object per
 * riconoscimento oggetti json
*/

object(Codes_in, Result, Codes_left) :-
    object_execute(Codes_in, Result, [], '', o0, Codes_left).

object_execute([C | Cs], Result, Members, Temp, Q, Codes_left) :-
    Q = o0,
    C = 123,
    !,
    whitespace(Cs, Codes_w_left),
    object_execute(Codes_w_left, Result, Members, Temp, o1, Codes_left).

object_execute([C | Cs], Result, Members, _Temp, Q, Codes_left) :-
    Q = o1,
    C = 125,
    !,
    Result =.. [jsonobj, Members],
    Codes_left = Cs.

object_execute([C | Cs], Result, Members, Temp, Q, Codes_left) :-
    Q = o1,
    C \= 125,
    !,
    stringa([C | Cs], Result_stringa, Codes_s_left),
    term_to_atom(Result_stringa, Atom),
    atom_concat(Temp, Atom, Temp1),
    whitespace(Codes_s_left, Codes_w_left),
    object_execute(Codes_w_left, Result, Members, Temp1, o2, Codes_left).

object_execute([C | Cs], Result, Members, Temp, Q, Codes_left) :-
    Q = o2,
    C = 58,
    !,
    atom_concat(Temp, ',', Temp1),
    value(Cs, Result_value, Codes_v_left),
    term_to_atom(Result_value, Atom),
    atom_concat(Temp1, Atom, Temp2),
    atom_to_term(Temp2, Term, _),
    append(Members, [Term], Members1),
    object_execute(Codes_v_left, Result, Members1, '', o3, Codes_left).

object_execute([C | Cs], Result, Members, _Temp, Q, Codes_left) :-
    Q = o3,
    C = 125,
    !,
    Result =.. [jsonobj, Members],
    Codes_left = Cs.

object_execute([C | Cs], Result, Members, Temp, Q, Codes_left) :-
    Q = o3,
    C = 44,
    !,
    whitespace(Cs, Codes_w_left),
    stringa(Codes_w_left, Result_stringa, Codes_s_left),
    term_to_atom(Result_stringa, Atom),
    atom_concat(Temp, Atom, Temp1),
    whitespace(Codes_s_left, Codes_w1_left),
    object_execute(Codes_w1_left, Result, Members, Temp1, o2, Codes_left).

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
    C = 93,
    !,
    Result =.. [jsonarray, Elements],
    Codes_left = Cs.

array_execute([C | Cs], Result, Elements, Q, Codes_left) :-
    Q = a1,
    C \= 93,
    !,
    value([C | Cs], Result_value, Codes_v_left),
    append(Elements, [Result_value], Elements1),
    array_execute(Codes_v_left, Result, Elements1, a2, Codes_left).

array_execute([C | Cs], Result, Elements, Q, Codes_left) :-
    Q = a2,
    C = 93,
    !,
    Result =.. [jsonarray, Elements],
    Codes_left = Cs.

array_execute([C | Cs], Result, Elements, Q, Codes_left) :-
    Q = a2,
    C = 44,
    !,
    value(Cs, Result_value, Codes_v_left),
    append(Elements, [Result_value], Elements1),
    array_execute(Codes_v_left, Result, Elements1, a2, Codes_left).

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

whitespace([C | Cs], Codes_left) :-
    not(whitespace_acceptable(C)),
    !,
    Codes_left = [C | Cs].

whitespace_acceptable(32). %spazio
whitespace_acceptable(10). %\n
whitespace_acceptable(13). %\r
whitespace_acceptable(9).  %\t

/*
 * fine predicato whitespace
*/

/*
 * inizio predicati per riconoscimento valori
 * elementari true, false e null
*/

true([A, B, C, D | Cs], Result, Codes_left) :-
    atom_codes('true', [A, B, C, D]),
    Result = true,
    Codes_left = Cs.

false([A, B, C, D, E | Cs], Result, Codes_left) :-
    atom_codes('false', [A, B, C, D, E]),
    Result = false,
    Codes_left = Cs.

null([A, B, C, D | Cs], Result, Codes_left) :-
    atom_codes('null', [A, B, C, D]),
    Result = null,
    Codes_left = Cs.

/*
 * fine predicati per riconoscimento valori elementari
*/

/*
 * inizio predicato per riconoscimento numeri
*/

numero(Codes_in, Result, Codes_left) :-
    numero_execute(Codes_in, Result, '', Codes_left).

numero_execute([], Result, Temp, Codes_left) :-
    atom_to_term(Temp, Term, _),
    number(Term),
    Result = Term,
    Codes_left = [].

numero_execute([C | Cs], Result, Temp, Codes_left) :-
    number_acceptable(C),
    !,
    atom_codes(Atom, [C]),
    atom_concat(Temp, Atom, Temp1),
    numero_execute(Cs, Result, Temp1, Codes_left).

numero_execute([C | Cs], Result, Temp, Codes_left) :-
    not(number_acceptable(C)),
    !,
    atom_to_term(Temp, Term, _),
    number(Term),
    Result = Term,
    Codes_left = [C | Cs].

number_acceptable(43).  %+
number_acceptable(45).  %-
number_acceptable(46).  %.
number_acceptable(69).  %E
number_acceptable(101). %e
number_acceptable(Code) :-
    Code >= 48,
    Code =< 57.

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

stringa_execute([C | Cs], Result, Temp, Q, Codes_left) :-
    Q = s1,
    C = 34,
    !,
    atom_concat(Temp, '"', Temp1),
    atom_to_term(Temp1, Term, _),
    string(Term),
    Result = Term,
    Codes_left = Cs.

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
    traduzione_pair(P, Trad_in, Trad),
    verifica_virgola([P | Ps], Virgola),
    atom_concat(Trad, Virgola, Temp),
    jsonobj_execute(Ps, Temp, Trad_out).

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
    jsonarray_caso_base(E),
    !,
    term_to_atom(E, Atom),
    verifica_virgola([E | Es], Virgola),
    atom_concat(Trad_in, Atom, Temp),
    atom_concat(Temp, Virgola, Temp1),
    jsonarray_execute(Es, Temp1, Trad_out).

jsonarray_execute([E | Es], Trad_in, Trad_out) :-
    string(E),
    !,
    atom_string(Atom, E),
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

traduzione_pair(Pair, Trad_in, Trad_out) :-
    atom(Trad_in),
    term_to_atom(Pair, Atom),
    atom_codes(Atom, Code_list),
    stringa(Code_list, Result, Codes_left),
    Codes_left = [44 | Cs],
    term_to_atom(Result, Atom1),
    atom_concat(Trad_in, Atom1, Temp),
    atom_concat(Temp, ' : ', Temp1),
    atom_codes(Atom2, Cs),
    atom_to_term(Atom2, Term, []),
    traduzione_pair_execute(Term, Temp1, Trad_out).

traduzione_pair_execute(Term, Trad_in, Trad_out) :-
    traduzione_pair_caso_base(Term),
    !,
    term_to_atom(Term, Atom),
    atom_concat(Trad_in, Atom, Trad_out).

traduzione_pair_execute(Term, Trad_in, Trad_out) :-
    compound(Term),
    !,
    Term =.. Temp,
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
    compound(JSON),
    atomo_o_stringa(FileName),
    jsonparse(JSONString, JSON),
    term_string(JSONString, Stringa),
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
 * inizio predicati utils
*/

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

verifica_virgola([_ | Xs], Result) :-
    Xs = [],
    !,
    Result = ''.

verifica_virgola([_ | Xs], Result) :-
    Xs \= [],
    !,
    Result = ', '.

%fine
%inizio

elemento_i_esimo(List, Index, Result) :-
    number(Index),
    elemento_i_esimo_execute(List, Index, Result).

elemento_i_esimo_execute([I | _], Index, Result) :-
    Index = 0,
    !,
    Result = I.

elemento_i_esimo_execute([_ | Is], Index, Result) :-
    Index > 0,
    !,
    X is Index - 1,
    elemento_i_esimo_execute(Is, X, Result).

%fine
%inizio

jsonarray_caso_base(X) :-
    valore_base(X),
    !.

jsonarray_caso_base(X) :-
    number(X),
    !.

%fine
%inizio

atomo_o_stringa(X) :-
    atom(X),
    !.

atomo_o_stringa(X) :-
    string(X),
    !.

%fine
%inizio

traduzione_pair_caso_base(X) :-
    valore_base(X),
    !.

traduzione_pair_caso_base(X) :-
    number(X),
    !.

traduzione_pair_caso_base(X) :-
    string(X),
    !.

%fine

/*
 * fine predicati utils
*/
