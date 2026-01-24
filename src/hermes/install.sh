#! /bin/sh

# shellcheck disable=SC2154

set -e -u

mkdir -p  /usr/local/bin/
mv hermes /usr/local/bin/hermes
chmod +x  /usr/local/bin/hermes
