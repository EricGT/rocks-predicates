# Testing Guide for rocks-predicates on Windows 11

## Prerequisites

Before running tests, ensure you have:

- **SWI-Prolog 10.0.0+** (native Windows installation)
- **Built rocksdb-pack-windows** with all DLLs (see [README-Windows.md](README-Windows.md))
- **About 5 GB free disk space** for test databases
- **SSD recommended** for performance tests

## Quick Start

### Run All Tests

From the `rocks-predicates-windows` directory:

```bash
"/c/Program Files/swipl/bin/swipl.exe" -g "run_tests" -t halt run_all_tests.pl
```

### Run Specific Test Suite

```bash
"/c/Program Files/swipl/bin/swipl.exe" -g "run_tests(test_suite_name)" -t halt tests/unit/test_rdb_basic.plt
```

### Run Performance Tests

```bash
"/c/Program Files/swipl/bin/swipl.exe" -g "run_tests(performance_benchmarks)" -t halt tests/performance/test_rdb_perf.plt
```

### Run with Stress Tests

```bash
set RUN_STRESS_TESTS=true
"/c/Program Files/swipl/bin/swipl.exe" -g "run_tests" -t halt run_all_tests.pl
```

## Test Categories

### Phase 1: Foundation Tests (Low-Level rocksdb.pl)

Located in `../rocksdb-pack-windows/test/`

**Test Suites**:
1. `test_rocksdb.pl` - Existing baseline tests (8 PLUnit suites)
2. `test_rocksdb_windows.plt` - Windows-specific paths, DLL loading, file locking
3. `test_rocksdb_errors.plt` - Error handling and type validation
4. `test_rocksdb_concurrent.plt` - Concurrent access and persistence
5. `test_rocksdb_memory.plt` - Memory management and blob cleanup

**Run Phase 1 only**:
```bash
cd ../rocksdb-pack-windows/test
"/c/Program Files/swipl/bin/swipl.exe" -g "run_tests" -t halt test_rocksdb.pl
```

### Phase 2: Core Tests (High-Level rocks_preds.pl)

Located in `tests/unit/`

**Test Suites**:
1. `test_rdb_basic.plt` - CRUD operations (open, close, assertz, retract, retractall)
2. `test_rdb_clause.plt` - Clause queries and unification
3. `test_rdb_indexing.plt` - Index operations and performance
4. `test_rdb_load.plt` - File loading operations
5. `test_rdb_properties.plt` - Predicate properties and metadata

**Run Phase 2 only**:
```bash
"/c/Program Files/swipl/bin/swipl.exe" -g "run_tests" -t halt tests/unit/test_rdb_basic.plt tests/unit/test_rdb_clause.plt tests/unit/test_rdb_indexing.plt tests/unit/test_rdb_load.plt tests/unit/test_rdb_properties.plt
```

### Phase 3: Integration & Quality Tests

Located in `tests/integration/`, `tests/windows/`, `tests/performance/`

**Test Suites**:
1. `test_rdb_rocksdb.plt` - Layer integration tests
2. `test_rdb_rdf.plt` - RDF module integration (if available)
3. `test_rdb_wordnet.plt` - WordNet module integration (if available)
4. `test_windows_specific.plt` - Windows edge cases
5. `test_rdb_perf.plt` - Performance benchmarks
6. `test_rdb_stress.plt` - Stress tests (optional)

**Run Phase 3 only**:
```bash
"/c/Program Files/swipl/bin/swipl.exe" -g "run_tests" -t halt tests/integration/test_rdb_rocksdb.plt tests/windows/test_windows_specific.plt tests/performance/test_rdb_perf.plt
```

## Interpreting Results

### Success

All tests pass with output like:

```
% PL-Unit: rdb_basic ............ done
% All 12 tests passed
```

### Failure

If tests fail, you'll see:

```
% PL-Unit: rdb_basic
ERROR: test test_name: assertion_failed
% 11 tests passed
% 1 test failed
```

Review the error message for specific issues.

### Performance Validation

Performance tests include assertions for minimum acceptable performance:

- **Assertion throughput**: > 1,000 facts/sec
- **Query latency**: < 1,000 μs (1 ms)
- **Index speedup**: > 0.5x (50% of original time or better)
- **Memory**: < 1 KB/fact

If performance assertions fail, the system is still functional but may be slower than expected on your hardware.

## Troubleshooting

### DLL Not Found

**Error**: `ERROR: library 'foreign(rocksdb4pl)' not found`

**Solutions**:
1. Verify rocksdb4pl.dll exists:
   ```bash
   ls ../rocksdb-pack-windows/lib/x64-win64/Release/rocksdb4pl.dll
   ```
2. Check load_rocks_predicates.pl is loaded
3. Rebuild rocksdb-pack-windows if necessary

### Database Lock Errors

**Error**: `rocks_error('IO error: lock hold by current process...')`

**Solutions**:
1. Close all SWI-Prolog instances
2. Delete test databases:
   ```bash
   rm -rf dbs/test_*
   ```
3. Restart tests

### Out of Disk Space

**Error**: Tests fail with disk space errors

**Solutions**:
1. Free up at least 5 GB disk space
2. Delete test databases: `rm -rf dbs/test_* dbs/perf* dbs/stress*`
3. Restart tests

### Slow Tests

If tests are running very slowly:

1. **Check antivirus**: Temporarily disable for test directory
2. **Use SSD**: HDD performance is significantly slower
3. **Close applications**: Free up system resources
4. **Skip stress tests**: Use default (no RUN_STRESS_TESTS)

### Test Failures

For specific test failures:

1. **Read error message carefully**: Often indicates the exact issue
2. **Check test dependencies**: Ensure rocksdb-pack-windows is built
3. **Verify environment**: Correct SWI-Prolog version, Windows 11
4. **Review logs**: Check for detailed error messages
5. **See TROUBLESHOOTING.md**: For detailed troubleshooting guide

## Cleaning Up

After testing, clean up test databases:

```bash
# From rocks-predicates-windows directory
rm -rf dbs/test_*
rm -rf dbs/perf*
rm -rf dbs/stress*
rm -rf tests/fixtures/*.pl
```

## Test Execution Time Estimates

| Test Phase | Estimated Time | Tests |
|------------|---------------|-------|
| Phase 1 (Foundation) | ~15 min | ~60 |
| Phase 2 (Core) | ~20 min | ~120 |
| Phase 3 (Integration) | ~30 min | ~60 |
| **Total (without stress)** | **~65 min** | **~240** |
| With Stress Tests | ~2-3 hours | ~255 |

*Times are estimates and may vary based on hardware*

## Continuous Integration

For CI environments, run quick validation:

```bash
"/c/Program Files/swipl/bin/swipl.exe" -g "run_tests" -t halt tests/unit/test_rdb_basic.plt tests/unit/test_rdb_clause.plt tests/unit/test_rdb_indexing.plt
```

Full test suite (including performance):

```bash
"/c/Program Files/swipl/bin/swipl.exe" -g "run_tests" -t halt run_all_tests.pl
```

## Test Development

### Adding New Tests

1. **Choose appropriate directory**: `tests/unit/`, `tests/integration/`, etc.
2. **Use PLUnit framework**: Follow existing test patterns
3. **Use test helpers**: Import `test_helpers_rdb.pl` for common operations
4. **Add to run_all_tests.pl**: Include in appropriate phase
5. **Document**: Add to this guide

### Test Naming Conventions

- **Files**: `test_<component>_<aspect>.plt`
- **Test suites**: `<component>_<aspect>` (e.g., `rdb_basic`, `rdb_indexing`)
- **Individual tests**: Descriptive names (e.g., `assertz_complex`, `index_performance`)

### Helper Modules

- **test_helpers_rdb.pl**: Helpers for rocks_preds tests
  - `setup_test_db/1`: Create isolated test database
  - `cleanup_test_db/1`: Clean up test database
  - `create_fixture/2`: Create fixture files
  - `generate_large_fixture/2`: Generate large test files
  - `assert_fact_count/3`: Assert expected count

- **test_helpers_rocksdb.pl**: Helpers for rocksdb tests
  - `test_db/1`: Default test database path
  - `delete_db/0,1`: Delete test databases
  - `setup_db/2,3`: Setup database with options
  - `cleanup_db/2`: Robust cleanup

## Reporting Test Results

After running tests:

1. Copy test output to `TEST_RESULTS.md`
2. Fill in environment details (OS, SWI-Prolog version, hardware)
3. Document any failures or issues
4. Note performance metrics
5. Complete validation checklist

See [TEST_RESULTS_TEMPLATE.md](TEST_RESULTS_TEMPLATE.md) for the template.

## Getting Help

If issues persist after troubleshooting:

1. **Check documentation**:
   - [README-Windows.md](README-Windows.md)
   - [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
   - [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md)

2. **Collect diagnostics**:
   ```bash
   "/c/Program Files/swipl/bin/swipl.exe" --version
   ls ../rocksdb-pack-windows/lib/x64-win64/Release/
   echo %PATH%
   ```

3. **Report issue** with:
   - Test output
   - Error messages
   - System configuration
   - Diagnostic information
