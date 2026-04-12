#! /bin/sh

set -e -u

mkdir -p        /usr/local/bin/
mv tools/hermes /usr/local/bin/hermes
chmod +x        /usr/local/bin/hermes
