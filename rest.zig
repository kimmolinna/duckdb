            duckdb.defineCMacro("_CRT_SECURE_NO_WARNINGS", null);
        duckdb.defineCMacro("_SCL_SECURE_NO_WARNINGS", null);
        duckdb.defineCMacro("_UNICODE", null);  
        duckdb.defineCMacro("NOMINMAX", null);
        duckdb.defineCMacro("STRICT", null);
        duckdb.defineCMacro("UNICODE", null);

                duckdb.linkSystemLibrary("libssl");
        duckdb.linkSystemLibrary("libcrypto");
        duckdb.step.dependOn(
            &b.addInstallFileWithDir(
                .{.path = "third_party/win64/libssl-3-x64.dll"},
                .bin,
                "libssl-3-x64.dll",
            ).step
        );
        duckdb.step.dependOn(
            &b.addInstallFileWithDir(
                .{.path = "third_party/win64/libcrypto-3-x64.dll"},
                .bin,
                "libcrypto-3-x64.dll",
            ).step
        );
