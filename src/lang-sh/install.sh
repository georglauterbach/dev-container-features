#! /bin/sh

set -e -u

DCF_LANG_SH_DIR=/usr/local/share/dev_containers/features/ghcr.io/georglauterbach/lang_sh
readonly DCF_LANG_SH_DIR

mkdir -p           "${DCF_LANG_SH_DIR}"
cp shellcheck.conf "${DCF_LANG_SH_DIR}"
cp libbash         "${DCF_LANG_SH_DIR}"

mkdir -p           /usr/local/bin/
cp -n shellcheck   /usr/local/bin/
