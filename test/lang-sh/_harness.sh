#! /bin/sh

__SUCCESS=true
__FINISHED=false

# shellcheck disable=SC2329
assert_failure() {
  printf '   ├ %-60s ' "${1:?Name of the test required}"
  shift 1
  "${@}" >/dev/null && { printf '❌ \e[31mFAILED\e[0m\n' ; __SUCCESS=false ; return 0 ; }
  printf '✅ \e[32mPASSED\e[0m\n'
}

# shellcheck disable=SC2329
assert_success() {
  printf '   ├ %-60s ' "${1:?Name of the test required}"
  shift 1
  "${@}" >/dev/null && { printf '✅ \e[32mPASSED\e[0m\n' ; return 0 ; }
  printf '❌ \e[31mFAILED\e[0m\n'
  __SUCCESS=false
}

report() {
  printf "   └ "
  if ! "${__FINISHED}"; then
    printf '⚠️ \e[31mNOT ALL TESTS RAN\e[0m\n'
    exit 1
  fi

  if "${__SUCCESS}"; then
    printf "✅ \e[32mPASSED\e[0m\n"
    exit 0
  else
    printf '❌ \e[31mFAILED\e[0m\n'
    exit 1
  fi
}

finish() {
  __FINISHED=true
}

trap report EXIT
