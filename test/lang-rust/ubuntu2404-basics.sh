#! /bin/bash

set -eE -u -o pipefail
shopt -s inherit_errexit

source lib.sh

command_exists_not rustup
command_exists_not rustc
command_exists_not cargo

dir_exists_not  /usr/share/bash-completion/completions
file_exists_not /usr/share/bash-completion/completions/rustup
file_exists_not /usr/share/bash-completion/completions/cargo

cd
assert_failure "cargo::init" cargo new --bin test_project

reportResults
