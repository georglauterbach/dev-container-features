#! /bin/sh

. ./_harness.sh

# -----------------------------------------------
# ----  Basic Tests  ----------------------------
# -----------------------------------------------

assert_success 'program exists'               test -s /usr/local/bin/shellcheck
assert_success 'program is in PATH'           command -v shellcheck
assert_success "ENV 'DCF_LANG_SH_DIR' is set" test -n "${DCF_LANG_SH_DIR:-}"

assert_success "'shellcheck.conf' exists and is not empty" test -s "${DCF_LANG_SH_DIR}/shellcheck.conf"
assert_success "'libbash' exists and is not empty"         test -s "${DCF_LANG_SH_DIR}/libbash"

# -----------------------------------------------
# ----  Apply ShellCheck  -----------------------
# -----------------------------------------------

TEST_WORK_DIR="$(mktemp -d)"
readonly TEST_WORK_DIR

# test 1: a clean script should pass shellcheck

CLEAN_SCRIPT="${TEST_WORK_DIR}/clean.sh"
cat > "${CLEAN_SCRIPT}" <<'SCRIPT'
#!/bin/sh
set -e -u
readonly GREETING="hello"
printf '%s\n' "${GREETING}"
SCRIPT

assert_success 'clean script passes shellcheck'  shellcheck "${CLEAN_SCRIPT}"

# test 2: SC2086 - unquoted variable (word splitting)

SC2086_SCRIPT="${TEST_WORK_DIR}/sc2086.sh"
cat > "${SC2086_SCRIPT}" <<'SCRIPT'
#!/bin/sh
MY_VAR="hello world"
echo $MY_VAR
SCRIPT

assert_failure 'SC2086: unquoted variable' shellcheck "${SC2086_SCRIPT}"

# test 3: SC2046 - unquoted command substitution

SC2046_SCRIPT="${TEST_WORK_DIR}/sc2046.sh"
cat > "${SC2046_SCRIPT}" <<'SCRIPT'
#!/bin/sh
files=$(ls /tmp)
cp $files /dest/
SCRIPT

assert_failure 'SC2046: unquoted cmd subst' shellcheck "${SC2046_SCRIPT}"

# test 4: SC2164 - cd without error handling

SC2164_SCRIPT="${TEST_WORK_DIR}/sc2164.sh"
cat > "${SC2164_SCRIPT}" <<'SCRIPT'
#!/bin/sh
cd /some/directory
echo "arrived"
SCRIPT

assert_failure 'SC2164: cd without || exit' shellcheck "${SC2164_SCRIPT}"

# test 5: SC2006 - backtick command substitution

SC2006_SCRIPT="${TEST_WORK_DIR}/sc2006.sh"
cat > "${SC2006_SCRIPT}" <<'SCRIPT'
#!/bin/sh
DATE=`date`
echo "${DATE}"
SCRIPT

assert_failure 'SC2006: backtick substitution' shellcheck "${SC2006_SCRIPT}"

# test 6: SC2115 - rm -rf with unquoted variable in path

SC2115_SCRIPT="${TEST_WORK_DIR}/sc2115.sh"
cat > "${SC2115_SCRIPT}" <<'SCRIPT'
#!/bin/sh
DIR=""
rm -rf /${DIR}
SCRIPT

assert_failure 'SC2115: risky rm -rf pattern' shellcheck "${SC2115_SCRIPT}"

# test 7: custom rcfile is usable

assert_success 'shellcheck rcfile is usable' \
  shellcheck --rcfile="${DCF_LANG_SH_DIR}/shellcheck.conf" "${CLEAN_SCRIPT}"

finish
