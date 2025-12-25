% test_rdb_indexing.plt - Indexing tests for rocks_preds
:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

:- begin_tests(rdb_indexing, [setup(setup_test_db(index)), cleanup(cleanup_test_db(index))]).

test(create_index_first_arg) :-
    rdb_assertz('dbs/test_index', record(a, 1)),
    rdb_assertz('dbs/test_index', record(b, 2)),
    rdb_index('dbs/test_index', record/2, 1),
    rdb_clause('dbs/test_index', record(b, X), true),
    assertion(X = 2).

test(create_index_second_arg) :-
    rdb_assertz('dbs/test_index', pair(x, alpha)),
    rdb_assertz('dbs/test_index', pair(y, beta)),
    rdb_index('dbs/test_index', pair/2, 2),
    rdb_clause('dbs/test_index', pair(Key, beta), true),
    assertion(Key = y).

test(multiple_indexes) :-
    rdb_assertz('dbs/test_index', triple(a, b, c)),
    rdb_index('dbs/test_index', triple/3, 1),
    rdb_index('dbs/test_index', triple/3, 2),
    rdb_index('dbs/test_index', triple/3, 3).

test(index_two_args) :-
    rdb_assertz(data(key, val)),
    rdb_index(data/2, 1),
    rdb_clause(data(key, X), true),
    assertion(X = val).

test(destroy_index) :-
    rdb_assertz('dbs/test_index', data(x, y)),
    rdb_index('dbs/test_index', data/2, 1),
    rdb_destroy_index('dbs/test_index', data/2, 1),
    rdb_clause('dbs/test_index', data(x, y), true).

test(index_performance) :-
    forall(between(1, 1000, N),
           rdb_assertz('dbs/test_index', entry(N, N))),
    statistics(cputime, T0),
    findall(X, rdb_clause('dbs/test_index', entry(500, X), true), _),
    statistics(cputime, T1),
    TimeNoIndex is T1 - T0,
    rdb_index('dbs/test_index', entry/2, 1),
    statistics(cputime, T2),
    findall(Y, rdb_clause('dbs/test_index', entry(500, Y), true), _),
    statistics(cputime, T3),
    TimeWithIndex is T3 - T2,
    format('No index: ~6f, With index: ~6f~n', [TimeNoIndex, TimeWithIndex]).

test(index_after_many_facts) :-
    forall(between(1, 500, N),
           rdb_assertz('dbs/test_index', many(N, N))),
    rdb_index('dbs/test_index', many/2, 1),
    rdb_clause('dbs/test_index', many(250, 250), true).

:- end_tests(rdb_indexing).

:- begin_tests(index_persistence, [setup(setup_test_db(persist_idx)), cleanup(cleanup_test_db(persist_idx))]).

test(index_persists_after_close) :-
    rdb_assertz('dbs/test_persist_idx', item(a, 1)),
    rdb_assertz('dbs/test_persist_idx', item(b, 2)),
    rdb_index('dbs/test_persist_idx', item/2, 1),
    rdb_close('dbs/test_persist_idx'),
    rdb_open('dbs/test_persist_idx', _),
    rdb_clause('dbs/test_persist_idx', item(b, X), true),
    assertion(X = 2).

:- end_tests(index_persistence).
