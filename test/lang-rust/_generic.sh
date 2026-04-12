#! /bin/sh

FAILED=false

# shellcheck disable=SC2329
assert_failure() {
  printf '   ├ %-60s ' "${1:?Name of the test required}"
  shift 1
  "${@}" >/dev/null && { printf '❌ \e[31mFAILED\e[0m\n' ; FAILED=true ; return 0 ; }
  printf '✅ \e[32mPASSED\e[0m\n'
}

# shellcheck disable=SC2329
assert_success() {
  printf '   ├ %-60s ' "${1:?Name of the test required}"
  shift 1
  "${@}" >/dev/null && { printf '✅ \e[32mPASSED\e[0m\n' ; return 0 ; }
  printf '❌ \e[31mFAILED\e[0m\n'
  FAILED=true
}

report() {
  printf "   └ "
  if ${FAILED:-true}; then
    printf '❌ \e[31mFAILED\e[0m\n'
    exit 1
  else
    printf "✅ \e[32mPASSED\e[0m\n"
    exit 0
  fi
}

trap report EXIT

readonly GENERATE_SHELL_COMPLETIONS="${GENERATE_SHELL_COMPLETIONS:?}"
readonly RUSTUP_DISABLE_AUTO_SELF_UPDATE="${RUSTUP_DISABLE_AUTO_SELF_UPDATE:?}"

readonly RUSTUP_HOME="${RUSTUP_HOME:?}"
readonly CARGO_HOME="${CARGO_HOME:?}"
readonly DCF_LANG_RUST_DIR="${DCF_LANG_RUST_DIR:?}"

assert_success 'lifecycle hook directory exists' test -d "${DCF_LANG_RUST_DIR}/lifecycle_hooks"
assert_success 'lifecycle hook script for onCreateCommand exists' \
  test -s "${DCF_LANG_RUST_DIR}/lifecycle_hooks/on_create_command.sh"

assert_success 'LLDB prettifier exists' test -s "${DCF_LANG_RUST_DIR}/lldb_prettifier.py"

if command -v rustup >/dev/null; then
  if ${GENERATE_SHELL_COMPLETIONS}; then
    assert_success 'shell completions directory exists' test -d /usr/share/bash-completion/completions
    assert_success 'shell completions for rustup exist' \
      test -s /usr/share/bash-completion/completions/rustup
    assert_success 'shell completions for cargo exist' \
      test -s /usr/share/bash-completion/completions/cargo
  fi

  if ${RUSTUP_DISABLE_AUTO_SELF_UPDATE}; then
    assert_success "file that indicates rustup's auto-self-update should be disabled exists" \
      test -f "${DCF_LANG_RUST_DIR}/.rustup_disable_auto_self_update"
  else
    assert_failure "file that indicates rustup's auto-self-update should be disabled does not exist" \
      test -e "${DCF_LANG_RUST_DIR}/.rustup_disable_auto_self_update"
  fi

  assert_success "'RUSTUP_HOME' is set correctly" \
    test "${RUSTUP_HOME}" = /usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_rust/toolchains/rustup/home
  assert_success "'CARGO_HOME' is set correctly" \
    test "${CARGO_HOME}" = /usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_rust/toolchains/cargo/home

  assert_success "directory defined by 'RUSTUP_HOME' exists" test -d "${RUSTUP_HOME}"
  assert_success "directory defined by 'CARGO_HOME' exists"  test -d "${CARGO_HOME}"

  assert_success "directory defined by 'RUSTUP_HOME' has the correct owner" \
    test "$(stat -c '%u' "${RUSTUP_HOME}")" -eq "$(id -u)"
  assert_success "directory defined by 'CARGO_HOME' has the correct owner" \
    test "$(stat -c '%u' "${CARGO_HOME}")" -eq "$(id -u)"
else
  assert_failure 'shell completions for rustup should not exist' \
    test -e /usr/share/bash-completion/completions/rustup
  assert_failure 'shell completions for cargo should not exist' \
    test -e /usr/share/bash-completion/completions/cargo
fi
