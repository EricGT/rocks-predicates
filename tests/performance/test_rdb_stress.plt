% test_rdb_stress.plt - Stress tests for rocks_preds
:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

:- begin_tests(stress_tests, [setup(setup_test_db(stress)), cleanup(cleanup_test_db(stress))]).

test(stress_long_running_queries) :-
    NumFacts = 10000,
    forall(between(1, NumFacts, N),
           rdb_assertz('dbs/test_stress', stress_fact(N))),
    get_time(T0),
    stress_query_loop(T0, 10),
    format('Completed 10 seconds of continuous queries~n').

test(stress_large_dataset, [timeout(600)]) :-
    NumFacts = 100000,
    format('Inserting ~D facts...~n', [NumFacts]),
    statistics(cputime, T0),
    forall(between(1, NumFacts, N),
           (rdb_assertz('dbs/test_stress', large_fact(N)),
            (N mod 10000 =:= 0 -> format('.') ; true))),
    statistics(cputime, T1),
    Time is T1 - T0,
    format('~nInserted ~D facts in ~2f sec~n', [NumFacts, Time]).

test(stress_concurrent_modifications) :-
    forall(between(1, 1000, N),
           rdb_assertz('dbs/test_stress', modifiable(N))),
    forall(between(1, 10, _Cycle),
           (rdb_retractall('dbs/test_stress', modifiable(_)),
            forall(between(1, 1000, N),
                   rdb_assertz('dbs/test_stress', modifiable(N))))).

test(stress_deep_nesting) :-
    create_deeply_nested_term(50, DeepTerm),
    rdb_assertz('dbs/test_stress', deep(DeepTerm)),
    rdb_clause('dbs/test_stress', deep(Retrieved), true),
    assertion(Retrieved = DeepTerm).

test(stress_wide_term) :-
    length(Args, 50),
    maplist(=(arg_value), Args),
    WideTerm =.. [wide_functor|Args],
    rdb_assertz('dbs/test_stress', WideTerm),
    rdb_clause('dbs/test_stress', Retrieved, true),
    functor(Retrieved, wide_functor, 50).

test(stress_many_predicates) :-
    forall(between(1, 100, N),
           (atom_concat(pred_, N, Pred),
            Fact =.. [Pred, value],
            rdb_assertz('dbs/test_stress', Fact))),
    findall(PI, rdb_current_predicate('dbs/test_stress', PI), Preds),
    length(Preds, Count),
    assertion(Count >= 100).

:- end_tests(stress_tests).

% Helper predicates

stress_query_loop(StartTime, Duration) :-
    get_time(CurrentTime),
    Elapsed is CurrentTime - StartTime,
    (   Elapsed < Duration
    ->  findall(X, rdb_clause('dbs/test_stress', stress_fact(X), true), _),
        stress_query_loop(StartTime, Duration)
    ;   true
    ).

create_deeply_nested_term(0, atom) :- !.
create_deeply_nested_term(N, nested(Inner)) :-
    N1 is N - 1,
    create_deeply_nested_term(N1, Inner).
