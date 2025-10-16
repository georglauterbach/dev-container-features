#! /bin/sh

# -----------------------------------------------
# ----  Source third-party libraries  -----------
# -----------------------------------------------

# shellcheck source=/dev/null
. dev-container-features-test-lib

# shellcheck disable=SC2034
readonly DATA_BASE_DIR='/opt/devcontainer/features/ghcr_io/georglauterbach'

# -----------------------------------------------
# ----  Assertions  -----------------------------
# -----------------------------------------------

__expect_failure() {
  sh -c "${*}" && return 1
  return 0
}

assert_failure() {
  __TEST_NAME="${1:?Name of the test required}"
  shift 1

  check "expect::failure|${__TEST_NAME}" __expect_failure "${@}"
}

assert_success() {
  __TEST_NAME="${1:?Name of the test required}"
  shift 1

  check "expect::success|${__TEST_NAME}" sh -c "${*}"
}

# -----------------------------------------------
# ----  Helper  ---------------------------------
# -----------------------------------------------

command_exists() {
  assert_success "command::${1}" command -v "${1}"
}

command_exists_not() {
  assert_failure "command::${1}" command -v "${1}"
}

dir_exists() {
  assert_success "directory::${1}" "[ -d \"${1}\" ]"
}

dir_exists_not() {
  assert_failure "directory::${1}" "[ -d \"${1}\" ]"
}

file_exists() {
  assert_success "file::${1}" "[ -f \"${1}\" ]"
}

file_exists_not() {
  assert_failure "file::${1}" "[ -f \"${1}\" ]"
}

env_is_set_with_value() {
  assert_success "env::set::${1}" "[ -v \"${1}\" ]"
  assert_success "env::set::${1}" "[ \"${1}\" = \"${2}\" ]"
}
