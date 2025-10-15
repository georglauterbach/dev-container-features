#! /bin/sh

# shellcheck disable=SC2154

set -e -u

# This is where the volume will be mounted to
readonly CACHE_MOUNT_POINT='/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/vscode_cache_extensions/data'

if [ -z "${_REMOTE_USER_HOME:-}" ]; then
  exit 0
fi

# We create the mount point and temporary directories here with the
# correct permissions. This is especially imperative for the mount
# point as the volume mount will cary over the _permissions_ of an
# existing directory. We _cannot_ use `chown` here because of
# `updateRemoteUserUID: true` in some cases, which would result in
# a UID mismatch; hence, we need `777` as the permissions.
for LOOP_VAR in "stable," "insiders,-insiders"; do
  PERSISTENCE_DIR="${CACHE_MOUNT_POINT}/$(printf '%s' "${LOOP_VAR}" | cut --delimiter=, --fields=1)"
  TMP_STORAGE_DIR="${_REMOTE_USER_HOME}/.vscode-server$(printf '%s' "${LOOP_VAR}" | cut --delimiter=, --fields=2)"

  mkdir --parents "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"
  chmod --recursive 777 "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"

  TMP_STORAGE_DIR=${TMP_STORAGE_DIR}/extensions

  rm --recursive --force "${TMP_STORAGE_DIR}"
  ln --symbolic "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"
done
