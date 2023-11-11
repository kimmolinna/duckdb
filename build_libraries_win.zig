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

    var child = std.ChildProcess.init(&[_][]const u8{"python3.11", "scripts/generate_version_hpp.py"},std.heap.page_allocator);
    try child.spawn();
    _ = try child.wait();
    const fastpforlib = b.addStaticLibrary(.{
        .name = "fastpforlib",
        .target = target,
        .optimize = optimize,
    });
    fastpforlib.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/fastpforlib")).items,
    });
    _ = try basicSetup(b,fastpforlib);
    const fmt = b.addStaticLibrary(.{
        .name = "fmt",
        .target = target,
        .optimize = optimize,
    });
    fmt.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/fmt")).items,
    });
    _ = try basicSetup(b,fmt);
    const fsst = b.addStaticLibrary(.{
        .name = "fsst",
        .target = target,
        .optimize = optimize,
    });
    fsst.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/fsst")).items,
    });
    _ = try basicSetup(b,fsst);
    const hyperloglog = b.addStaticLibrary(.{
        .name = "hyperloglog",
        .target = target,
        .optimize = optimize,
    });
    hyperloglog.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/hyperloglog")).items,
    });
    _ = try basicSetup(b,hyperloglog);
    const mbedtls = b.addStaticLibrary(.{
        .name = "mbedtls",
        .target = target,
        .optimize = optimize,
    });
    mbedtls.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/mbedtls")).items,
    });
    _ = try basicSetup(b,mbedtls);
    const miniz = b.addStaticLibrary(.{
        .name = "miniz",
        .target = target,
        .optimize = optimize,
    });
    miniz.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/miniz")).items,
    });
    _ = try basicSetup(b,miniz);
    const pg_query = b.addStaticLibrary(.{
        .name = "pg_query",
        .target = target,
        .optimize = optimize,
    });
    pg_query.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/libpg_query")).items,
    });
    pg_query.addIncludePath(std.build.LazyPath.relative("third_party/libpg_query/include"));
    _ = try basicSetup(b,pg_query);
    const re2 = b.addStaticLibrary(.{
        .name = "re2",
        .target = target,
        .optimize = optimize,
    });
    re2.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/re2")).items,
    });
    _ = try basicSetup(b,re2);
    const utf8proc = b.addStaticLibrary(.{
        .name = "utf8proc",
        .target = target,
        .optimize = optimize,
    });
    utf8proc.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/utf8proc")).items, 
    });
    _ = try basicSetup(b,utf8proc);
    const httpfs_extension = b.addStaticLibrary(.{
        .name = "httpfs_extension",
        .target = target,
        .optimize = optimize,
    });
    httpfs_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "extension/httpfs")).items,
    });
    httpfs_extension.addIncludePath(std.build.LazyPath.relative("extension/httpfs/include"));
    httpfs_extension.addIncludePath(std.build.LazyPath.relative("third_party/httplib"));
    httpfs_extension.addIncludePath(std.build.LazyPath.relative("third_party/openssl/include"));
    httpfs_extension.addIncludePath(std.build.LazyPath.relative("third_party/picohash"));
    _ = try basicSetup(b,httpfs_extension);
    const icu_extension = b.addStaticLibrary(.{
        .name = "icu_extension",
        .target = target,
        .optimize = optimize,
    });
    icu_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "extension/icu")).items, 
    });
    icu_extension.addIncludePath(std.build.LazyPath.relative("extension/icu/include"));
    icu_extension.addIncludePath(std.build.LazyPath.relative("extension/icu/third_party/icu/common"));
    icu_extension.addIncludePath(std.build.LazyPath.relative("extension/icu/third_party/icu/i18n"));
    _ = try basicSetup(b,icu_extension);

    const parquet_extension = b.addStaticLibrary(.{
        .name = "parquet_extension",
        .target = target,
        .optimize = optimize,
    });
    parquet_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "extension/parquet")).items,
    });
    parquet_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/parquet")).items, 
    });
    parquet_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/snappy")).items, 
    });
    parquet_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/thrift")).items,
    });
    parquet_extension.addCSourceFiles(.{
        .files = (try iterateFiles(b, "third_party/zstd")).items,
    });
    parquet_extension.addIncludePath(std.build.LazyPath.relative("extension/parquet/include"));
    parquet_extension.addIncludePath(std.build.LazyPath.relative("third_party/parquet"));    
    parquet_extension.addIncludePath(std.build.LazyPath.relative("third_party/snappy"));    
    parquet_extension.addIncludePath(std.build.LazyPath.relative("third_party/thrift"));    
    parquet_extension.addIncludePath(std.build.LazyPath.relative("third_party/zstd/include"));    
    _ = try basicSetup(b,parquet_extension);
    const catalog = b.addStaticLibrary(.{
        .name = "catalog",
        .target = target,
        .optimize = optimize,
    });
    catalog.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/catalog")).items,
    });
    _ = try basicSetup(b,catalog);
     const common = b.addStaticLibrary(.{
        .name = "common",
        .target = target,
        .optimize = optimize,
    });
    common.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/common")).items,
    });
    _ = try basicSetup(b,common);
    const core_funtions = b.addStaticLibrary(.{
        .name = "core_funtions",
        .target = target,
        .optimize = optimize,
    });
    core_funtions.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/core_functions")).items,
    });
    _ = try basicSetup(b,core_funtions);
    const execution = b.addStaticLibrary(.{
        .name = "execution",
        .target = target,
        .optimize = optimize,
    });
    execution.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/execution")).items,
    });
    _ = try basicSetup(b,execution);
    const function = b.addStaticLibrary(.{
        .name = "function",
        .target = target,
        .optimize = optimize,
    });
    function.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/function")).items,
    });
    _ = try basicSetup(b,function);
    const main = b.addStaticLibrary(.{
        .name = "main",
        .target = target,
        .optimize = optimize,
    });
    main.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/main")).items,
    });
    _ = try basicSetup(b,main);
    const optimizer = b.addStaticLibrary(.{
        .name = "optimizer",
        .target = target,
        .optimize = optimize,
    });
    optimizer.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/optimizer")).items,
    });
    _ = try basicSetup(b,optimizer);
    const parallel = b.addStaticLibrary(.{
        .name = "parallel",
        .target = target,
        .optimize = optimize,
    });
    parallel.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/parallel")).items,
    });
    _ = try basicSetup(b,parallel);
    const parser = b.addStaticLibrary(.{
        .name = "parser",
        .target = target,
        .optimize = optimize,
    });
    parser.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/parser")).items,
    });
    _ = try basicSetup(b,parser);
    const planner = b.addStaticLibrary(.{
        .name = "planner",
        .target = target,
        .optimize = optimize,
    });
    planner.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/planner")).items,
    });
    _ = try basicSetup(b,planner);
    const storage = b.addStaticLibrary(.{
        .name = "storage",
        .target = target,
        .optimize = optimize,
    });
    storage.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/storage")).items,
    });
    _ = try basicSetup(b,storage);
    const transaction = b.addStaticLibrary(.{
        .name = "transaction",
        .target = target,
        .optimize = optimize,
    });
    transaction.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/transaction")).items,
    });
    _ = try basicSetup(b,transaction);
    const verification = b.addStaticLibrary(.{
        .name = "verification",
        .target = target,
        .optimize = optimize,
    });
    verification.addCSourceFiles(.{
        .files = (try iterateFiles(b, "src/verification")).items,
    });
    _ = try basicSetup(b,verification);

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
        "third_party/httplib",
        "third_party/hyperloglog",
        "third_party/jaro_winkler",
        "third_party/libpg_query/include",
        "third_party/mbedtls/include",
        "third_party/miniparquet",
        "third_party/miniz",
        "third_party/pcg",
        "third_party/re2",
        "third_party/tdigest",
        "third_party/utf8proc/include",
    };
    for (include_dirs) |include_dir|{
        in.addIncludePath(std.build.LazyPath.relative(include_dir));
    }
    in.defineCMacro("DUCKDB_BUILD_LIBRARY",null);
    in.linkLibCpp();
    in.force_pic = true;
    in.strip = true;
    b.installArtifact(in);
}