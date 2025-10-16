#! /bin/bash

set -eE -u -o pipefail
shopt -s inherit_errexit

source lib.sh

assert_success :

reportResults
