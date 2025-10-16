#! /bin/sh

set -e -u
. lib.sh

file_exists "${DATA_BASE_DIR}/rust/rustup/home/rustup-init"

command_exists_not rustup
command_exists_not rustc
command_exists_not cargo

dir_exists_not  /usr/share/bash-completion/completions
file_exists_not /usr/share/bash-completion/completions/rustup
file_exists_not /usr/share/bash-completion/completions/cargo

cd
assert_failure "cargo::init" cargo new --bin test_project

reportResults
