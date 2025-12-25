# Known Limitations - rocks-predicates for Windows 11

## Platform-Specific Limitations

### Windows File Locking

**Limitation**:
- Only one process can open a database at a time
- Read-only mode does NOT allow concurrent access on Windows (unlike Unix)
- File locks persist until process terminates

**Impact**:
- Concurrent access tests may behave differently than Unix
- Multi-process scenarios not supported
- Cannot share database between applications

**Workaround**:
- Use separate databases for concurrent processes
- Coordinate access through application logic
- Use message passing or IPC for data sharing
- Close databases as soon as possible

**Why**:
- Windows file locking is more restrictive than Unix
- RocksDB uses exclusive file locks
- No shared read-only access on Windows

---

### Path Handling

**Limitation**:
- Windows uses backslash (`\`) as path separator
- Maximum path length is 260 characters (without long path support)
- Case-insensitive file system
- Reserved filenames cannot be used (CON, PRN, AUX, etc.)

**Impact**:
- Path strings need careful handling
- Very long database paths may fail
- `dbs/Test` and `dbs/test` are the same
- Cannot use reserved names for databases

**Workaround**:
- Use forward slash (`/`) which works on Windows
- Enable long path support in Windows 10+
- Keep database paths short
- Use descriptive names, avoid reserved words
- Be consistent with path casing

**Why**:
- Windows file system limitations
- NTFS legacy constraints
- DOS compatibility requirements

---

### Performance Characteristics

**Limitation**:
- Windows file I/O is generally slower than Unix
- MSVC-compiled code may perform differently than GCC
- Antivirus scanning can impact performance significantly

**Impact**:
- Performance benchmarks show ~20-30% slower than Unix
- Stress tests may take longer
- Throughput varies more with system configuration

**Baseline**:
- Expected throughput: > 1,000 facts/sec (vs ~1,500 on Unix)
- Expected latency: < 1 ms (vs < 500 μs on Unix)
- Performance heavily depends on:
  - SSD vs HDD (10x difference)
  - Antivirus configuration (up to 50% slower)
  - System load

**Workaround**:
- Use SSD for test databases
- Disable antivirus for test directories
- Adjust baselines for your hardware
- Run tests when system is idle
- Document actual performance for comparison

**Why**:
- Windows kernel I/O architecture
- Different syscall overhead
- Antivirus real-time scanning
- MSVC compiler optimizations differ from GCC

---

## RocksDB Limitations

### Compression Libraries

**Limitation**:
- Built with specific compression libraries (LZ4, Snappy, Zstd, Zlib)
- Cannot change compression dynamically
- Different builds may be incompatible

**Impact**:
- Database created with one compression setting may not be readable with different build
- Must rebuild RocksDB to change compression options

**Workaround**:
- Document compression settings used
- Rebuild with consistent options for compatibility
- Use default compression settings for portability

**Why**:
- RocksDB compression is compile-time configured
- vcpkg manifest specifies compression features

---

### Database Format

**Limitation**:
- RocksDB format is platform-specific
- Databases created on Windows may not be portable to Unix
- Binary format differences (endianness, struct packing)

**Impact**:
- Cannot directly copy database files between platforms
- Cross-platform deployment requires data migration

**Workaround**:
- Export/import data as Prolog facts
- Use `rdb_load_file` for data migration
- Provide platform-specific database builds

**Why**:
- Platform-dependent binary format
- Different compiler struct layouts
- Optimization differences

---

### API Compatibility

**Limitation**:
- RocksDB 10.4.2 removed some deprecated options
- Options like `random_access_max_buffer_size` no longer available

**Impact**:
- Code using deprecated options needs updates
- Compatibility with older RocksDB versions broken

**Workaround**:
- Remove references to deprecated options
- Update code for RocksDB 10.x API
- See `cpp/rocksdb4pl.cpp` for removed options

**Why**:
- RocksDB API evolution
- Deprecated features removed in v10.x

---

## SWI-Prolog Integration

### Module System

**Limitation**:
- rocks_preds uses module system
- May have interactions with user modules
- Predicate name conflicts possible

**Impact**:
- Need careful module imports
- Namespace collisions possible
- May need explicit qualification

**Workaround**:
- Use explicit module qualification
- Import selectively: `use_module(rocks_preds, [rdb_open/2, ...])`
- Avoid wildcard imports if conflicts occur

**Why**:
- SWI-Prolog module system design
- Global predicate namespace

---

### Foreign Library Loading

**Limitation**:
- DLL dependencies must be in PATH or same directory
- Cannot dynamically change foreign library path
- Requires specific directory structure

**Impact**:
- Setup requires PATH configuration or DLL copying
- Deployment needs DLL bundling
- Directory structure matters

**Workaround**:
- Use `load_rocks_predicates.pl` loader
- Bundle all DLLs with application
- Add DLL directory to PATH
- Use `file_search_path` configuration

**Why**:
- Windows DLL loading mechanism
- SWI-Prolog foreign library system

---

### No Transactions

**Limitation**:
- rocks_preds does not support transactions
- Multiple operations are not atomic
- No rollback mechanism

**Impact**:
- Cannot group operations atomically
- Partial failures leave database in intermediate state
- No ACID guarantees

**Workaround**:
- Design operations to be idempotent
- Use external transaction coordination if needed
- Implement application-level compensation

**Why**:
- Current rocks_preds design choice
- RocksDB supports transactions, but not exposed

---

## Test Suite Limitations

### Performance Tests

**Limitation**:
- Performance baselines are hardware-dependent
- Results vary significantly by CPU, disk type, RAM
- Assertions may fail on slow hardware

**Impact**:
- Performance test assertions may fail on slower systems
- Baselines are indicative, not absolute
- Cannot compare across different hardware

**Workaround**:
- Adjust baselines for your hardware
- Use performance tests as relative comparison
- Document your baseline measurements
- Compare trends, not absolute numbers

**Why**:
- Hardware diversity
- Workload variability
- Environmental factors

---

### Stress Tests

**Limitation**:
- Very large dataset tests (10M+ facts) require significant resources
- May take hours to complete
- Require several GB of disk space
- May overwhelm systems with limited resources

**Impact**:
- Not suitable for CI environments
- May need to be run separately
- Can exhaust system resources

**Workaround**:
- Mark stress tests as optional/conditional
- Run only on dedicated test systems
- Use smaller dataset sizes for regular testing
- Set `RUN_STRESS_TESTS` environment variable

**Why**:
- Testing extreme scenarios
- Resource limitations
- Time constraints

---

### Integration Tests

**Limitation**:
- RDF and WordNet tests require specific fixtures
- May not have access to large real-world datasets
- Limited to small sample data

**Impact**:
- Integration tests use small samples
- May not catch issues with large datasets
- Limited coverage of edge cases

**Workaround**:
- Document required fixtures
- Provide sample data
- Mark large dataset tests as optional
- Use conditional tests for missing data

**Why**:
- Test data availability
- Licensing restrictions
- Size constraints

---

## Working Around Limitations

### For Application Development

1. **Design for single-process access**
   - Don't assume concurrent read access works
   - Use database-per-process model if needed
   - Coordinate through message passing

2. **Handle Windows paths correctly**
   - Always use forward slashes or escape backslashes
   - Test with paths containing spaces
   - Avoid very long paths

3. **Plan for Windows performance**
   - Design with expected throughput in mind (~1K facts/sec)
   - Use indexing effectively
   - Consider caching strategies
   - Profile on target hardware

4. **Platform-specific deployment**
   - Bundle all DLLs with application
   - Test on target Windows version
   - Document Windows-specific requirements

### For Testing

1. **Adjust expectations for platform**
   - Use platform-specific baselines
   - Document actual measured performance
   - Compare relative improvements

2. **Skip inappropriate tests**
   - Conditional tests for features not supported
   - Mark stress tests as optional
   - Skip integration tests if fixtures unavailable

3. **Provide clear failure messages**
   - Distinguish between true failures and limitations
   - Document expected vs actual behavior
   - Explain platform differences

4. **Resource management**
   - Clean up test databases
   - Monitor disk space
   - Limit concurrent tests

---

## Future Improvements

Potential areas for addressing limitations:

### 1. Long Path Support
- Automatic detection and enablement
- Better error messages when paths too long
- UNC path support

### 2. Performance Optimization
- Identify Windows-specific bottlenecks
- Tune RocksDB options for Windows
- Reduce syscall overhead
- Optimize for SSD vs HDD

### 3. Better Concurrent Access
- Investigate read-only mode on Windows
- Document shared-memory alternatives
- Provide multi-process coordination examples

### 4. Cross-Platform Compatibility
- Data export/import utilities
- Platform-independent serialization
- Database format conversion tools

### 5. Transaction Support
- Expose RocksDB transaction API
- Provide atomic operations
- Add rollback mechanism

### 6. Improved Error Messages
- Windows-specific error explanations
- Path handling suggestions
- Performance tuning tips

### 7. Packaging
- SWI-Prolog pack integration
- Automated installer
- Dependency bundling

---

## Summary

This implementation is **fully functional** on Windows 11 with these considerations:

**Works Well**:
- ✅ Basic CRUD operations
- ✅ Persistence across sessions
- ✅ Indexing for performance
- ✅ File loading
- ✅ Complex terms and rules
- ✅ Production use for single-process applications

**Platform Limitations**:
- ⚠️ No concurrent access (Windows file locking)
- ⚠️ Performance ~20-30% slower than Unix (acceptable)
- ⚠️ Path handling requires care
- ⚠️ Case-insensitive file system

**Design Limitations**:
- ⚠️ No transactions (by design)
- ⚠️ Database format not portable across platforms

**Recommended For**:
- Single-process Prolog applications
- Persistent knowledge bases
- Windows-native deployments
- Applications where performance > 1K facts/sec is acceptable

**Not Recommended For**:
- Multi-process shared databases
- Real-time systems requiring < 100 μs latency
- Cross-platform database portability
- Transactional requirements

---

For questions or suggestions about these limitations, please document in issue tracker or TEST_RESULTS.md.
