#! /bin/sh

# shellcheck disable=SC2154

set -e -u

log() {
  printf "%s %-5s: %s\n" "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${2:-}"
}

parse_dev_container_options() {
  log 'info' 'Parsing input from options'
}

main() {
  parse_dev_container_options
  echo "Add '[[ -f ${HOME}/.config/bash/90-hermes.sh ]] && source \"${HOME}/.config/bash/90-hermes.sh\"' to your Bash setup to enable hermes"

  mkdir --parents /usr/local/bin/
  mv "hermes-v11.2.3-$(uname --machine)-unknown-linux-musl" /usr/local/bin/hermes
  chmod +x /usr/local/bin/hermes
}

main "${@}"
