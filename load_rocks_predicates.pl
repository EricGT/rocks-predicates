% load_rocks_predicates.pl - Windows loader for rocks-predicates
%
% This file configures the module search paths to find the rocksdb-pack-windows
% build, then loads the rocks-predicates library.
%
% Usage:
%   ?- consult('load_rocks_predicates.pl').
%   ?- rdb_open('dbs/test', DB).
%   ?- rdb_assertz('dbs/test', person(john)).
%   ?- rdb_clause('dbs/test', person(X), Body).

:- module(load_rocks_predicates, [
    ensure_rocks_predicates/0
]).

% Configure paths BEFORE loading library(rocksdb)
% Point to the rocksdb-pack-windows build
:- asserta(user:file_search_path(foreign, '../rocksdb-pack-windows/lib/x64-win64/Release')).
:- asserta(user:file_search_path(library, '../rocksdb-pack-windows/prolog')).

% Now library(rocksdb) will resolve correctly
:- use_module(library(rocksdb)).

% Load rocks_preds from same directory
:- use_module(rocks_preds).

% Re-export key predicates from rocks_preds for convenience
:- reexport(rocks_preds, [
    rdb_open/2,
    rdb_open/3,
    rdb_close/0,
    rdb_close/1,
    rdb_assertz/1,
    rdb_assertz/2,
    rdb_retract/1,
    rdb_retract/2,
    rdb_retractall/1,
    rdb_retractall/2,
    rdb_clause/2,
    rdb_clause/3,
    rdb_clause/4,
    rdb_nth_clause/3,
    rdb_nth_clause/4,
    rdb_load_file/1,
    rdb_load_file/2,
    rdb_current_predicate/1,
    rdb_current_predicate/2,
    rdb_predicate_property/2,
    rdb_predicate_property/3,
    rdb_index/2,
    rdb_index/3,
    rdb_destroy_index/2,
    rdb_destroy_index/3
]).

ensure_rocks_predicates :-
    writeln('rocks-predicates loaded successfully for Windows').
    writeln('RocksDB pack location: ../rocksdb-pack-windows/').
