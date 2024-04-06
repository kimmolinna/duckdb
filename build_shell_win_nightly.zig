const std = @import("std");
const builtin = @import("builtin");
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const optimize = b.standardOptimizeOption(.{});
    var child = std.ChildProcess.init(&[_][]const u8{ "python3.11", "scripts/generate_version_hpp.py" }, std.heap.page_allocator);
    try child.spawn();
    _ = try child.wait();
    const fastpforlib = b.addStaticLibrary(.{
        .name = "fastpforlib",
        .target = target,
        .optimize = optimize,
    });
    fastpforlib.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/fastpforlib")).items,
    });

    _ = try basicSetup(b, fastpforlib);
    const fmt = b.addStaticLibrary(.{
        .name = "fmt",
        .target = target,
        .optimize = optimize,
    });
    fmt.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/fmt")).items,
    });

    _ = try basicSetup(b, fmt);
    const fsst = b.addStaticLibrary(.{
        .name = "fsst",
        .target = target,
        .optimize = optimize,
    });
    fsst.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/fsst")).items,
    });
    _ = try basicSetup(b, fsst);
    const hyperloglog = b.addStaticLibrary(.{
        .name = "hyperloglog",
        .target = target,
        .optimize = optimize,
    });
    hyperloglog.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/hyperloglog")).items,
    });
    _ = try basicSetup(b, hyperloglog);
    const mbedtls = b.addStaticLibrary(.{
        .name = "mbedtls",
        .target = target,
        .optimize = optimize,
    });
    mbedtls.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/mbedtls")).items,
    });
    _ = try basicSetup(b, mbedtls);
    const miniz = b.addStaticLibrary(.{
        .name = "miniz",
        .target = target,
        .optimize = optimize,
    });
    miniz.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/miniz")).items,
    });
    _ = try basicSetup(b, miniz);
    const pg_query = b.addStaticLibrary(.{
        .name = "pg_query",
        .target = target,
        .optimize = optimize,
    });
    pg_query.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/libpg_query")).items,
    });
    pg_query.addIncludePath(std.Build.LazyPath.relative("third_party/libpg_query/include"));
    _ = try basicSetup(b, pg_query);
    const re2 = b.addStaticLibrary(.{
        .name = "re2",
        .target = target,
        .optimize = optimize,
    });
    re2.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/re2")).items,
    });
    _ = try basicSetup(b, re2);
    const skiplist = b.addStaticLibrary(.{
        .name = "skiplistlib",
        .target = target,
        .optimize = optimize,
    });
    skiplist.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/skiplist")).items,
    });
    _ = try basicSetup(b, skiplist);
    const utf8proc = b.addStaticLibrary(.{
        .name = "utf8proc",
        .target = target,
        .optimize = optimize,
    });
    utf8proc.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/utf8proc")).items,
    });
    _ = try basicSetup(b, utf8proc);
    const httpfs_extension = b.addStaticLibrary(.{
        .name = "httpfs_extension",
        .target = target,
        .optimize = optimize,
    });
    httpfs_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "extension/httpfs")).items,
    });
    httpfs_extension.addIncludePath(std.Build.LazyPath.relative("extension/httpfs/include"));
    httpfs_extension.addIncludePath(std.Build.LazyPath.relative("third_party/httplib"));
    httpfs_extension.addIncludePath(std.Build.LazyPath.relative("third_party/openssl/include"));
    httpfs_extension.addIncludePath(std.Build.LazyPath.relative("third_party/picohash"));
    _ = try basicSetup(b, httpfs_extension);
    const icu_extension = b.addStaticLibrary(.{
        .name = "icu_extension",
        .target = target,
        .optimize = optimize,
    });
    icu_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "extension/icu")).items,
    });
    icu_extension.addIncludePath(std.Build.LazyPath.relative("extension/icu/include"));
    icu_extension.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/common"));
    icu_extension.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/i18n"));
    _ = try basicSetup(b, icu_extension);

    const parquet_extension = b.addStaticLibrary(.{
        .name = "parquet_extension",
        .target = target,
        .optimize = optimize,
    });
    parquet_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "extension/parquet")).items,
    });
    parquet_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/parquet")).items,
    });
    parquet_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/snappy")).items,
    });
    parquet_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/thrift")).items,
    });
    parquet_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/zstd")).items,
    });
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("extension/parquet/include"));
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("third_party/parquet"));
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("third_party/snappy"));
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("third_party/thrift"));
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("third_party/zstd/include"));
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("third_party/lz4"));
    _ = try basicSetup(b, parquet_extension);
    const catalog = b.addStaticLibrary(.{
        .name = "catalog",
        .target = target,
        .optimize = optimize,
    });
    catalog.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/catalog")).items,
    });
    _ = try basicSetup(b, catalog);
    const common = b.addStaticLibrary(.{
        .name = "common",
        .target = target,
        .optimize = optimize,
    });
    common.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/common")).items,
    });
    _ = try basicSetup(b, common);
    const core_funtions = b.addStaticLibrary(.{
        .name = "core_funtions",
        .target = target,
        .optimize = optimize,
    });
    core_funtions.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/core_functions")).items,
    });
    _ = try basicSetup(b, core_funtions);
    const execution = b.addStaticLibrary(.{
        .name = "execution",
        .target = target,
        .optimize = optimize,
    });
    execution.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/execution")).items,
    });
    _ = try basicSetup(b, execution);
    const function = b.addStaticLibrary(.{
        .name = "function",
        .target = target,
        .optimize = optimize,
    });
    function.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/function")).items,
    });
    _ = try basicSetup(b, function);
    const main = b.addStaticLibrary(.{
        .name = "main",
        .target = target,
        .optimize = optimize,
    });
    main.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/main")).items,
    });
    _ = try basicSetup(b, main);
    const optimizer = b.addStaticLibrary(.{
        .name = "optimizer",
        .target = target,
        .optimize = optimize,
    });
    optimizer.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/optimizer")).items,
    });
    _ = try basicSetup(b, optimizer);
    const parallel = b.addStaticLibrary(.{
        .name = "parallel",
        .target = target,
        .optimize = optimize,
    });
    parallel.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/parallel")).items,
    });
    _ = try basicSetup(b, parallel);
    const parser = b.addStaticLibrary(.{
        .name = "parser",
        .target = target,
        .optimize = optimize,
    });
    parser.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/parser")).items,
    });
    _ = try basicSetup(b, parser);
    const planner = b.addStaticLibrary(.{
        .name = "planner",
        .target = target,
        .optimize = optimize,
    });
    planner.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/planner")).items,
    });
    _ = try basicSetup(b, planner);
    const storage = b.addStaticLibrary(.{
        .name = "storage",
        .target = target,
        .optimize = optimize,
    });
    storage.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/storage")).items,
    });
    _ = try basicSetup(b, storage);
    const transaction = b.addStaticLibrary(.{
        .name = "transaction",
        .target = target,
        .optimize = optimize,
    });
    transaction.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/transaction")).items,
    });
    _ = try basicSetup(b, transaction);
    const verification = b.addStaticLibrary(.{
        .name = "verification",
        .target = target,
        .optimize = optimize,
    });
    verification.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/verification")).items,
    });
    _ = try basicSetup(b, verification);
    const duckdb = b.addStaticLibrary(.{
        .name = "duckdb_static",
        .target = target,
        .optimize = optimize,
    });
    duckdb.addIncludePath(std.Build.LazyPath.relative("extension/httpfs/include"));
    duckdb.addIncludePath(std.Build.LazyPath.relative("extension/icu/include"));
    duckdb.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/common"));
    duckdb.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/i18n"));
    duckdb.addIncludePath(std.Build.LazyPath.relative("extension/parquet/include"));
    duckdb.addIncludePath(std.Build.LazyPath.relative("third_party/httplib"));
    duckdb.addIncludePath(std.Build.LazyPath.relative("third_party/libpg_query/include"));
    duckdb.addIncludePath(std.Build.LazyPath.relative("src/duckdb/execution/index/art/"));
    duckdb.addIncludePath(std.Build.LazyPath.relative("third_party/openssl/include"));
    duckdb.defineCMacro("BUILD_HTTPFS_EXTENSION", "TRUE");
    duckdb.defineCMacro("BUILD_ICU_EXTENSION", "TRUE");
    duckdb.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    duckdb.defineCMacro("DUCKDB_MAIN_LIBRARY", null);
    duckdb.defineCMacro("DUCKDB_USE_STANDARD_ASSERT", null);
    duckdb.defineCMacro("DUCKDB", null);
    duckdb.defineCMacro("SQLITE_OMIT_LOAD_EXTENSION", "1");
    duckdb.linkLibrary(catalog);
    duckdb.linkLibrary(common);
    duckdb.linkLibrary(core_funtions);
    duckdb.linkLibrary(execution);
    duckdb.linkLibrary(fastpforlib);
    duckdb.linkLibrary(fmt);
    duckdb.linkLibrary(fsst);
    duckdb.linkLibrary(function);
    duckdb.linkLibrary(httpfs_extension);
    duckdb.linkLibrary(hyperloglog);
    duckdb.linkLibrary(icu_extension);
    duckdb.linkLibrary(main);
    duckdb.linkLibrary(mbedtls);
    duckdb.linkLibrary(miniz);
    duckdb.linkLibrary(optimizer);
    duckdb.linkLibrary(parallel);
    duckdb.linkLibrary(parquet_extension);
    duckdb.linkLibrary(parser);
    duckdb.linkLibrary(pg_query);
    duckdb.linkLibrary(planner);
    duckdb.linkLibrary(re2);
    duckdb.linkLibrary(skiplist);
    duckdb.linkLibrary(storage);
    duckdb.linkLibrary(transaction);
    duckdb.linkLibrary(utf8proc);
    duckdb.linkLibrary(verification);
    duckdb.linkLibC();
    _ = try basicSetup(b, duckdb);
    const sqlite_api = b.addStaticLibrary(.{
        .name = "sqlite_api",
        .target = target,
        .optimize = optimize,
    });
    sqlite_api.addCSourceFiles(.{ .files = (try iterateFiles(b, "tools/sqlite3_api_wrapper")).items });
    sqlite_api.addCSourceFile(.{ .file = .{ .path = "tools/sqlite3_api_wrapper/sqlite3/os_win.c" }, .flags = &.{"-Wno-error=implicit-function-declaration"} });
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("extension"));
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("extension/httpfs/include"));
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("extension/icu/include"));
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/common"));
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/i18n"));
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("extension/parquet/include"));
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("third_party/catch"));
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("third_party/libpg_query/include"));
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("tools/sqlite3_api_wrapper/include"));
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("tools/sqlite3_api_wrapper/sqlite3_udf_api/include"));
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("tools/sqlite3_api_wrapper/sqlite3"));
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("tools/sqlite3_api_wrapper/test/include"));
    sqlite_api.defineCMacro("BUILD_HTTPFS_EXTENSION", "ON");
    sqlite_api.defineCMacro("BUILD_ICU_EXTENSION", "ON");
    sqlite_api.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    sqlite_api.defineCMacro("SQLITE_SHELL_IS_UTF8", null);
    sqlite_api.defineCMacro("USE_DUCKDB_SHELL_WRAPPER", "TRUE");
    sqlite_api.linkLibrary(utf8proc);
    sqlite_api.linkLibrary(duckdb);
    sqlite_api.linkLibC();
    _ = try basicSetup(b, sqlite_api);
    const shell = b.addExecutable(.{
        .name = "duckdb",
        .target = target,
        .optimize = optimize,
    });
    shell.addCSourceFile(.{ .file = std.Build.LazyPath.relative("tools/shell/shell.c"), .flags = &.{} });
    shell.addIncludePath(std.Build.LazyPath.relative("extension/httpfs/include"));
    shell.addIncludePath(std.Build.LazyPath.relative("extension/icu/include"));
    shell.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/common"));
    shell.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/i18n"));
    shell.addIncludePath(std.Build.LazyPath.relative("extension/parquet/include"));
    shell.addIncludePath(std.Build.LazyPath.relative("third_party/httplib"));
    shell.addIncludePath(std.Build.LazyPath.relative("third_party/libpg_query/include"));
    shell.addIncludePath(std.Build.LazyPath.relative("third_party/openssl/include"));
    shell.addIncludePath(std.Build.LazyPath.relative("tools/shell/include"));
    shell.addIncludePath(std.Build.LazyPath.relative("tools/sqlite3_api_wrapper/include"));
    shell.defineCMacro("DUCKDB_BUILD_LIBRARY", null);
    shell.defineCMacro("SQLITE_OMIT_LOAD_EXTENSION", "1");
    shell.addIncludePath(std.Build.LazyPath.relative("third_party/openssl/include"));
    shell.addObjectFile(std.Build.LazyPath.relative("third_party/openssl/lib/libcrypto.lib"));
    shell.addObjectFile(std.Build.LazyPath.relative("third_party/openssl/lib/libssl.lib"));
    shell.addObjectFile(std.Build.LazyPath.relative("third_party/win64/ws2_32.lib"));
    shell.addObjectFile(std.Build.LazyPath.relative("third_party/win64/crypt32.lib"));
    shell.addObjectFile(std.Build.LazyPath.relative("third_party/win64/cryptui.lib"));
    shell.addObjectFile(std.Build.LazyPath.relative("third_party/win64/rstrtmgr.lib"));
    shell.step.dependOn(&b.addInstallFileWithDir(
        .{ .path = "third_party/openssl/lib/libssl-3-x64.dll" },
        .bin,
        "libssl-3-x64.dll",
    ).step);
    shell.step.dependOn(&b.addInstallFileWithDir(
        .{ .path = "third_party/openssl/lib/libcrypto-3-x64.dll" },
        .bin,
        "libcrypto-3-x64.dll",
    ).step);
    shell.linkLibrary(duckdb);
    shell.linkLibrary(utf8proc);
    shell.linkLibrary(fastpforlib);
    shell.linkLibrary(fmt);
    shell.linkLibrary(fsst);
    shell.linkLibrary(hyperloglog);
    shell.linkLibrary(mbedtls);
    shell.linkLibrary(miniz);
    shell.linkLibrary(pg_query);
    shell.linkLibrary(re2);
    shell.linkLibrary(skiplist);
    shell.linkLibrary(utf8proc);
    shell.linkLibrary(parquet_extension);
    shell.linkLibrary(httpfs_extension);
    shell.linkLibrary(icu_extension);
    shell.linkLibrary(sqlite_api);
    shell.linkLibC();
    shell.want_lto = false;
    _ = try basicSetup(b, shell);
}
fn iterateFiles(b: *std.Build, path: []const u8) !std.ArrayList([]const u8) {
    var files = std.ArrayList([]const u8).init(b.allocator);
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    var walker = try dir.walk(b.allocator);
    defer walker.deinit();
    var out: [256]u8 = undefined;
    const exclude_files: []const []const u8 = &.{ "grammar.cpp", "symbols.cpp", "os_win.c", "linenoise.cpp", "parquetcli.cpp", "utf8proc_data.cpp", "test_sqlite3_api_wrapper.cpp" };
    const allowed_exts: []const []const u8 = &.{ ".c", ".cpp", ".cxx", ".c++", ".cc" };
    while (try walker.next()) |entry| {
        const ext = std.fs.path.extension(entry.basename);
        const include_file = for (allowed_exts) |e| {
            if (std.mem.eql(u8, ext, e))
                break true;
        } else false;
        if (include_file) {
            const exclude_file = for (exclude_files) |e| {
                if (std.mem.eql(u8, entry.basename, e))
                    break true;
            } else false;
            if (!exclude_file) {
                const file = try std.fmt.bufPrint(&out, ("{s}/{s}"), .{ path, entry.path });
                try files.append(b.dupe(file));
            }
        }
    }
    return files;
}
fn basicSetup(b: *std.Build, in: *std.Build.Step.Compile) !void {
    const include_dirs = [_][]const u8{
        "src/include",
        "third_party/concurrentqueue",
        "third_party/fast_float",
        "third_party/fastpforlib",
        "third_party/fmt/include",
        "third_party/fsst",
        "third_party/httplib",
        "third_party/hyperloglog",
        "third_party/jaro_winkler",
        "third_party/libpg_query/include",
        "third_party/mbedtls/include",
        "third_party/miniparquet",
        "third_party/miniz",
        "third_party/pcg",
        "third_party/re2",
        "third_party/skiplist",
        "third_party/tdigest",
        "third_party/utf8proc/include",
    };
    for (include_dirs) |include_dir| {
        in.addIncludePath(std.Build.LazyPath.relative(include_dir));
    }
    in.defineCMacro("DUCKDB_BUILD_LIBRARY", null);
    in.linkLibCpp();
    in.root_module.pic = true;
    in.root_module.strip = true;
    b.installArtifact(in);
}
