#! /usr/bin/env bash

# shellcheck disable=SC2154

set -e

# shellcheck source=test/rust/lib.sh
source lib.sh

echo "RUSTUP_HOME=${RUSTUP_HOME}"

ls -lh /usr/rust/rustup/toolchains
ls -lh /usr/rust/cargo/home
ls -lh /usr/rust/cargo/home/bin

command_exists rustup
command_exists rustc
command_exists cargo

assert_success "rustup::default" "rustup default | grep stable"

assert_success "version::rustc" rustc --version
assert_success "version::Cargo" cargo --version
assert_success "version::rustup" rustc --version

reportResults