% test_rdb_basic.plt - Basic CRUD operation tests for rocks_preds
:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

:- begin_tests(rdb_open_close, [cleanup(cleanup_test_db(basic))]).

test(open_two_args, [setup(cleanup_test_db(basic))]) :-
    rdb_open('dbs/test_basic', DB),
    assertion(blob(DB, _)),
    rdb_close('dbs/test_basic').

test(open_three_args, [setup(cleanup_test_db(basic2))]) :-
    rdb_open('dbs/test_basic2', DB, []),
    assertion(blob(DB, _)),
    rdb_close('dbs/test_basic2').

test(close_default, [setup(cleanup_test_db(basic3))]) :-
    rdb_open('dbs/test_basic3', _),
    rdb_close.

test(close_specific, [setup(cleanup_test_db(basic4))]) :-
    rdb_open('dbs/test_basic4', _),
    rdb_close('dbs/test_basic4').

test(multiple_dbs, [setup((cleanup_test_db(db1), cleanup_test_db(db2)))]) :-
    rdb_open('dbs/test_db1', DB1),
    rdb_open('dbs/test_db2', DB2),
    assertion(DB1 \= DB2),
    rdb_assertz('dbs/test_db1', fact1(a)),
    rdb_assertz('dbs/test_db2', fact2(b)),
    rdb_clause('dbs/test_db1', fact1(a), true),
    rdb_clause('dbs/test_db2', fact2(b), true),
    rdb_close('dbs/test_db1'),
    rdb_close('dbs/test_db2').

:- end_tests(rdb_open_close).

:- begin_tests(rdb_assertz, [setup(setup_test_db(assertz)), cleanup(cleanup_test_db(assertz))]).

test(assertz_one_arg) :-
    rdb_assertz(person(john)),
    rdb_clause(person(john), true).

test(assertz_two_args) :-
    rdb_assertz('dbs/test_assertz', person(mary)),
    rdb_clause('dbs/test_assertz', person(mary), true).

test(assertz_complex) :-
    rdb_assertz('dbs/test_assertz', parent(john, bob, [age(10), gender(male)])),
    rdb_clause('dbs/test_assertz', parent(john, bob, Meta), true),
    memberchk(age(10), Meta).

test(assertz_rule) :-
    rdb_assertz('dbs/test_assertz', (grandparent(X,Z) :- parent(X,Y), parent(Y,Z))),
    rdb_clause('dbs/test_assertz', grandparent(_,_), Body),
    assertion(Body \= true).

test(assertz_multiple) :-
    rdb_assertz('dbs/test_assertz', num(1)),
    rdb_assertz('dbs/test_assertz', num(2)),
    rdb_assertz('dbs/test_assertz', num(3)),
    findall(X, rdb_clause('dbs/test_assertz', num(X), true), Nums),
    assertion(Nums = [1,2,3]).

:- end_tests(rdb_assertz).

:- begin_tests(rdb_retract, [setup(setup_test_db(retract)), cleanup(cleanup_test_db(retract))]).

test(retract_one_arg) :-
    rdb_assertz(temp(data)),
    rdb_retract(temp(data)),
    assertion(\+ rdb_clause(temp(data), true)).

test(retract_two_args) :-
    rdb_assertz('dbs/test_retract', temp(data)),
    rdb_retract('dbs/test_retract', temp(data)),
    assertion(\+ rdb_clause('dbs/test_retract', temp(data), true)).

test(retract_pattern) :-
    rdb_assertz('dbs/test_retract', item(a, 1)),
    rdb_assertz('dbs/test_retract', item(b, 2)),
    rdb_assertz('dbs/test_retract', item(c, 3)),
    rdb_retract('dbs/test_retract', item(b, _)),
    !,
    findall(X, rdb_clause('dbs/test_retract', item(X, _), true), Items),
    assertion(Items = [a,c]).

test(retract_unify) :-
    rdb_assertz('dbs/test_retract', value(test)),
    rdb_retract('dbs/test_retract', value(X)),
    assertion(X == test).

:- end_tests(rdb_retract).

:- begin_tests(rdb_retractall, [setup(setup_test_db(retractall)), cleanup(cleanup_test_db(retractall))]).

test(retractall_one_arg) :-
    rdb_assertz(multi(1)),
    rdb_assertz(multi(2)),
    rdb_assertz(multi(3)),
    rdb_retractall(multi(_)),
    assertion(\+ rdb_clause(multi(_), true)).

test(retractall_two_args) :-
    rdb_assertz('dbs/test_retractall', multi(a)),
    rdb_assertz('dbs/test_retractall', multi(b)),
    rdb_assertz('dbs/test_retractall', multi(c)),
    rdb_retractall('dbs/test_retractall', multi(_)),
    assertion(\+ rdb_clause('dbs/test_retractall', multi(_), true)).

test(retractall_partial) :-
    rdb_assertz('dbs/test_retractall', pair(a,1)),
    rdb_assertz('dbs/test_retractall', pair(a,2)),
    rdb_assertz('dbs/test_retractall', pair(b,3)),
    rdb_retractall('dbs/test_retractall', pair(a,_)),
    findall(X-Y, rdb_clause('dbs/test_retractall', pair(X,Y), true), Pairs),
    assertion(Pairs = [b-3]).

:- end_tests(rdb_retractall).
