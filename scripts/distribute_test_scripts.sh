#! /bin/sh

set -e -u

for DIR in test/*; do
  cp scripts/test_harness.sh "${DIR}/_harness.sh"
done
