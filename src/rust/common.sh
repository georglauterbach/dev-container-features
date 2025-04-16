#! /usr/bin/env bash

function log() {
  printf "%s %-5s %s: %s\n" \
    "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${FUNCNAME[1]:-}" "${2:-}"
}

function value_is_true() {
  declare -n __VAR=${1}
  [[ ${__VAR} == 'true' ]]
}

function parse_linux_distribution() {
  log 'info' 'Parsing Linux distribution'
  export LINUX_DISTRIBUTION_NAME='unknown'

  if [[ ! -f /etc/os-release ]]; then
    log 'warn' "File '/etc/os-release' does not exists - Linux distribution unknown"
    return 0
  fi

  # shellcheck disable=SC2034
  source /etc/os-release

  case "${ID_LIKE:-${ID:-__unknown__}}" in
    ( 'debian' )
      log 'info' "Distribution recognized as Debian-like"
      LINUX_DISTRIBUTION_NAME='debian'

      export DEBIAN_FRONTEND=noninteractive
      export DEBCONF_NONINTERACTIVE_SEEN=true
      ;;

    ( '__unknown__' )
      log 'warn' "Could not parse distribution from '/etc/os-release'"
      ;;

	  ( * )
	    log 'info' 'Linux distribution unknown'
	    ;;
  esac
}
