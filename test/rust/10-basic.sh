#! /usr/bin/env bash

set -e
source ../lib.sh

file_exists "${DATA_BASE_DIR}/rust/rustup/home/rustup-init"

command_exists rustup
command_exists rustc
command_exists cargo

dir_exists  /usr/share/bash-completion/completions
file_exists /usr/share/bash-completion/completions/rustup
file_exists /usr/share/bash-completion/completions/cargo

assert_success 'version::rustc'  rustc  --version
assert_success 'version::Cargo'  cargo  --version
assert_success 'version::rustup' rustup --version

assert_success 'rustup::default-toolchain'  'rustup default | grep nightly'
assert_success 'rustup::additional-targets' "rustup target list | grep -q 'aarch64-unknown-linux-gnu (installed)'"
assert_success 'rustup::additional-components' "rustup component list | grep -q 'rust-docs-aarch64-unknown-linux-gnu (installed)'"
assert_success 'rustup::additional-components' "rustup component list | grep -q 'rustfmt-aarch64-unknown-linux-gnu (installed)'"

cd
assert_success "cargo::init" cargo new --bin test_project
cd test_project
assert_success "cargo::run"  cargo run

reportResults
