#! /bin/sh

set -e -u

readonly DCF_LANG_SH_DIR="${DCF_LANG_SH_DIR:?}"

main() {
  install -D -m 0644 configuration/shellcheck.conf "${DCF_LANG_SH_DIR}/shellcheck.conf"
  install -D -m 0644 libraries/libbash             "${DCF_LANG_SH_DIR}/libbash"
  install -D -m 0755 tools/shellcheck              /usr/local/bin/shellcheck
}

main "${@}"
