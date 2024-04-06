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
    var child = std.ChildProcess.init(&[_][]const u8{ "python3", "scripts/amalgamation.py", "--extended" }, std.heap.page_allocator);
    try child.spawn();
    _ = try child.wait();
    const libduckdb = b.addSharedLibrary(.{
        .name = "duckdb",
        .target = target,
        .optimize = optimize,
    });
    libduckdb.addIncludePath(std.Build.LazyPath.relative("extension/httpfs/include"));
    libduckdb.addIncludePath(std.Build.LazyPath.relative("extension/icu/include"));
    libduckdb.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/common"));
    libduckdb.addIncludePath(std.Build.LazyPath.relative("extension/icu/third_party/icu/i18n"));
    libduckdb.addIncludePath(std.Build.LazyPath.relative("extension/parquet/include"));
    libduckdb.addIncludePath(std.Build.LazyPath.relative("src/amalgamation"));
    libduckdb.addIncludePath(std.Build.LazyPath.relative("third_party/httplib"));
    libduckdb.addIncludePath(std.Build.LazyPath.relative("third_party/libpg_query/include"));
    libduckdb.addIncludePath(std.Build.LazyPath.relative("third_party/openssl/include"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/openssl/lib/libcrypto.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/openssl/lib/libssl.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/win64/crypt32.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/win64/cryptui.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/win64/rstrtmgr.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/win64/ws2_32.lib"));
    libduckdb.step.dependOn(&b.addInstallFileWithDir(
        .{ .path = "third_party/openssl/lib/libssl-3-x64.dll" },
        .bin,
        "libssl-3-x64.dll",
    ).step);
    libduckdb.step.dependOn(&b.addInstallFileWithDir(
        .{ .path = "third_party/openssl/lib/libcrypto-3-x64.dll" },
        .bin,
        "libcrypto-3-x64.dll",
    ).step);
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/catalog.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/common.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/core_funtions.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/execution.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/fastpforlib.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/fmt.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/fsst.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/function.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/httpfs_extension.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/hyperloglog.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/icu_extension.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/main.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/mbedtls.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/miniz.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/optimizer.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/parallel.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/parquet_extension.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/parser.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/pg_query.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/planner.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/re2.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/skiplistlib.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/storage.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/transaction.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/utf8proc.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/verification.lib"));
    libduckdb.defineCMacro("BUILD_HTTPFS_EXTENSION", "TRUE");
    libduckdb.defineCMacro("BUILD_ICU_EXTENSION", "TRUE");
    libduckdb.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    libduckdb.defineCMacro("DUCKDB_BUILD_LIBRARY", null);
    libduckdb.defineCMacro("DUCKDB_MAIN_LIBRARY", null);
    libduckdb.defineCMacro("DUCKDB", null);
    libduckdb.linkLibCpp();
    libduckdb.force_pic = true;
    libduckdb.strip = true;
    b.installArtifact(libduckdb);
}
