#! /bin/bash

set -e -u

if [ ! -d .github ] || [ ! -d .devcontainer ] || [ ! -d .devcontainer/features ]; then
  echo 'Execute this script from the repository root' >&2
  exit 1
fi

ARCHITECTURE="$(uname -m)"
readonly ARCHITECTURE

readonly HERMES_VERSION="${HERMES_VERSION:-12.0.0}"
readonly HERMES_FILE=src/hermes/hermes

readonly SHELLCHECK_VERSION="${SHELLCHECK_VERSION:-0.11.0}"
readonly SHELLCHECK_FILE=src/lang-sh/shellcheck

if [ ! -f "${HERMES_FILE}" ]; then
  wget --quiet --output-document="${HERMES_FILE}" \
    "https://github.com/georglauterbach/hermes/releases/download/v${HERMES_VERSION}/hermes-v${HERMES_VERSION}-${ARCHITECTURE}-unknown-linux-musl"
  chmod +x "${HERMES_FILE}"
fi

if [ ! -f "${SHELLCHECK_FILE}" ]; then
  wget --quiet --output-document=- \
    "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.${ARCHITECTURE}.tar.xz" \
    | tar xJf - "shellcheck-v${SHELLCHECK_VERSION}/shellcheck"
  mv "shellcheck-v${SHELLCHECK_VERSION}/shellcheck" "${SHELLCHECK_FILE}"
  rmdir "shellcheck-v${SHELLCHECK_VERSION}"
  chmod +x "${SHELLCHECK_FILE}"
fi
