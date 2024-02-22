git fetch upstream 
git merge upstream/main
zig build --build-file build_libraries_win.zig -Doptimize=ReleaseFast
zig build --build-file build_dynamic_library_win.zig -Doptimize=ReleaseFast
zig build --build-file build_shell_win.zig -Doptimize=ReleaseFast