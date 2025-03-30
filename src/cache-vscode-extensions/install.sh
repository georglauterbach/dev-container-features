#! /usr/bin/env bash

# shellcheck disable=SC2154

set -eE -u -o pipefail
shopt -s inherit_errexit

readonly CACHE_MOUNT_POINT='/opt/vscode-extensions-cache'

mkdir --parents "${CACHE_MOUNT_POINT}/"{stable,insiders}
chown --recursive "${_REMOTE_USER}:${_REMOTE_USER}" "${CACHE_MOUNT_POINT}"

mkdir --parents "${_REMOTE_USER_HOME}/.vscode-server"{,-insiders}
chown "${_REMOTE_USER}:${_REMOTE_USER}" "${_REMOTE_USER_HOME}/.vscode-server"{,-insiders}

ln --force --symbolic --no-target-directory \
  "${CACHE_MOUNT_POINT}/stable"   "${_REMOTE_USER_HOME}/.vscode-server/extensions"
ln --force --symbolic --no-target-directory \
  "${CACHE_MOUNT_POINT}/insiders" "${_REMOTE_USER_HOME}/.vscode-server-insiders/extensions"

chown --no-dereference "${_REMOTE_USER}:${_REMOTE_USER}" \
  "${_REMOTE_USER_HOME}/.vscode-server/extensions"       \
  "${_REMOTE_USER_HOME}/.vscode-server-insiders/extensions"
