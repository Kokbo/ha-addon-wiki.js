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

require_safe_path() {
    local name="${1}"
    local value="${2}"
    local prefix="${3}"

    require_option "${name}" "${value}"

    if [[ "${value}" == *"'"* || "${value}" == *$'\n'* ]]; then
        bashio::exit.nok "The ${name} option contains unsupported characters."
    fi

    if [[ "${value}" == "${prefix}" || "${value}" == "${prefix}/" ]]; then
        bashio::exit.nok "The ${name} option must point to a subdirectory of ${prefix}."
    fi

    if [[ "${value}" != "${prefix}/"* ]]; then
        bashio::exit.nok "The ${name} option must be inside ${prefix}."
    fi
}

DB_HOST="$(bashio::config 'DB_HOST')"
DB_PORT="$(bashio::config 'DB_PORT')"
DB_NAME="$(bashio::config 'DB_NAME')"
DB_USER="$(bashio::config 'DB_USER')"
DB_PASS="$(bashio::config 'DB_PASS')"
WIKI_CONTENT_PATH="$(bashio::config 'WIKI_CONTENT_PATH')"
WIKI_DATA_PATH="$(bashio::config 'WIKI_DATA_PATH')"

require_option "DB_HOST" "${DB_HOST}"
require_option "DB_PORT" "${DB_PORT}"
require_option "DB_NAME" "${DB_NAME}"
require_option "DB_USER" "${DB_USER}"
require_option "DB_PASS" "${DB_PASS}"
require_safe_path "WIKI_CONTENT_PATH" "${WIKI_CONTENT_PATH}" "/config"
require_safe_path "WIKI_DATA_PATH" "${WIKI_DATA_PATH}" "/data"

export DB_TYPE="mysql"
export DB_HOST
export DB_PORT
export DB_NAME
export DB_USER
export DB_PASS

mkdir -p "${WIKI_CONTENT_PATH}" "${WIKI_DATA_PATH}" /logs
chown -R node:node "${WIKI_CONTENT_PATH}" "${WIKI_DATA_PATH}" /logs

WIKI_CONFIG_FILE="/tmp/wikijs-config.yml"
cp /wiki/config.yml "${WIKI_CONFIG_FILE}"
printf "\ndataPath: '%s'\n" "${WIKI_DATA_PATH}" >> "${WIKI_CONFIG_FILE}"
export CONFIG_FILE="${WIKI_CONFIG_FILE}"

bashio::log.info "Starting Wiki.js with MariaDB at ${DB_HOST}:${DB_PORT}/${DB_NAME}"
bashio::log.info "If Wiki.js reports ER_ACCESS_DENIED_ERROR, verify the MariaDB login, password, and rights match these add-on options."
bashio::log.info "Home Assistant documentation folder is available to Wiki.js at ${WIKI_CONTENT_PATH}"
bashio::log.info "To sync pages as files, enable Wiki.js Storage > Local File System and set its path to ${WIKI_CONTENT_PATH}"

exec su-exec node:node node --no-deprecation server
