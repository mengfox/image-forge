#!/bin/sh
set -eu

SCRIPT_PATH="${1:-}"
INTERVAL="${2:-60}"
TASK_NAME="${3:-automation}"
APP_DIR="${APP_DIR:-/var/www/html}"
CONFIG_FILE="${APP_DIR}/config.php"

if [ -z "${SCRIPT_PATH}" ]; then
    echo "zjmf-automation-loop requires a script path" >&2
    exit 1
fi

last_wait_log=0

while true; do
    now="$(date +%s)"

    if [ ! -f "${CONFIG_FILE}" ] || [ ! -f "${SCRIPT_PATH}" ]; then
        if [ $((now - last_wait_log)) -ge 300 ]; then
            echo "[${TASK_NAME}] waiting for installation to finish before running ${SCRIPT_PATH}" >&2
            last_wait_log="${now}"
        fi
        sleep "${INTERVAL}"
        continue
    fi

    php "${SCRIPT_PATH}" || echo "[${TASK_NAME}] command failed: php ${SCRIPT_PATH}" >&2
    sleep "${INTERVAL}"
done