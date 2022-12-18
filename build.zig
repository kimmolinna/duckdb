const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    var child = std.ChildProcess.init(&[_][]const u8{"python3", "scripts/generate_version_hpp.py"},std.heap.page_allocator);
    try child.spawn();
    _ = try child.wait();

    const fastpforlib = b.addStaticLibrary("fastpforlib", null);
    fastpforlib.addCSourceFiles((try iterateFiles(b, "third_party/fastpforlib")).items, &.{});
    _ = try basicSetup(fastpforlib, mode, target);
 
    const fmt = b.addStaticLibrary("fmt", null);
    fmt.addCSourceFiles((try iterateFiles(b, "third_party/fmt")).items, &.{});
    _ = try basicSetup(fmt, mode, target);

    const fsst = b.addStaticLibrary("fsst", null);
    fsst.addCSourceFiles((try iterateFiles(b, "third_party/fsst")).items, &.{});
    _ = try basicSetup(fsst, mode, target);

    const hyperloglog = b.addStaticLibrary("hyperloglog", null);
    hyperloglog.addCSourceFiles((try iterateFiles(b, "third_party/hyperloglog")).items, &.{});
    _ = try basicSetup(hyperloglog, mode, target);

    const mbedtls = b.addStaticLibrary("mbedtls", null);
    mbedtls.addCSourceFiles((try iterateFiles(b, "third_party/mbedtls")).items, &.{});
    _ = try basicSetup(mbedtls, mode, target);

    const miniz = b.addStaticLibrary("miniz", null);
    miniz.addCSourceFiles((try iterateFiles(b, "third_party/miniz")).items, &.{});
    _ = try basicSetup(miniz, mode, target);

    const pg_query = b.addStaticLibrary("pg_query", null);
    pg_query.addCSourceFiles((try iterateFiles(b, "third_party/libpg_query")).items, &.{});
    pg_query.addIncludePath("third_party/libpg_query/include");
    _ = try basicSetup(pg_query, mode, target);

    const re2 = b.addStaticLibrary("re2", null);
    re2.addCSourceFiles((try iterateFiles(b, "third_party/re2")).items, &.{});
    _ = try basicSetup(re2, mode, target);

    const utf8proc = b.addStaticLibrary("utf8proc", null);
    utf8proc.addCSourceFiles((try iterateFiles(b, "third_party/utf8proc")).items, &.{});
    _ = try basicSetup(utf8proc, mode, target);

    const httpfs_extension = b.addStaticLibrary("httpfs_extension", null);
    httpfs_extension.addCSourceFiles((try iterateFiles(b, "extension/httpfs")).items, &.{});
    httpfs_extension.addIncludePath("extension/httpfs/include");
    httpfs_extension.addIncludePath("third_party/httplib");
    httpfs_extension.addIncludePath("third_party/openssl/include");
    httpfs_extension.addIncludePath("third_party/picohash");
    _ = try basicSetup(httpfs_extension, mode, target);

    const icu_extension = b.addStaticLibrary("icu_extension", null);
    icu_extension.addCSourceFiles((try iterateFiles(b, "extension/icu")).items, &.{});
    icu_extension.addIncludePath("extension/icu/include");
    icu_extension.addIncludePath("extension/icu/third_party/icu/common");
    icu_extension.addIncludePath("extension/icu/third_party/icu/i18n");
    _ = try basicSetup(icu_extension, mode, target);

    const jemalloc_extension = b.addStaticLibrary("jemalloc_extension", null);
    jemalloc_extension.addCSourceFiles((try iterateFiles(b, "extension/jemalloc")).items, &.{});
    jemalloc_extension.addIncludePath("extension/jemalloc/include");
    jemalloc_extension.addIncludePath("extension/jemalloc/jemalloc/include");
    if ((target.isLinux() or builtin.os.tag == .linux)){
        _ = try basicSetup(jemalloc_extension, mode, target);
    }

    const parquet_extension = b.addStaticLibrary("parquet_extension", null);
    parquet_extension.addCSourceFiles((try iterateFiles(b, "extension/parquet")).items, &.{});
    parquet_extension.addCSourceFiles((try iterateFiles(b, "third_party/parquet")).items, &.{});
    parquet_extension.addCSourceFiles((try iterateFiles(b, "third_party/snappy")).items, &.{});
    parquet_extension.addCSourceFiles((try iterateFiles(b, "third_party/thrift")).items, &.{});
    parquet_extension.addCSourceFiles((try iterateFiles(b, "third_party/zstd")).items, &.{});
    parquet_extension.addIncludePath("extension/parquet/include");
    parquet_extension.addIncludePath("third_party/parquet");    
    parquet_extension.addIncludePath("third_party/snappy");    
    parquet_extension.addIncludePath("third_party/thrift");    
    parquet_extension.addIncludePath("third_party/zstd/include");    
    _ = try basicSetup(parquet_extension, mode, target);
  
    const duckdb_sources = try iterateFiles(b, "src");    

    const libduckdb = b.addSharedLibrary("duckdb",null, .unversioned);
    libduckdb.addCSourceFiles(duckdb_sources.items, &.{});
    libduckdb.addIncludePath("extension/httpfs/include");
    libduckdb.addIncludePath("extension/icu/include");
    libduckdb.addIncludePath("extension/icu/third_party/icu/common");
    libduckdb.addIncludePath("extension/icu/third_party/icu/i18n");
    libduckdb.addIncludePath("extension/parquet/include");
    libduckdb.addIncludePath("third_party/httplib");
    libduckdb.addIncludePath("third_party/libpg_query/include");
    libduckdb.addIncludePath("/opt/homebrew/opt/openssl@3/"); 
    libduckdb.defineCMacro("BUILD_HTTPFS_EXTENSION", "TRUE");
    libduckdb.defineCMacro("BUILD_ICU_EXTENSION", "TRUE");
    libduckdb.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    libduckdb.defineCMacro("duckdb_EXPORTS",null);
    libduckdb.defineCMacro("DUCKDB_MAIN_LIBRARY",null);
    libduckdb.defineCMacro("DUCKDB",null);

    if (target.isWindows() or builtin.os.tag == .windows){
        libduckdb.addIncludePath("third_party/openssl/include");
        libduckdb.addObjectFile("third_party/openssl/lib/libcrypto.lib");
        libduckdb.addObjectFile("third_party/openssl/lib/libssl.lib");
        libduckdb.addObjectFile("third_party/win64/ws2_32.lib");
        libduckdb.addObjectFile("third_party/win64/crypt32.lib");
        libduckdb.addObjectFile("third_party/win64/cryptui.lib");
        libduckdb.step.dependOn(
            &b.addInstallFileWithDir(
                .{.path = "third_party/openssl/lib/libssl-3-x64.dll"},
                .bin,
                "libssl-3-x64.dll",
            ).step
        );
        libduckdb.step.dependOn(
            &b.addInstallFileWithDir(
                .{.path = "third_party/openssl/lib/libcrypto-3-x64.dll"},
                .bin,
                "libcrypto-3-x64.dll",
            ).step
        );
    }

    if (target.isLinux() or builtin.os.tag == .linux){
        libduckdb.addIncludePath("third_party/openssl/include");
        libduckdb.defineCMacro("BUILD_JEMALLOC_EXTENSION", "TRUE");
        libduckdb.addIncludePath("extension/jemalloc/include");
        libduckdb.addIncludePath("extension/jemalloc/jemalloc/include"); 
        libduckdb.linkLibrary(jemalloc_extension); 
        libduckdb.linkSystemLibrary("ssl");
        libduckdb.linkSystemLibrary("crypto");
    }

    if (target.isDarwin() or builtin.os.tag == .macos){
        libduckdb.addIncludePath("/opt/homebrew/opt/openssl@3/"); 
        libduckdb.addLibraryPath("/opt/homebrew/opt/openssl@3/lib");
        libduckdb.linkSystemLibrary("ssl");
        libduckdb.linkSystemLibrary("crypto");
    }

    libduckdb.linkLibrary(fastpforlib);
    libduckdb.linkLibrary(fmt);
    libduckdb.linkLibrary(fsst);
    libduckdb.linkLibrary(hyperloglog);
    libduckdb.linkLibrary(mbedtls);
    libduckdb.linkLibrary(miniz);
    libduckdb.linkLibrary(pg_query);
    libduckdb.linkLibrary(re2);
    libduckdb.linkLibrary(utf8proc);
    libduckdb.linkLibrary(parquet_extension);
    libduckdb.linkLibrary(httpfs_extension);
    libduckdb.linkLibrary(icu_extension);
    _ = try basicSetup(libduckdb, mode, target);
    libduckdb.linkLibC();

    const static = b.addStaticLibrary("duckdb_static", null);  
    static.addCSourceFiles(duckdb_sources.items, &.{});
    static.addIncludePath("extension/httpfs/include");
    static.addIncludePath("extension/icu/include");
    static.addIncludePath("extension/icu/third_party/icu/common");
    static.addIncludePath("extension/icu/third_party/icu/i18n");
    static.addIncludePath("extension/parquet/include");
    static.addIncludePath("third_party/httplib"); 
    static.addIncludePath("third_party/libpg_query/include");
    static.defineCMacro("BUILD_HTTPFS_EXTENSION", "TRUE");
    static.defineCMacro("BUILD_ICU_EXTENSION", "TRUE");
    static.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    static.defineCMacro("DUCKDB_MAIN_LIBRARY",null);
    static.defineCMacro("DUCKDB",null);
    static.defineCMacro("SQLITE_OMIT_LOAD_EXTENSION","1");
    _ = try basicSetup(static, mode, target);
    if (target.isLinux() or builtin.os.tag == .linux){
        static.defineCMacro("BUILD_JEMALLOC_EXTENSION", "TRUE");
        static.addIncludePath("extension/jemalloc/include");
        static.addIncludePath("extension/jemalloc/jemalloc/include"); 
    }
 
    const sqlite_api = b.addStaticLibrary("sqlite_api", null);
    sqlite_api.addCSourceFiles(
        (try iterateFiles(b, "tools/sqlite3_api_wrapper")).items, &.{});
    if (target.isWindows()){
        sqlite_api.addCSourceFile(
            "tools/sqlite3_api_wrapper/sqlite3/os_win.c", 
            &.{});}    
    if (target.isLinux() or builtin.os.tag == .linux){
        sqlite_api.defineCMacro("BUILD_JEMALLOC_EXTENSION", "TRUE");
        sqlite_api.addIncludePath("extension/jemalloc/include");
        sqlite_api.addIncludePath("extension/jemalloc/jemalloc/include"); 
    }
    sqlite_api.addIncludePath("extension");
    sqlite_api.addIncludePath("extension/httpfs/include");
    sqlite_api.addIncludePath("extension/icu/include");
    sqlite_api.addIncludePath("extension/icu/third_party/icu/common");
    sqlite_api.addIncludePath("extension/icu/third_party/icu/i18n");
    sqlite_api.addIncludePath("extension/parquet/include");
    sqlite_api.addIncludePath("third_party/catch");
    sqlite_api.addIncludePath("third_party/libpg_query/include");
    sqlite_api.addIncludePath("tools/sqlite3_api_wrapper/include");
    sqlite_api.addIncludePath("tools/sqlite3_api_wrapper/sqlite3_udf_api/include");
    sqlite_api.addIncludePath("tools/sqlite3_api_wrapper/test/include");
    sqlite_api.defineCMacro("BUILD_HTTPFS_EXTENSION", "ON");
    sqlite_api.defineCMacro("BUILD_ICU_EXTENSION", "ON");
    sqlite_api.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    sqlite_api.defineCMacro("SQLITE_SHELL_IS_UTF8", null);
    sqlite_api.defineCMacro("USE_DUCKDB_SHELL_WRAPPER", null);
    sqlite_api.linkLibrary(static);
    sqlite_api.linkLibrary(utf8proc);
    _ = try basicSetup(sqlite_api, mode, target);
    sqlite_api.linkLibC();
    
// shell aka DuckDBClient
    const shell = b.addExecutable("duckdb", null);
    shell.addCSourceFile("tools/shell/shell.c", &.{});
    shell.addIncludePath("extension/httpfs/include");
    shell.addIncludePath("extension/icu/include");
    shell.addIncludePath("extension/parquet/include");
    shell.addIncludePath("third_party/libpg_query/include");
    shell.addIncludePath("tools/shell/include");
    shell.addIncludePath("tools/sqlite3_api_wrapper/include");
    shell.defineCMacro("DUCKDB_BUILD_LIBRARY",null);
    shell.defineCMacro("SQLITE_OMIT_LOAD_EXTENSION", "1");
    if (target.isWindows() or builtin.os.tag == .windows){
        shell.addIncludePath("third_party/openssl/include");
        shell.addObjectFile("third_party/openssl/lib/libcrypto.lib");
        shell.addObjectFile("third_party/openssl/lib/libssl.lib");
        shell.addObjectFile("third_party/win64/ws2_32.lib");
        shell.addObjectFile("third_party/win64/crypt32.lib");
        shell.addObjectFile("third_party/win64/cryptui.lib");
        shell.step.dependOn(
            &b.addInstallFileWithDir(
                .{.path = "third_party/openssl/lib/libssl-3-x64.dll"},
                .bin,
                "libssl-3-x64.dll",
            ).step
        );
        shell.step.dependOn(
            &b.addInstallFileWithDir(
                .{.path = "third_party/openssl/lib/libcrypto-3-x64.dll"},
                .bin,
                "libcrypto-3-x64.dll",
            ).step
        );
    }
    if (target.isLinux() or builtin.os.tag == .linux){
        shell.addIncludePath("third_party/openssl/include");
        shell.linkSystemLibrary("ssl");
        shell.linkSystemLibrary("crypto");
        shell.addCSourceFile(
            "tools/shell/linenoise.cpp",&.{});
        shell.defineCMacro("HAVE_LINENOISE", "1");
        shell.defineCMacro("BUILD_JEMALLOC_EXTENSION", "TRUE");
        shell.linkLibrary(jemalloc_extension);
    }  
    if (target.isDarwin() or builtin.os.tag == .macos){
        shell.addIncludePath("/opt/homebrew/opt/openssl@3/include");
        shell.addLibraryPath("/opt/homebrew/opt/openssl@3/lib");
        shell.linkSystemLibrary("ssl");
        shell.linkSystemLibrary("crypto");
        // commented until @kubkon fixes bug #13985
        // shell.addCSourceFile( 
        //    "tools/shell/linenoise.cpp",&.{});
        // shell.defineCMacro("HAVE_LINENOISE", "1");
    }

    shell.linkLibrary(fastpforlib);
    shell.linkLibrary(fmt);
    shell.linkLibrary(fsst);
    shell.linkLibrary(hyperloglog);
    shell.linkLibrary(mbedtls);
    shell.linkLibrary(miniz);    
    shell.linkLibrary(pg_query);    
    shell.linkLibrary(re2);
    shell.linkLibrary(sqlite_api);
    shell.linkLibrary(static);
    shell.linkLibrary(utf8proc);
    shell.linkLibrary(parquet_extension);
    shell.linkLibrary(httpfs_extension);
    shell.linkLibrary(icu_extension);
    _ = try basicSetup(shell, mode, target);
    shell.linkLibC();
    shell.want_lto = false; 
}

fn iterateFiles(b: *std.build.Builder, path: []const u8)!std.ArrayList([]const u8) {
    var files = std.ArrayList([]const u8).init(b.allocator);
    var dir = try std.fs.cwd().openIterableDir(path, .{ });
    var walker = try dir.walk(b.allocator);
    defer walker.deinit();
    var out: [256] u8 = undefined;
    const exclude_files:[]const[]const u8 = &.{
        "grammar.cpp","symbols.cpp","os_win.c","linenoise.cpp","parquetcli.cpp",
        "utf8proc_data.cpp","test_sqlite3_api_wrapper.cpp"};
    const allowed_exts: []const[]const u8 =  &.{".c", ".cpp", ".cxx", ".c++", ".cc"};
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
            if (!exclude_file){
                const file = try std.fmt.bufPrint(&out, ("{s}/{s}"), .{path,entry.path}); 
                try files.append(b.dupe(file));
            }
        }  
    }
    return files;
}

fn basicSetup(in: *std.build.LibExeObjStep, mode: std.builtin.Mode,target: std.zig.CrossTarget)!void {
    const include_dirs= [_][]const u8{
        "src/include",
        "third_party/concurrentqueue",
        "third_party/fast_float",
        "third_party/fastpforlib",
        "third_party/fmt/include",
        "third_party/fsst",
        "third_party/hyperloglog",
        "third_party/mbedtls/include",
        "third_party/miniparquet",
        "third_party/miniz",
        "third_party/pcg",
        "third_party/re2",
        "third_party/tdigest",
        "third_party/utf8proc/include",
        "third_party/mbedtls/include",
        "third_party/jaro_winkler",
    };
    for (include_dirs) |include_dir|{
        in.addIncludePath(include_dir);
    }
    in.defineCMacro("DUCKDB_BUILD_LIBRARY",null);
    in.linkLibCpp();
    in.setBuildMode(mode);
    in.force_pic = true;
    in.setTarget(target);
    in.strip = true;
    in.install();
}