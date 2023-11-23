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
    const optimize = b.standardOptimizeOption(.{});
    const libduckdb = b.addSharedLibrary(.{
        .name = "duckdb",
        .target = target,
        .optimize = optimize,
    });
    libduckdb.addIncludePath(std.build.LazyPath.relative("extension/httpfs/include"));
    libduckdb.addIncludePath(std.build.LazyPath.relative("extension/icu/include"));
    libduckdb.addIncludePath(std.build.LazyPath.relative("extension/icu/third_party/icu/common"));
    libduckdb.addIncludePath(std.build.LazyPath.relative("extension/icu/third_party/icu/i18n"));
    libduckdb.addIncludePath(std.build.LazyPath.relative("extension/jemalloc/include"));
    libduckdb.addIncludePath(std.build.LazyPath.relative("extension/jemalloc/jemalloc/include"));
    libduckdb.addIncludePath(std.build.LazyPath.relative("extension/parquet/include"));
    libduckdb.addIncludePath(std.build.LazyPath.relative("third_party/httplib"));
    libduckdb.addIncludePath(std.build.LazyPath.relative("third_party/libpg_query/include"));
    libduckdb.addIncludePath(std.build.LazyPath.relative("third_party/openssl/include"));
    libduckdb.defineCMacro("BUILD_HTTPFS_EXTENSION", "TRUE");
    libduckdb.defineCMacro("BUILD_ICU_EXTENSION", "TRUE");
    libduckdb.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    libduckdb.defineCMacro("duckdb_EXPORTS", null);
    libduckdb.defineCMacro("DUCKDB_MAIN_LIBRARY", null);
    libduckdb.defineCMacro("DUCKDB", null);
    if (target.isWindows() or builtin.os.tag == .windows) {
        libduckdb.addIncludePath(std.build.LazyPath.relative("third_party/openssl/include"));
        libduckdb.addObjectFile(std.build.LazyPath.relative("third_party/openssl/lib/libcrypto.lib"));
        libduckdb.addObjectFile(std.build.LazyPath.relative("third_party/openssl/lib/libssl.lib"));
        libduckdb.addObjectFile(std.build.LazyPath.relative("third_party/win64/ws2_32.lib"));
        libduckdb.addObjectFile(std.build.LazyPath.relative("third_party/win64/crypt32.lib"));
        libduckdb.addObjectFile(std.build.LazyPath.relative("third_party/win64/cryptui.lib"));
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
    }
    if (target.isLinux()) {
        libduckdb.addIncludePath(std.build.LazyPath.relative("third_party/openssl/include"));
        libduckdb.linkSystemLibrary("ssl");
        libduckdb.linkSystemLibrary("crypto");
    }
    if (target.isDarwin()) {
        libduckdb.addIncludePath(std.build.LazyPath.relative("/opt/homebrew/opt/openssl@3/"));
        libduckdb.addLibraryPath(std.build.LazyPath.relative("/opt/homebrew/opt/openssl@3/lib"));
        libduckdb.linkSystemLibrary("ssl");
        libduckdb.linkSystemLibrary("crypto");
    }
    libduckdb.addLibraryPath(std.build.LazyPath.relative("zig-out/lib"));
    libduckdb.linkSystemLibrary("catalog");
    libduckdb.linkSystemLibrary("common");
    libduckdb.linkSystemLibrary("core_funtions");
    libduckdb.linkSystemLibrary("execution");
    libduckdb.linkSystemLibrary("fastpforlib");
    libduckdb.linkSystemLibrary("fmt");
    libduckdb.linkSystemLibrary("fsst");
    libduckdb.linkSystemLibrary("function");
    libduckdb.linkSystemLibrary("httpfs_extension");
    libduckdb.linkSystemLibrary("hyperloglog");
    libduckdb.linkSystemLibrary("icu_extension");
    libduckdb.linkSystemLibrary("main");
    libduckdb.linkSystemLibrary("mbedtls");
    libduckdb.linkSystemLibrary("miniz");
    libduckdb.linkSystemLibrary("optimizer");
    libduckdb.linkSystemLibrary("parallel");
    libduckdb.linkSystemLibrary("parquet_extension");
    libduckdb.linkSystemLibrary("parser");
    libduckdb.linkSystemLibrary("pg_query");
    libduckdb.linkSystemLibrary("planner");
    libduckdb.linkSystemLibrary("re2");
    libduckdb.linkSystemLibrary("skiplistlib");
    libduckdb.linkSystemLibrary("storage");
    libduckdb.linkSystemLibrary("transaction");
    libduckdb.linkSystemLibrary("utf8proc");
    libduckdb.linkSystemLibrary("verification");
    libduckdb.linkLibC();
    _ = try basicSetup(b, libduckdb);
}
fn basicSetup(b: *std.build.Builder, in: *std.build.LibExeObjStep) !void {
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
        in.addIncludePath(std.build.LazyPath.relative(include_dir));
    }
    in.defineCMacro("DUCKDB_BUILD_LIBRARY", null);
    in.linkLibCpp();
    in.force_pic = true;
    in.strip = true;
    b.installArtifact(in);
}
