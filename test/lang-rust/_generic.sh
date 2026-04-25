#! /bin/sh

. ./_harness.sh

readonly GENERATE_SHELL_COMPLETIONS="${GENERATE_SHELL_COMPLETIONS:?}"
readonly RUSTUP_DISABLE_AUTO_SELF_UPDATE="${RUSTUP_DISABLE_AUTO_SELF_UPDATE:?}"

readonly RUSTUP_HOME="${RUSTUP_HOME:?}"
readonly CARGO_HOME="${CARGO_HOME:?}"
readonly DCF_LANG_RUST_DIR="${DCF_LANG_RUST_DIR:?}"

assert_success 'LLDB prettifier exists'          test -s "${DCF_LANG_RUST_DIR}/lldb_prettifier.py"

if command -v rustup >/dev/null; then
  if ${GENERATE_SHELL_COMPLETIONS}; then
    assert_success 'shell completions directory exists' \
      test -d /usr/share/bash-completion/completions
    assert_success 'shell completions for rustup exist' \
      test -s /usr/share/bash-completion/completions/rustup
    assert_success 'shell completions for cargo exist'  \
      test -s /usr/share/bash-completion/completions/cargo
  fi

  if ${RUSTUP_DISABLE_AUTO_SELF_UPDATE}; then
    assert_success "file that indicates rustup's auto-self-update should be disabled exists" \
      test -f "${DCF_LANG_RUST_DIR}/.rustup_disable_auto_self_update"
  else
    assert_failure "file that indicates rustup's auto-self-update should be disabled does not exist" \
      test -e "${DCF_LANG_RUST_DIR}/.rustup_disable_auto_self_update"
  fi
else
  assert_failure 'shell completions for rustup should not exist' \
    test -e /usr/share/bash-completion/completions/rustup
  assert_failure 'shell completions for cargo should not exist' \
    test -e /usr/share/bash-completion/completions/cargo
fi

finish
