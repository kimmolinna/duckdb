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
 
    const hyperloglog = b.addStaticLibrary("hyperloglog", null);
    hyperloglog.addCSourceFiles((try iterateFiles(b, "third_party/hyperloglog")).items, &.{});
    _ = try basicSetup(hyperloglog, mode, target);

    const pg_query = b.addStaticLibrary("pg_query", null);
    pg_query.addCSourceFiles((try iterateFiles(b, "third_party/libpg_query")).items, &.{});
    pg_query.addIncludeDir("third_party/libpg_query/include");
    _ = try basicSetup(pg_query, mode, target);

    const miniz = b.addStaticLibrary("miniz", null);
    miniz.addCSourceFiles((try iterateFiles(b, "third_party/miniz")).items, &.{});
    _ = try basicSetup(miniz, mode, target);

    const re2 = b.addStaticLibrary("re2", null);
    re2.addCSourceFiles((try iterateFiles(b, "third_party/re2")).items, &.{});
    _ = try basicSetup(re2, mode, target);

    const utf8proc = b.addStaticLibrary("utf8proc", null);
    utf8proc.addCSourceFiles((try iterateFiles(b, "third_party/utf8proc")).items, &.{});
    _ = try basicSetup(utf8proc, mode, target);

    const parquet_extension = b.addStaticLibrary("parquet_extension", null);
    parquet_extension.addCSourceFiles((try iterateFiles(b, "extension/parquet")).items, &.{});
    parquet_extension.addCSourceFiles((try iterateFiles(b, "third_party/parquet")).items, &.{});
    parquet_extension.addCSourceFiles((try iterateFiles(b, "third_party/snappy")).items, &.{});
    parquet_extension.addCSourceFiles((try iterateFiles(b, "third_party/thrift")).items, &.{});
    parquet_extension.addCSourceFiles((try iterateFiles(b, "third_party/zstd")).items, &.{});
    parquet_extension.addIncludeDir("extension/parquet/include");
    parquet_extension.addIncludeDir("third_party/parquet");    
    parquet_extension.addIncludeDir("third_party/snappy");    
    parquet_extension.addIncludeDir("third_party/thrift");    
    parquet_extension.addIncludeDir("third_party/zstd/include");    
    _ = try basicSetup(parquet_extension, mode, target);

    const icu_extension = b.addStaticLibrary("icu_extension", null);
    icu_extension.addCSourceFiles((try iterateFiles(b, "extension/icu")).items, &.{});
    icu_extension.addIncludeDir("extension/icu/include");
    icu_extension.addIncludeDir("extension/icu/third_party/icu/common");
    icu_extension.addIncludeDir("extension/icu/third_party/icu/i18n");
    _ = try basicSetup(icu_extension, mode, target);

    const httpfs_extension = b.addStaticLibrary("httpfs_extension", null);
    httpfs_extension.addCSourceFiles((try iterateFiles(b, "extension/httpfs")).items, &.{});
    httpfs_extension.addIncludeDir("extension/httpfs/include");
    httpfs_extension.addIncludeDir("third_party/httplib");
    httpfs_extension.addIncludeDir("third_party/openssl/include");
    httpfs_extension.addIncludeDir("third_party/picohash");
    _ = try basicSetup(httpfs_extension, mode, target);
  
    const duckdb_sources = try iterateFiles(b, "src");    
    const libduckdb = b.addSharedLibrary("duckdb",null, .unversioned);
    libduckdb.addCSourceFiles(duckdb_sources.items, &.{});
    libduckdb.addIncludeDir("extension/httpfs/include");
    libduckdb.addIncludeDir("extension/icu/include");
    libduckdb.addIncludeDir("extension/icu/third_party/icu/common");
    libduckdb.addIncludeDir("extension/icu/third_party/icu/i18n");
    libduckdb.addIncludeDir("extension/parquet/include");
    libduckdb.addIncludeDir("third_party/httplib"); 
    libduckdb.addIncludeDir("third_party/libpg_query/include");
    libduckdb.defineCMacro("BUILD_HTTPFS_EXTENSION", "ON");
    libduckdb.defineCMacro("BUILD_ICU_EXTENSION", "ON");
    libduckdb.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    libduckdb.defineCMacro("duckdb_EXPORTS",null);
    libduckdb.defineCMacro("DUCKDB_MAIN_LIBRARY",null);
    libduckdb.defineCMacro("DUCKDB",null);

    if (target.isWindows() or builtin.os.tag == .windows){
        libduckdb.addObjectFile("third_party/openssl/lib/libcrypto.lib");
        libduckdb.addObjectFile("third_party/openssl/lib/libssl.lib");
        libduckdb.addObjectFile("third_party/win64/ws2_32.lib");
        libduckdb.addObjectFile("third_party/win64/crypt32.lib");
        libduckdb.addObjectFile("third_party/win64/cryptui.lib");
        libduckdb.step.dependOn(
            &b.addInstallFileWithDir(
                .{.path = "third_party/openssl/dll/libssl-3-x64.dll"},
                .bin,
                "libssl-3-x64.dll",
            ).step
        );
        libduckdb.step.dependOn(
            &b.addInstallFileWithDir(
                .{.path = "third_party/openssl/dll/libcrypto-3-x64.dll"},
                .bin,
                "libcrypto-3-x64.dll",
            ).step
        );
    }else{
        libduckdb.linkSystemLibrary("ssl");
        libduckdb.linkSystemLibrary("crypto");
    }
    libduckdb.linkLibrary(re2);
    libduckdb.linkLibrary(fastpforlib);
    libduckdb.linkLibrary(fmt);
    libduckdb.linkLibrary(hyperloglog);
    libduckdb.linkLibrary(miniz);
    libduckdb.linkLibrary(parquet_extension);
    libduckdb.linkLibrary(pg_query);
    libduckdb.linkLibrary(utf8proc);
    libduckdb.linkLibrary(parquet_extension);
    libduckdb.linkLibrary(icu_extension);
    libduckdb.linkLibrary(httpfs_extension);
    _ = try basicSetup(libduckdb, mode, target);
    libduckdb.linkLibC();

    const bun = b.addSharedLibrary("duckdb_bun",null, .unversioned);
    bun.addCSourceFile("third_party/bun/sql.c",&.{});
    bun.linkLibC();
    bun.addIncludeDir("src");    
    bun.addIncludeDir("include");
    bun.linkLibrary(libduckdb);
    _ = try basicSetup(bun, mode, target);

    const static = b.addStaticLibrary("duckdb_static", null);  
    static.addCSourceFiles(duckdb_sources.items, &.{});
    static.addIncludeDir("extension/httpfs/include");
    static.addIncludeDir("extension/icu/include");
    static.addIncludeDir("extension/icu/third_party/icu/common");
    static.addIncludeDir("extension/icu/third_party/icu/i18n");
    static.addIncludeDir("extension/parquet/include");
    static.addIncludeDir("third_party/httplib"); 
    static.addIncludeDir("third_party/libpg_query/include");
    static.defineCMacro("BUILD_HTTPFS_EXTENSION", "ON");
    static.defineCMacro("BUILD_ICU_EXTENSION", "ON");
    static.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    static.defineCMacro("DUCKDB_MAIN_LIBRARY",null);
    static.defineCMacro("DUCKDB",null);
    static.defineCMacro("SQLITE_OMIT_LOAD_EXTENSION","1");
    _ = try basicSetup(static, mode, target);

    const sqlite = b.addStaticLibrary("sqlite_api", null);
    sqlite.addCSourceFiles(
        (try iterateFiles(b, "tools/sqlite3_api_wrapper")).items, &.{});
    if (target.isWindows()){
        sqlite.addCSourceFile(
            "tools/sqlite3_api_wrapper/sqlite3/os_win.c", 
            &.{});}    
    sqlite.addIncludeDir("extension");
    sqlite.addIncludeDir("extension/httpfs/include");
    sqlite.addIncludeDir("extension/icu/include");
    sqlite.addIncludeDir("extension/icu/third_party/icu/common");
    sqlite.addIncludeDir("extension/icu/third_party/icu/i18n");
    sqlite.addIncludeDir("extension/parquet/include");
    sqlite.addIncludeDir("third_party/libpg_query/include");
    sqlite.addIncludeDir("tools/sqlite3_api_wrapper/include");
    sqlite.addIncludeDir("tools/sqlite3_api_wrapper/sqlite3_udf_api/include");
    sqlite.addIncludeDir("tools/sqlite3_api_wrapper/sqlite3");
    sqlite.defineCMacro("BUILD_HTTPFS_EXTENSION", "ON");
    sqlite.defineCMacro("BUILD_ICU_EXTENSION", "ON");
    sqlite.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    sqlite.defineCMacro("SQLITE_SHELL_IS_UTF8", null);
    sqlite.linkLibrary(static);
    sqlite.linkLibrary(utf8proc);
    _ = try basicSetup(sqlite, mode, target);
    sqlite.linkLibC();
    const sqlite_step = b.step("sqlite","Compiling Static library");
    sqlite_step.dependOn(&sqlite.step);
    sqlite_step.dependOn(&static.step);
    sqlite_step.dependOn(&utf8proc.step);
    
// shell aka DuckDBClient
    const shell = b.addExecutable("duckdb", null);
    shell.addCSourceFile("tools/shell/shell.c", &.{});
    shell.addIncludeDir("extension/httpfs/include");
    shell.addIncludeDir("extension/icu/include");
    shell.addIncludeDir("extension/parquet/include");
    shell.addIncludeDir("third_party/libpg_query/include");
    shell.addIncludeDir("third_party/openssl/include");
    shell.addIncludeDir("tools/shell/include");
    shell.addIncludeDir("tools/sqlite3_api_wrapper/include");
    shell.defineCMacro("DUCKDB_BUILD_LIBRARY",null);
    shell.defineCMacro("SQLITE_OMIT_LOAD_EXTENSION", "1");
    if (target.isWindows() or builtin.os.tag == .windows){
        shell.addObjectFile("third_party/openssl/lib/libcrypto.lib");
        shell.addObjectFile("third_party/openssl/lib/libssl.lib");
        shell.addObjectFile("third_party/win64/ws2_32.lib");
        shell.addObjectFile("third_party/win64/crypt32.lib");
        shell.addObjectFile("third_party/win64/cryptui.lib");
        shell.step.dependOn(
            &b.addInstallFileWithDir(
                .{.path = "third_party/openssl/dll/libssl-3-x64.dll"},
                .bin,
                "libssl-3-x64.dll",
            ).step
        );
        shell.step.dependOn(
            &b.addInstallFileWithDir(
                .{.path = "third_party/openssl/dll/libcrypto-3-x64.dll"},
                .bin,
                "libcrypto-3-x64.dll",
            ).step
        );
    }else{
        shell.linkSystemLibrary("ssl");
        shell.linkSystemLibrary("crypto");
        shell.addCSourceFile(
            "tools/shell/linenoise.cpp",&.{});
        shell.defineCMacro("HAVE_LINENOISE", "1");
    }
    shell.linkLibrary(re2);
    shell.linkLibrary(static);
    shell.linkLibrary(fastpforlib);
    shell.linkLibrary(fmt);
    shell.linkLibrary(httpfs_extension);
    shell.linkLibrary(hyperloglog);
    shell.linkLibrary(icu_extension);
    shell.linkLibrary(miniz);    
    shell.linkLibrary(parquet_extension);
    shell.linkLibrary(pg_query);    
    shell.linkLibrary(sqlite);
    shell.linkLibrary(utf8proc);
    _ = try basicSetup(shell, mode, target);
    shell.linkLibC();    
}

fn iterateFiles(b: *std.build.Builder, path: []const u8)!std.ArrayList([]const u8) {
    var files = std.ArrayList([]const u8).init(b.allocator);
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    var walker = try dir.walk(b.allocator);
    defer walker.deinit();
    var out: [256] u8 = undefined;
    const exclude_files:[]const[]const u8 = &.{
        "grammar.cpp","symbols.cpp","os_win.c","linenoise.cpp","parquetcli.cpp",
        "utf8proc_data.cpp","test_sqlite3_api_wrapper.cpp","test_sqlite3_udf_api_wrapper.cpp",};
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
        "third_party/hyperloglog",
        "third_party/miniparquet",
        "third_party/miniz",
        "third_party/pcg",
        "third_party/re2",
        "third_party/tdigest",
        "third_party/utf8proc/include",
    };
    for (include_dirs) |include_dir|{
        in.addIncludeDir(include_dir);
    }
    in.defineCMacro("DUCKDB_BUILD_LIBRARY",null);
    in.linkLibCpp();
    in.setBuildMode(mode);
    in.force_pic = true;
    in.setTarget(target);
    in.strip = true;
    in.install();
}