#! /usr/bin/env bash

set -eE -u -o pipefail
shopt -s inherit_errexit

function log() {
  printf "%s %-5s %s: %s\n" \
    "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${FUNCNAME[1]:-}" "${2:-}"
}

function parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  RUSTUP_DEFAULT_TOOLCHAIN="${RUSTUP_DEFAULT_TOOLCHAIN:?RUSTUP_DEFAULT_TOOLCHAIN not set or null}"
  RUSTUP_UPDATE_DEFAULT_TOOLCHAIN="${RUSTUP_UPDATE_DEFAULT_TOOLCHAIN:?RUSTUP_UPDATE_DEFAULT_TOOLCHAIN not set or null}"
  RUSTUP_PROFILE="${RUSTUP_PROFILE:?RUSTUP_PROFILE not set or null}"
  RUSTUP_DIST_SERVER="${RUSTUP_DIST_SERVER:?RUSTUP_DIST_SERVER not set or null}"
  RUSTUP_UPDATE_ROOT="${RUSTUP_UPDATE_ROOT:?RUSTUP_UPDATE_ROOT not set or null}"
  RUSTUP_INIT_TARGET_TRIPLE=${RUSTUP_INIT_TARGET_TRIPLE:?RUSTUP_INIT_TARGET_TRIPLE is not set or null}

  ADDITIONAL_TARGETS="${ADDITIONAL_TARGETS?ADDITIONAL_TARGETS not set}"
  ADDITIONAL_COMPONENTS=${ADDITIONAL_COMPONENTS?ADDITIONAL_COMPONENTS not set}
  ADDITIONAL_PACKAGES=${ADDITIONAL_PACKAGES?ADDITIONAL_PACKAGES not set}

  INSTALL_MOLD="${INSTALL_MOLD:?INSTALL_MOLD not set or null}"
  MOLD_VERSION="${MOLD_VERSION?MOLD_VERSION not set}"

  [[ -v http_proxy ]]  || export http_proxy=${HTTP_PROXY?HTTP_PROXY not set}
  [[ -v https_proxy ]] || export https_proxy=${HTTP_PROXYS?HTTPS_PROXY not set}
  [[ -v no_proxy ]]    || export no_proxy=${NO_PROXY?NO_PROXY not set}
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
  # These directories
  #
  # 1. contain the binaries `cargo`, `rustup`, etc.;
  # 2. contain the repository files (mounted from the host)
  #
  # respectively.
  export RUSTUP_HOME='/usr/local/bin/rustup'
  export CARGO_HOME=${RUSTUP_HOME}

  # These variables are used when acquiring and
  # updating `rustup`.
  export RUSTUP_DIST_SERVER
  export RUSTUP_UPDATE_ROOT

  # We update path to be able to execute `rustup-init`
  # directly.
  export PATH="/usr/local/bin/rustup/bin:${PATH}"

  mkdir -p "${RUSTUP_HOME}/bin"

  local RUSTUP_INSTALLER_ARGUMENTS=(
    '-y'
    '--no-modify-path'
    '--default-toolchain' "${RUSTUP_DEFAULT_TOOLCHAIN}"
    '--profile' "${RUSTUP_PROFILE}"
  )

  if [[ ${RUSTUP_UPDATE_DEFAULT_TOOLCHAIN} == 'false' ]]; then
    RUSTUP_INSTALLER_ARGUMENTS+=('--no-update-default-toolchain')
  fi

  # This is the point where the actual installation takes place.
  wget -O "${RUSTUP_HOME}/bin/rustup-init" "${RUSTUP_UPDATE_ROOT}/dist/$(uname -m)-${RUSTUP_INIT_TARGET_TRIPLE}/rustup-init"
  chmod +x "${RUSTUP_HOME}/bin/"*
  rustup-init "${RUSTUP_INSTALLER_ARGUMENTS[@]}"

  cat >>/etc/environment <<EOM

# Rust
RUSTUP_DIST_SERVER=${RUSTUP_DIST_SERVER}
RUSTUP_UPDATE_ROOT=${RUSTUP_UPDATE_ROOT}
EOM

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

  if [[ -n ${ADDITIONAL_PACKAGES} ]]; then
    local PACKAGES
    IFS=',' read -r -a PACKAGES <<< "${ADDITIONAL_PACKAGES// /}"
    apt-get --yes install --no-install-recommends "${PACKAGES[@]}"
  fi

  mkdir -p                       /usr/share/bash-completion/completions
  rustup completions bash       >/usr/share/bash-completion/completions/rustup
  rustup completions bash cargo >/usr/share/bash-completion/completions/cargo
}

function install_mold() {
  if [[ ${INSTALL_MOLD} == 'true' ]]; then
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
