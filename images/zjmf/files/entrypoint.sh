#!/bin/sh
set -eu

APP_DIR="${APP_DIR:-/var/www/html}"
APP_SEED_DIR="${APP_SEED_DIR:-/opt/zjmf-seed}"
ENABLE_SWOOLE_LOADER="${ENABLE_SWOOLE_LOADER:-0}"
SWOOLE_LOADER_INI="/usr/local/etc/php/conf.d/01-swoole-loader.ini"
SWOOLE_LOADER_EXT="$(php-config --extension-dir)/swoole_loader_73_zts.so"

is_effectively_empty_dir() {
    [ -d "$1" ] || return 0
    [ -z "$(find "$1" -mindepth 1 -maxdepth 1 ! -name 'lost+found' -print -quit 2>/dev/null)" ]
}

configure_swoole_loader() {
    if [ "${ENABLE_SWOOLE_LOADER}" = "1" ] && [ -f "${SWOOLE_LOADER_EXT}" ]; then
        if php -r 'exit(PHP_ZTS ? 0 : 1);'; then
            echo "extension=swoole_loader_73_zts.so" > "${SWOOLE_LOADER_INI}"
        else
            echo "ENABLE_SWOOLE_LOADER=1 was requested, but current PHP runtime is non-ZTS; skipping swoole_loader_73_zts.so" >&2
            rm -f "${SWOOLE_LOADER_INI}"
        fi
    else
        rm -f "${SWOOLE_LOADER_INI}"
    fi
}

maybe_seed_app() {
    if [ ! -d "${APP_DIR}" ]; then
        mkdir -p "${APP_DIR}"
    fi

    if [ -d "${APP_SEED_DIR}" ] && [ -f "${APP_SEED_DIR}/public/index.php" ]; then
        if is_effectively_empty_dir "${APP_DIR}"; then
            echo "Initializing ZJMF application files into ${APP_DIR}" >&2
            cp -a "${APP_SEED_DIR}/." "${APP_DIR}/"
        fi
    fi
}

fix_permissions() {
    if [ -d "${APP_DIR}" ]; then
        find "${APP_DIR}" -maxdepth 3 -type d \
            \( -name runtime -o -name upload -o -name uploads -o -name cache -o -name logs \) \
            -exec chown -R www-data:www-data {} + || true

        [ -e "${APP_DIR}/config.php" ] && chown www-data:www-data "${APP_DIR}/config.php" || true
    fi
}

configure_swoole_loader
maybe_seed_app
fix_permissions

exec docker-php-entrypoint "$@"