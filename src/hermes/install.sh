#! /usr/bin/env bash

# shellcheck disable=SC2154

set -eE -u -o pipefail
shopt -s inherit_errexit

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

  readonly HERMES_VERSION=v${HERMES_VERSION:?HERMES_VERSION not set or null}
  readonly HERMES_ACQUIRE_INSECURE=${HERMES_ACQUIRE_INSECURE:?HERMES_ACQUIRE_INSECURE not set or null}
  readonly HERMES_RUN=${HERMES_RUN:?HERMES_RUN not set or null}
  readonly HERMES_ARGUMENTS=${HERMES_ARGUMENTS:?HERMES_ARGUMENTS not set or null}

  [[ -v http_proxy ]]  || export http_proxy=${PROXY_HTTP_HTTP_ADDRESS?PROXY_HTTP_HTTP_ADDRESS not set}
  [[ -v https_proxy ]] || export https_proxy=${PROXY_HTTP_HTTPS_ADDRESS?PROXY_HTTP_HTTPS_ADDRESS not set}
  [[ -v no_proxy ]]    || export no_proxy=${PROXY_HTTP_NO_PROXY_ADDRESS?PROXY_HTTP_NO_PROXY_ADDRESS not set}

  readonly HERMES_OUTPUT_FILE='/usr/local/bin/hermes'
}

function pre_flight_checks() {
  log 'info' 'Running pre-flight checks'

  DOWNLOAD_COMMAND=('curl' '--silent' '--show-error' '--location' '--fail')

  if [[ ! -f /etc/os-release ]]; then
    log 'error' "No '/etc/os-release' - no way of determining distribution"
    exit 1
  fi

  # shellcheck disable=SC2034
  source /etc/os-release

  case "${ID_LIKE}" in
    ( 'debian' )
      log 'info' 'Distribution recognized as Debian-like'

      export DEBIAN_FRONTEND=noninteractive
      export DEBCONF_NONINTERACTIVE_SEEN=true

      if ! apt-get --yes --quiet=2 --option=Dpkg::Use-Pty=0 update \
      || ! apt-get --yes --quiet=2 --option=Dpkg::Use-Pty=0 install \
        --no-install-recommends apt-utils ca-certificates curl dialog doas file locales tzdata; then
        log 'warn' 'Basic setup failed - this may (or may not) impact acquisition and installation later'
      fi
      ;;

    ( * )
      log 'warn' "Distribution '${ID_LIKE}' currently not supported - expect problems"
      ;;
  esac

  if [[ $(id -u "${_CONTAINER_USER}") -ne 0 ]] && command -v doas &>/dev/null; then
    log 'info' "Setting up 'doas' to make 'sudo' work"
    echo "permit nopass ${_CONTAINER_USER}" >/etc/doas.conf
    chown root:root /etc/doas.conf
    chmod 0400 /etc/doas.conf
    doas -C /etc/doas.conf
    ln -s "$(command -v doas)" /usr/local/bin/sudo
  fi

  if command -v curl &>/dev/null; then
    value_is_true HERMES_ACQUIRE_INSECURE && DOWNLOAD_COMMAND+=('--insecure')
    DOWNLOAD_COMMAND+=('--output' "${HERMES_OUTPUT_FILE}")
  elif command -v wget &>/dev/null; then
    DOWNLOAD_COMMAND=('wget')
    value_is_true HERMES_ACQUIRE_INSECURE && DOWNLOAD_COMMAND+=('--no-check-certificate')
    DOWNLOAD_COMMAND+=("--output-document=${HERMES_OUTPUT_FILE}")
  else
    log 'error' "Neither 'curl' nor 'wget' found but required"
    exit 1
  fi

  readonly DOWNLOAD_COMMAND
  return 0
}

function acquire_hermes() {
  log 'info' "Acquiring 'hermes' now"

  mkdir --parents "$(dirname "${HERMES_OUTPUT_FILE}")"
  rm --recursive --force "${HERMES_OUTPUT_FILE}"

  "${DOWNLOAD_COMMAND[@]}" \
    "https://github.com/georglauterbach/hermes/releases/download/${HERMES_VERSION}/hermes-${HERMES_VERSION}-$(uname -m)-unknown-linux-musl" >/command.sh

  chmod +x /usr/local/bin/hermes
}

function main() {
  parse_dev_container_options
  pre_flight_checks
  acquire_hermes

  if value_is_true HERMES_RUN; then
    log 'info' 'Running hermes now'

    # shellcheck disable=SC2086
    su "--shell=$(command -v hermes)" -- "${_CONTAINER_USER}" --verbose --non-interactive run ${HERMES_ARGUMENTS}
  else
    log 'info' 'Not running hermes'
  fi

  return 0
}

main "${@}"
