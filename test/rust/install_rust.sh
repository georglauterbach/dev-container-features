#! /usr/bin/env bash

# shellcheck disable=SC2154

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "Rust version" rustc --version
check "Cargo version" cargo --version
check "rustup version" rustc --version

echo "${RUST_RUSTUP_DEFAULT_TOOLCHAIN}" >/tmp/rust_version

reportResults
