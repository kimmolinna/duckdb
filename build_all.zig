const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    //const mode = b.standardReleaseOptions();
    const mode = .ReleaseSmall;

    const include_dirs= [_][]const u8{
        "src/include",
        "third_party/fmt/include",
        "third_party/libpg_query/include",
        "third_party/utf8proc/include",
        "third_party/httplib",
        "third_party/concurrentqueue",
        "third_party/pcg",
        "third_party/zstd/include",
        "third_party/miniparquet",
        "third_party/picohash",
        "third_party/thrift",
        "third_party/fast_float",
        "third_party/parquet",
        "third_party/fastpforlib",
        "third_party/snappy",
        "third_party/hyperloglog",
        "third_party/miniz",
        "third_party/re2",
        "third_party/tdigest",
        "third_party",
        "extension/httpfs/include",
        "extension/icu/include",
        "extension/parquet/include",
    }; 
    
    const duckdb_folders = [_][]const u8{ 
        "src",
        "third_party/fastpforlib",
        "third_party/fmt",
        "third_party/hyperloglog",
        "third_party/libpg_query",
        "third_party/miniz",
        "third_party/re2",
        "third_party/utf8proc",
        "extension/parquet",
        "third_party/parquet",
        "third_party/snappy",
        "third_party/thrift",
        "third_party/zstd",
        "extension/icu",
        "extension/httpfs",
    };

    var duckdb_sources = std.ArrayList([]const u8).init(b.allocator);
    const allowed_exts = [_][]const u8{ ".c", ".cpp", ".cxx", ".c++", ".cc" };
    const excluded_files = [_][]const u8{
        "grammar.cpp",
        "symbols.cpp",
        "utf8proc_data.cpp",
        "parquetcli.cpp"
    };
    for (duckdb_folders) |duckdb_folder| {
        var dir = try std.fs.cwd().openDir(duckdb_folder, .{ .iterate = true });
        var walker = try dir.walk(b.allocator);
        defer walker.deinit();
        var out: [256] u8 = undefined;

        while (try walker.next()) |entry| {
            const ext = std.fs.path.extension(entry.basename);
            const include_file = for (allowed_exts) |e| {
                if (std.mem.eql(u8, ext, e))
                    break true;
                } else false;
            if (include_file) {
                // we have to clone the path as walker.next() or walker.deinit() will override/kill it
                const exclude_file = for (excluded_files) |ex| {
                    if (std.mem.eql(u8,entry.basename,ex))
                        break false;        
                    } else true;
                if (exclude_file){
                    const file = try std.fmt.bufPrint(&out, "{s}/{s}", .{duckdb_folder,entry.path}); 
                    try duckdb_sources.append(b.dupe(file));
                }  
            }
        }
    }   

    const duckdb = b.addSharedLibrary("duckdb",null, .unversioned);
    for (include_dirs) |include_dir|{
        duckdb.addIncludeDir(include_dir);
    }
    
    duckdb.defineCMacro("BUILD_HTTPFS_EXTENSION", "ON");
    duckdb.defineCMacro("BUILD_ICU_EXTENSION", "ON");
    duckdb.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    duckdb.defineCMacro("DUCKDB_BUILD_LIBRARY",null);
    duckdb.defineCMacro("DUCKDB_MAIN_LIBRARY",null);
    duckdb.defineCMacro("duckdb_EXPORTS",null);

    if (target.isWindows()){
        duckdb.addObjectFile("third_party/win64/lib/libssl.lib");
        duckdb.addObjectFile("third_party/win64/lib/libcrypto.lib");
    }else{
        duckdb.linkSystemLibrary("ssl");
        duckdb.linkSystemLibrary("crypto");
    }

    duckdb.addCSourceFiles(duckdb_sources.items, &.{});
    duckdb.force_pic = true;
    duckdb.linkLibCpp();
    duckdb.setBuildMode(mode);
    duckdb.setTarget(target);
    duckdb.strip = true;
    duckdb.install();    

    const shell = b.addExecutable("duckdb", null);
    for (include_dirs) |include_dir|{
        shell.addIncludeDir(include_dir);
    }
    shell.addIncludeDir("tools/shell/include");
    shell.addIncludeDir("tools/sqlite3_api_wrapper/include");
    shell.addIncludeDir("tools/sqlite3_api_wrapper/sqlite3_udf_api/include");
    shell.addIncludeDir("tools/sqlite3_api_wrapper/sqlite3");
    shell.defineCMacro("BUILD_HTTPFS_EXTENSION", "ON");
    shell.defineCMacro("BUILD_ICU_EXTENSION", "ON");
    shell.defineCMacro("BUILD_PARQUET_EXTENSION", "TRUE");
    shell.defineCMacro("DUCKDB_BUILD_LIBRARY",null);
    shell.defineCMacro("DUCKDB_MAIN_LIBRARY",null);
    shell.defineCMacro("SQLITE_SHELL_IS_UTF8", null);
 
    if (target.isWindows()){
        shell.addCSourceFile(
            "tools/sqlite3_api_wrapper/sqlite3/os_win.c", 
            &.{});
        shell.addObjectFile("third_party/win64/lib/libssl.lib");
        shell.addObjectFile("third_party/win64/lib/libcrypto.lib");
    }else{
        shell.linkLibCpp();
        shell.defineCMacro("HAVE_LINENOISE", "1");
        shell.linkSystemLibrary("ssl");
        shell.linkSystemLibrary("crypto");
        shell.addCSourceFile(
            "tools/shell/linenoise.cpp",&.{});
    }
    shell.addCSourceFiles(duckdb_sources.items, &.{});
    shell.addCSourceFile("tools/sqlite3_api_wrapper/sqlite3_api_wrapper.cpp",&.{});
    shell.addCSourceFile("tools/sqlite3_api_wrapper/sqlite3_udf_api/sqlite3_udf_wrapper.cpp",&.{});
    shell.addCSourceFile("tools/sqlite3_api_wrapper/sqlite3_udf_api/cast_sqlite.cpp",&.{});
    shell.addCSourceFile("tools/sqlite3_api_wrapper/sqlite3/printf.c", &.{});
    shell.addCSourceFile("tools/sqlite3_api_wrapper/sqlite3/strglob.c", &.{});
    shell.addCSourceFile("tools/shell/shell.c", &.{});
    shell.linkLibC();
    shell.force_pic = true;
    shell.setBuildMode(mode);
    shell.setTarget(target);
    shell.strip = true;
    shell.install();
 }