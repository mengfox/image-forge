#!/bin/sh
set -eu

APP_DIR="${APP_DIR:-/var/www/html}"
APP_SEED_DIR="${APP_SEED_DIR:-/opt/zjmf-seed}"

is_effectively_empty_dir() {
    [ -d "$1" ] || return 0
    [ -z "$(find "$1" -mindepth 1 -maxdepth 1 ! -name 'lost+found' -print -quit 2>/dev/null)" ]
}

if [ ! -d "${APP_DIR}" ]; then
    mkdir -p "${APP_DIR}"
fi

if [ -d "${APP_SEED_DIR}" ] && [ -f "${APP_SEED_DIR}/public/index.php" ]; then
    if is_effectively_empty_dir "${APP_DIR}"; then
        echo "Initializing ZJMF application files into ${APP_DIR}" >&2
        cp -a "${APP_SEED_DIR}/." "${APP_DIR}/"
    fi
fi

if [ -d "${APP_DIR}" ]; then
    find "${APP_DIR}" -maxdepth 3 -type d \
        \( -name runtime -o -name upload -o -name uploads -o -name cache -o -name logs \) \
        -exec chown -R www-data:www-data {} + || true

    [ -e "${APP_DIR}/config.php" ] && chown www-data:www-data "${APP_DIR}/config.php" || true
fi

exec docker-php-entrypoint "$@"