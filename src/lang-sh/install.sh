#! /bin/sh

set -e -u

FEATURE_SHARED_DIR=/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_bash
readonly FEATURE_SHARED_DIR

main() {
  cp shellcheck.conf "${FEATURE_SHARED_DIR}"
  cp libbash         "${FEATURE_SHARED_DIR}"
}

main
