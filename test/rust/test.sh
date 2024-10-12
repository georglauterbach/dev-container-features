#! /usr/bin/env bash

set -eE -u -o pipefail
shopt -s inherit_errexit

rustup default stable

command -v rustup-init
command -v rustup
command -v rustc
command -v cargo
