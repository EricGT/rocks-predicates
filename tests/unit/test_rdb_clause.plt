% test_rdb_clause.plt - Clause query tests for rocks_preds
:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

:- begin_tests(rdb_clause_queries, [setup(setup_test_db(clause)), cleanup(cleanup_test_db(clause))]).

test(clause_unify_head) :-
    rdb_assertz('dbs/test_clause', person(john, 30)),
    rdb_assertz('dbs/test_clause', person(mary, 25)),
    findall(Age, rdb_clause('dbs/test_clause', person(john, Age), true), Ages),
    assertion(Ages = [30]).

test(clause_first_arg_var) :-
    rdb_assertz('dbs/test_clause', parent(john, bob)),
    rdb_assertz('dbs/test_clause', parent(mary, bob)),
    findall(P, rdb_clause('dbs/test_clause', parent(P, bob), true), Parents),
    length(Parents, 2),
    assertion(memberchk(john, Parents)),
    assertion(memberchk(mary, Parents)).

test(clause_all_vars) :-
    rdb_assertz('dbs/test_clause', fact(a,b,c)),
    rdb_assertz('dbs/test_clause', fact(x,y,z)),
    findall(X-Y-Z, rdb_clause('dbs/test_clause', fact(X,Y,Z), true), Facts),
    length(Facts, 2).

test(clause_with_body) :-
    rdb_assertz('dbs/test_clause', (rule(X) :- fact(X), X > 0)),
    rdb_clause('dbs/test_clause', rule(_), Body),
    assertion(Body \= true).

test(clause_backtrack) :-
    rdb_assertz('dbs/test_clause', num(1)),
    rdb_assertz('dbs/test_clause', num(2)),
    rdb_assertz('dbs/test_clause', num(3)),
    findall(X, rdb_clause('dbs/test_clause', num(X), true), Nums),
    assertion(Nums = [1,2,3]).

test(clause_nonexistent) :-
    assertion(\+ rdb_clause('dbs/test_clause', nonexistent(_), true)).

test(clause_two_args) :-
    rdb_assertz(simple(data)),
    rdb_clause(simple(data), true).

test(clause_four_args_cref) :-
    rdb_assertz('dbs/test_clause', tracked(item)),
    rdb_clause('dbs/test_clause', tracked(item), true, CRef),
    assertion(ground(CRef)).

:- end_tests(rdb_clause_queries).

:- begin_tests(rdb_nth_clause, [setup(setup_test_db(nth)), cleanup(cleanup_test_db(nth))]).

test(nth_clause_first) :-
    rdb_assertz('dbs/test_nth', item(a)),
    rdb_assertz('dbs/test_nth', item(b)),
    rdb_assertz('dbs/test_nth', item(c)),
    rdb_nth_clause('dbs/test_nth', item(X), 1, _),
    assertion(X = a).

test(nth_clause_last) :-
    rdb_assertz('dbs/test_nth', item(a)),
    rdb_assertz('dbs/test_nth', item(b)),
    rdb_assertz('dbs/test_nth', item(c)),
    rdb_nth_clause('dbs/test_nth', item(X), 3, _),
    assertion(X = c).

test(nth_clause_enumerate) :-
    rdb_assertz('dbs/test_nth', val(1)),
    rdb_assertz('dbs/test_nth', val(2)),
    rdb_assertz('dbs/test_nth', val(3)),
    findall(N-X, rdb_nth_clause('dbs/test_nth', val(X), N, _), Pairs),
    assertion(Pairs = [1-1, 2-2, 3-3]).

test(nth_clause_three_args) :-
    rdb_assertz(data(test)),
    rdb_nth_clause(data(X), 1, _),
    assertion(X = test).

:- end_tests(rdb_nth_clause).
