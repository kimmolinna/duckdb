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
    libduckdb.addIncludePath(std.Build.LazyPath.relative("third_party/httplib"));
    libduckdb.addIncludePath(std.Build.LazyPath.relative("third_party/libpg_query/include"));
    libduckdb.addIncludePath(std.Build.LazyPath.relative("third_party/openssl/include"));
    libduckdb.addIncludePath(std.Build.LazyPath.relative("third_party/openssl/include"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/openssl/lib/libcrypto.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/openssl/lib/libssl.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/win64/ws2_32.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/win64/crypt32.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/win64/cryptui.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("third_party/win64/rstrtmgr.lib"));
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
    libduckdb.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src")).items,
    });
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/catalog.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/common.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/core_funtions.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/execution.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/function.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/main.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/optimizer.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/parallel.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/parser.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/planner.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/storage.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/transaction.lib"));
    // libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/verification.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/fastpforlib.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/fmt.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/fsst.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/httpfs_extension.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/hyperloglog.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/icu_extension.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/mbedtls.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/miniz.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/parquet_extension.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/pg_query.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/re2.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/skiplistlib.lib"));
    libduckdb.addObjectFile(std.Build.LazyPath.relative("zig-out/lib/utf8proc.lib"));
    _ = try basicSetup(b, libduckdb);
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
    in.defineCMacro("BUILD_HTTPFS_EXTENSION", "TRUE");
    in.defineCMacro("BUILD_ICU_EXTENSION", "TRUE");
    in.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    in.defineCMacro("DUCKDB_MAIN_LIBRARY", null);
    in.defineCMacro("DUCKDB_BUILD_LIBRARY", null);
    in.defineCMacro("_WIN32", null);
    in.defineCMacro("DUCKDB", null);
    in.linkLibC();
    in.linkLibCpp();
    in.root_module.pic = true;
    in.root_module.strip = true;
    b.installArtifact(in);
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
