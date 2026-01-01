#! /bin/sh

# This script uses the short flags (e.g., "-f") for commands instead of the
# long flags (e.g. "--force") to work on Alpine and other distributions.

# shellcheck disable=SC2154

set -e -u

# This is where the volume will be mounted to
readonly CACHE_MOUNT_POINT='/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/vscode_cache_extensions/data'

if [ -z "${_REMOTE_USER_HOME:-}" ]; then
  exit 0
fi

# We create the mount point and temporary directories here with the
# correct permissions. This is imperative for the mount point as
# the volume mount will cary over the _permissions_ of an existing
# directory. We _cannot_ use `chown` here because of
# `updateRemoteUserUID: true` in some cases, which would result in
# a UID mismatch; hence, we need `777` as the permissions.
for LOOP_VAR in "stable," "insiders,-insiders"; do
  PERSISTENCE_DIR="${CACHE_MOUNT_POINT}/$(printf '%s' "${LOOP_VAR}" | cut -d , -f 1)"
  TMP_STORAGE_DIR="${_REMOTE_USER_HOME}/.vscode-server$(printf '%s' "${LOOP_VAR}" | cut --delimiter=, --fields=2)"

  # shellcheck disable=SC2174
  mkdir -m 777 -p "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"

  TMP_STORAGE_DIR=${TMP_STORAGE_DIR}/extensions

  rm -r -f "${TMP_STORAGE_DIR}"
  ln -s "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"
done
