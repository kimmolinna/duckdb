import os
import re
import sys
import subprocess

version_dir = os.path.join('src', 'include', 'duckdb', 'function', 'pragma')
header_file = os.path.join(version_dir, "version.hpp")

def git_commit_hash():
    return subprocess.check_output(['git','log','-1','--format=%h']).strip().decode('utf8')

def git_dev_version():
    version = subprocess.check_output(['git','describe','--tags','--abbrev=0']).strip().decode('utf8')
    long_version = subprocess.check_output(['git','describe','--tags','--long']).strip().decode('utf8')
    version_splits = version.split('.')
    dev_version = long_version.split('-')[1]
    if int(dev_version) == 0:
        # directly on a tag: emit the regular version
        return '.'.join(version_splits)
    else:
        # not on a tag: increment the version by one and add a -devX suffix
        version_splits[2] = str(int(version_splits[2]) + 1)
        return '.'.join(version_splits) + "-dev" + dev_version

with open_utf8(header_file, 'w') as hfile:
    hfile.write("#pragma once\n")
    hfile.write("#define DUCKDB_SOURCE_ID \"%s\"\n" % git_commit_hash())
    hfile.write("#define DUCKDB_VERSION \"%s\"\n" % git_dev_version())
