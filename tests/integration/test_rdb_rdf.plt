% test_rdb_rdf.plt - RDF module integration tests
:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

% Only run if rdf.pl module exists
:- if(exists_source('../../rdf.pl')).

:- use_module('../../rdf').

:- begin_tests(rdf_integration, [setup(setup_test_db(rdf)), cleanup(cleanup_test_db(rdf))]).

test(rdf_triple_storage) :-
    rdb_assertz('dbs/test_rdf', rdf(subject1, predicate1, object1)),
    rdb_assertz('dbs/test_rdf', rdf(subject1, predicate2, object2)),
    % Check that our specific triples were stored
    rdb_clause('dbs/test_rdf', rdf(subject1, predicate1, object1), true),
    rdb_clause('dbs/test_rdf', rdf(subject1, predicate2, object2), true).

test(rdf_query_subject) :-
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

:- else.

% Placeholder test when rdf.pl is not available
:- begin_tests(rdf_integration, []).

test(rdf_module_not_available, [condition(fail)]) :-
    format('RDF module not found - skipping RDF tests~n').

:- end_tests(rdf_integration).

:- endif.
