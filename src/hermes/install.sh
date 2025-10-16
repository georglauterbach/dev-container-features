#! /bin/sh

# shellcheck disable=SC2154

set -e -u

log() {
  printf "%s %-5s: %s\n" "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${2:-}"
}

parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  readonly INIT_BASHRC="${INIT_BASHRC:?INIT_BASHRC not set or null}"
  readonly INIT_BASHRC_OVERWRITE="${INIT_BASHRC_OVERWRITE:?INIT_BASHRC_OVERWRITE not set or null}"
}

initialize_bashrc() {
  if [ "${HERMES_INIT_BASHRC}" = 'false' ]; then
    log 'info' 'Not initializing hermes'
    return 0
  fi

  if [ "${HERMES_INIT_BASHRC_OVERWRITE}" = 'true' ]; then
    log 'info' 'Initializing hermes by overwriting .bashrc'
    cat >"${_REMOTE_USER_HOME}/.bashrc" <<"EOF"
#! /usr/bin/env bash

source "${HOME}/.config/bash/90-hermes.sh"
EOF
  else
    log 'info' 'Initializing hermes by extending .bashrc'
    cat >>"${_REMOTE_USER_HOME}/.bashrc" <<"EOF"
#! /usr/bin/env bash

source "${HOME}/.config/bash/90-hermes.sh"
EOF
  fi
}

main() {
  parse_dev_container_options
  initialize_bashrc

  mkdir --parents /usr/local/bin/
  mv "hermes-v11.0.0-$(uname --machine)-unknown-linux-musl" /usr/local/bin/hermes
}

main "${@}"
