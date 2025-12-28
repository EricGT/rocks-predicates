% test_windows_specific.plt - Windows-specific edge case tests
:- use_module(library(plunit)).
:- use_module('../../rocks_preds').
:- use_module('../helpers/test_helpers_rdb').

:- begin_tests(windows_edge_cases, [cleanup(cleanup_test_db(win))]).

test(windows_case_insensitive_paths, [setup(cleanup_test_db(testdb))]) :-
    rdb_open('dbs/test_TestDB', _DB1),
    rdb_assertz('dbs/test_TestDB', fact(a)),
    rdb_close('dbs/test_TestDB'),
    rdb_open('dbs/test_testdb', _DB2),
    rdb_clause('dbs/test_testdb', fact(a), true),
    rdb_close('dbs/test_testdb'),
    cleanup_test_db(testdb).

test(windows_file_locking, [setup(cleanup_test_db(locked))]) :-
    rdb_open('dbs/test_locked', DB),
    assertion(blob(DB, _)),
    rdb_close('dbs/test_locked').

test(windows_path_forward_slash, [setup(cleanup_test_db(fwdslash))]) :-
    rdb_open('dbs/test_fwdslash', _),
    rdb_assertz('dbs/test_fwdslash', data(test)),
    rdb_clause('dbs/test_fwdslash', data(test), true),
    rdb_close('dbs/test_fwdslash').

test(windows_path_backslash, [setup(cleanup_test_db(backslash))]) :-
    rdb_open('dbs\\test_backslash', _),
    rdb_assertz('dbs\\test_backslash', data(test)),
    rdb_clause('dbs\\test_backslash', data(test), true),
    rdb_close('dbs\\test_backslash').

test(windows_temp_directory, [setup(cleanup_test_db(temp)), cleanup(cleanup_test_db(temp)), condition(exists_directory('c:/temp'))]) :-
    rdb_open('c:/temp/test_temp', _),
    rdb_assertz('c:/temp/test_temp', temp_data(value)),
    rdb_close('c:/temp/test_temp'),
    delete_directory_and_contents('c:/temp/test_temp').

:- end_tests(windows_edge_cases).

:- begin_tests(path_handling, [cleanup(cleanup_test_db(path))]).

test(relative_path, [setup(cleanup_test_db(rel))]) :-
    rdb_open('dbs/test_rel', _),
    rdb_assertz('dbs/test_rel', fact(relative)),
    rdb_close('dbs/test_rel').

test(absolute_path, [setup(cleanup_test_db(abs)), cleanup(cleanup_test_db(abs))]) :-
    working_directory(CWD, CWD),
    atom_concat(CWD, '/dbs/test_abs', AbsPath),
    rdb_open(AbsPath, _),
    rdb_assertz(AbsPath, fact(absolute)),
    rdb_close(AbsPath),
    delete_directory_and_contents(AbsPath).

:- end_tests(path_handling).
