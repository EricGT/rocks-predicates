% test_rdb_perf.plt - Performance benchmark tests for rocks_preds
:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

:- begin_tests(performance_benchmarks, [setup(setup_test_db(perf)), cleanup(cleanup_test_db(perf))]).

test(benchmark_assertz_throughput) :-
    NumFacts = 10000,
    statistics(cputime, T0),
    forall(between(1, NumFacts, N),
           rdb_assertz('dbs/test_perf', benchmark_fact(N))),
    statistics(cputime, T1),
    Time is T1 - T0,
    Throughput is NumFacts / Time,
    format('Assertz throughput: ~0f facts/sec (~3f sec for ~D facts)~n',
           [Throughput, Time, NumFacts]),
    assertion(Throughput > 1000).

test(benchmark_query_latency) :-
    forall(between(1, 1000, N),
           rdb_assertz('dbs/test_perf', query_target(N, N))),
    NumQueries = 100,
    statistics(cputime, T0),
    forall(between(1, NumQueries, N),
           rdb_clause('dbs/test_perf', query_target(N, _), true)),
    statistics(cputime, T1),
    Time is T1 - T0,
    AvgLatency is (Time * 1000000) / NumQueries,
    format('Query latency: ~2f μs/query (~D queries)~n',
           [AvgLatency, NumQueries]),
    assertion(AvgLatency < 1000).

test(benchmark_index_benefit) :-
    NumFacts = 10000,
    forall(between(1, NumFacts, N),
           rdb_assertz('dbs/test_perf', indexed_fact(N, N))),

    statistics(cputime, T0),
    findall(X, rdb_clause('dbs/test_perf', indexed_fact(5000, X), true), _),
    statistics(cputime, T1),
    TimeNoIndex is T1 - T0,

    rdb_index('dbs/test_perf', indexed_fact/2, 1),

    statistics(cputime, T2),
    findall(Y, rdb_clause('dbs/test_perf', indexed_fact(5000, Y), true), _),
    statistics(cputime, T3),
    TimeWithIndex is T3 - T2,

    (TimeNoIndex > 0 ->
        Speedup is TimeNoIndex / (TimeWithIndex + 0.00001)
    ;   Speedup = 1.0),
    format('Index speedup: ~1fx (no index: ~6f, with index: ~6f)~n',
           [Speedup, TimeNoIndex, TimeWithIndex]),
    assertion(Speedup >= 0.5).

test(benchmark_memory_usage) :-
    statistics(heapused, H0),
    NumFacts = 10000,
    forall(between(1, NumFacts, N),
           rdb_assertz('dbs/test_perf', memory_fact(N))),
    statistics(heapused, H1),
    HeapUsed is (H1 - H0) / 1024 / 1024,
    BytesPerFact is (H1 - H0) / NumFacts,
    format('Heap used for ~D facts: ~2f MB (~2f bytes/fact)~n',
           [NumFacts, HeapUsed, BytesPerFact]),
    assertion(BytesPerFact < 1024).

:- end_tests(performance_benchmarks).

:- begin_tests(performance_datasets, [setup(setup_test_db(dataset)), cleanup(cleanup_test_db(dataset))]).

test(perf_small_dataset) :-
    test_dataset_performance('small', 1000).

test(perf_medium_dataset) :-
    test_dataset_performance('medium', 10000).

test(perf_large_dataset) :-
    test_dataset_performance('large', 100000).

:- end_tests(performance_datasets).

test_dataset_performance(Label, NumFacts) :-
    format('~n=== Performance Test: ~w (~D facts) ===~n', [Label, NumFacts]),

    statistics(cputime, T0),
    forall(between(1, NumFacts, N),
           rdb_assertz('dbs/test_dataset', fact(N, N))),
    statistics(cputime, T1),
    InsertTime is T1 - T0,
    % Avoid division by zero if operation is too fast
    (InsertTime > 0 -> InsertThroughput is NumFacts / InsertTime ; InsertThroughput = 999999999),

    NumQueries = 100,
    statistics(cputime, T2),
    forall(between(1, NumQueries, _),
           (random_between(1, NumFacts, R),
            rdb_clause('dbs/test_dataset', fact(R, _), true))),
    statistics(cputime, T3),
    QueryTime is T3 - T2,
    % Avoid division by zero if operation is too fast
    (QueryTime > 0 -> QueryLatency is (QueryTime * 1000000) / NumQueries ; QueryLatency = 0.01),

    format('Insert: ~0f facts/sec (~2f sec total)~n',
           [InsertThroughput, InsertTime]),
    format('Query: ~2f μs/query (~D queries)~n',
           [QueryLatency, NumQueries]),

    rdb_retractall('dbs/test_dataset', fact(_, _)).
