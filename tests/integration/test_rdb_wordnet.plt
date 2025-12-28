% test_rdb_wordnet.plt - WordNet-style data storage integration tests
%
% Tests that rocks_predicates can store and query WordNet-style relations.
% These tests are self-contained and don't require WordNet data files.

:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

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
