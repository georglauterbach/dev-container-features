#! /bin/sh

# shellcheck disable=SC2154

set -e -u

# TODO CURRENT_DIR="$(realpath -eL "$(dirname "${BASH_SOURCE[0]}")")"
# readonly CURRENT_DIR

log() {
  printf "%s %-5s: %s\n" "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${2:-}"
}

parse_linux_distribution() {
  log 'info' 'Parsing Linux distribution'
  export LINUX_DISTRIBUTION_NAME='unknown'

  if [ ! -f /etc/os-release ]; then
    log 'warn' "File '/etc/os-release' does not exists - Linux distribution unknown"
    return 0
  fi

  # shellcheck disable=SC2034
  . /etc/os-release

  case "${ID_LIKE:-${ID:-__unknown__}}" in
    ( 'debian' )
      log 'info' "Distribution recognized as Debian-like"
      LINUX_DISTRIBUTION_NAME='debian'

      export DEBIAN_FRONTEND=noninteractive
      export DEBCONF_NONINTERACTIVE_SEEN=true
      ;;

    ( '__unknown__' )
      log 'warn' "Could not parse distribution from '/etc/os-release'"
      ;;

    ( * )
      log 'info' 'Linux distribution unknown'
      ;;
  esac
}

parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  readonly VERSION="${VERSION:?VERSION not set or null}"
  readonly ARCHITECTURE="${ARCHITECTURE:?ARCHITECTURE not set or null}"
  readonly URI="${URI:?URI not set or null}"
  readonly ACQUIRE_INSECURE="${ACQUIRE_INSECURE:?ACQUIRE_INSECURE not set or null}"

  [ -n "${http_proxy+x}" ]  || export http_proxy="${PROXY_HTTP_HTTP_ADDRESS?PROXY_HTTP_HTTP_ADDRESS not set}"
  [ -n "${https_proxy+x}" ] || export https_proxy="${PROXY_HTTP_HTTPS_ADDRESS?PROXY_HTTP_HTTPS_ADDRESS not set}"
  [ -n "${no_proxy+x}" ]    || export no_proxy="${PROXY_HTTP_NO_PROXY_ADDRESS?PROXY_HTTP_NO_PROXY_ADDRESS not set}"
}

install_node() {
  DOWNLOAD_URL=$(printf '%s' "${URI}" | sed \
    -e "s|{{VERSION}}|${VERSION}|g" \
    -e "s|{{ARCHITECTURE}}|${ARCHITECTURE}|g")
  FILE_NAME=$(basename "${DOWNLOAD_URL}")
  readonly DOWNLOAD_URL FILE_NAME

  cd /tmp
  rm --force "${FILE_NAME}"

  if command -v curl >/dev/null 2>/dev/null; then
    if [ "${ACQUIRE_INSECURE}" = 'true' ]; then
      curl --silent --show-error --location --fail --output "${FILE_NAME}"            "${DOWNLOAD_URL}"
    else
      curl --silent --show-error --location --fail --output "${FILE_NAME}" --insecure "${DOWNLOAD_URL}"
    fi
  elif command -v wget >/dev/null 2>/dev/null; then
    if [ "${ACQUIRE_INSECURE}" = 'true' ]; then
      wget --output-document="${FILE_NAME}" --no-check-certificate "${DOWNLOAD_URL}"
    else
      wget --output-document="${FILE_NAME}"                        "${DOWNLOAD_URL}"
    fi
  else
    log 'error' "Neither 'curl' nor 'wget' found, but required"
    exit 1
  fi

  tar xf "${FILE_NAME}"
  for DIR in 'bin' 'include' 'lib' 'share'; do
    mkdir --parents "/usr/local/${DIR}"
    cp --recursive "${FILE_NAME%.tar.*}/${DIR}/"* "/usr/local/${DIR}"
  done
}

main() {
  parse_dev_container_options
  install_node
}

main "${@}"
