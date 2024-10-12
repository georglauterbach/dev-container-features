#! /usr/bin/env bash

# shellcheck disable=SC2154

set -e

# shellcheck source=test/rust/lib.sh
source lib.sh

assert_success "rustup::default" "rustup default | grep -F '1.81.0'"

assert_success "rustup::target::aarch" "rustup target list | grep -F 'aarch64'"
assert_success "rustup::target::uefi"  "rustup target list | grep -F 'uefi'"

assert_success "rustup::component::llvm-tools" "rustup component list | grep -F 'llvm-tools'"
assert_success "rustup::component::rustfmt"    "rustup component list | grep -F 'rustfmt'"

command_exists mold
assert_success "linker::mold::version" "mold --version | grep -F '2.34.1'"

reportResults
