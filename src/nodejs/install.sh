#! /usr/bin/env bash

# shellcheck disable=SC2154

set -eE -u -o pipefail
shopt -s inherit_errexit

CURRENT_DIR="$(realpath -eL "$(dirname "${BASH_SOURCE[0]}")")"
readonly CURRENT_DIR

# shellcheck source=./common.sh
source "${CURRENT_DIR}/common.sh"

function parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  readonly VERSION=${VERSION:?VERSION not set or null}
  readonly ARCHITECTURE=${ARCHITECTURE:?ARCHITECTURE not set or null}
  readonly URL=${URL:?URL not set or null}

  [[ -v http_proxy ]]  || export http_proxy=${PROXY_HTTP_HTTP_ADDRESS?PROXY_HTTP_HTTP_ADDRESS not set}
  [[ -v https_proxy ]] || export https_proxy=${PROXY_HTTP_HTTPS_ADDRESS?PROXY_HTTP_HTTPS_ADDRESS not set}
  [[ -v no_proxy ]]    || export no_proxy=${PROXY_HTTP_NO_PROXY_ADDRESS?PROXY_HTTP_NO_PROXY_ADDRESS not set}
}

function install_node() {
  local DOWNLOAD_URL FILE_NAME
  DOWNLOAD_URL=$(sed \
    -e "s|<<VERSION>>|${VERSION}|g" \
    -e "s|<<ARCHITECTURE>>|${ARCHITECTURE}|g" \
    <<< "${URL}")
  FILE_NAME=$(basename "${DOWNLOAD_URL}")
  readonly DOWNLOAD_URL FILE_NAME

  cd /tmp
  rm --force "${FILE_NAME}"

  if command -v curl &>/dev/null; then
    DOWNLOAD_COMMAND=('curl' '--silent' '--show-error' '--location' '--fail')
    value_is_true ACQUIRE_INSECURE && DOWNLOAD_COMMAND+=('--insecure')
    DOWNLOAD_COMMAND+=('--output' "${FILE_NAME}")
  elif command -v wget &>/dev/null; then
    DOWNLOAD_COMMAND=('wget')
    value_is_true ACQUIRE_INSECURE && DOWNLOAD_COMMAND+=('--no-check-certificate')
    DOWNLOAD_COMMAND+=("--output-document=${FILE_NAME}")
  else
    log 'error' "Neither 'curl' nor 'wget' found, but required"
    exit 1
  fi

  "${DOWNLOAD_COMMAND[@]}" "${DOWNLOAD_URL}"

  tar xf "${FILE_NAME}"
  for DIR in 'bin' 'include' 'lib' 'share'; do
    mkdir --parents "/usr/local/${DIR}"
    cp --recursive "${FILE_NAME%.tar.*}/${DIR}/"* "/usr/local/${DIR}"
  done
}

function main() {
  parse_dev_container_options
  install_node

  return 0
}

main "${@}"

