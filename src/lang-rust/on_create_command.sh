#! /bin/sh

set -e -u

mkdir --parents /usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_rust/lifecycle_hooks
cp on_create_command.sh /usr/local/share/dev_containers/features/ghcr_io/georglauterbach/lang_rust/lifecycle_hooks/on_create_command.sh
