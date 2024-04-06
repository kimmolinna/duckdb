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
    try iterateFiles(b, "third_party/fastpforlib");
    fastpforlib.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_fastpforlib.cc" }, .flags = &.{} });
    _ = try basicSetup(b, fastpforlib);

    const fmt = b.addStaticLibrary(.{
        .name = "fmt",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "third_party/fmt");
    fmt.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_fmt.cc" }, .flags = &.{} });
    _ = try basicSetup(b, fmt);

    const fsst = b.addStaticLibrary(.{
        .name = "fsst",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "third_party/fsst");
    fsst.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_fsst.cc" }, .flags = &.{} });
    _ = try basicSetup(b, fsst);

    const hyperloglog = b.addStaticLibrary(.{
        .name = "hyperloglog",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "third_party/hyperloglog");
    hyperloglog.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_hyperloglog.cc" }, .flags = &.{} });
    _ = try basicSetup(b, hyperloglog);

    const mbedtls = b.addStaticLibrary(.{
        .name = "mbedtls",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "third_party/mbedtls");
    mbedtls.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_mbedtls.cc" }, .flags = &.{} });
    _ = try basicSetup(b, mbedtls);

    const miniz = b.addStaticLibrary(.{
        .name = "miniz",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "third_party/miniz");
    miniz.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_miniz.cc" }, .flags = &.{} });
    _ = try basicSetup(b, miniz);

    const pg_query = b.addStaticLibrary(.{
        .name = "pg_query",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "third_party/libpg_query");
    pg_query.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_libpg_query.cc" }, .flags = &.{} });
    pg_query.addIncludePath(std.Build.LazyPath.relative("third_party/libpg_query/include"));
    _ = try basicSetup(b, pg_query);

    const re2 = b.addStaticLibrary(.{
        .name = "re2",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "third_party/re2");
    re2.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_re2.cc" }, .flags = &.{} });
    _ = try basicSetup(b, re2);

    const skiplist = b.addStaticLibrary(.{
        .name = "skiplistlib",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "third_party/skiplist");
    skiplist.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_skiplist.cc" }, .flags = &.{} });
    _ = try basicSetup(b, skiplist);

    const utf8proc = b.addStaticLibrary(.{
        .name = "utf8proc",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "third_party/utf8proc");
    utf8proc.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_utf8proc.cc" }, .flags = &.{} });
    _ = try basicSetup(b, utf8proc);

    const httpfs_extension = b.addStaticLibrary(.{
        .name = "httpfs_extension",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "extension/httpfs");
    httpfs_extension.addCSourceFile(.{ .file = .{ .path = "tmp/extension_httpfs.cc" }, .flags = &.{} });
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
    try iterateFiles(b, "extension/icu");
    icu_extension.addCSourceFile(.{ .file = .{ .path = "tmp/extension_icu.cc" }, .flags = &.{} });
    icu_extension.addIncludePath(std.Build.LazyPath.relative("extension/icu/include"));
    icu_extension.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/common"));
    icu_extension.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/i18n"));
    _ = try basicSetup(b, icu_extension);

    const parquet_extension = b.addStaticLibrary(.{
        .name = "parquet_extension",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "extension/parquet");
    parquet_extension.addCSourceFile(.{ .file = .{ .path = "tmp/extension_parquet.cc" }, .flags = &.{} });
    try iterateFiles(b, "third_party/parquet");
    parquet_extension.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_parquet.cc" }, .flags = &.{} });
    try iterateFiles(b, "third_party/snappy");
    parquet_extension.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_snappy.cc" }, .flags = &.{} });
    try iterateFiles(b, "third_party/thrift");
    parquet_extension.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_thrift.cc" }, .flags = &.{} });
    try iterateFiles(b, "third_party/zstd");
    parquet_extension.addCSourceFile(.{ .file = .{ .path = "tmp/third_party_zstd.cc" }, .flags = &.{} });
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("extension/parquet/include"));
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("third_party/parquet"));
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("third_party/snappy"));
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("third_party/thrift"));
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("third_party/zstd/include"));
    parquet_extension.addIncludePath(std.Build.LazyPath.relative("third_party/lz4"));
    _ = try basicSetup(b, parquet_extension);

    const duckdb = b.addStaticLibrary(.{
        .name = "duckdb_static",
        .target = target,
        .optimize = optimize,
    });
    try iterateFiles(b, "src");
    parquet_extension.addCSourceFile(.{ .file = .{ .path = "tmp/src.cc" }, .flags = &.{} });
    _ = try basicSetup(b, duckdb);
}
fn iterateFiles(b: *std.Build, path: []const u8) !void {
    const allocator = b.allocator;
    const path_size = std.mem.replacementSize(u8, path, "/", "_");
    const file_name_path = try allocator.alloc(u8, path_size);
    defer allocator.free(file_name_path);

    _ = std.mem.replace(u8, path, "/", "_", file_name_path);

    const file_name = try std.fmt.allocPrint(allocator, ("tmp/{s}.cc"), .{file_name_path});
    defer allocator.free(file_name);

    var new_file = try std.fs.cwd().createFile(file_name, .{});
    defer new_file.close();

    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();

    var walker = try dir.walk(allocator);
    defer walker.deinit();

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
                const file = try std.fmt.allocPrint(allocator, ("{s}/{s}"), .{ path, entry.path });
                defer allocator.free(file);

                var orig_file = try std.fs.cwd().openFile(file, .{});
                defer orig_file.close();

                const file_size = (try orig_file.stat()).size;
                var buffer = try allocator.alloc(u8, file_size);
                defer allocator.free(buffer);

                const end_index = try orig_file.readAll(buffer);
                const data = buffer[0..end_index];
                const size = std.mem.replacementSize(u8, data, "#pragma once", "");
                const output = try allocator.alloc(u8, size);
                defer allocator.free(output);

                _ = std.mem.replace(u8, data, "#pragma once", "", output);
                _ = try new_file.write(output);
                _ = try new_file.write("\n");
            }
        }
    }
}
fn basicSetup(b: *std.Build, in: *std.Build.Step.Compile) !void {
    const include_dirs = [_][]const u8{
        "src/include",
        "third_party/concurrentqueue",
        "third_party/fast_float",
        "third_party/fastpforlib",
        "third_party/fmt",
        "third_party/fmt/include",
        "third_party/fsst",
        "third_party/httplib",
        "third_party/hyperloglog",
        "third_party/jaro_winkler",
        "third_party/libpg_query",
        "third_party/libpg_query/include",
        "third_party/mbedtls",
        "third_party/mbedtls/include",
        "third_party/mbedtls/library",
        "third_party/miniparquet",
        "third_party/miniz",
        "third_party/pcg",
        "third_party/re2",
        "third_party/skiplist",
        "third_party/tdigest",
        "third_party/utf8proc",
        "third_party/utf8proc/include",
    };
    for (include_dirs) |include_dir| {
        in.addIncludePath(std.Build.LazyPath.relative(include_dir));
    }
    in.defineCMacro("DUCKDB_BUILD_LIBRARY", null);
    in.linkLibC();
    in.linkLibCpp();
    in.root_module.pic = true;
    in.root_module.strip = true;
    b.installArtifact(in);
}
