#! /bin/sh

set -e -u

readonly DCF_LANG_RUST_DIR=/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_rust

parse_dev_container_options() {
  readonly GENERATE_SHELL_COMPLETIONS="${GENERATE_SHELL_COMPLETIONS:?GENERATE_SHELL_COMPLETIONS not set or null}"
  readonly RUSTUP_DISABLE_AUTO_SELF_UPDATE="${RUSTUP_DISABLE_AUTO_SELF_UPDATE:?RUSTUP_DISABLE_AUTO_SELF_UPDATE not set or null}"
}

copy_lifecycle_hook_scripts() {
  mkdir --parents "${DCF_LANG_RUST_DIR}/lifecycle_hooks"
  cp lifecycle_hooks/on_create_command.sh "${DCF_LANG_RUST_DIR}/lifecycle_hooks/on_create_command.sh"
}

rustup_adjustments() {
  if ! command -v rustup >/dev/null 2>/dev/null; then
    echo "WARN  'rustup' is not installed - not performing actions associated with 'rustup' (shell completions, disabling automatic self-update)" >&2
    return 0
  fi

  if [ "${GENERATE_SHELL_COMPLETIONS}" = 'true' ]; then
    mkdir  -p                      /usr/share/bash-completion/completions
    rustup completions bash       >/usr/share/bash-completion/completions/rustup
    rustup completions bash cargo >/usr/share/bash-completion/completions/cargo
  fi

  if [ "${RUSTUP_DISABLE_AUTO_SELF_UPDATE}" = 'true' ]; then
    touch "${DCF_LANG_RUST_DIR}/.rustup_disable_auto_self_update"
  fi
}

copy_lldb_prettifiers() {
  cp "scripts/lldb_prettifier.py.txt" "${DCF_LANG_RUST_DIR}/lldb_prettifier.py"
  chmod 644 "${DCF_LANG_RUST_DIR}/lldb_prettifier.py"
}

main() {
  parse_dev_container_options

  mkdir -p "${DCF_LANG_RUST_DIR}"

  copy_lifecycle_hook_scripts
  rustup_adjustments
  copy_lldb_prettifiers
}

main "${@}"
