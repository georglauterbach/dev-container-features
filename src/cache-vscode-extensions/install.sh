#! /usr/bin/env bash

# shellcheck disable=SC2154

set -eE -u -o pipefail
shopt -s inherit_errexit

# This is where the volume will be mounted to
readonly CACHE_MOUNT_POINT='/opt/devcontainer/features/ghcr_io/georglauterbach/cache_vscode_extensions/data'

# We create the mount point and temporary directories here with the
# correct permissions. This is especially imperative for the mount
# point as the volume mount will cary over the _permissions_ of an
# existing directory. We _cannot_ use `chown` here because of
# `updateRemoteUserUID: true` in some cases, which would result in
# a UID mismatch; hence, we need `777` as the permissions.
for LOOP_VAR in "stable," "insiders,-insiders"; do
  PERSISTENCE_DIR="${CACHE_MOUNT_POINT}/$(cut --delimiter=, --fields=1 <<< "${LOOP_VAR}")"
  TMP_STORAGE_DIR="${_REMOTE_USER_HOME}/.vscode-server$(cut --delimiter=, --fields=2 <<< "${LOOP_VAR}")"

  mkdir --parents "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"
  chmod --recursive 777 "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"

  TMP_STORAGE_DIR=${TMP_STORAGE_DIR}/extensions

  rm --recursive --force "${TMP_STORAGE_DIR}"
  ln --symbolic "${PERSISTENCE_DIR}" "${TMP_STORAGE_DIR}"
done
