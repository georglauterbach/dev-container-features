#! /bin/sh

set -e -u

FEATURE_SHARE_DIR=/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_rust
readonly FEATURE_SHARE_DIR

log() {
  printf "%s %-5s: %s\n" "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${2:-}"
}

parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  readonly GENERATE_SHELL_COMPLETIONS="${GENERATE_SHELL_COMPLETIONS:?GENERATE_SHELL_COMPLETIONS not set or null}"
  readonly RUSTUP_DISABLE_AUTO_SELF_UPDATE="${RUSTUP_DISABLE_AUTO_SELF_UPDATE:?RUSTUP_DISABLE_AUTO_SELF_UPDATE not set or null}"
}

copy_lifecycle_hook_scripts() {
  mkdir --parents "${FEATURE_SHARE_DIR}/lifecycle_hooks"
  cp data/on_create_command.sh "${FEATURE_SHARE_DIR}/lifecycle_hooks/on_create_command.sh"
}

rustup_adjustments() {
  if command -v rustup >/dev/null 2>/dev/null; then
    log 'info' "'rustup' is installed"
  else
    log 'warn' "'rustup' is not installed - not performing actions associated with 'rustup' (shell completions, disabling automatic self-update)"
    return 0
  fi

  if [ "${GENERATE_SHELL_COMPLETIONS}" = 'true' ]; then
    log 'info' 'Generating completions for rustup and Cargo'
    mkdir  --parents               /usr/share/bash-completion/completions
    rustup completions bash       >/usr/share/bash-completion/completions/rustup
    rustup completions bash cargo >/usr/share/bash-completion/completions/cargo
  else
    log 'info' 'Not generating completions for rustup and Cargo'
  fi

  if [ "${RUSTUP_DISABLE_AUTO_SELF_UPDATE}" = 'true' ]; then
    log 'info' "Disabling rustup's self-update feature when container runs"
    touch "${FEATURE_SHARE_DIR}/.rustup_disable_auto_self_update"
  else
    log 'info' "Not disabling rustup's self-update feature when container runs"
  fi
}

copy_lldb_prettifiers() {
  log 'info' 'Copying prettifier for LLDB'
  cp "data/lldb_prettifier.py.txt" "${FEATURE_SHARE_DIR}/lldb_prettifier.py"
  chmod 777 "${FEATURE_SHARE_DIR}/lldb_prettifier.py"
}

main() {
  parse_dev_container_options

  mkdir --parents "${FEATURE_SHARE_DIR}"

  copy_lifecycle_hook_scripts
  rustup_adjustments
  copy_lldb_prettifiers
}

main "${@}"
