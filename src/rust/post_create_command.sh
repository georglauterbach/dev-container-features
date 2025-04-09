#! /usr/bin/env bash

set -eE -u -o pipefail
shopt -s inherit_errexit

# shellcheck disable=SC2157
if [[ -z RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE ]]; then
  echo "INFO  No toolchain file provided - skipping setup"
  exit 0
else
  echo "INFO  Toolchain file set to 'RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE'"
fi

if ! cd "$(dirname "RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE")"; then
  echo "ERROR Could not change into directory of toolchain file 'RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE'" >&2
  exit 1
fi

TOOLCHAIN_VERSION=$(command grep -E 'channel = .*' "RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE" \
  | cut -d '=' -f 2 | tr -d "'\" " || echo '')
readonly TOOLCHAIN_VERSION

echo "INFO  Toolchain version set to '${TOOLCHAIN_VERSION}'"

if [[ -z ${TOOLCHAIN_VERSION} ]]; then
  echo "INFO  Toolchain file 'RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE' does not contain toolchain version information"
  exit 0
fi

echo "INFO  Setting default rustup toolchain version to '${TOOLCHAIN_VERSION}'"
if ! rustup default "${TOOLCHAIN_VERSION}"; then
  echo "ERROR Could not set default toolchain to '${TOOLCHAIN_VERSION}' (loaded from 'RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE')" >&2
  exit 1
fi
