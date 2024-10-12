#! /usr/bin/env bash

set -eE -u -o pipefail
shopt -s inherit_errexit

function log() {
  printf "%s %-5s %s: %s\n" \
    "$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z" || :)" "${1:-}" "${FUNCNAME[1]:-}" "${2:-}"
}

function parse_linux_distribution() {
  export LINUX_DISTRIBUTION_NAME='unknown'

  [[ -f /etc/os-release ]] || return 0

  # shellcheck disable=SC2034
  source /etc/os-release

  if [[ ${ID_LIKE} =~ ^debian$ ]]; then
    LINUX_DISTRIBUTION_NAME='debian'
    export DEBIAN_FRONTEND=noninteractive
    export DEBCONF_NONINTERACTIVE_SEEN=true
  fi
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

  export HOME='/root'

  if [[ ${LINUX_DISTRIBUTION_NAME} == 'unknown' ]]; then
    log 'error' 'Could not determine Linux distribution name'
    exit 1
  fi

  log 'debug' 'Ensuring that login shells get the correct path if the user updates PATH using ENV'
  rm -f /etc/profile.d/00-restore-env.sh
  echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" >/etc/profile.d/00-restore-env.sh
  chmod +x /etc/profile.d/00-restore-env.sh

  case "${LINUX_DISTRIBUTION_NAME}" in
    ( 'debian' )
      log 'info' 'Updating APT package index and installing required base packages'
      apt-get --yes update
      apt-get --yes install --no-install-recommends 'build-essential' 'ca-certificates' 'curl'
      ;;

    ( * )
      log 'error' "This is a bug and should not have happened (could not match Linux distribution name '${LINUX_DISTRIBUTION_NAME}')"
      exit 1
  esac
}

function install_rust() {
  [[ ${RUST_INSTALL} == 'true' ]] || return 0

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
    log 'debug' "Host triple set to '${RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE}'"
  fi

  # This is the point where the actual installation takes place.
  log 'debug' "Acquiring rustup-init"
  curl -sSfL -o "${RUSTUP_HOME}/bin/rustup-init" "${RUST_RUSTUP_UPDATE_ROOT}/dist/${RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE}/rustup-init"
  chmod +x "${RUSTUP_HOME}/bin/"*
  log 'debug' "Installing rustup via rustup-init"
  rustup-init "${RUSTUP_INSTALLER_ARGUMENTS[@]}"

  if [[ ${RUST_RUSTUP_DEFAULT_TOOLCHAIN} != 'none' ]]; then
    rustup default "${RUST_RUSTUP_DEFAULT_TOOLCHAIN}"
  fi

  if [[ -n ${RUST_RUSTUP_ADDITIONAL_TARGETS} ]]; then
    local __RUST_RUSTUP_ADDITIONAL_TARGETS
    IFS=',' read -r -a __RUST_RUSTUP_ADDITIONAL_TARGETS <<< "${RUST_RUSTUP_ADDITIONAL_TARGETS// /}"
    log 'debug' "Installing additional rustup targets: ${__RUST_RUSTUP_ADDITIONAL_TARGETS[*]}"
    rustup target add "${__RUST_RUSTUP_ADDITIONAL_TARGETS[@]}"
  fi

  if [[ -n ${RUST_RUSTUP_ADDITIONAL_COMPONENTS} ]]; then
    local __RUST_RUSTUP_ADDITIONAL_COMPONENTS
    IFS=',' read -r -a __RUST_RUSTUP_ADDITIONAL_COMPONENTS <<< "${RUST_RUSTUP_ADDITIONAL_COMPONENTS// /}"
    log 'debug' "Adding additional rustup components: ${__RUST_RUSTUP_ADDITIONAL_COMPONENTS[*]}"
    rustup component add "${__RUST_RUSTUP_ADDITIONAL_COMPONENTS[@]}"
  fi

  log 'debug' 'Setting up bash completion'
  mkdir -p                       /usr/share/bash-completion/completions
  rustup completions bash       >/usr/share/bash-completion/completions/rustup
  rustup completions bash cargo >/usr/share/bash-completion/completions/cargo

  log 'debug' 'Creating default directories for rustup and cargo metadata and build files'
  mkdir -p /usr/rust/{rustup_home,cargo_home,cargo_target}
  chmod -R 777 /usr/rust
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

  local MOLD_DIR
  MOLD_DIR="mold-${LINKER_MOLD_VERSION}-$(uname -m)-linux"
  curl --silent --show-error --fail --location                                                      \
    "https://github.com/rui314/mold/releases/download/v${LINKER_MOLD_VERSION}/${MOLD_DIR}.tar.gz" | \
    tar xvz -C /tmp

  cp "/tmp/${MOLD_DIR}/"{bin/{mold,ld.mold},lib/mold/mold-wrapper.so} /usr/local/bin/
  rm -r "/tmp/${MOLD_DIR}"
}

function post_flight_checks() {
  case "${LINUX_DISTRIBUTION_NAME}" in
    ( 'debian' )
      log 'info' 'Cleaning up APT and its cache'
      apt-get --yes autoremove
      apt-get --yes clean
      rm -rf /var/lib/apt/lists/*
      ;;

    ( * )
      log 'error' "This is a bug and should not have happened (could not match Linux distribution name '${LINUX_DISTRIBUTION_NAME}')"
      exit 1
  esac
}

function main() {
  parse_linux_distribution
  parse_dev_container_options
  pre_flight_checks

  install_rust
  install_additional_packages
  install_mold

  post_flight_checks
}

main "${@}"
