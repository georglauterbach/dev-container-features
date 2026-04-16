#! /bin/sh

# shellcheck disable=SC2154

set -e -u

readonly CACHE_DIR="${DCF_VSCODE_CACHE_EXTENSIONS_DIR:?}/data"

prepare_cache_directory() {
  CHANNEL_NAME="${1:?channel name required}"
  CHANNEL_SUFFIX="${2:-}"
  PERSISTENCE_DIR="${CACHE_DIR}/${CHANNEL_NAME}"
  TMP_STORAGE_DIR="${_REMOTE_USER_HOME}/.vscode-server${CHANNEL_SUFFIX}"

  # shellcheck disable=SC2174
  mkdir -m 777 -p "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"

  TMP_STORAGE_DIR=${TMP_STORAGE_DIR}/extensions

  rm -r -f "${TMP_STORAGE_DIR}"
  ln -s "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"
}

main() {
  if [ -z "${_REMOTE_USER_HOME:-}" ]; then
    echo "Environment variable '_REMOTE_USER_HOME' not set but required" >&2
    exit 1
  fi

  # We create the mount point and temporary directories here with the
  # correct permissions. This is imperative for the mount point as
  # the volume mount will carry over the _permissions_ of an existing
  # directory. We _cannot_ use `chown` here because of
  # `updateRemoteUserUID: true` in some cases, which would result in
  # a UID mismatch; hence, we need `777` as the permissions.
  prepare_cache_directory stable
  prepare_cache_directory insiders -insiders
}

main "${@}"
