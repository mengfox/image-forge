#!/bin/sh
set -eu

APP_DIR="${APP_DIR:-/var/www/html}"
APP_CONFIG_FILE="${APP_CONFIG_FILE:-${APP_DIR}/config.php}"
CRON_ENABLED="${CRON_ENABLED:-true}"
CRON_COMMAND="${CRON_COMMAND:-php think cron}"
CRON_INTERVAL_SECONDS="${CRON_INTERVAL_SECONDS:-60}"
CRON_RUN_ON_START="${CRON_RUN_ON_START:-true}"
CRON_WAIT_LOG_INTERVAL_SECONDS="${CRON_WAIT_LOG_INTERVAL_SECONDS:-300}"

last_wait_log=0

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

app_is_configured() {
    [ -f "${APP_CONFIG_FILE}" ] || return 1

    php -r '
        $file = $argv[1];
        $cfg = @require $file;
        if (!is_array($cfg)) {
            exit(1);
        }
        foreach (["hostname", "database", "username"] as $key) {
            if (!isset($cfg[$key]) || $cfg[$key] === "" || strpos((string)$cfg[$key], "#") !== false) {
                exit(1);
            }
        }
    ' "${APP_CONFIG_FILE}" >/dev/null 2>&1
}

database_is_ready() {
    php -r '
        $file = $argv[1];
        $cfg = @require $file;
        if (!is_array($cfg)) {
            fwrite(STDERR, "config load failed");
            exit(1);
        }
        $host = (string)($cfg["hostname"] ?? "");
        $port = (string)($cfg["hostport"] ?? "3306");
        $db = (string)($cfg["database"] ?? "");
        $user = (string)($cfg["username"] ?? "");
        $pass = (string)($cfg["password"] ?? "");
        $charset = (string)($cfg["charset"] ?? "utf8");
        if ($host === "" || $db === "" || $user === "" || strpos($host, "#") !== false || strpos($db, "#") !== false) {
            fwrite(STDERR, "config incomplete");
            exit(1);
        }
        try {
            new PDO(
                "mysql:host={$host};port={$port};dbname={$db};charset={$charset}",
                $user,
                $pass,
                [
                    PDO::ATTR_TIMEOUT => 3,
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                ]
            );
        } catch (Throwable $e) {
            fwrite(STDERR, $e->getMessage());
            exit(1);
        }
    ' "${APP_CONFIG_FILE}"
}

wait_until_ready() {
    while true; do
        now="$(date +%s)"

        if ! app_is_configured; then
            if [ $((now - last_wait_log)) -ge "${CRON_WAIT_LOG_INTERVAL_SECONDS}" ]; then
                log "waiting for installation to finish before running cron"
                last_wait_log="${now}"
            fi
            sleep "${CRON_INTERVAL_SECONDS}"
            continue
        fi

        if ! db_message="$(database_is_ready 2>&1)"; then
            if [ $((now - last_wait_log)) -ge "${CRON_WAIT_LOG_INTERVAL_SECONDS}" ]; then
                log "waiting for database readiness before running cron: ${db_message}"
                last_wait_log="${now}"
            fi
            sleep "${CRON_INTERVAL_SECONDS}"
            continue
        fi

        return 0
    done
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

wait_until_ready

case "${CRON_RUN_ON_START}" in
    true|TRUE|1|yes|YES|on|ON)
        run_cron || true
        ;;
esac

while true; do
    sleep "${CRON_INTERVAL_SECONDS}"
    wait_until_ready
    run_cron || true
done
