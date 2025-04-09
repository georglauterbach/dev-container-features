#! /usr/bin/env bash

set -e

# shellcheck source=./lib.sh
source lib.sh

assert_success whoami

dir_exists /usr/rust
dir_exists /usr/rust/rustup
dir_exists /usr/rust/cargo/home
dir_exists /usr/rust/cargo/target

command_exists rustup
command_exists rustc
command_exists cargo

assert_failure "rustup::default" rustup default

dir_exists  /usr/share/bash-completion/completions
file_exists /usr/share/bash-completion/completions/rustup
file_exists /usr/share/bash-completion/completions/cargo

file_exists /usr/rust/rustup/rustup-init
file_exists /usr/rust/cargo/home/env
dir_exists  /usr/rust/cargo/home/bin

reportResults
