% test_rocks_predicates_windows.pl - Test suite for rocks-predicates on Windows
:- initialization(main, main).

main :-
    % Set working directory
    working_directory(_, 'c:/Users/Eric/Projects/Prolog_AI_Assistant_Research/rocks-predicates-windows'),

    % Load the Windows configuration
    write('Loading rocks-predicates...'), nl,
    consult('load_rocks_predicates.pl'),
    write('OK'), nl, nl,

    % Run all tests
    write('=== Running rocks-predicates Windows Tests ==='), nl, nl,
    test_basic_operations,
    test_persistence,
    test_indexing,

    write('=== All tests PASSED! ==='), nl,
    halt(0).

main :-
    write('=== Tests FAILED! ==='), nl,
    halt(1).

% Test 1: Basic operations (open, assertz, clause, close)
test_basic_operations :-
    write('Test 1: Basic operations'), nl,

    % Open database
    write('  Opening database... '),
    rdb_open('dbs/test_windows', DB),
    write('OK'), nl,

    % Assert some facts
    write('  Asserting facts... '),
    rdb_assertz('dbs/test_windows', person(john)),
    rdb_assertz('dbs/test_windows', person(mary)),
    rdb_assertz('dbs/test_windows', person(bob)),
    rdb_assertz('dbs/test_windows', parent(john, bob)),
    rdb_assertz('dbs/test_windows', parent(mary, bob)),
    write('OK'), nl,

    % Query facts
    write('  Querying facts... '),
    findall(P, rdb_clause('dbs/test_windows', person(P), true), Persons),
    length(Persons, 3),
    write('OK (found 3 persons)'), nl,

    % Query with pattern
    write('  Querying parents... '),
    findall(X-Y, rdb_clause('dbs/test_windows', parent(X, Y), true), Parents),
    length(Parents, 2),
    write('OK (found 2 parent relations)'), nl,

    % Retract a fact
    write('  Retracting fact... '),
    rdb_retract('dbs/test_windows', person(bob)),
    findall(P, rdb_clause('dbs/test_windows', person(P), true), Persons2),
    length(Persons2, 2),
    write('OK (2 persons remain)'), nl,

    % Close database
    write('  Closing database... '),
    rdb_close('dbs/test_windows'),
    write('OK'), nl, nl.

% Test 2: Persistence across sessions
test_persistence :-
    write('Test 2: Persistence'), nl,

    % Create a new database with persistent data
    write('  Creating persistent database... '),
    rdb_open('dbs/persist_test', DB),
    rdb_assertz('dbs/persist_test', saved_fact(hello_world)),
    rdb_assertz('dbs/persist_test', saved_fact(test_data)),
    rdb_close('dbs/persist_test'),
    write('OK'), nl,

    % Reopen and verify data persists
    write('  Reopening database... '),
    rdb_open('dbs/persist_test', DB2),
    write('OK'), nl,

    write('  Verifying persisted data... '),
    findall(X, rdb_clause('dbs/persist_test', saved_fact(X), true), Facts),
    length(Facts, 2),
    memberchk(hello_world, Facts),
    memberchk(test_data, Facts),
    write('OK (data persisted)'), nl,

    rdb_close('dbs/persist_test'),
    nl.

% Test 3: Indexing
test_indexing :-
    write('Test 3: Indexing'), nl,

    % Open database
    write('  Opening database... '),
    rdb_open('dbs/index_test', DB),
    write('OK'), nl,

    % Add some data
    write('  Adding test data... '),
    rdb_assertz('dbs/index_test', record(a, 1)),
    rdb_assertz('dbs/index_test', record(b, 2)),
    rdb_assertz('dbs/index_test', record(c, 3)),
    write('OK'), nl,

    % Create index on first argument
    write('  Creating index on first argument... '),
    rdb_index('dbs/index_test', record/2, 1),
    write('OK'), nl,

    % Query using indexed argument
    write('  Querying with indexed argument... '),
    rdb_clause('dbs/index_test', record(b, X), true),
    X = 2,
    write('OK (index works)'), nl,

    % Check current predicates
    write('  Checking current predicates... '),
    findall(PI, rdb_current_predicate('dbs/index_test', PI), Preds),
    memberchk(record/2, Preds),
    write('OK'), nl,

    rdb_close('dbs/index_test'),
    nl.
