#! /usr/bin/env bash

set -e
source lib.sh

command_exists_not rustup
command_exists_not rustc
command_exists_not cargo

file_exists_not /usr/share/bash-completion/completions/rustup
file_exists_not /usr/share/bash-completion/completions/cargo

file_exists "${DATA_BASE_DIR}/rust/prettifier_for_lldb.py"

reportResults
