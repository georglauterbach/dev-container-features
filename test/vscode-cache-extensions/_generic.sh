#! /bin/sh

FAILED=false

# shellcheck disable=SC2329
assert_failure() {
  printf '   ├ %-60s ' "${1:?Name of the test required}"
  shift 1
  "${@}" >/dev/null && { printf '❌ \e[31mFAILED\e[0m\n' ; FAILED=true ; return 0 ; }
  printf '✅ \e[32mPASSED\e[0m\n'
}

# shellcheck disable=SC2329
assert_success() {
  printf '   ├ %-60s ' "${1:?Name of the test required}"
  shift 1
  "${@}" >/dev/null && { printf '✅ \e[32mPASSED\e[0m\n' ; return 0 ; }
  printf '❌ \e[31mFAILED\e[0m\n'
  FAILED=true
}

report() {
  printf "   └ "
  if ${FAILED:-true}; then
    printf '❌ \e[31mFAILED\e[0m\n'
    exit 1
  else
    printf "✅ \e[32mPASSED\e[0m\n"
    exit 0
  fi
}

trap report EXIT

readonly CACHE_MOUNT_POINT=/usr/local/share/dev_containers/features/ghcr_io/georglauterbach/vscode_cache_extensions/data

assert_success 'mount point exists' test -d "${CACHE_MOUNT_POINT}"

assert_success 'stable: symlink target directory exists' test -d "${CACHE_MOUNT_POINT}/stable"
assert_success 'stable: symlink source directory parent exists' test -d "${HOME}/.vscode-server"
assert_success 'stable: symlink source directory is a symbolic link' \
  test -L "${HOME}/.vscode-server/extensions"
assert_success 'stable: symbolic link resolves to correct location' \
  test "$(readlink "${HOME}/.vscode-server/extensions")" = "${CACHE_MOUNT_POINT}/stable"


assert_success 'insiders: symlink target directory exists' test -d "${CACHE_MOUNT_POINT}/insiders"
assert_success 'insiders: symlink source directory parent exists' test -d "${HOME}/.vscode-server-insiders"
assert_success 'insiders: symlink source directory is a symbolic link' \
  test -L "${HOME}/.vscode-server-insiders/extensions"
assert_success 'insiders: symbolic link resolves to correct location' \
  test "$(readlink "${HOME}/.vscode-server-insiders/extensions")" = "${CACHE_MOUNT_POINT}/insiders"
