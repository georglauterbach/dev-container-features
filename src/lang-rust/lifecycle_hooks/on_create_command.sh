#! /bin/sh

set -e -u

FEATURE_SHARE_DIR=/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_rust
readonly FEATURE_SHARE_DIR

# update directory permissions
update_directory() {
  ENV_NAME=${1:?"(bug) environment variable name required"}
  ENV_VALUE=$(eval "echo \"\$${ENV_NAME}\"")

  echo "Adjusting directory '${ENV_NAME}=${ENV_VALUE}'"

  if [ -z "${ENV_VALUE}" ]; then
    echo "  -> environment variable '${ENV_NAME}' not set, null or empty"
    return 1
  fi

  if [ -d "${ENV_VALUE}" ]; then
    echo "  -> directory already exists"
  else
    printf "  -> creating directory: "

    if mkdir --parents "${ENV_VALUE}"                   2>/dev/null \
    || sudo mkdir --parents "${ENV_VALUE}"              2>/dev/null \
    || su - root sh -c "mkdir --parents '${ENV_VALUE}'" 2>/dev/null
    then
      echo 'done'
    else
      echo "FAILED ('sudo' missing or 'su' with 'root' failed)"
    fi
  fi

  if [ "$(stat -c '%u' "${ENV_VALUE}")" -ne "$(id -u)" ] \
  || {
    # we check for Rustup's settings.toml here explicitly because
    # this file is known to make problems
    [ -f "${ENV_VALUE}/settings.toml" ] \
    && [ "$(stat -c '%u' "${ENV_VALUE}/settings.toml")" -ne "$(id -u)" ]
  }; then
    printf "  -> updating permissions: "

    if chown --recursive "$(id -u):$(id -g)" "${ENV_VALUE}"                   2>/dev/null \
    || sudo chown --recursive "$(id -u):$(id -g)" "${ENV_VALUE}"              2>/dev/null \
    || su - root sh -c "chown --recursive '$(id -u):$(id -g)' '${ENV_VALUE}'" 2>/dev/null
    then
      echo 'done'
    else
      echo "FAILED ('sudo' missing or 'su' with 'root' failed)"
    fi
  else
    echo "  -> directory already has proper permissions"
  fi
}

rustup_adjustments() {
  echo "Adjusting 'rustup'"
  if ! command -v rustup >/dev/null 2>/dev/null; then
    echo "  -> 'rustup' is not installed"
    echo "  -> not running other commands"
    return 0
  fi

  echo "  -> 'rustup' is installed"
  if [ -f "${FEATURE_SHARE_DIR}/.rustup_disable_auto_self_update" ]; then
    echo "  -> disabling rustup's self-update feature"
    rustup set auto-self-update disable
  else
    echo "  -> not disabling rustup's self-update feature"
  fi
}

main() {
  for ENV_NAME in 'RUSTUP_HOME' 'CARGO_HOME'; do
    if ! update_directory "${ENV_NAME}"; then
      echo "  -> not running other commands"
    fi
  done

  rustup_adjustments
}

main "${@}"
