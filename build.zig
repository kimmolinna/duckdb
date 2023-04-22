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

    const fastpforlib = b.addStaticLibrary(.{
        .name = "fastpforlib",
        .target = target,
        .optimize = optimize,
    });
    fastpforlib.addCSourceFiles((try iterateFiles(b, "third_party/fastpforlib")).items, &.{});
    _ = try basicSetup(b,fastpforlib);
 
    const fmt = b.addStaticLibrary(.{
        .name = "fmt",
        .target = target,
        .optimize = optimize,
    });
    fmt.addCSourceFiles((try iterateFiles(b, "third_party/fmt")).items, &.{});
    _ = try basicSetup(b,fmt);

    const fsst = b.addStaticLibrary(.{
        .name = "fsst",
        .target = target,
        .optimize = optimize,
    });
    fsst.addCSourceFiles((try iterateFiles(b, "third_party/fsst")).items, &.{});
    _ = try basicSetup(b,fsst);

    const hyperloglog = b.addStaticLibrary(.{
        .name = "hyperloglog",
        .target = target,
        .optimize = optimize,
    });
    hyperloglog.addCSourceFiles((try iterateFiles(b, "third_party/hyperloglog")).items, &.{});
    _ = try basicSetup(b,hyperloglog);

    const mbedtls = b.addStaticLibrary(.{
        .name = "mbedtls",
        .target = target,
        .optimize = optimize,
    });
    mbedtls.addCSourceFiles((try iterateFiles(b, "third_party/mbedtls")).items, &.{});
    _ = try basicSetup(b,mbedtls);

    const miniz = b.addStaticLibrary(.{
        .name = "miniz",
        .target = target,
        .optimize = optimize,
    });
    miniz.addCSourceFiles((try iterateFiles(b, "third_party/miniz")).items, &.{});
    _ = try basicSetup(b,miniz);

    const pg_query = b.addStaticLibrary(.{
        .name = "pg_query",
        .target = target,
        .optimize = optimize,
    });
    pg_query.addCSourceFiles((try iterateFiles(b, "third_party/libpg_query")).items, &.{});
    pg_query.addIncludePath("third_party/libpg_query/include");
    _ = try basicSetup(b,pg_query);

    const re2 = b.addStaticLibrary(.{
        .name = "re2",
        .target = target,
        .optimize = optimize,
    });
    re2.addCSourceFiles((try iterateFiles(b, "third_party/re2")).items, &.{});
    _ = try basicSetup(b,re2);

    const utf8proc = b.addStaticLibrary(.{
        .name = "utf8proc",
        .target = target,
        .optimize = optimize,
    });
    utf8proc.addCSourceFiles((try iterateFiles(b, "third_party/utf8proc")).items, &.{});
    _ = try basicSetup(b,utf8proc);

    const httpfs_extension = b.addStaticLibrary(.{
        .name = "httpfs_extension",
        .target = target,
        .optimize = optimize,
    });
    httpfs_extension.addCSourceFiles((try iterateFiles(b, "extension/httpfs")).items, &.{});
    httpfs_extension.addIncludePath("extension/httpfs/include");
    httpfs_extension.addIncludePath("third_party/httplib");
    httpfs_extension.addIncludePath("third_party/openssl/include");
    httpfs_extension.addIncludePath("third_party/picohash");
    _ = try basicSetup(b,httpfs_extension);

    const icu_extension = b.addStaticLibrary(.{
        .name = "icu_extension",
        .target = target,
        .optimize = optimize,
    });
    icu_extension.addCSourceFiles((try iterateFiles(b, "extension/icu")).items, &.{});
    icu_extension.addIncludePath("extension/icu/include");
    icu_extension.addIncludePath("extension/icu/third_party/icu/common");
    icu_extension.addIncludePath("extension/icu/third_party/icu/i18n");
    _ = try basicSetup(b,icu_extension);

    const jemalloc_extension = b.addStaticLibrary(.{
        .name = "jemalloc_extension",
        .target = target,
        .optimize = optimize,
    });
    jemalloc_extension.addCSourceFiles((try iterateFiles(b, "extension/jemalloc")).items, &.{});
    jemalloc_extension.addIncludePath("extension/jemalloc/include");
    jemalloc_extension.addIncludePath("extension/jemalloc/jemalloc/include");
    if ((target.isLinux() or builtin.os.tag == .linux)){
        _ = try basicSetup(b,jemalloc_extension);
    }

    const parquet_extension = b.addStaticLibrary(.{
        .name = "parquet_extension",
        .target = target,
        .optimize = optimize,
    });
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
    _ = try basicSetup(b,parquet_extension);
  
    const duckdb_sources = try iterateFiles(b, "src");    

    const libduckdb = b.addSharedLibrary(.{
        .name = "duckdb",
        .target = target,
        .optimize = optimize,
    });
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
    _ = try basicSetup(b,libduckdb);
    libduckdb.linkLibC();
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

fn basicSetup(b:*std.build.Builder, in: *std.build.LibExeObjStep)!void {
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