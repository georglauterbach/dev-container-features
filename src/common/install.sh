#! /usr/bin/env bash

# shellcheck disable=SC2154

set -eE -u -o pipefail
shopt -s inherit_errexit

function log() {
  printf "%s %-5s %s: %s\n" \
    "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${FUNCNAME[1]:-}" "${2:-}"
}

function parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  SYSTEM_PACKAGES_UPDATE=${SYSTEM_PACKAGES_UPDATE:?SYSTEM_PACKAGES_UPDATE not set or null}
  SYSTEM_PACKAGES_UPGRADE=${SYSTEM_PACKAGES_UPGRADE:?SYSTEM_PACKAGES_UPGRADE not set or null}
  SYSTEM_PACKAGES_ADDITIONAL_PACKAGES=${SYSTEM_PACKAGES_ADDITIONAL_PACKAGES:?SYSTEM_PACKAGES_ADDITIONAL_PACKAGES not set or null}
  SYSTEM_PACKAGES_CLEAN=${SYSTEM_PACKAGES_CLEAN:?SYSTEM_PACKAGES_CLEAN not set or null}

  SYSTEM_SETUP_DOAS=${SYSTEM_SETUP_DOAS:?SYSTEM_SETUP_DOAS not set or null}
  SYSTEM_TIME_ZONE=${SYSTEM_TIME_ZONE:?SYSTEM_TIME_ZONE not set or null}

  USER_CONFIG_PROMPT=${USER_CONFIG_PROMPT:?USER_CONFIG_PROMPT not set or null}
  USER_PACKAGES_INSTALL=${USER_PACKAGES_INSTALL:?USER_PACKAGES_INSTALL not set or null}

  [[ -v http_proxy ]]  || export http_proxy=${PROXY_HTTP_HTTP_ADDRESS?PROXY_HTTP_HTTP_ADDRESS not set}
  [[ -v https_proxy ]] || export https_proxy=${PROXY_HTTP_HTTPS_ADDRESS?PROXY_HTTP_HTTPS_ADDRESS not set}
  [[ -v no_proxy ]]    || export no_proxy=${PROXY_HTTP_NO_PROXY_ADDRESS?PROXY_HTTP_NO_PROXY_ADDRESS not set}
}

function parse_linux_distribution() {
  export LINUX_DISTRIBUTION_NAME='unknown'

  [[ -f /etc/os-release ]] || return 0

  # shellcheck disable=SC2034
  source /etc/os-release

  case "${ID_LIKE}" in
    ( 'debian' )
      [[ -n ${SYSTEM_TIME_ZONE} ]] && export TZ=${SYSTEM_TIME_ZONE}
      LINUX_DISTRIBUTION_NAME='debian'
      ;;

    ( * )
      LINUX_DISTRIBUTION_NAME='unknown'
      ;;
  esac
}

function handle_system_packages() {
  case "${LINUX_DISTRIBUTION_NAME}" in
    ( 'debian' )
      export DEBIAN_FRONTEND='noninteractive'
      export DEBCONF_NONINTERACTIVE_SEEN='true'

      ${SYSTEM_PACKAGES_UPDATE}  && { log 'info' 'Updating package signatures' ; apt-get --yes update ; }
      ${SYSTEM_PACKAGES_UPGRADE} && { log 'info' 'Upgrading existing packages' ; apt-get --yes dist-upgrade ; }

      local __SYSTEM_PACKAGES_ADDITIONAL_PACKAGES
      IFS=',' read -r -a __SYSTEM_PACKAGES_ADDITIONAL_PACKAGES <<< "${SYSTEM_PACKAGES_ADDITIONAL_PACKAGES// /}"

      if [[ ${#__SYSTEM_PACKAGES_ADDITIONAL_PACKAGES[@]} -gt 0 ]]; then
        log 'info' "Installing additional packages: ${__SYSTEM_PACKAGES_ADDITIONAL_PACKAGES[*]}"
        apt-get --yes install --no-install-recommends "${__SYSTEM_PACKAGES_ADDITIONAL_PACKAGES[@]}"
      fi

      if ${SYSTEM_PACKAGES_CLEAN}; then
        log 'info' 'Running package cleanup'
        apt-get --yes autoremove
        apt-get --yes clean
        rm -rf /var/lib/apt/lists/* /tmp/*
      fi
      ;;

    ( * )
      log 'info' 'Distribution unknown - not running custom system setup'
      ;;
  esac

  if ${SYSTEM_SETUP_DOAS}; then
    log 'info' "Setting up 'doas'"
    if ! command -v doas &>/dev/null; then
      log 'error' "Setup for 'doas' enabled but 'doas' is not installed"
      exit 1
    fi

    echo "permit nopass ${_REMOTE_USER}" >/etc/doas.conf
    chown root:root /etc/doas.conf
    chmod 0400 /etc/doas.conf
    doas -C /etc/doas.conf
    ln -s "$(command -v doas)" /usr/local/bin/sudo
  fi
}

function handle_user_config() {
  :
}

function handle_user_packages() {
  :
}

function main() {
  parse_dev_container_options
  handle_system_packages
  handle_user_config
  handle_user_packages
}

main "${@}"

