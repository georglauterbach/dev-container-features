#! /usr/bin/env bash

# -----------------------------------------------
# ----  Source third-party libraries  -----------
# -----------------------------------------------

# shellcheck source=/dev/null
source dev-container-features-test-lib

# shellcheck disable=SC2034
readonly DATA_BASE_DIR='/usr/local/share/dev_containers/features/ghcr_io/georglauterbach'

# -----------------------------------------------
# ----  Assertions  -----------------------------
# -----------------------------------------------

function __expect_failure() {
  bash -c "${*}" && return 1
  return 0
}

function assert_failure() {
  local TEST_NAME="${1:?Name of the test required}"
  shift 1

  check "expect::failure|${TEST_NAME}" __expect_failure "${@}"
}

function assert_success() {
  local TEST_NAME="${1:?Name of the test required}"
  shift 1

  check "expect::success|${TEST_NAME}" bash -c "${*}"
}

# -----------------------------------------------
# ----  Helper  ---------------------------------
# -----------------------------------------------

function command_exists() {
  assert_success "command::${1}" command -v "${1}"
}

function command_exists_not() {
  assert_failure "command::${1}" command -v "${1}"
}

function dir_exists() {
  assert_success "directory::${1}" "[[ -d ${1} ]]"
}

function dir_exists_not() {
  assert_failure "directory::${1}" "[[ -d ${1} ]]"
}

function file_exists() {
  assert_success "file::${1}" "[[ -f ${1} ]]"
}

function file_exists_not() {
  assert_failure "file::${1}" "[[ -f ${1} ]]"
}

function env_is_set_with_value() {
  assert_success "env::set::${1}" "[[ -v ${1} ]]"
  assert_success "env::set::${1}" "[[ ${1} == ${2} ]]"
}
