#! /bin/sh

set -e -u

readonly DCF_LANG_SH_DIR=/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_sh
readonly SHELLCHECK_CONF_SOURCE=configuration/shellcheck.conf
readonly LIBBASH_SOURCE=libraries/libbash
readonly SHELLCHECK_BINARY_SOURCE=tools/shellcheck
readonly SHELLCHECK_BINARY_TARGET=/usr/local/bin/shellcheck

install_runtime_files() {
  install -D -m 0644 "${SHELLCHECK_CONF_SOURCE}" "${DCF_LANG_SH_DIR}/shellcheck.conf"
  install -D -m 0644 "${LIBBASH_SOURCE}" "${DCF_LANG_SH_DIR}/libbash"
}

install_shellcheck() {
  install -D -m 0755 "${SHELLCHECK_BINARY_SOURCE}" "${SHELLCHECK_BINARY_TARGET}"
}

main() {
  install_runtime_files
  install_shellcheck
}

main "${@}"
