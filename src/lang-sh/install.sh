#! /bin/sh

set -e -u

FEATURE_SHARE_DIR=/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_bash
readonly FEATURE_SHARE_DIR

parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  readonly COPY_LIBBASH="${COPY_LIBBASH:?COPY_LIBBASH not set or null}"
}

main() {
  parse_dev_container_options

  cp shellcheck.conf "${FEATURE_SHARE_DIR}"
  cp libbash "${FEATURE_SHARE_DIR}"

  if "${COPY_LIBBASH}"; then
    mkdir --parents /usr/local/lib
    cp libbash /usr/local/lib/
  fi

  return 0
}
