% test_rdb_wordnet.plt - WordNet module integration tests
:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

% Only run if wn.pl file exists
:- if(exists_source('../../wn.pl')).

:- consult('../../wn').

:- begin_tests(wordnet_integration, [setup(setup_test_db(wn)), cleanup(cleanup_test_db(wn))]).

test(wordnet_basic) :-
    rdb_open('dbs/test_wn', _),
    rdb_assertz('dbs/test_wn', hyp(synset1, synset2)),
    rdb_clause('dbs/test_wn', hyp(synset1, synset2), true),
    rdb_close('dbs/test_wn').

test(wordnet_relations) :-
    rdb_open('dbs/test_wn', _),
    rdb_assertz('dbs/test_wn', s(100, 1, word, n, 1, 0)),
    rdb_assertz('dbs/test_wn', hyp(100, 200)),
    findall(X, rdb_clause('dbs/test_wn', hyp(100, X), true), Hyps),
    assertion(Hyps = [200]),
    rdb_close('dbs/test_wn').

:- end_tests(wordnet_integration).

:- else.

% Placeholder test when wn.pl is not available
:- begin_tests(wordnet_integration, []).

test(wordnet_module_not_available, [condition(fail)]) :-
    format('WordNet module not found - skipping WordNet tests~n').

:- end_tests(wordnet_integration).

:- endif.
