% test_rdb_load.plt - File loading tests for rocks_preds
:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

:- begin_tests(rdb_load_file, [setup(setup_test_db(load)), cleanup(cleanup_test_db(load))]).

test(load_simple_file) :-
    create_fixture('tests/fixtures/simple.pl', [
        'fact(1).',
        'fact(2).',
        'fact(3).'
    ]),
    rdb_load_file('dbs/test_load', 'tests/fixtures/simple.pl'),
    findall(X, rdb_clause('dbs/test_load', fact(X), true), Facts),
    assertion(Facts = [1,2,3]).

test(load_rules) :-
    create_fixture('tests/fixtures/rules.pl', [
        'parent(john, bob).',
        'parent(mary, bob).',
        'grandparent(X, Z) :- parent(X, Y), parent(Y, Z).'
    ]),
    rdb_load_file('dbs/test_load', 'tests/fixtures/rules.pl'),
    rdb_clause('dbs/test_load', grandparent(_, _), Body),
    assertion(Body \= true).

test(load_large_file) :-
    NumFacts = 1000,
    generate_large_fixture('tests/fixtures/large.pl', NumFacts),
    statistics(cputime, T0),
    rdb_load_file('dbs/test_load', 'tests/fixtures/large.pl'),
    statistics(cputime, T1),
    Time is T1 - T0,
    findall(_, rdb_clause('dbs/test_load', largefact(_), true), All),
    length(All, Count),
    assertion(Count = NumFacts),
    (Time > 0 ->
        Throughput is NumFacts / Time,
        format('Loaded ~D facts in ~3f sec (~1f facts/sec)~n',
               [NumFacts, Time, Throughput])
    ;   format('Loaded ~D facts in < 0.001 sec (very fast!)~n', [NumFacts])
    ).

test(load_missing_file, [error(_)]) :-
    rdb_load_file('dbs/test_load', 'nonexistent.pl').

test(load_complex_terms) :-
    create_fixture('tests/fixtures/complex.pl', [
        'data([a,b,c], {key:value}).',
        'nested(outer(inner(deep))).'
    ]),
    rdb_load_file('dbs/test_load', 'tests/fixtures/complex.pl'),
    rdb_clause('dbs/test_load', data([a,b,c], _), true),
    rdb_clause('dbs/test_load', nested(outer(inner(deep))), true).

test(load_one_arg) :-
    create_fixture('tests/fixtures/test1.pl', ['temp(data).']),
    rdb_load_file('tests/fixtures/test1.pl'),
    rdb_clause(temp(data), true).

:- end_tests(rdb_load_file).
