% test_rdb_properties.plt - Predicate properties tests for rocks_preds
:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

:- begin_tests(rdb_properties, [setup(setup_test_db(props)), cleanup(cleanup_test_db(props))]).

test(current_predicate_list) :-
    rdb_assertz('dbs/test_props', fact1(a)),
    rdb_assertz('dbs/test_props', fact2(b)),
    rdb_assertz('dbs/test_props', fact3(c)),
    findall(PI, rdb_current_predicate('dbs/test_props', PI), Preds),
    length(Preds, 3),
    assertion(memberchk(fact1/1, Preds)),
    assertion(memberchk(fact2/1, Preds)),
    assertion(memberchk(fact3/1, Preds)).

test(current_predicate_one_arg) :-
    rdb_assertz(mydata(test)),
    findall(PI, rdb_current_predicate(PI), Preds),
    assertion(memberchk(mydata/1, Preds)).

test(predicate_property_count) :-
    rdb_assertz('dbs/test_props', counted(1)),
    rdb_assertz('dbs/test_props', counted(2)),
    rdb_assertz('dbs/test_props', counted(3)),
    rdb_predicate_property('dbs/test_props', counted(_), number_of_clauses(N)),
    assertion(N = 3).

test(property_indexed) :-
    rdb_assertz('dbs/test_props', indexed_pred(a, b)),
    rdb_index('dbs/test_props', indexed_pred/2, 1),
    rdb_predicate_property('dbs/test_props', indexed_pred(_, _), indexed(Args)),
    assertion(memberchk(1, Args)).

test(property_backtrack) :-
    rdb_assertz('dbs/test_props', multi(1)),
    rdb_assertz('dbs/test_props', multi(2)),
    findall(Prop, rdb_predicate_property('dbs/test_props', multi(_), Prop), Props),
    assertion(Props \= []).

test(nonexistent_predicate) :-
    assertion(\+ rdb_current_predicate('dbs/test_props', nonexistent/1)).

test(property_two_args, [nondet]) :-
    rdb_assertz(sample(data)),
    rdb_predicate_property(sample(_), Prop),
    assertion(ground(Prop)).

:- end_tests(rdb_properties).
