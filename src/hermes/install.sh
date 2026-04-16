#! /bin/sh

set -e -u

main() {
  install -D -m 0755 tools/hermes /usr/local/bin/hermes
}

main "${@}"
