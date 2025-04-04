#! /usr/bin/env bash

# shellcheck disable=SC2154

set -eE -u -o pipefail
shopt -s inherit_errexit

readonly CACHE_MOUNT_POINT='/opt/vscode-extensions-cache'

mkdir --parents "${CACHE_MOUNT_POINT}/"{stable,insiders}
#chown --recursive "${_REMOTE_USER}:${_REMOTE_USER}" "${CACHE_MOUNT_POINT}"

mkdir --parents "${_REMOTE_USER_HOME}/.vscode-server"{,-insiders}
chown --recursive "${_REMOTE_USER}:${_REMOTE_USER}" "${_REMOTE_USER_HOME}/.vscode-server"{,-insiders}

readonly EXTENSIONS_DIR="${_REMOTE_USER_HOME}/.vscode-server/extensions"
[[ -e ${EXTENSIONS_DIR} ]] && rm --recursive --force "${EXTENSIONS_DIR}"
ln --force --symbolic --no-target-directory "${CACHE_MOUNT_POINT}/stable" "${EXTENSIONS_DIR}"

readonly EXTENSIONS_INSIDERS_DIR="${_REMOTE_USER_HOME}/.vscode-server-insiders/extensions"
[[ -e ${EXTENSIONS_INSIDERS_DIR} ]] && rm --recursive --force "${EXTENSIONS_INSIDERS_DIR}"
ln --force --symbolic --no-target-directory "${CACHE_MOUNT_POINT}/insiders" "${EXTENSIONS_INSIDERS_DIR}"

chown --recursive "${_REMOTE_USER}:${_REMOTE_USER}" "${EXTENSIONS_DIR}" "${EXTENSIONS_INSIDERS_DIR}"
