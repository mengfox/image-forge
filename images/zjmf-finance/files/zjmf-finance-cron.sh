#!/bin/sh
set -eu

APP_DIR="${APP_DIR:-/var/www/html}"
CRON_ENABLED="${CRON_ENABLED:-true}"
CRON_COMMAND="${CRON_COMMAND:-php think cron}"
CRON_INTERVAL_SECONDS="${CRON_INTERVAL_SECONDS:-60}"
CRON_RUN_ON_START="${CRON_RUN_ON_START:-true}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

run_cron() {
    log "running in ${APP_DIR}: ${CRON_COMMAND}"
    if [ ! -d "${APP_DIR}" ]; then
        log "app dir not found: ${APP_DIR}"
        return 1
    fi

    (
        cd "${APP_DIR}"
        sh -lc "${CRON_COMMAND}"
    ) || log "command failed with exit code $?"
}

case "${CRON_ENABLED}" in
    true|TRUE|1|yes|YES|on|ON) ;;
    *)
        log "cron disabled, sleeping forever"
        exec tail -f /dev/null
        ;;
esac

case "${CRON_RUN_ON_START}" in
    true|TRUE|1|yes|YES|on|ON)
        run_cron || true
        ;;
esac

while true; do
    sleep "${CRON_INTERVAL_SECONDS}"
    run_cron || true
done
