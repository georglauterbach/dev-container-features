#! /usr/bin/env bash

set -eE -u -o pipefail
shopt -s inherit_errexit

function log() {
  printf "%s %-5s %s: %s\n" \
    "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${FUNCNAME[1]:-}" "${2:-}"
}

function parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  RUSTUP_DEFAULT_TOOLCHAIN="${RUSTUP_DEFAULT_TOOLCHAIN:-none}"
  RUSTUP_UPDATE_DEFAULT_TOOLCHAIN="${RUSTUP_UPDATE_DEFAULT_TOOLCHAIN:-false}"
  RUSTUP_PROFILE="${RUSTUP_PROFILE:-minimal}"
  ADDITIONAL_TARGETS="${ADDITIONAL_TARGETS:-}"
  ADDITIONAL_COMPONENTS=${ADDITIONAL_COMPONENTS:-}
  INSTALL_MOLD="${INSTALL_MOLD:-false}"
}

function pre_flight_checks() {
  log 'info' 'Checking privilege level'
  if [[ ${EUID} -ne 0 ]]; then
    log 'info' 'This script must be run with superuser privilege (root)'
    exit 1
  fi

  log 'debug' 'Ensuring that login shells get the correct path if the user updates PATH using ENV'
  rm -f /etc/profile.d/00-restore-env.sh
  echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" >/etc/profile.d/00-restore-env.sh
  chmod +x /etc/profile.d/00-restore-env.sh

  log 'info' 'Updating APT package index and installing required packages'
  export DEBIAN_FRONTEND=noninteractive
  apt-get --yes update
  apt-get --yes install --no-install-recommends 'build-essential'
}

function install_rust() {
  local __CARGO_HOME_INSTALL='/usr/local/bin/rustup'
  local __RUSTUP_HOME_INSTALL='/usr/local/bin/rustup'

  mkdir -p "${__CARGO_HOME_INSTALL}" "${__RUSTUP_HOME_INSTALL}"

  # These directories
  #
  # 1. contain the binaries `cargo`, `rustup`, etc.;
  # 2. contain the repository files (mounted from the host)
  #
  # respectively.
  export CARGO_HOME=${__RUSTUP_HOME_INSTALL}
  export RUSTUP_HOME=${__RUSTUP_HOME_INSTALL}

  local RUSTUP_INSTALLER_ARGUMENTS=(
    '-y'
    '--no-modify-path'
    '--default-toolchain' "${RUSTUP_DEFAULT_TOOLCHAIN}"
    '--profile' "${RUSTUP_PROFILE}"
  )

  if [[ ${RUSTUP_UPDATE_DEFAULT_TOOLCHAIN} == 'true' ]]; then
    RUSTUP_INSTALLER_ARGUMENTS+=('--no-update-default-toolchain')
  fi

  # We do not install a toolchain at this point in time because
  # on the one hand, Cargo will do so for us the first time we
  # interact with the unCORE code, on the other hand, we want to
  # keep this container image as small as possible.
  curl -sSfL 'https://sh.rustup.rs' | bash -s -- "${RUSTUP_INSTALLER_ARGUMENTS[@]}"

  export PATH="/usr/local/bin/rustup/bin:${PATH}"

  mkdir -p /usr/local/.dev_container_feature_rust
  chmod -R 777 /usr/local/.dev_container_feature_rust

  if [[ -n ${ADDITIONAL_TARGETS} ]]; then
    local TARGETS
    IFS=',' read -r -a TARGETS <<< "${ADDITIONAL_TARGETS// /}"
    for TARGET in "${TARGETS[@]}"; do
      log 'debug' "Installing additional target ${TARGET}"
      rustup target add "${TARGET}"
    done
  fi

  if [[ -n ${ADDITIONAL_COMPONENTS} ]]; then
    local COMPONENTS
    IFS=',' read -r -a COMPONENTS <<< "${ADDITIONAL_COMPONENTS// /}"
    rustup component add "${COMPONENTS[@]}"
  fi
}

function install_mold() {
  if [[ ${INSTALL_MOLD} == 'true' ]]; then
    MOLD_VERSION='2.4.0'
    MOLD_DIR="mold-${MOLD_VERSION}-$(uname -m)-linux"

    curl --silent --show-error --fail --location                                               \
      "https://github.com/rui314/mold/releases/download/v${MOLD_VERSION}/${MOLD_DIR}.tar.gz" | \
      tar xvz -C /tmp

    cp "/tmp/${MOLD_DIR}/"{bin/{mold,ld.mold},lib/mold/mold-wrapper.so} /usr/local/bin/
    rm -r "/tmp/${MOLD_DIR}"
  fi
}

function main() {
  parse_dev_container_options
  pre_flight_checks

  install_rust
  install_mold
}

main "${@}"
