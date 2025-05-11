#! /usr/bin/env bash

set -e

# shellcheck source=./lib.sh
source lib.sh

assert_success whoami

dir_exists /opt/devcontainer/features/ghcr_io/georglauterbach/rust
dir_exists /opt/devcontainer/features/ghcr_io/georglauterbach/rust/rustup/home
dir_exists /opt/devcontainer/features/ghcr_io/georglauterbach/rust/cargo/home

command_exists rustup
command_exists rustc
command_exists cargo

assert_failure "rustup::default" rustup default

dir_exists  /usr/share/bash-completion/completions
file_exists /usr/share/bash-completion/completions/rustup
file_exists /usr/share/bash-completion/completions/cargo

file_exists /opt/devcontainer/features/ghcr_io/georglauterbach/rust/rustup/home/rustup-init
file_exists /opt/devcontainer/features/ghcr_io/georglauterbach/rust/cargo/home/env
dir_exists  /opt/devcontainer/features/ghcr_io/georglauterbach/rust/cargo/home/bin

reportResults
