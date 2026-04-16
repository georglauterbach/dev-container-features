#! /bin/sh

. ./_harness.sh

readonly CACHE_DIR="${DCF_VSCODE_CACHE_EXTENSIONS_DIR:?}/data"

assert_success 'mount point exists' test -d "${CACHE_DIR}"

assert_success 'stable: symlink target directory exists' test -d "${CACHE_DIR}/stable"
assert_success 'stable: symlink source directory parent exists' test -d "${HOME}/.vscode-server"
assert_success 'stable: symlink source directory is a symbolic link' \
  test -L "${HOME}/.vscode-server/extensions"
assert_success 'stable: symbolic link resolves to correct location' \
  test "$(readlink "${HOME}/.vscode-server/extensions")" = "${CACHE_DIR}/stable"


assert_success 'insiders: symlink target directory exists' test -d "${CACHE_DIR}/insiders"
assert_success 'insiders: symlink source directory parent exists' test -d "${HOME}/.vscode-server-insiders"
assert_success 'insiders: symlink source directory is a symbolic link' \
  test -L "${HOME}/.vscode-server-insiders/extensions"
assert_success 'insiders: symbolic link resolves to correct location' \
  test "$(readlink "${HOME}/.vscode-server-insiders/extensions")" = "${CACHE_DIR}/insiders"

finish
