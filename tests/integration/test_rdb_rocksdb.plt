% test_rdb_rocksdb.plt - Integration tests between rocks_preds and rocksdb
:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

:- begin_tests(integration_layers, [setup(setup_test_db(integ)), cleanup(cleanup_test_db(integ))]).

test(underlying_rocksdb_operations) :-
    rdb_open('dbs/test_integ', DB),
    assertion(blob(DB, _)),
    rdb_assertz('dbs/test_integ', test(data)),
    rdb_close('dbs/test_integ').

test(persistence_integration) :-
    rdb_open('dbs/test_integ', _),
    rdb_assertz('dbs/test_integ', persistent(fact)),
    rdb_close('dbs/test_integ'),
    rdb_open('dbs/test_integ', _),
    rdb_clause('dbs/test_integ', persistent(fact), true),
    rdb_close('dbs/test_integ').

test(data_survives_restart) :-
    rdb_open('dbs/test_integ', _),
    forall(between(1, 100, N),
           rdb_assertz('dbs/test_integ', num(N))),
    rdb_close('dbs/test_integ'),
    rdb_open('dbs/test_integ', _),
    findall(X, rdb_clause('dbs/test_integ', num(X), true), Nums),
    length(Nums, 100),
    rdb_close('dbs/test_integ').

test(index_survives_restart) :-
    rdb_open('dbs/test_integ', _),
    rdb_assertz('dbs/test_integ', indexed(a, 1)),
    rdb_assertz('dbs/test_integ', indexed(b, 2)),
    rdb_index('dbs/test_integ', indexed/2, 1),
    rdb_close('dbs/test_integ'),
    rdb_open('dbs/test_integ', _),
    rdb_clause('dbs/test_integ', indexed(b, X), true),
    assertion(X = 2),
    rdb_close('dbs/test_integ').

test(multiple_predicates) :-
    rdb_assertz('dbs/test_integ', pred1(a)),
    rdb_assertz('dbs/test_integ', pred2(b)),
    rdb_assertz('dbs/test_integ', pred3(c)),
    % Note: This counts ALL predicates including those from previous tests
    % This is acceptable since we're testing that multiple predicates can coexist
    findall(PI, rdb_current_predicate('dbs/test_integ', PI), Preds),
    length(Preds, NumPreds),
    assertion(NumPreds >= 3),  % At least our 3 predicates
    memberchk(pred1/1, Preds),
    memberchk(pred2/1, Preds),
    memberchk(pred3/1, Preds),
    rdb_close('dbs/test_integ').

:- end_tests(integration_layers).
