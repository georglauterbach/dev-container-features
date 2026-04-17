#! /bin/sh

. ./_harness.sh

assert_success 'program exists'              command -v hermes
assert_success 'program version is correct'  test "$(hermes --version)" = 'hermes 12.4.0'
assert_success 'program runs'                hermes

finish
