#! /usr/bin/env bash

set -eE -u -o pipefail
shopt -s inherit_errexit

CURRENT_DIR="$(realpath -eL "$(dirname "${BASH_SOURCE[0]}")")"
readonly CURRENT_DIR

# shellcheck source=./common.sh
source "${CURRENT_DIR}/common.sh"

function parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  readonly UV_INSTALL="${UV_INSTALL:?UV_INSTALL not set or null}"
  readonly UV_INSTALL_VERSION=${UV_INSTALL_VERSION:?UV_INSTALL_VERSION not set or null}
  readonly UV_INSTALL_METHOD="${UV_INSTALL_METHOD:?UV_INSTALL_METHOD not set or null}"
  readonly UV_INSTALL_URI="${UV_INSTALL_URI?UV_INSTALL_URI not set}"

  [[ -v http_proxy ]]  || export http_proxy=${PROXY_HTTP_HTTP_ADDRESS?PROXY_HTTP_HTTP_ADDRESS not set}
  [[ -v https_proxy ]] || export https_proxy=${PROXY_HTTP_HTTPS_ADDRESS?PROXY_HTTP_HTTPS_ADDRESS not set}
  [[ -v no_proxy ]]    || export no_proxy=${PROXY_HTTP_NO_PROXY_ADDRESS?PROXY_HTTP_NO_PROXY_ADDRESS not set}
}

function pre_flight_checks() {
  if [[ ! ${UV_INSTALL_METHOD} =~ ^(curl|wget|pipx?)$ ]]; then
    log 'error' "Installation method '${UV_INSTALL_METHOD}' for uv unknown"
    exit 1
  fi
}

function install_uv() {
  value_is_true UV_INSTALL || return 0
  log 'info' "Installing UV"

  local INSTALLATION_URI
  if [[ -n ${UV_INSTALL_URI} ]]; then
    INSTALLATION_URI=${UV_INSTALL_URI}
  elif [[ ${UV_INSTALL_VERSION} == 'latest' ]]; then
    INSTALLATION_URI='https://astral.sh/uv/install.sh'
  else
    INSTALLATION_URI="https://astral.sh/uv/${UV_INSTALL_VERSION}/install.sh"
  fi

  case "${UV_INSTALL_METHOD}" in
    ( 'curl' )
      curl -LsSf "${INSTALLATION_URI}" | sh
      ;;

    ( 'wget' )
      wget -qO- "https://astral.sh/uv/${UV_INSTALL_VERSION}/install.sh" | sh
      ;;

    ( 'pip' | 'pipx' )
      if [[ ${UV_INSTALL_VERSION} == 'latest' ]]; then
        "${UV_INSTALL_METHOD}" install uv
      else
        "${UV_INSTALL_METHOD}" install "uv==${UV_INSTALL_VERSION}"
      fi
      ;;

    ( * )
      log 'error' "BUG! Installation method '${UV_INSTALL_METHOD}' unknown or not yet implemented"
      ;;
  esac
}

function main() {
  parse_dev_container_options
  parse_linux_distribution

  install_uv
}

main "${@}"
