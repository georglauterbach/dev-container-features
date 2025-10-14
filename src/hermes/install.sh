#! /usr/bin/env bash

# shellcheck disable=SC2154

set -eE -u -o pipefail
shopt -s inherit_errexit

CURRENT_DIR="$(realpath -eL "$(dirname "${BASH_SOURCE[0]}")")"
readonly CURRENT_DIR

function log() {
  printf "%s %-5s %s: %s\n" \
    "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${FUNCNAME[1]:-}" "${2:-}"
}

function value_is_true() {
  declare -n __VAR=${1}
  [[ ${__VAR} == 'true' ]]
}

function parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  readonly HERMES_RUN=${HERMES_RUN:?HERMES_RUN not set or null}
  readonly HERMES_INIT_BASHRC=${HERMES_INIT_BASHRC:?HERMES_INIT_BASHRC not set or null}
  readonly HERMES_INIT_BASHRC_OVERWRITE=${HERMES_INIT_BASHRC_OVERWRITE:?HERMES_INIT_BASHRC_OVERWRITE not set or null}
}

function main() {
  parse_dev_container_options

  cp "${CURRENT_DIR}/hermes" /usr/local/bin/

  if value_is_true HERMES_RUN; then
    log 'info' 'Running hermes'
    hermes
  else
    log 'info' 'Not running hermes'
  fi

  if ! value_is_true HERMES_INIT_BASHRC; then
    log 'info' 'Not initializing hermes'
    return 0
  fi

  if value_is_true HERMES_INIT_BASHRC_OVERWRITE; then
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

  return 0
}

main "${@}"
