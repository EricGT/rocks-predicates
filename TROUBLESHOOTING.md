# Troubleshooting Guide - rocks-predicates on Windows 11

## Test Failures

### DLL Not Found

**Symptoms**:
- Error: `ERROR: library 'foreign(rocksdb4pl)' not found`
- Tests fail immediately on startup
- Module loading errors

**Diagnosis**:

1. Check DLL exists:
   ```bash
   ls ../rocksdb-pack-windows/lib/x64-win64/Release/rocksdb4pl.dll
   ```

2. Verify dependencies:
   ```bash
   ls ../rocksdb-pack-windows/lib/x64-win64/Release/*.dll
   ```

3. Check load configuration:
   ```bash
   cat load_rocks_predicates.pl
   ```

**Solutions**:

1. **Rebuild rocksdb-pack-windows**:
   ```bash
   cd ../rocksdb-pack-windows
   cmake --build build --config Release
   ```

2. **Verify file_search_path**:
   - Ensure `load_rocks_predicates.pl` correctly points to DLL directory
   - Path should be: `../rocksdb-pack-windows/lib/x64-win64/Release`

3. **Add DLL path to environment** (if needed):
   ```bash
   set PATH=%PATH%;C:\path\to\rocksdb-pack-windows\lib\x64-win64\Release
   ```

4. **Check SWI-Prolog architecture**:
   - Must be 64-bit SWI-Prolog for x64-win64 DLLs
   - Check with: `swipl --version`

---

### Database Lock Errors

**Symptoms**:
- Error: `rocks_error('IO error: lock hold by current process...')`
- Error: `rocks_error('IO error: lock...')`
- Tests fail when opening database
- Cannot delete test databases

**Diagnosis**:

1. Check for orphaned SWI-Prolog processes:
   ```bash
   tasklist | findstr swipl
   ```

2. Check for open file handles:
   ```bash
   handle.exe dbs\test_*
   ```
   (Requires Sysinternals Handle tool)

3. List locked files in test directory:
   ```bash
   dir /s dbs\test_*\LOCK
   ```

**Solutions**:

1. **Close all SWI-Prolog instances**:
   ```bash
   taskkill /F /IM swipl.exe
   taskkill /F /IM swipl-win.exe
   ```

2. **Delete test databases**:
   ```bash
   rmdir /s /q dbs\test_*
   ```

3. **Wait for file handles to release**:
   - Sometimes Windows needs a few seconds
   - Close and wait 5-10 seconds before retrying

4. **Reboot** (if issue persists):
   - Last resort for stubborn file locks

---

### Performance Tests Failing

**Symptoms**:
- Performance tests pass but assertions fail
- Throughput below baseline (< 1,000 facts/sec)
- Latency above baseline (> 1,000 μs)
- Tests timeout

**Diagnosis**:

1. **Check system load**:
   ```bash
   taskmgr
   ```
   - Look for high CPU/disk usage

2. **Check antivirus activity**:
   - Look for real-time scanning
   - Check if test directory is being scanned

3. **Check disk type**:
   - HDD vs SSD makes significant difference
   - Check with: `wmic diskdrive get model,mediatype`

4. **Check available resources**:
   ```bash
   systeminfo | findstr "Memory"
   ```

**Solutions**:

1. **Close other applications**:
   - Free up CPU and disk I/O
   - Close browsers, IDEs, etc.

2. **Temporarily disable antivirus for test directory**:
   - Add exception for `dbs/` and `rocks-predicates-windows/` directories
   - Re-enable after testing

3. **Use SSD storage for test databases**:
   - Move test directory to SSD
   - Update paths in test configuration

4. **Adjust performance baselines for your hardware**:
   - Edit test files to lower thresholds if on slower hardware
   - Document actual performance in TEST_RESULTS.md

5. **Run tests when system is idle**:
   - No other intensive tasks running
   - Background services settled

---

### Out of Memory

**Symptoms**:
- Tests crash with out-of-memory errors
- SWI-Prolog stack overflow
- Large dataset tests fail
- System becomes unresponsive

**Diagnosis**:

1. **Check available RAM**:
   ```bash
   systeminfo | findstr "Available Physical Memory"
   ```

2. **Check SWI-Prolog memory limits**:
   ```bash
   swipl --dump-runtime-variables | findstr stack
   ```

3. **Monitor memory during tests**:
   - Use Task Manager to watch memory usage
   - Identify which test consumes most memory

**Solutions**:

1. **Increase SWI-Prolog stack/heap size**:
   ```bash
   "/c/Program Files/swipl/bin/swipl.exe" --stack-limit=8g -g "run_tests" -t halt run_all_tests.pl
   ```

2. **Skip very large stress tests**:
   - Don't set `RUN_STRESS_TESTS=true`
   - Run stress tests separately with more resources

3. **Run tests in smaller batches**:
   - Run Phase 1, 2, 3 separately
   - Clean up between phases

4. **Free up system memory**:
   - Close other applications
   - Clear disk cache
   - Restart system before testing

5. **Reduce test dataset sizes** (temporary):
   - Edit test files to use smaller datasets
   - Document modifications in results

---

### Path Handling Errors

**Symptoms**:
- Database not found errors
- Path separator issues (forward slash vs backslash)
- Cannot create database in specified path
- "The system cannot find the path specified"

**Diagnosis**:

1. **Check path syntax**:
   - Forward slash: `dbs/test`
   - Backslash: `dbs\\test` (needs escaping)

2. **Verify directory exists**:
   ```bash
   ls dbs/
   ```

3. **Check for special characters**:
   - Spaces, Unicode characters, etc.

4. **Test absolute vs relative paths**:
   ```bash
   cd rocks-predicates-windows
   pwd
   ```

**Solutions**:

1. **Use forward slashes** (preferred):
   ```prolog
   rdb_open('dbs/test', DB).
   ```

2. **Escape backslashes** (if needed):
   ```prolog
   rdb_open('dbs\\test', DB).
   ```

3. **Create missing directories**:
   ```bash
   mkdir -p dbs
   ```

4. **Avoid paths with spaces** (or quote them):
   - Good: `dbs/mytest`
   - Problematic: `dbs/my test`
   - Solution: `'dbs/my test'` or `dbs/mytest`

5. **Use absolute paths** (if relative paths fail):
   ```prolog
   rdb_open('C:/Users/Eric/Projects/Prolog_AI_Assistant_Research/rocks-predicates-windows/dbs/test', DB).
   ```

---

### File Locking on Windows

**Symptoms**:
- Cannot delete test databases
- "Access denied" errors
- File in use by another process
- Tests leave databases locked

**Diagnosis**:

1. **Check for open handles**:
   ```bash
   handle.exe dbs\
   ```

2. **Check LOCK files**:
   ```bash
   dir /s /b dbs\*LOCK*
   ```

3. **Verify all databases closed**:
   - Review test cleanup code
   - Check for missing `rdb_close` calls

**Solutions**:

1. **Ensure all databases are closed**:
   - Check test cleanup hooks
   - Verify `rdb_close` in all code paths

2. **Wait for file handles to release**:
   - Wait 5-10 seconds after close
   - Windows may need time to release locks

3. **Use robust cleanup** in helpers:
   ```prolog
   cleanup_test_db(DBPath) :-
       catch(rdb_close(DBPath), _, true),
       sleep(1),  % Wait for lock release
       delete_directory_and_contents(DBPath).
   ```

4. **Force delete** (careful):
   ```bash
   rmdir /s /q dbs\test_*
   ```

---

### Character Encoding Issues

**Symptoms**:
- Unicode characters not stored correctly
- Encoding errors on load
- Strange characters in output
- "Cannot represent character" errors

**Diagnosis**:

1. **Check file encoding**:
   - Test files should be UTF-8
   - Check with text editor

2. **Check SWI-Prolog locale**:
   ```prolog
   current_prolog_flag(encoding, Encoding).
   ```

3. **Verify data roundtrip**:
   - Store Unicode, retrieve, compare

**Solutions**:

1. **Ensure files are UTF-8 encoded**:
   - Save with UTF-8 encoding
   - Add BOM if needed

2. **Add encoding directive** to test files:
   ```prolog
   :- encoding(utf8).
   ```

3. **Set locale** (if needed):
   ```bash
   set LANG=en_US.UTF-8
   ```

4. **Use atoms for Unicode** (not strings):
   ```prolog
   rdb_assertz(unicode_data('こんにちは')).
   ```

---

## Windows-Specific Issues

### Long Path Names (> 260 characters)

**Symptoms**:
- "Path too long" errors
- Cannot create database
- MAX_PATH exceeded

**Diagnosis**:

1. **Measure path length**:
   ```bash
   echo %CD%\dbs\test_database_name | find /c /v ""
   ```

2. **Check Windows long path support**:
   ```bash
   reg query HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled
   ```

**Solutions**:

1. **Enable long path support** in Windows 10+:
   ```bash
   reg add HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1 /f
   ```
   (Requires administrator privileges and reboot)

2. **Use shorter database paths**:
   - Move project closer to drive root
   - Use shorter database names

3. **Use UNC paths** (may bypass limit):
   ```
   \\?\C:\path\to\database
   ```

---

### Reserved Filenames

**Symptoms**:
- Cannot create database named CON, PRN, etc.
- Unexpected errors with specific names

**Diagnosis**:

1. **Check for reserved names**:
   - CON, PRN, AUX, NUL
   - COM1-9, LPT1-9

**Solutions**:

1. **Avoid Windows reserved names**:
   - Use descriptive names: `my_database`, `facts_db`
   - Not: `CON`, `PRN`, `AUX`, etc.

2. **Add suffix/prefix**:
   - `db_con` instead of `con`
   - `test_aux` instead of `aux`

---

### Case Sensitivity

**Symptoms**:
- Database opened with different case than created
- Unexpected behavior with path casing

**Diagnosis**:

1. **Windows file system is case-insensitive**:
   - `dbs/Test` and `dbs/test` are the same

2. **Check if issue is case-related**:
   - Try with consistent casing

**Solutions**:

1. **Be consistent with casing**:
   - Choose one style and stick with it
   - Recommend: all lowercase

2. **Don't rely on case differences**:
   - On Windows, `dbs/Test` = `dbs/test`
   - For portability, use all lowercase

---

## Build Issues

### RocksDB4pl Build Fails

**Symptoms**:
- CMake configuration errors
- Compilation errors
- Linking errors

**Diagnosis**:

See `../rocksdb-pack-windows/TROUBLESHOOTING.md` for detailed build troubleshooting.

**Quick Check**:

1. **Verify Visual Studio installed**:
   ```bash
   where cl.exe
   ```

2. **Verify vcpkg**:
   ```bash
   C:\vcpkg\vcpkg.exe list
   ```

3. **Check CMake**:
   ```bash
   cmake --version
   ```

**Solutions**:

1. **Rebuild from scratch**:
   ```bash
   cd ../rocksdb-pack-windows
   rmdir /s /q build
   mkdir build && cd build
   cmake .. -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake
   cmake --build . --config Release
   ```

2. **See rocksdb-pack-windows documentation**:
   - [README-Windows.md](../rocksdb-pack-windows/README-Windows.md)
   - [TROUBLESHOOTING.md](../rocksdb-pack-windows/TROUBLESHOOTING.md)

---

## Runtime Issues

### Tests Hang or Freeze

**Symptoms**:
- Tests stop responding
- No output for long time
- CPU usage 100%

**Diagnosis**:

1. **Check which test is running**:
   - Look at last output
   - Identify test suite/test name

2. **Check for infinite loops**:
   - Review test code
   - Look for backtracking issues

3. **Check system resources**:
   - Disk I/O at 100%?
   - Memory exhausted?

**Solutions**:

1. **Kill and restart**:
   ```bash
   taskkill /F /IM swipl.exe
   ```

2. **Run individual test** to isolate:
   ```bash
   "/c/Program Files/swipl/bin/swipl.exe" -g "run_tests(specific_test)" -t halt test_file.plt
   ```

3. **Add timeout** to problematic tests:
   ```prolog
   test(slow_test, [timeout(60)]) :- ...
   ```

4. **Skip problematic test** temporarily:
   ```prolog
   test(problem_test, [condition(fail)]) :- ...
   ```

---

## Getting Help

If issues persist after trying these solutions:

### 1. Check Documentation

- [README-Windows.md](README-Windows.md)
- [TESTING.md](TESTING.md)
- [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md)
- [../rocksdb-pack-windows/README-Windows.md](../rocksdb-pack-windows/README-Windows.md)

### 2. Collect Diagnostics

```bash
# SWI-Prolog version
"/c/Program Files/swipl/bin/swipl.exe" --version

# DLL files
ls ../rocksdb-pack-windows/lib/x64-win64/Release/

# Environment
echo %PATH%

# System info
systeminfo
```

### 3. Report Issue

Include:
- **Test output** (full or relevant excerpt)
- **Error messages** (exact text)
- **System configuration** (OS, SWI-Prolog version, hardware)
- **Diagnostic information** (from above)
- **Steps to reproduce**
- **What you've tried** (from this guide)

### 4. Workaround Documentation

If you find a workaround not listed here:
- Document it in TEST_RESULTS.md
- Consider submitting documentation update
- Share with community
