#! /usr/bin/env bash

# shellcheck disable=SC2154

set -eE -u -o pipefail
shopt -s inherit_errexit

source /etc/os-release

export USER=${USER:-${_REMOTE_USER:?TODO}}

case "${ID}" in
  ( 'ubuntu' | 'debian' )
    # These environment variables are used by APT and dpkg. Their # values make APT and
    # dpkg behave as non-interactive.
    export DEBIAN_FRONTEND='noninteractive'
    export DEBCONF_NONINTERACTIVE_SEEN='true'

    # We configure `tzdata` here so that we do not get prompted later when
    # installing packages (e.g. on an interactive shell).
    export TZ='Etc/UTC'

    # We ensure we use the most recent versions of packages from the base image. Here,
    # `dist-upgrade` is okay as well, because we do not have prior commands installing
    # software that could potentially be damaged.
    apt-get --yes update
    apt-get --yes dist-upgrade
    apt-get --yes install --no-install-recommends \
      apt-utils ca-certificates curl dialog doas file locales tzdata
    # We also perform a proper cleanup
    apt-get --yes autoremove
    apt-get --yes clean
    # rm -rf /var/lib/apt/lists/* /tmp/*

    # This stage sets up the previously installed package `doas`, a sudo replacement.
    # We configure it so that the user `ubuntu` can execute root commands password-less.
    echo "permit nopass ${USER}" >/etc/doas.conf
    chown root:root /etc/doas.conf
    chmod 0400 /etc/doas.conf
    doas -C /etc/doas.conf
    ln -s "$(command -v doas)" /usr/local/bin/sudo
    ;;

  ( * ) ;;
esac


