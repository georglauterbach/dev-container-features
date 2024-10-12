#! /usr/bin/env bash

# shellcheck disable=SC2154

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "Rust version" rustc --version
check "Cargo version" cargo --version
check "rustup version" rustc --version

for ENV_VARIABLE in                      \
  'RUST_INSTALL'                         \
  'RUST_RUSTUP_DEFAULT_TOOLCHAIN'        \
  'RUST_RUSTUP_UPDATE_DEFAULT_TOOLCHAIN'
do
  check "Variable '${ENV_VARIABLE}'" \
    echo "${ENV_VARIABLE}=${!ENV_VARIABLE:?${ENV_VARIABLE} not set or null}"
done

reportResults
