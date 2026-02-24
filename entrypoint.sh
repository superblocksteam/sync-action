#!/bin/bash

set -euo pipefail

SUPERBLOCKS_CLI_VERSION="${SUPERBLOCKS_CLI_VERSION:-latest}"
SUPERBLOCKS_DOMAIN="${SUPERBLOCKS_DOMAIN:-app.superblocks.com}"
SUPERBLOCKS_PATH="${SUPERBLOCKS_PATH:-.}"
SUPERBLOCKS_SYNC_SHA="${SUPERBLOCKS_SYNC_SHA:-HEAD}"

if [[ -z "${SUPERBLOCKS_TOKEN:-}" ]]; then
  echo "The 'SUPERBLOCKS_TOKEN' environment variable is unset or empty. Exiting..."
  exit 1
fi

REPO_DIR="${REPO_DIR:-${GITHUB_WORKSPACE:-$(pwd)}}"
cd "${REPO_DIR}"

if [[ "${SUPERBLOCKS_PATH}" = /* ]]; then
  SYNC_ROOT="${SUPERBLOCKS_PATH}"
else
  SYNC_ROOT="${REPO_DIR}/${SUPERBLOCKS_PATH}"
fi
if [[ ! -d "${SYNC_ROOT}" ]]; then
  echo "Sync root directory does not exist: ${SYNC_ROOT}"
  exit 1
fi

git config --global --add safe.directory "${REPO_DIR}"

printf "Installing Superblocks CLI (%s)...\n" "${SUPERBLOCKS_CLI_VERSION}"
npm install -g @superblocksteam/cli@"${SUPERBLOCKS_CLI_VERSION}"
superblocks --version

printf "\nLogging in to Superblocks...\n"
superblocks config set domain "${SUPERBLOCKS_DOMAIN}"
superblocks login -t "${SUPERBLOCKS_TOKEN}"

if [[ "${SUPERBLOCKS_SYNC_SHA}" == "HEAD" ]]; then
  SYNC_SHA="$(git rev-parse HEAD)"
else
  SYNC_SHA="${SUPERBLOCKS_SYNC_SHA}"
fi

printf "Sync SHA: %s\n" "${SYNC_SHA}"
printf "Sync root: %s\n" "${SYNC_ROOT}"

pushd "${SYNC_ROOT}" >/dev/null
superblocks sync --sha "${SYNC_SHA}" --json
popd >/dev/null

printf "\nSync complete.\n"
