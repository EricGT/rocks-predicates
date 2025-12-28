% run_all_tests.pl - Master test runner for rocks-predicates Windows testing
:- initialization(main, main).

% Load rocks_predicates with Windows DLL configuration
:- consult('load_rocks_predicates.pl').

main :-
    format('~n=== rocks-predicates Windows Test Suite ===~n~n'),
    format('Starting comprehensive testing...~n~n'),

    statistics(cputime, T0),

    % Phase 1: Foundation (Low-Level rocksdb.pl)
    run_phase_1,

    % Phase 2: Core (High-Level rocks_preds.pl)
    run_phase_2,

    % Phase 3: Integration & Quality
    run_phase_3,

    % Optional: Stress tests
    (getenv('RUN_STRESS_TESTS', 'true') ->
        run_stress_tests
    ;   format('~nSkipping stress tests (set RUN_STRESS_TESTS=true to enable)~n')
    ),

    statistics(cputime, T1),
    Time is T1 - T0,

    format('~n=== All Test Phases Complete ===~n'),
    format('Total time: ~2f seconds~n', [Time]),
    halt(0).

main :-
    format('~n=== TEST SUITE FAILED ===~n'),
    format('One or more test phases failed. Review output above.~n'),
    halt(1).

%! run_phase_1 is det.
%
% Run Phase 1: Foundation tests (low-level rocksdb.pl API)

run_phase_1 :-
    format('~n==========================================~n'),
    format('PHASE 1: Foundation (Low-Level rocksdb.pl)~n'),
    format('==========================================~n~n'),
    format('NOTE: Phase 1 low-level rocksdb tests require running from rocksdb-pack-windows directory.~n'),
    format('Skipping Phase 1 - run these tests separately if needed.~n'),
    format('To run: cd ../rocksdb-pack-windows/test && swipl -g "run_tests" -t halt test_rocksdb.pl~n~n').

%! run_phase_2 is det.
%
% Run Phase 2: Core tests (high-level rocks_preds.pl API)

run_phase_2 :-
    format('~n==========================================~n'),
    format('PHASE 2: Core Functionality (rocks_preds.pl)~n'),
    format('==========================================~n~n'),
    statistics(cputime, T0),

    run_test('tests/unit/test_rdb_basic.plt', 'Basic CRUD operations'),
    run_test('tests/unit/test_rdb_clause.plt', 'Clause queries'),
    run_test('tests/unit/test_rdb_indexing.plt', 'Indexing operations'),
    run_test('tests/unit/test_rdb_load.plt', 'File loading'),
    run_test('tests/unit/test_rdb_properties.plt', 'Predicate properties'),

    statistics(cputime, T1),
    Time is T1 - T0,
    format('~nPhase 2 completed in ~2f seconds~n', [Time]).

%! run_phase_3 is det.
%
% Run Phase 3: Integration & Quality tests

run_phase_3 :-
    format('~n==========================================~n'),
    format('PHASE 3: Integration & Quality~n'),
    format('==========================================~n~n'),
    statistics(cputime, T0),

    run_test('tests/integration/test_rdb_rocksdb.plt', 'Layer integration'),
    run_test('tests/integration/test_rdb_rdf.plt', 'RDF module integration'),
    run_test('tests/integration/test_rdb_wordnet.plt', 'WordNet module integration'),
    run_test('tests/windows/test_windows_specific.plt', 'Windows edge cases'),
    run_test('tests/performance/test_rdb_perf.plt', 'Performance benchmarks'),

    statistics(cputime, T1),
    Time is T1 - T0,
    format('~nPhase 3 completed in ~2f seconds~n', [Time]).

%! run_stress_tests is det.
%
% Run optional stress tests

run_stress_tests :-
    format('~n==========================================~n'),
    format('STRESS TESTS (Optional)~n'),
    format('==========================================~n~n'),
    statistics(cputime, T0),

    run_test('tests/performance/test_rdb_stress.plt', 'Stress tests'),

    statistics(cputime, T1),
    Time is T1 - T0,
    format('~nStress tests completed in ~2f seconds~n', [Time]).

%! run_test(+File, +Description) is det.
%
% Load and run tests from a single test file.
% Handles missing files gracefully.

run_test(File, Description) :-
    format('~n--- ~w ---~n', [Description]),
    format('Loading ~w...~n', [File]),
    (exists_file(File) ->
        (catch(
            (load_files(File, [silent(true)]),
             run_tests),
            Error,
            (format('ERROR loading/running ~w: ~w~n', [File, Error]),
             fail))
        ->  format('~w: PASSED~n', [Description])
        ;   format('~w: FAILED~n', [Description]),
            fail)
    ;   format('WARNING: File ~w not found - skipping~n', [File])
    ).
