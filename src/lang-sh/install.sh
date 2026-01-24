#! /bin/sh

set -e -u

FEATURE_SHARED_DIR=/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_sh
readonly FEATURE_SHARED_DIR

mkdir -p           "${FEATURE_SHARED_DIR}"
cp shellcheck.conf "${FEATURE_SHARED_DIR}"
cp libbash         "${FEATURE_SHARED_DIR}"

mkdir -p      /usr/local/bin/
cp shellcheck /usr/local/bin/
