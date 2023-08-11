### Building Zig
Get the required packages for building and create symbolic links::
```bash
sudo apt-get install zlib1g zlib1g-dev
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
# Fingerprint: 6084 F3CF 814B 57C1 CF12 EFD5 15CF 4D18 AF4F 7421
sudo apt-get update
sudo apt-get install clang-16 libclang-16-dev lldb-16 liblldb-16-dev lld-16 llvm-16 libllvm16 lld-16 liblld-16-dev cmake
sudo ln -s /usr/bin/clang++-16 /usr/bin/c++
sudo ln -s /usr/bin/llvm-config-16 /usr/bin/llvm-config
```
Macbook:
```bash
brew install llvm zstd
brew link llvm --force 
```
Get Zig source from `git clone https://github.com/ziglang/zig` and build it:

```bash
mkdir build
cd build
cmake .. -DZIG_STATIC_LLVM=ON -DCMAKE_PREFIX_PATH="$(brew --prefix llvm);$(brew --prefix zstd)"
make install
```

Add Zig-path to enviromental variables.

Get DuckDB source from `git clone https://github.com/kimmolinna/duckdb-zig-build`

Set up an upstream fetch
```bash
 git remote -v
 git remote add upstream https://github.com/duckdb/duckdb.git
 git fetch upstream
 git checkout master
 git merge upstream/master
```
Confirm that the openssl libraries are installed and linked correctly. The following files should be pointing to `libssl.so.3` and `libcrypto.so.3`:

```bash
libssl.so
libcrypto.so
```
And then you are ready to build duckdb
```bash
zig build -Doptimize=ReleaseFast # using build.zig
zig build --build-file build_shell.zig -Doptimize=ReleaseFast  # define build-file 
zig build --build-file build_shell.zig -Doptimize=ReleaseFast -Dtarget=x86_64-windows-gnu
zig build --build-file build_libraries_win.zig -Doptimize=ReleaseFast # build libraries for Windows
zig build --build-file build_dynamic_library_win.zig -Doptimize=ReleaseFast # build dynamic library for Windows
zig build --build-file build_shell_win.zig -Doptimize=ReleaseFast # build shell for Windows
```