#! /usr/bin/env bash

set -e
source lib.sh

assert_success whoami

dir_exists "${DATA_BASE_DIR}/rust"
dir_exists "${DATA_BASE_DIR}/rust/rustup/home"
dir_exists "${DATA_BASE_DIR}/rust/cargo/home"

command_exists rustup
command_exists rustc
command_exists cargo

assert_failure "rustup::default" rustup default

dir_exists  /usr/share/bash-completion/completions
file_exists /usr/share/bash-completion/completions/rustup
file_exists /usr/share/bash-completion/completions/cargo

file_exists "${DATA_BASE_DIR}/rust/rustup/home/rustup-init"
file_exists "${DATA_BASE_DIR}/rust/cargo/home/env"
dir_exists  "${DATA_BASE_DIR}/rust/cargo/home/bin"

reportResults
