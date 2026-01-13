#! /bin/sh

# shellcheck disable=SC2154

set -e -u

log() {
  printf "%s %-5s: %s\n" "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${2:-}"
}

parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  readonly VERSION="${VERSION:?VERSION not set or null}"
  readonly ARCHITECTURE="${ARCHITECTURE:?ARCHITECTURE not set or null}"
  readonly URI="${URI:?URI not set or null}"

  [ -n "${http_proxy+x}" ]  || export http_proxy="${PROXY_HTTP_HTTP_ADDRESS?PROXY_HTTP_HTTP_ADDRESS not set}"
  [ -n "${https_proxy+x}" ] || export https_proxy="${PROXY_HTTP_HTTPS_ADDRESS?PROXY_HTTP_HTTPS_ADDRESS not set}"
  [ -n "${no_proxy+x}" ]    || export no_proxy="${PROXY_HTTP_NO_PROXY_ADDRESS?PROXY_HTTP_NO_PROXY_ADDRESS not set}"
}

main() {
  parse_dev_container_options

  DOWNLOAD_URL=$(printf '%s' "${URI}" | sed \
    -e "s|{{VERSION}}|${VERSION}|g" \
    -e "s|{{ARCHITECTURE}}|${ARCHITECTURE}|g")
  FILE_NAME=$(basename "${DOWNLOAD_URL}")
  readonly DOWNLOAD_URL FILE_NAME

  cd /tmp
  rm -f "${FILE_NAME}"

  if command -v curl >/dev/null 2>/dev/null; then
    curl --silent --show-error --location --fail --output "${FILE_NAME}" "${DOWNLOAD_URL}"
  elif command -v wget >/dev/null 2>/dev/null; then
    wget --output-document="${FILE_NAME}" "${DOWNLOAD_URL}"
  else
    log 'error' "Neither 'curl' nor 'wget' found, but required"
    exit 1
  fi

  tar xf "${FILE_NAME}"
  for DIR in 'bin' 'include' 'lib' 'share'; do
    mkdir -p "/usr/local/${DIR}"
    cp -r "${FILE_NAME%.tar.*}/${DIR}/"* "/usr/local/${DIR}"
  done
}

main "${@}"
