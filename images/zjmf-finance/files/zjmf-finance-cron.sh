#!/bin/sh
set -eu

CRON_ENABLED="${CRON_ENABLED:-true}"
CRON_COMMAND="${CRON_COMMAND:-php /var/www/html/think cron}"
CRON_INTERVAL_SECONDS="${CRON_INTERVAL_SECONDS:-900}"
CRON_RUN_ON_START="${CRON_RUN_ON_START:-false}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

run_cron() {
    log "running: ${CRON_COMMAND}"
    sh -lc "${CRON_COMMAND}" || log "command failed with exit code $?"
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
        run_cron
        ;;
esac

while true; do
    sleep "${CRON_INTERVAL_SECONDS}"
    run_cron
done
