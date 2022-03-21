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

    var duckdb_sources = std.ArrayList([]const u8).init(b.allocator);
    var dir = try std.fs.cwd().openDir("src", .{ .iterate = true });
    var walker = try dir.walk(b.allocator);
    defer walker.deinit();
    var out: [256] u8 = undefined;

    const allowed_exts = [_][]const u8{ ".c", ".cpp", ".cxx", ".c++", ".cc" };
    while (try walker.next()) |entry| {
        const ext = std.fs.path.extension(entry.basename);
        const include_file = for (allowed_exts) |e| {
            if (std.mem.eql(u8, ext, e))
                break true;
            } else false;
        if (include_file) {
            // we have to clone the path as walker.next() or walker.deinit() will override/kill it
            const file = try std.fmt.bufPrint(&out, "src/{s}", .{entry.path}); 
            try duckdb_sources.append(b.dupe(file));
        }  
    }

    const fastpforlib = b.addStaticLibrary("fastpforlib", null);
    fastpforlib.addCSourceFile("third_party/fastpforlib/bitpacking.cpp", &.{});
    _ = try basicSetup(fastpforlib, mode, target);

    const fmt = b.addStaticLibrary("fmt", null);
    fmt.addCSourceFile("third_party/fmt/format.cc", &.{});
    _ = try basicSetup(fmt, mode, target);

    const hyperloglog = b.addStaticLibrary("hyperloglog", null);
    hyperloglog.addCSourceFiles(&.{
        "third_party/hyperloglog/hyperloglog.cpp",
        "third_party/hyperloglog/sds.cpp", 
    }, &.{});
    _ = try basicSetup(hyperloglog, mode, target);

    const pg_query = b.addStaticLibrary("pg_query", null);
    pg_query.addCSourceFiles(&.{
        "third_party/libpg_query/pg_functions.cpp",
        "third_party/libpg_query/postgres_parser.cpp",
        "third_party/libpg_query/src_backend_nodes_list.cpp",
        "third_party/libpg_query/src_backend_nodes_makefuncs.cpp",
        "third_party/libpg_query/src_backend_nodes_value.cpp",
        "third_party/libpg_query/src_backend_parser_gram.cpp",
        "third_party/libpg_query/src_backend_parser_parser.cpp", 
        "third_party/libpg_query/src_backend_parser_scan.cpp",
        "third_party/libpg_query/src_backend_parser_scansup.cpp",
        "third_party/libpg_query/src_common_keywords.cpp",
    }, &.{});
    pg_query.addIncludeDir("third_party/libpg_query/include");
    _ = try basicSetup(pg_query, mode, target);
  
    const miniz = b.addStaticLibrary("miniz", null);
    miniz.addCSourceFile("third_party/miniz/miniz.cpp", &.{});
    _ = try basicSetup(miniz, mode, target);

    const duckdb_re2 = b.addStaticLibrary("duckdb_re2", null);
    duckdb_re2.addCSourceFiles(&.{
        "third_party/re2/re2/bitstate.cc",
        "third_party/re2/re2/compile.cc",
        "third_party/re2/re2/dfa.cc",
        "third_party/re2/re2/filtered_re2.cc",
        "third_party/re2/re2/mimics_pcre.cc",
        "third_party/re2/re2/nfa.cc",
        "third_party/re2/re2/onepass.cc",
        "third_party/re2/re2/parse.cc",
        "third_party/re2/re2/perl_groups.cc",
        "third_party/re2/re2/prefilter_tree.cc",
        "third_party/re2/re2/prefilter.cc",
        "third_party/re2/re2/prog.cc",
        "third_party/re2/re2/re2.cc",
        "third_party/re2/re2/regexp.cc",
        "third_party/re2/re2/set.cc",
        "third_party/re2/re2/simplify.cc",
        "third_party/re2/re2/stringpiece.cc",
        "third_party/re2/re2/tostring.cc",
        "third_party/re2/re2/unicode_casefold.cc",
        "third_party/re2/re2/unicode_groups.cc",
        "third_party/re2/util/rune.cc",
        "third_party/re2/util/strutil.cc",
    }, &.{});
    _ = try basicSetup(duckdb_re2, mode, target);

    const utf8proc = b.addStaticLibrary("utf8proc", null);
    utf8proc.addCSourceFiles(&.{
        "third_party/utf8proc/utf8proc_wrapper.cpp",
        "third_party/utf8proc/utf8proc.cpp", 
    }, &.{});
    _ = try basicSetup(utf8proc, mode, target);

    const parquet_extension = b.addStaticLibrary("parquet_extension", null);
    parquet_extension.addCSourceFiles(&.{
        "extension/parquet/column_reader.cpp",
        "extension/parquet/column_writer.cpp",
        "extension/parquet/parquet_metadata.cpp",
        "extension/parquet/parquet_reader.cpp",
        "extension/parquet/parquet_statistics.cpp",
        "extension/parquet/parquet_timestamp.cpp",
        "extension/parquet/parquet_writer.cpp",
        "extension/parquet/parquet-extension.cpp",
        "extension/parquet/zstd_file_system.cpp",
        "third_party/parquet/parquet_constants.cpp",
        "third_party/parquet/parquet_types.cpp",
        "third_party/snappy/snappy-sinksource.cc",
        "third_party/snappy/snappy.cc",
        "third_party/thrift/thrift/protocol/TProtocol.cpp",
        "third_party/thrift/thrift/transport/TBufferTransports.cpp",
        "third_party/thrift/thrift/transport/TTransportException.cpp",
        "third_party/zstd/common/entropy_common.cpp",
        "third_party/zstd/common/error_private.cpp",
        "third_party/zstd/common/fse_decompress.cpp",
        "third_party/zstd/common/xxhash.cpp",
        "third_party/zstd/common/zstd_common.cpp",
        "third_party/zstd/compress/fse_compress.cpp",
        "third_party/zstd/compress/hist.cpp",
        "third_party/zstd/compress/huf_compress.cpp",
        "third_party/zstd/compress/zstd_compress_literals.cpp",
        "third_party/zstd/compress/zstd_compress_sequences.cpp",
        "third_party/zstd/compress/zstd_compress_superblock.cpp",
        "third_party/zstd/compress/zstd_compress.cpp",
        "third_party/zstd/compress/zstd_double_fast.cpp",
        "third_party/zstd/compress/zstd_fast.cpp",
        "third_party/zstd/compress/zstd_lazy.cpp",
        "third_party/zstd/compress/zstd_ldm.cpp",
        "third_party/zstd/compress/zstd_opt.cpp",
        "third_party/zstd/decompress/huf_decompress.cpp",
        "third_party/zstd/decompress/zstd_ddict.cpp",
        "third_party/zstd/decompress/zstd_decompress_block.cpp",
        "third_party/zstd/decompress/zstd_decompress.cpp",
    }, &.{});
    parquet_extension.addIncludeDir("extension/parquet/include");
    parquet_extension.addIncludeDir("third_party/parquet");    
    parquet_extension.addIncludeDir("third_party/snappy");    
    parquet_extension.addIncludeDir("third_party/thrift");    
    parquet_extension.addIncludeDir("third_party/zstd/include");    
    _ = try basicSetup(parquet_extension, mode, target);

    const icu_extension = b.addStaticLibrary("icu_extension", null);
    icu_extension.addCSourceFiles(&.{
        "extension/icu/icu-collate.cpp",
        "extension/icu/icu-dateadd.cpp",
        "extension/icu/icu-datefunc.cpp",
        "extension/icu/icu-datepart.cpp",
        "extension/icu/icu-datesub.cpp",
        "extension/icu/icu-datetrunc.cpp",
        "extension/icu/icu-extension.cpp",
        "extension/icu/icu-makedate.cpp",
    }, &.{});
    icu_extension.addIncludeDir("extension/icu/include");
    _ = try basicSetup(icu_extension, mode, target);

    const httpfs_extension = b.addStaticLibrary("httpfs_extension", null);
    httpfs_extension.addCSourceFiles(&.{
        "extension/httpfs/crypto.cpp",
        "extension/httpfs/httpfs-extension.cpp",
        "extension/httpfs/httpfs.cpp",
        "extension/httpfs/s3fs.cpp",
    }, &.{});
    httpfs_extension.addIncludeDir("extension/httpfs/include");
    httpfs_extension.addIncludeDir("third_party/httplib");
    httpfs_extension.addIncludeDir("third_party/openssl/include");
    httpfs_extension.addIncludeDir("third_party/picohash");
    _ = try basicSetup(httpfs_extension, mode, target);
  
    const duckdb_static = b.addStaticLibrary("duckdb_static", null);  
    duckdb_static.addCSourceFiles(duckdb_sources.items, &.{});
    duckdb_static.addIncludeDir("extension/httpfs/include");
    duckdb_static.addIncludeDir("extension/icu/include");
    duckdb_static.addIncludeDir("extension/parquet/include");
    duckdb_static.addIncludeDir("third_party/httplib"); 
    duckdb_static.addIncludeDir("third_party/libpg_query/include");
    duckdb_static.defineCMacro("BUILD_HTTPFS_EXTENSION", "ON");
    duckdb_static.defineCMacro("BUILD_ICU_EXTENSION", "ON");
    duckdb_static.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    duckdb_static.defineCMacro("DUCKDB_MAIN_LIBRARY",null);
    duckdb_static.defineCMacro("DUCKDB",null);
    duckdb_static.defineCMacro("SQLITE_OMIT_LOAD_EXTENSION","1");
    _ = try basicSetup(duckdb_static, mode, target);
    
    const duckdb = b.addSharedLibrary("duckdb",null, .unversioned);
    duckdb.addCSourceFiles(duckdb_sources.items, &.{});
    duckdb.addIncludeDir("extension/httpfs/include");
    duckdb.addIncludeDir("extension/icu/include");
    duckdb.addIncludeDir("extension/parquet/include");
    duckdb.addIncludeDir("third_party/httplib"); 
    duckdb.addIncludeDir("third_party/libpg_query/include");
    duckdb.defineCMacro("BUILD_HTTPFS_EXTENSION", "ON");
    duckdb.defineCMacro("BUILD_ICU_EXTENSION", "ON");
    duckdb.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    duckdb.defineCMacro("duckdb_EXPORTS",null);
    duckdb.defineCMacro("DUCKDB_MAIN_LIBRARY",null);
    duckdb.defineCMacro("DUCKDB",null);
    if (target.isWindows() or builtin.os.tag == .windows){
        duckdb.addObjectFile("third_party/openssl/lib/libcrypto.lib");
        duckdb.addObjectFile("third_party/openssl/lib/libssl.lib");
        duckdb.addObjectFile("third_party/win64/ws2_32.lib");
        duckdb.addObjectFile("third_party/win64/crypt32.lib");
        duckdb.addObjectFile("third_party/win64/cryptui.lib");
    }else{
        duckdb.linkSystemLibrary("ssl");
        duckdb.linkSystemLibrary("crypto");
    }
    duckdb.linkLibrary(duckdb_re2);
    duckdb.linkLibrary(fastpforlib);
    duckdb.linkLibrary(fmt);
    duckdb.linkLibrary(hyperloglog);
    duckdb.linkLibrary(miniz);
    duckdb.linkLibrary(parquet_extension);
    duckdb.linkLibrary(pg_query);
    duckdb.linkLibrary(utf8proc);
    duckdb.linkLibrary(parquet_extension);
    duckdb.linkLibrary(icu_extension);
    duckdb.linkLibrary(httpfs_extension);
    _ = try basicSetup(duckdb, mode, target);
    duckdb.linkLibC();

    const sqlite3_api_wrapper_static = b.addStaticLibrary("sqlite3_api_wrapper_static", null);
    sqlite3_api_wrapper_static.addCSourceFiles(&.{
        "tools/sqlite3_api_wrapper/sqlite3_api_wrapper.cpp",
        "tools/sqlite3_api_wrapper/sqlite3_udf_api/sqlite3_udf_wrapper.cpp",
        "tools/sqlite3_api_wrapper/sqlite3_udf_api/cast_sqlite.cpp",
        "tools/sqlite3_api_wrapper/sqlite3/printf.c",
        "tools/sqlite3_api_wrapper/sqlite3/strglob.c",
        }, &.{});
    if (target.isWindows()){
        sqlite3_api_wrapper_static.addCSourceFile(
            "tools/sqlite3_api_wrapper/sqlite3/os_win.c", 
            &.{});
    }    
    sqlite3_api_wrapper_static.addIncludeDir("extension");
    sqlite3_api_wrapper_static.addIncludeDir("extension/httpfs/include");
    sqlite3_api_wrapper_static.addIncludeDir("extension/icu/include");
    sqlite3_api_wrapper_static.addIncludeDir("extension/parquet/include");
    sqlite3_api_wrapper_static.addIncludeDir("third_party/libpg_query/include");
    sqlite3_api_wrapper_static.addIncludeDir("tools/sqlite3_api_wrapper/include");
    sqlite3_api_wrapper_static.addIncludeDir("tools/sqlite3_api_wrapper/sqlite3_udf_api/include");
    sqlite3_api_wrapper_static.addIncludeDir("tools/sqlite3_api_wrapper/sqlite3");
    sqlite3_api_wrapper_static.defineCMacro("BUILD_HTTPFS_EXTENSION", "ON");
    sqlite3_api_wrapper_static.defineCMacro("BUILD_ICU_EXTENSION", "ON");
    sqlite3_api_wrapper_static.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    sqlite3_api_wrapper_static.defineCMacro("SQLITE_SHELL_IS_UTF8", null);
    sqlite3_api_wrapper_static.linkLibrary(duckdb_static);
    sqlite3_api_wrapper_static.linkLibrary(utf8proc);
    _ = try basicSetup(sqlite3_api_wrapper_static, mode, target);
    sqlite3_api_wrapper_static.linkLibC();
 
// shell aka DuckDBClient
    const shell = b.addExecutable("duckdb", null);
    shell.addCSourceFile("tools/shell/shell.c", &.{});
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
                .{.path = "third_party/openssl/bin/libssl-3-x64.dll"},
                .bin,
                "libssl-3-x64.dll",
            ).step
        );
        shell.step.dependOn(
            &b.addInstallFileWithDir(
                .{.path = "third_party/openssl/bin/libcrypto-3-x64.dll"},
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
    shell.linkLibrary(duckdb_re2);
    shell.linkLibrary(duckdb_static);
    shell.linkLibrary(fastpforlib);
    shell.linkLibrary(fmt);
    shell.linkLibrary(httpfs_extension);
    shell.linkLibrary(hyperloglog);
    shell.linkLibrary(icu_extension);
    shell.linkLibrary(miniz);    
    shell.linkLibrary(parquet_extension);
    shell.linkLibrary(pg_query);    
    shell.linkLibrary(sqlite3_api_wrapper_static);
    shell.linkLibrary(utf8proc);
    _ = try basicSetup(shell, mode, target);
    shell.linkLibC();    
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
