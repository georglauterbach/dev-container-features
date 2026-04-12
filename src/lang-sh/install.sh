#! /bin/sh

set -e -u

readonly DCF_LANG_SH_DIR=/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_sh

mkdir -p                         "${DCF_LANG_SH_DIR}"
cp configuration/shellcheck.conf "${DCF_LANG_SH_DIR}"
cp libraries/libbash             "${DCF_LANG_SH_DIR}"

mkdir -p               /usr/local/bin/
cp -n tools/shellcheck /usr/local/bin/
