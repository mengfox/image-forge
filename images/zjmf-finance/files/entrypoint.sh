#!/bin/sh
set -eu

APP_DIR="${APP_DIR:-/var/www/html}"
APP_SEED_DIR="${APP_SEED_DIR:-/opt/zjmf-finance-seed}"

is_effectively_empty_dir() {
    [ -d "$1" ] || return 0
    [ -z "$(find "$1" -mindepth 1 -maxdepth 1 ! -name 'lost+found' -print -quit 2>/dev/null)" ]
}

maybe_seed_app() {
    if [ ! -d "${APP_DIR}" ]; then
        mkdir -p "${APP_DIR}"
    fi

    if [ -d "${APP_SEED_DIR}" ] && [ -f "${APP_SEED_DIR}/public/index.php" ]; then
        if is_effectively_empty_dir "${APP_DIR}"; then
            echo "Initializing ZJMF Finance application files into ${APP_DIR}" >&2
            cp -a "${APP_SEED_DIR}/." "${APP_DIR}/"
        fi
    fi
}

fix_permissions() {
    if [ -d "${APP_DIR}" ]; then
        find "${APP_DIR}" -maxdepth 3 -type d \
            \( -name runtime -o -name uploads -o -name upload -o -name cache -o -name logs -o -name data \) \
            -exec chown -R www-data:www-data {} + || true

        [ -e "${APP_DIR}/config.php" ] && chown www-data:www-data "${APP_DIR}/config.php" || true
    fi
}

fix_session_dir() {
    SESSION_DIR="/tmp/session"
    if [ ! -d "${SESSION_DIR}" ]; then
        echo "Creating session directory ${SESSION_DIR}" >&2
        mkdir -p "${SESSION_DIR}"
    fi

    current_perms="$(stat -c '%a' "${SESSION_DIR}" 2>/dev/null || echo "000")"
    if [ "${current_perms}" != "777" ]; then
        echo "Fixing session directory permissions: ${current_perms} -> 777" >&2
        chmod 777 "${SESSION_DIR}"
    fi
}

maybe_seed_app
fix_permissions
fix_session_dir

exec docker-php-entrypoint "$@"