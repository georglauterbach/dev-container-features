#! /bin/sh

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

assert_success 'program exists'               test -s /usr/local/bin/shellcheck
assert_success 'program is in PATH'           command -v shellcheck
assert_success "ENV 'DCF_LANG_SH_DIR' is set" test -v DCF_LANG_SH_DIR

assert_success "'shellcheck.conf' exists and is not empty" test -s "${DCF_LANG_SH_DIR}/shellcheck.conf"
assert_success "'libbash' exists and is not empty"         test -s "${DCF_LANG_SH_DIR}/libbash"

report
