#! /bin/sh

set -e -u

readonly TOOL_SOURCE=tools/hermes
readonly TOOL_TARGET=/usr/local/bin/hermes

install_binary() {
  if [ ! -f "${TOOL_SOURCE}" ]; then
    echo "Missing source binary: ${TOOL_SOURCE}" >&2
    exit 1
  fi

  install -D -m 0755 "${TOOL_SOURCE}" "${TOOL_TARGET}"
}

main() {
  install_binary
}

main "${@}"
