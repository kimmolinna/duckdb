### Building Zig
Get the required packages for building and create symbolic links::
```bash
sudo apt-get install clang-13 libclang-13-dev lldb-13 liblldb-13-dev lld-13 llvm-13 libllvm13 lld-13 liblld-13-dev cmake
sudo ln -s /usr/bin/clang++-13 /usr/bin/c++
sudo ln -s /usr/bin/llvm-config-13 /usr/bin/llvm-config
```

Get Zig source from `git clone https://github.com/ziglang/zig` and build it:

```bash
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make install
```
Add Zig-path to enviromental variables.

Get DuckDB source from `git clone https://github.com/kimmolinna/duckdb`

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
zig build
zig build -Dtarget=x86_64-windows-gnu
```