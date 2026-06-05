#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source /usr/lib/bashio/bashio.sh

require_option() {
    local name="${1}"
    local value="${2}"

    if [[ -z "${value}" || "${value}" == "null" ]]; then
        bashio::exit.nok "The ${name} option must be set."
    fi
}

DB_HOST="$(bashio::config 'DB_HOST')"
DB_PORT="$(bashio::config 'DB_PORT')"
DB_NAME="$(bashio::config 'DB_NAME')"
DB_USER="$(bashio::config 'DB_USER')"
DB_PASS="$(bashio::config 'DB_PASS')"

require_option "DB_HOST" "${DB_HOST}"
require_option "DB_PORT" "${DB_PORT}"
require_option "DB_NAME" "${DB_NAME}"
require_option "DB_USER" "${DB_USER}"
require_option "DB_PASS" "${DB_PASS}"

export DB_TYPE="mysql"
export DB_HOST
export DB_PORT
export DB_NAME
export DB_USER
export DB_PASS

mkdir -p /data/wiki/content /wiki/data /logs

if [[ ! -L /wiki/data/content ]] || [[ "$(readlink /wiki/data/content)" != "/data/wiki/content" ]]; then
    rm -rf /wiki/data/content
    ln -s /data/wiki/content /wiki/data/content
fi

chown -R node:node /data/wiki /wiki/data /logs

bashio::log.info "Starting Wiki.js with MariaDB at ${DB_HOST}:${DB_PORT}/${DB_NAME}"

exec su-exec node:node node --no-deprecation server
