#! /bin/sh

set -e -u

# This is where the volume will be mounted to
readonly CACHE_MOUNT_POINT=/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/vscode_cache_extensions/data
readonly REMOTE_USER_HOME="${_REMOTE_USER_HOME:-}"

if [ -z "${REMOTE_USER_HOME}" ]; then
  exit 0
fi

prepare_cache_directory() {
  CHANNEL_NAME=${1:?channel name required}
  CHANNEL_SUFFIX=${2-}
  PERSISTENCE_DIR="${CACHE_MOUNT_POINT}/${CHANNEL_NAME}"
  TMP_STORAGE_DIR="${REMOTE_USER_HOME}/.vscode-server${CHANNEL_SUFFIX}"

  # shellcheck disable=SC2174
  mkdir -m 777 -p "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"

  TMP_STORAGE_DIR=${TMP_STORAGE_DIR}/extensions

  rm -r -f "${TMP_STORAGE_DIR}"
  ln -s "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"
}

main() {
  # We create the mount point and temporary directories here with the
  # correct permissions. This is imperative for the mount point as
  # the volume mount will carry over the _permissions_ of an existing
  # directory. We _cannot_ use `chown` here because of
  # `updateRemoteUserUID: true` in some cases, which would result in
  # a UID mismatch; hence, we need `777` as the permissions.
  prepare_cache_directory stable ''
  prepare_cache_directory insiders '-insiders'
}

main "${@}"
