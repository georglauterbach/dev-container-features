#! /bin/sh

set -e

. /etc/os-release

if [ "${ID}" = "alpine" ]; then
  apk add --no-cache bash coreutils gcompat libgcc
fi

exec /bin/bash "$(dirname "${0}")/install_actual.sh" "${@}"
