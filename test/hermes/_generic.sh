#! /bin/sh

FAILED=false

# shellcheck disable=SC2329
assert_failure() {
  printf '   ├ %-30s ' "${1:?Name of the test required}"
  shift 1
  "${@}" >/dev/null && { printf '❌ \e[31mFAILED\e[0m\n' ; FAILED=true ; return 0 ; }
  printf '✅ \e[32mPASSED\e[0m\n'
}

# shellcheck disable=SC2329
assert_success() {
  printf '   ├ %-30s ' "${1:?Name of the test required}"
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

assert_success 'program exists'              command -v hermes
assert_success 'program version is correct'  test "$(hermes --version)" = 'hermes 12.3.2'
assert_success 'program runs'                hermes
