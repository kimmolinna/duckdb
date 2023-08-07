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

    var child = std.ChildProcess.init(&[_][]const u8{"python3", "scripts/generate_version_hpp.py"},std.heap.page_allocator);
    try child.spawn();
    _ = try child.wait();
    
// shell aka DuckDBClient
    const shell = b.addExecutable(.{
        .name = "duckdb",
        .target = target,
        .optimize = optimize,
    });
    shell.addCSourceFile("tools/shell/shell.c", &.{});
    shell.addIncludePath("extension/httpfs/include");
    shell.addIncludePath("extension/icu/include");
    shell.addIncludePath("extension/parquet/include");
    shell.addIncludePath("third_party/libpg_query/include");
    shell.addIncludePath("tools/shell/include");
    shell.addIncludePath("tools/sqlite3_api_wrapper/include");
    shell.defineCMacro("DUCKDB_BUILD_LIBRARY",null);
    shell.defineCMacro("SQLITE_OMIT_LOAD_EXTENSION", "1");
    if (target.isWindows()){
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
    if (target.isLinux()){
        shell.addIncludePath("third_party/openssl/include");
        shell.linkSystemLibrary("ssl");
        shell.linkSystemLibrary("crypto");
        shell.addCSourceFile(
            "tools/shell/linenoise.cpp",&.{});
        shell.defineCMacro("HAVE_LINENOISE", "1");
        shell.defineCMacro("BUILD_JEMALLOC_EXTENSION", "TRUE");
        shell.linkSystemLibrary("jemalloc_extension");
    }  
    if (target.isDarwin()){
        shell.addIncludePath("/opt/homebrew/opt/openssl@3/include");
        shell.addLibraryPath("/opt/homebrew/opt/openssl@3/lib");
        shell.linkSystemLibrary("ssl");
        shell.linkSystemLibrary("crypto");
        shell.addCSourceFile( 
            "tools/shell/linenoise.cpp",&.{});
        shell.defineCMacro("HAVE_LINENOISE", "1");
    }
    shell.addLibraryPath("zig-out/lib");
    shell.linkSystemLibrary("fastpforlib");
    shell.linkSystemLibrary("fmt");
    shell.linkSystemLibrary("fsst");
    shell.linkSystemLibrary("hyperloglog");
    shell.linkSystemLibrary("mbedtls");
    shell.linkSystemLibrary("miniz");    
    shell.linkSystemLibrary("pg_query");    
    shell.linkSystemLibrary("re2");
    shell.linkSystemLibrary("sqlite_api");
    shell.linkSystemLibrary("duckdb_static");
    shell.linkSystemLibrary("utf8proc");
    shell.linkSystemLibrary("parquet_extension");
    shell.linkSystemLibrary("httpfs_extension");
    shell.linkSystemLibrary("icu_extension");
    _ = try basicSetup(b,shell);
    shell.linkLibC();
    shell.linkLibCpp();
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

fn basicSetup(b: *std.build.Builder,in: *std.build.LibExeObjStep)!void {
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
    in.force_pic = true;
    in.strip = true;
    b.installArtifact(in);
}