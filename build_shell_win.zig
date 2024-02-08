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
    const duckdb = b.addStaticLibrary(.{
        .name = "duckdb",
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
    duckdb.addLibraryPath(std.Build.LazyPath.relative("zig-out/lib"));
    duckdb.linkSystemLibrary("catalog");
    duckdb.linkSystemLibrary("common");
    duckdb.linkSystemLibrary("core_funtions");
    duckdb.linkSystemLibrary("execution");
    duckdb.linkSystemLibrary("fastpforlib");
    duckdb.linkSystemLibrary("fmt");
    duckdb.linkSystemLibrary("fsst");
    duckdb.linkSystemLibrary("function");
    duckdb.linkSystemLibrary("httpfs_extension");
    duckdb.linkSystemLibrary("hyperloglog");
    duckdb.linkSystemLibrary("icu_extension");
    duckdb.linkSystemLibrary("main");
    duckdb.linkSystemLibrary("mbedtls");
    duckdb.linkSystemLibrary("miniz");
    duckdb.linkSystemLibrary("optimizer");
    duckdb.linkSystemLibrary("parallel");
    duckdb.linkSystemLibrary("parquet_extension");
    duckdb.linkSystemLibrary("parser");
    duckdb.linkSystemLibrary("pg_query");
    duckdb.linkSystemLibrary("planner");
    duckdb.linkSystemLibrary("re2");
    duckdb.linkSystemLibrary("skiplistlib");
    duckdb.linkSystemLibrary("storage");
    duckdb.linkSystemLibrary("transaction");
    duckdb.linkSystemLibrary("utf8proc");
    duckdb.linkSystemLibrary("verification");
    duckdb.linkLibC();
    _ = try basicSetup(b, duckdb);
    const sqlite_api = b.addStaticLibrary(.{
        .name = "sqlite_api",
        .target = target,
        .optimize = optimize,
    });
    sqlite_api.addCSourceFiles(.{
        .files = (try iterateFiles(b, "tools/sqlite3_api_wrapper")).items,
    });
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("tools/sqlite3_api_wrapper/sqlite3"));
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
    sqlite_api.addIncludePath(std.Build.LazyPath.relative("tools/sqlite3_api_wrapper/test/include"));
    sqlite_api.defineCMacro("BUILD_HTTPFS_EXTENSION", "ON");
    sqlite_api.defineCMacro("BUILD_ICU_EXTENSION", "ON");
    sqlite_api.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    sqlite_api.defineCMacro("SQLITE_SHELL_IS_UTF8", null);
    sqlite_api.defineCMacro("USE_DUCKDB_SHELL_WRAPPER", "TRUE");
    sqlite_api.addLibraryPath(std.Build.LazyPath.relative("zig-out/lib"));
    sqlite_api.linkSystemLibrary("utf8proc");
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
    shell.addLibraryPath(std.Build.LazyPath.relative("zig-out/lib"));
    shell.linkSystemLibrary("duckdb");
    shell.linkSystemLibrary("utf8proc");
    shell.linkSystemLibrary("fastpforlib");
    shell.linkSystemLibrary("fmt");
    shell.linkSystemLibrary("fsst");
    shell.linkSystemLibrary("hyperloglog");
    shell.linkSystemLibrary("mbedtls");
    shell.linkSystemLibrary("miniz");
    shell.linkSystemLibrary("pg_query");
    shell.linkSystemLibrary("re2");
    shell.linkSystemLibrary("skiplistlib");
    shell.linkSystemLibrary("utf8proc");
    shell.linkSystemLibrary("parquet_extension");
    shell.linkSystemLibrary("httpfs_extension");
    shell.linkSystemLibrary("icu_extension");
    shell.linkLibrary(sqlite_api);
    shell.linkLibrary(duckdb);
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
