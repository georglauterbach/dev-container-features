#! /usr/bin/env bash

# shellcheck disable=SC2154

set -e
source lib.sh

command_exists mold
assert_success "linker::mold::version" "mold --version | grep -F '2.39.0'"

reportResults
