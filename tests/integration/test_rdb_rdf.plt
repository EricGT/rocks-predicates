% test_rdb_rdf.plt - RDF triple storage integration tests
%
% Tests that rocks_predicates can store and query RDF-style triples.
% These tests are self-contained and don't require external RDF libraries.

:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

:- begin_tests(rdf_integration, [setup(setup_test_db(rdf)), cleanup(cleanup_test_db(rdf))]).

test(rdf_triple_storage, [nondet]) :-
    rdb_assertz('dbs/test_rdf', rdf(subject1, predicate1, object1)),
    rdb_assertz('dbs/test_rdf', rdf(subject1, predicate2, object2)),
    % Check that our specific triples were stored
    rdb_clause('dbs/test_rdf', rdf(subject1, predicate1, object1), true),
    rdb_clause('dbs/test_rdf', rdf(subject1, predicate2, object2), true).

test(rdf_query_subject, [nondet]) :-
    rdb_assertz('dbs/test_rdf', rdf(subject1, knows, person2)),
    rdb_assertz('dbs/test_rdf', rdf(subject1, likes, item3)),
    % Check that our specific subject queries work
    rdb_clause('dbs/test_rdf', rdf(subject1, knows, person2), true),
    rdb_clause('dbs/test_rdf', rdf(subject1, likes, item3), true).

test(rdf_persistence) :-
    rdb_open('dbs/test_rdf', _),
    rdb_assertz('dbs/test_rdf', rdf(s, p, o)),
    rdb_close('dbs/test_rdf'),
    rdb_open('dbs/test_rdf', _),
    rdb_clause('dbs/test_rdf', rdf(s, p, o), true),
    rdb_close('dbs/test_rdf').

:- end_tests(rdf_integration).
