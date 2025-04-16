#! /usr/bin/env bash

set -eE -u -o pipefail
shopt -s inherit_errexit

CURRENT_DIR="$(realpath -eL "$(dirname "${BASH_SOURCE[0]}")")"
readonly CURRENT_DIR

# shellcheck source=./common.sh
source "${CURRENT_DIR}/common.sh"

function parse_dev_container_options() {
  log 'info' 'Parsing input from options'

  readonly RUST_INSTALL="${RUST_INSTALL:?RUST_INSTALLnot set or null}"
  readonly RUST_INSTALL_BASE_PACKAGES="${RUST_INSTALL_BASE_PACKAGES:?RUST_INSTALL_BASE_PACKAGESnot set or null}"
  readonly RUST_RUSTUP_DEFAULT_TOOLCHAIN=${RUST_RUSTUP_DEFAULT_TOOLCHAIN:?RUST_RUSTUP_DEFAULT_TOOLCHAIN not set or null}
  readonly RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE=${RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE?RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE not set}
  readonly RUST_RUSTUP_UPDATE_DEFAULT_TOOLCHAIN=${RUST_RUSTUP_UPDATE_DEFAULT_TOOLCHAIN:?RUST_RUSTUP_UPDATE_DEFAULT_TOOLCHAIN not set or null}
  readonly RUST_RUSTUP_PROFILE=${RUST_RUSTUP_PROFILE:?RUST_RUSTUP_PROFILE not set or null}
  readonly RUST_RUSTUP_ADDITIONAL_TARGETS=${RUST_RUSTUP_ADDITIONAL_TARGETS?RUST_RUSTUP_ADDITIONAL_TARGETS not set}
  readonly RUST_RUSTUP_ADDITIONAL_COMPONENTS=${RUST_RUSTUP_ADDITIONAL_COMPONENTS?RUST_RUSTUP_ADDITIONAL_COMPONENTS not set}
  readonly RUST_RUSTUP_DIST_SERVER=${RUST_RUSTUP_DIST_SERVER:?RUST_RUSTUP_DIST_SERVER not set or null}
  readonly RUST_RUSTUP_UPDATE_ROOT=${RUST_RUSTUP_UPDATE_ROOT:?RUST_RUSTUP_UPDATE_ROOT not set or null}
  RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE=${RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE?RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLEnot set or null}

  readonly SYSTEM_PACKAGES_PACKAGE_MANAGER_SET_PROXIES=${SYSTEM_PACKAGES_PACKAGE_MANAGER_SET_PROXIES:?SYSTEM_PACKAGES_PACKAGE_MANAGER_SET_PROXIES not set or null}
  readonly SYSTEM_PACKAGES_ADDITIONAL_PACKAGES="${SYSTEM_PACKAGES_ADDITIONAL_PACKAGES?SYSTEM_PACKAGES_ADDITIONAL_PACKAGES not set}"

  readonly LINKER_MOLD_INSTALL=${LINKER_MOLD_INSTALL:?LINKER_MOLD_INSTALL not set or null}
  readonly LINKER_MOLD_VERSION=${LINKER_MOLD_VERSION?LINKER_MOLD_VERSION not set}

  [[ -v http_proxy ]]  || export http_proxy=${PROXY_HTTP_HTTP_ADDRESS?PROXY_HTTP_HTTP_ADDRESS not set}
  [[ -v https_proxy ]] || export https_proxy=${PROXY_HTTP_HTTPS_ADDRESS?PROXY_HTTP_HTTPS_ADDRESS not set}
  [[ -v no_proxy ]]    || export no_proxy=${PROXY_HTTP_NO_PROXY_ADDRESS?PROXY_HTTP_NO_PROXY_ADDRESS not set}

  return 0
}

function pre_flight_checks() {
  log 'info' "Running pre-flight checks"

  case "${LINUX_DISTRIBUTION_NAME}" in
    ( 'debian' )
      if value_is_true SYSTEM_PACKAGES_PACKAGE_MANAGER_SET_PROXIES; then
        local APT_CONFIG_FILE='/etc/apt/apt.conf' ; readonly APT_CONFIG_FILE
        mkdir --parents "$(dirname "${APT_CONFIG_FILE}")"
        if [[ -n ${https_proxy} ]]; then
          echo "Acquire::http::Proxy \"${https_proxy}\";" >>"${APT_CONFIG_FILE}"
        elif [[ -n ${http_proxy} ]]; then
          echo "Acquire::http::Proxy \"${http_proxy}\";"  >>"${APT_CONFIG_FILE}"
        fi
      fi

      if value_is_true RUST_INSTALL_BASE_PACKAGES; then
        log 'info' 'Updating APT package index and installing required base packages'
        apt-get --yes --quiet=2 --option=Dpkg::Use-Pty=0 update
        apt-get --yes --quiet=2 --option=Dpkg::Use-Pty=0 install --no-install-recommends \
          'build-essential' 'ca-certificates' 'curl'
      fi
      ;;

    ( * ) ;;
  esac

  return 0
}

function install_additional_packages() {
  if [[ -n ${SYSTEM_PACKAGES_ADDITIONAL_PACKAGES} ]]; then
    local __SYSTEM_PACKAGES_ADDITIONAL_PACKAGES
    IFS=',' read -r -a __SYSTEM_PACKAGES_ADDITIONAL_PACKAGES <<< "${SYSTEM_PACKAGES_ADDITIONAL_PACKAGES// /}"

    case "${LINUX_DISTRIBUTION_NAME}" in
      ( 'debian' )
        log 'info' 'Installing additional packages via APT'
        apt-get --yes --quiet=2 --option=Dpkg::Use-Pty=0 update
        apt-get --yes --quiet=2 --option=Dpkg::Use-Pty=0 install --no-install-recommends \
          "${__SYSTEM_PACKAGES_ADDITIONAL_PACKAGES[@]}"
        ;;

      ( * )
        log 'error' 'Distribution unknown - installing additional packages is not supported'
        exit 1
        ;;
    esac
  fi

  return 0
}

function install_rust() {
  value_is_true RUST_INSTALL || return 0

  log 'debug' 'Setting installation environment variables'
  # These directories contain metadata and files required by
  # `rustup` (toolchain files, components, etc.) and `cargo`
  # (crates, etc.).
  export RUSTUP_HOME='/usr/rust/rustup'
  export CARGO_HOME='/usr/rust/cargo/home'
  export CARGO_TARGET='/usr/rust/cargo/target'

  mkdir -p "${RUSTUP_HOME}" "${CARGO_HOME}" "${CARGO_TARGET}"

  # These variables are used when acquiring and updating `rustup`.
  export RUSTUP_DIST_SERVER
  export RUST_RUSTUP_UPDATE_ROOT

  local RUSTUP_INSTALLER_ARGUMENTS=(
    '-y'
    '--no-modify-path'
    '--default-toolchain' "${RUST_RUSTUP_DEFAULT_TOOLCHAIN}"
    '--profile' "${RUST_RUSTUP_PROFILE}"
  )

  if ! value_is_true RUST_RUSTUP_UPDATE_DEFAULT_TOOLCHAIN; then
    log 'trace' 'Default toolchain will not be updated'
    RUSTUP_INSTALLER_ARGUMENTS+=('--no-update-default-toolchain')
  fi

  if [[ -z ${RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE} ]]; then
    RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE="$(uname -m)-unknown-linux-gnu"
    log 'debug' "Host triple set to '${RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE}'"
  fi

  # This is the point where the actual installation takes place.
  log 'debug' "Acquiring rustup-init"
  curl -sSfL -o "${RUSTUP_HOME}/rustup-init" "${RUST_RUSTUP_UPDATE_ROOT}/dist/${RUST_RUSTUP_RUSTUP_INIT_HOST_TRIPLE}/rustup-init"
  log 'debug' "Installing rustup via rustup-init"
  chmod +x "${RUSTUP_HOME}/rustup-init"
  "${RUSTUP_HOME}/rustup-init" "${RUSTUP_INSTALLER_ARGUMENTS[@]}"

  # This commands exports a new PATH with `${CARGO_HOME}/bin` as an additional entry
  # shellcheck source=/dev/null
  source "${CARGO_HOME}/env"

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
  mkdir  -p                      /usr/share/bash-completion/completions
  rustup completions bash       >/usr/share/bash-completion/completions/rustup
  rustup completions bash cargo >/usr/share/bash-completion/completions/cargo

  log 'trace' 'Adjusting permissions for /usr/rust'
  chmod -R 777 /usr/rust

  return 0
}

function install_mold() {
  value_is_true LINKER_MOLD_INSTALL || return 0
  log 'info' "Installing linker 'mold'"

  local MOLD_DIR
  MOLD_DIR="mold-${LINKER_MOLD_VERSION}-$(uname -m)-linux"
  curl --silent --show-error --fail --location                                                      \
    "https://github.com/rui314/mold/releases/download/v${LINKER_MOLD_VERSION}/${MOLD_DIR}.tar.gz" | \
    tar xvz -C /tmp

  cp "/tmp/${MOLD_DIR}/"{bin/{mold,ld.mold},lib/mold/mold-wrapper.so} /usr/local/bin/
  rm -r "/tmp/${MOLD_DIR}"

  return 0
}

function setup_post_create_command() {
  log 'info' 'Setting up postCreateCommand script'

  local PSC='/opt/devcontainer/features/ghcr_io/georglauterbach/rust/post_start_command.sh'
  readonly PSC

  mkdir --parents "$(dirname "${PSC}")"
  cp "$(realpath -eL "$(dirname "${BASH_SOURCE[0]}")")/$(basename "${PSC}")" "${PSC}"
  sed -i "s|RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE|${RUST_RUSTUP_DEFAULT_TOOLCHAIN_FILE}|g" "${PSC}"
  chmod +x "${PSC}"
}

function main() {
  parse_dev_container_options
  parse_linux_distribution
  pre_flight_checks

  install_additional_packages
  install_rust
  install_mold

  setup_post_create_command
}

main "${@}"
