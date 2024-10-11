#! /usr/bin/env bash

set -eE -u -o pipefail
shopt -s inherit_errexit

function log() {
  printf "%s %-5s %s: %s\n" \
    "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${FUNCNAME[1]:-}" "${2:-}"
}

function parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  RUST_INSTALL="${RUST_INSTALL:?RUST_INSTALL is not set or null}"
  RUST_RUSTUP_DEFAULT_TOOLCHAIN=${RUST_RUSTUP_DEFAULT_TOOLCHAIN:?RUST_RUSTUP_DEFAULT_TOOLCHAIN not set or null}
  RUST_RUSTUP_UPDATE_DEFAULT_TOOLCHAIN=${RUST_RUSTUP_UPDATE_DEFAULT_TOOLCHAIN:?RUST_RUSTUP_UPDATE_DEFAULT_TOOLCHAIN not set or null}
  RUST_RUSTUP_PROFILE=${RUST_RUSTUP_PROFILE:?RUST_RUSTUP_PROFILE not set or null}
  RUST_RUSTUP_ADDITIONAL_TARGETS=${RUST_RUSTUP_ADDITIONAL_TARGETS?RUST_RUSTUP_ADDITIONAL_TARGETS not set}
  RUST_RUSTUP_ADDITIONAL_COMPONENTS=${RUST_RUSTUP_ADDITIONAL_COMPONENTS?RUST_RUSTUP_ADDITIONAL_COMPONENTS not set}
  RUST_RUSTUP_DIST_SERVER=${RUST_RUSTUP_DIST_SERVER:?RUST_RUSTUP_DIST_SERVER not set or null}
  RUST_RUSTUP_UPDATE_ROOT=${RUST_RUSTUP_UPDATE_ROOT:?RUST_RUSTUP_UPDATE_ROOT not set or null}
  RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE=${RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE?RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE is not set or null}

  SYSTEM_PACKAGES_ADDITIONAL_PACKAGES="${SYSTEM_PACKAGES_ADDITIONAL_PACKAGES?SYSTEM_PACKAGES_ADDITIONAL_PACKAGES not set}"

  LINKER_MOLD_INSTALL=${LINKER_MOLD_INSTALL:?LINKER_MOLD_INSTALL not set or null}
  LINKER_MOLD_VERSION=${LINKER_MOLD_VERSION?LINKER_MOLD_VERSION not set}

  [[ -v http_proxy ]]  || export http_proxy=${PROXY_HTTP_HTTP_ADDRESS?PROXY_HTTP_HTTP_ADDRESS not set}
  [[ -v https_proxy ]] || export https_proxy=${PROXY_HTTP_HTTPS_ADDRESS?PROXY_HTTP_HTTPS_ADDRESS not set}
  [[ -v no_proxy ]]    || export no_proxy=${PROXY_HTTP_NO_PROXY_ADDRESS?PROXY_HTTP_NO_PROXY_ADDRESS not set}
}

function pre_flight_checks() {
  log 'info' 'Checking privilege level'
  if [[ ${EUID} -ne 0 ]]; then
    log 'error' 'This script must be run with superuser privilege (root)'
    exit 1
  fi

  log 'debug' 'Ensuring that login shells get the correct path if the user updates PATH using ENV'
  rm -f /etc/profile.d/00-restore-env.sh
  echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" >/etc/profile.d/00-restore-env.sh
  chmod +x /etc/profile.d/00-restore-env.sh
}

function install_rust() {
  [[ ${RUST_INSTALL} == 'true' ]] || return 0

  log 'info' 'Updating APT package index and installing required base packages'
  export DEBIAN_FRONTEND=noninteractive
  export DEBCONF_NONINTERACTIVE_SEEN=true
  apt-get --yes update
  apt-get --yes install --no-install-recommends 'build-essential'

  log 'debug' 'Setting installation environment variables'
  # These directories contain metadata and files required by
  # `rustup` (toolchain files, components, etc.) and `cargo`
  # (crates, etc.).
  export RUSTUP_HOME='/usr/local/bin/rustup'
  export CARGO_HOME=${RUSTUP_HOME}

  # These variables are used when acquiring and updating `rustup`.
  export RUSTUP_DIST_SERVER
  export RUST_RUSTUP_UPDATE_ROOT

  # We update path to be able to execute `rustup-init` directly.
  log 'trace' 'Setting installation environment variables'
  mkdir -p "${RUSTUP_HOME}/bin"
  export PATH="${RUSTUP_HOME}/bin:${PATH}"

  local RUSTUP_INSTALLER_ARGUMENTS=(
    '-y'
    '--no-modify-path'
    '--default-toolchain' "${RUST_RUSTUP_DEFAULT_TOOLCHAIN}"
    '--profile' "${RUST_RUSTUP_PROFILE}"
  )

  if [[ ${RUST_RUSTUP_UPDATE_DEFAULT_TOOLCHAIN} == 'false' ]]; then
  log 'trace' 'Default toolchain will not be updated'
    RUSTUP_INSTALLER_ARGUMENTS+=('--no-update-default-toolchain')
  fi

  if [[ -z ${RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE} ]]; then
    RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE="$(uname -m)-unknown-linux-gnu"
  fi

  # This is the point where the actual installation takes place.
  wget -O "${RUSTUP_HOME}/bin/rustup-init" "${RUST_RUSTUP_UPDATE_ROOT}/dist/${RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE}/rustup-init"
  chmod +x "${RUSTUP_HOME}/bin/"*
  rustup-init "${RUSTUP_INSTALLER_ARGUMENTS[@]}"

  if [[ -n ${RUST_RUSTUP_ADDITIONAL_TARGETS} ]]; then
    local __RUST_RUSTUP_ADDITIONAL_TARGETS
    IFS=',' read -r -a TARGETS <<< "${RUST_RUSTUP_ADDITIONAL_TARGETS// /}"
    for RUSTUP_ADDITIONAL_TARGET in "${__RUST_RUSTUP_ADDITIONAL_TARGETS[@]}"; do
      log 'debug' "Installing additional target ${RUSTUP_ADDITIONAL_TARGET}"
      rustup target add "${RUSTUP_ADDITIONAL_TARGET}"
    done
  fi

  if [[ -n ${RUST_RUSTUP_ADDITIONAL_COMPONENTS} ]]; then
    local __RUST_RUSTUP_ADDITIONAL_COMPONENTS
    IFS=',' read -r -a __RUST_RUSTUP_ADDITIONAL_COMPONENTS <<< "${RUST_RUSTUP_ADDITIONAL_COMPONENTS// /}"
    rustup component add "${__RUST_RUSTUP_ADDITIONAL_COMPONENTS[@]}"
  fi

  mkdir -p                       /usr/share/bash-completion/completions
  rustup completions bash       >/usr/share/bash-completion/completions/rustup
  rustup completions bash cargo >/usr/share/bash-completion/completions/cargo
}

function install_additional_packages() {
  if [[ -n ${SYSTEM_PACKAGES_ADDITIONAL_PACKAGES} ]]; then
    local __SYSTEM_PACKAGES_ADDITIONAL_PACKAGES
    IFS=',' read -r -a __SYSTEM_PACKAGES_ADDITIONAL_PACKAGES <<< "${SYSTEM_PACKAGES_ADDITIONAL_PACKAGES// /}"
    apt-get --yes install --no-install-recommends "${__SYSTEM_PACKAGES_ADDITIONAL_PACKAGES[@]}"
  fi

  return 0
}

function install_mold() {
  [[ ${LINKER_MOLD_INSTALL} == 'true' ]] || return 0

  local MOLD_DIR="mold-${LINKER_MOLD_VERSION}-$(uname -m)-linux"
  curl --silent --show-error --fail --location                                               \
    "https://github.com/rui314/mold/releases/download/v${LINKER_MOLD_VERSION}/${MOLD_DIR}.tar.gz" | \
    tar xvz -C /tmp

  cp "/tmp/${MOLD_DIR}/"{bin/{mold,ld.mold},lib/mold/mold-wrapper.so} /usr/local/bin/
  rm -r "/tmp/${MOLD_DIR}"
}

function post_flight_checks() {
  apt-get --yes autoremove
  apt-get --yes clean
  rm -rf /var/lib/apt/lists/*
}

function main() {
  parse_dev_container_options
  pre_flight_checks

  install_rust
  install_additional_packages
  install_mold

  post_flight_checks
}

main "${@}"
