# rocks-predicates for Windows 11

Windows-specific guide for using rocks-predicates with the rocksdb-pack-windows build.

## Overview

rocks-predicates provides persistent Prolog predicate storage using RocksDB. This Windows build uses the native MSVC-compiled rocksdb-pack-windows as its foundation.

## Prerequisites

**Must be completed first:**

1. **rocksdb-pack-windows** - Must be built and tested
   - Location: `../rocksdb-pack-windows/`
   - DLL: `lib/x64-win64/Release/rocksdb4pl.dll`
   - All tests must pass

2. **SWI-Prolog 10.0.0+** - Native Windows installation
   - Location: `C:\Program Files\swipl\`
   - Version: 10.0.0 or higher

## Quick Start

### 1. Load the Library

```prolog
?- consult('load_rocks_predicates.pl').
rocks-predicates loaded successfully for Windows
RocksDB pack location: ../rocksdb-pack-windows/
true.
```

### 2. Open a Database

```prolog
?- rdb_open('dbs/my_facts', DB).
true.
```

### 3. Store Facts

```prolog
?- rdb_assertz('dbs/my_facts', person(john)).
true.

?- rdb_assertz('dbs/my_facts', person(mary)).
true.

?- rdb_assertz('dbs/my_facts', parent(john, bob)).
true.
```

### 4. Query Facts

```prolog
?- rdb_clause('dbs/my_facts', person(X), true).
X = john ;
X = mary.

?- rdb_clause('dbs/my_facts', parent(X, Y), true).
X = john,
Y = bob.
```

### 5. Close the Database

```prolog
?- rdb_close('dbs/my_facts').
true.
```

## API Reference

### Database Lifecycle

#### `rdb_open/2` and `rdb_open/3`
Open a RocksDB database for storing predicates.

```prolog
rdb_open('dbs/mydb', DB).
rdb_open('dbs/mydb', DB, []).
```

#### `rdb_close/0` and `rdb_close/1`
Close a database.

```prolog
rdb_close('dbs/mydb').
rdb_close.  % Close default database
```

### Storing Facts

#### `rdb_assertz/1` and `rdb_assertz/2`
Add a fact to the database.

```prolog
rdb_assertz('dbs/mydb', person(john)).
rdb_assertz(person(mary)).  % Uses default database
```

#### `rdb_retract/1` and `rdb_retract/2`
Remove a fact from the database.

```prolog
rdb_retract('dbs/mydb', person(john)).
```

#### `rdb_retractall/1` and `rdb_retractall/2`
Remove all matching facts.

```prolog
rdb_retractall('dbs/mydb', person(_)).
```

### Querying Facts

#### `rdb_clause/2`, `rdb_clause/3`, and `rdb_clause/4`
Query facts from the database.

```prolog
% Basic query
rdb_clause('dbs/mydb', person(X), true).

% With body
rdb_clause('dbs/mydb', Head, Body).
```

#### `rdb_nth_clause/3` and `rdb_nth_clause/4`
Access facts by index.

```prolog
rdb_nth_clause('dbs/mydb', person(_), 1, Ref).
```

### Indexing

#### `rdb_index/2` and `rdb_index/3`
Create an index for faster queries.

```prolog
% Index first argument of record/2
rdb_index('dbs/mydb', record/2, 1).
```

#### `rdb_destroy_index/2` and `rdb_destroy_index/3`
Remove an index.

```prolog
rdb_destroy_index('dbs/mydb', record/2, 1).
```

### Metadata

#### `rdb_current_predicate/1` and `rdb_current_predicate/2`
List predicates stored in the database.

```prolog
rdb_current_predicate('dbs/mydb', PI).
```

#### `rdb_predicate_property/2` and `rdb_predicate_property/3`
Query properties of stored predicates.

```prolog
rdb_predicate_property('dbs/mydb', person/1, Property).
```

### Bulk Loading

#### `rdb_load_file/1` and `rdb_load_file/2`
Load facts from a Prolog file into the database.

```prolog
rdb_load_file('dbs/mydb', 'facts.pl').
```

## Running Tests

Execute the test suite to verify your installation:

```cmd
cd c:\Users\Eric\Projects\Prolog_AI_Assistant_Research\rocks-predicates-windows
"C:\Program Files\swipl\bin\swipl.exe" test_rocks_predicates_windows.pl
```

Expected output:
```
Loading rocks-predicates...
OK

=== Running rocks-predicates Windows Tests ===

Test 1: Basic operations
  Opening database... OK
  Asserting facts... OK
  Querying facts... OK (found 3 persons)
  Querying parents... OK (found 2 parent relations)
  Retracting fact... OK (2 persons remain)
  Closing database... OK

Test 2: Persistence
  Creating persistent database... OK
  Reopening database... OK
  Verifying persisted data... OK (data persisted)

Test 3: Indexing
  Opening database... OK
  Adding test data... OK
  Creating index on first argument... OK
  Querying with indexed argument... OK (index works)
  Checking current predicates... OK

=== All tests PASSED! ===
```

## Project Structure

```
rocks-predicates-windows/
├── dbs/                            # Database storage directory
├── load_rocks_predicates.pl        # Windows loader (configures paths)
├── test_rocks_predicates_windows.pl # Windows test suite
├── README-Windows.md               # This file
├── rocks_preds.pl                  # Core implementation (from upstream)
├── rdf.pl                          # RDF support
├── wn.pl                           # WordNet support
└── README.md                       # Original README
```

## How It Works

The `load_rocks_predicates.pl` loader configures SWI-Prolog's file search paths to locate the rocksdb-pack-windows build:

```prolog
:- asserta(user:file_search_path(foreign, '../rocksdb-pack-windows/lib/x64-win64/Release')).
:- asserta(user:file_search_path(library, '../rocksdb-pack-windows/prolog')).
```

This allows `rocks_preds.pl` to successfully load `library(rocksdb)` without modification.

## Troubleshooting

### Error: "library(rocksdb) not found"

**Cause**: The file search paths are not configured correctly.

**Solution**: Ensure `rocksdb-pack-windows/` exists in the parent directory and contains the built DLL.

### Error: "The specified module could not be found"

**Cause**: Missing DLL dependencies.

**Solution**: Verify these files exist in `rocksdb-pack-windows/lib/x64-win64/Release/`:
- `rocksdb4pl.dll`
- `rocksdb-shared.dll`
- `lz4.dll`
- `snappy.dll`
- `zlib1.dll`
- `zstd.dll`

### Warning: "Singleton variables"

**Effect**: Cosmetic only - does not affect functionality.

**Solution**: These warnings can be safely ignored.

### Database Already Open Error

**Cause**: Trying to open a database that's already open.

**Solution**: Close the database first with `rdb_close/1` before reopening.

## Performance Notes

- **Indexing**: Use `rdb_index/3` for frequently queried arguments to improve performance
- **Batch operations**: Group multiple `rdb_assertz` calls when adding large amounts of data
- **Database location**: Store databases on SSD for best performance
- **Expected performance**: ~70,000 facts/second loading, microsecond query times with indexing

## Persistence

All data is persisted to disk automatically. Facts survive:
- SWI-Prolog session restarts
- System reboots
- Application crashes

Database files are stored in the directory specified when calling `rdb_open/2` (e.g., `dbs/mydb/`).

## Comparison with library(persistency)

**Use rocks-predicates when:**
- Storing millions+ of facts
- Need high-performance indexing
- Require complex query patterns
- Working with large datasets

**Use library(persistency) when:**
- Storing thousands of facts
- Simple persistence requirements
- Minimal dependencies preferred

## Known Issues

1. **Module load warning**: "Local definition overrides weak import from files_ex" - cosmetic only
2. **No transactions**: rocks-predicates does not support multi-operation transactions
3. **Single writer**: Only one process should write to a database at a time

## Support

For issues specific to the Windows build, check:
- `rocksdb-pack-windows/README-Windows.md`
- `rocksdb-pack-windows/WINDOWS_SUCCESS.md`

For general rocks-predicates questions, see the [upstream README](README.md).

## Version Information

- **rocks-predicates**: Latest from https://github.com/EricGT/rocks-predicates
- **rocksdb-pack**: 0.14.4 (Windows MSVC build)
- **RocksDB**: 10.4.2
- **SWI-Prolog**: 10.0.0+
- **Platform**: Windows 11 with MSVC 19.44
