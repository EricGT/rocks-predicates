% test_helpers_rdb.pl - Test helpers for rocks_preds testing
:- module(test_helpers_rdb, [
    setup_test_db/1,           % Setup isolated test database
    cleanup_test_db/1,         % Cleanup test database
    create_fixture/2,          % Create fixture file
    generate_large_fixture/2,  % Generate large fixture
    assert_fact_count/3        % Assert expected fact count
]).

:- use_module('../../rocks_preds').
:- use_module(library(filesex)).

%! setup_test_db(+DBPath) is det.
%
% Setup an isolated test database. Creates a unique test database path
% by prefixing with 'test_', deletes any existing database at that path,
% and opens a new database.

setup_test_db(DBPath) :-
    atom_concat('dbs/test_', DBPath, FullPath),
    (exists_directory(FullPath) ->
        delete_directory_and_contents(FullPath) ; true),
    rdb_open(FullPath, _).

%! cleanup_test_db(+DBPath) is det.
%
% Cleanup test database. Closes the database and deletes all files.
% Uses catch to handle errors gracefully.

cleanup_test_db(DBPath) :-
    atom_concat('dbs/test_', DBPath, FullPath),
    ignore(rdb_close(FullPath)),
    (exists_directory(FullPath) ->
        delete_directory_and_contents(FullPath) ; true).

%! create_fixture(+Path, +Lines) is det.
%
% Create a fixture file with the given lines of Prolog code.
% Each line should be a string representing Prolog code.

create_fixture(Path, Lines) :-
    open(Path, write, Stream),
    forall(member(Line, Lines),
           format(Stream, '~w~n', [Line])),
    close(Stream).

%! generate_large_fixture(+Path, +NumFacts) is det.
%
% Generate a large fixture file with NumFacts simple facts.
% Facts are of the form largefact(N).

generate_large_fixture(Path, NumFacts) :-
    open(Path, write, Stream),
    forall(between(1, NumFacts, N),
           format(Stream, 'largefact(~d).~n', [N])),
    close(Stream).

%! assert_fact_count(+DB, +Template, +ExpectedCount) is det.
%
% Assert that the number of facts matching Template in DB equals ExpectedCount.
% Fails with an assertion error if counts don't match.

assert_fact_count(DB, Template, ExpectedCount) :-
    findall(Template, rdb_clause(DB, Template, true), Facts),
    length(Facts, ActualCount),
    assertion(ActualCount == ExpectedCount).
