### Building Zig
Get the required packages for building and create symbolic links::
```bash
sudo apt-get install zlib1g zlib1g-dev
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
# Fingerprint: 6084 F3CF 814B 57C1 CF12 EFD5 15CF 4D18 AF4F 7421
sudo apt-get update
sudo apt-get install clang-14 libclang-14-dev lldb-14 liblldb-14-dev lld-14 llvm-14 libllvm14 lld-14 liblld-14-dev cmake
sudo ln -s /usr/bin/clang++-14 /usr/bin/c++
sudo ln -s /usr/bin/llvm-config-14 /usr/bin/llvm-config
```

Get Zig source from `git clone https://github.com/ziglang/zig` and build it:

```bash
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC_ZLIB=ON
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
zig build -Drelease-fast=true
zig build -Drelease-fast=true -Dtarget=x86_64-windows-gnu
```
