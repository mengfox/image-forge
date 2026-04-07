#!/bin/sh
set -eu

APP_DIR="${APP_DIR:-/var/www/html}"

if [ -d "${APP_DIR}" ]; then
    find "${APP_DIR}" -maxdepth 3 -type d \
        \( -name runtime -o -name upload -o -name uploads -o -name cache -o -name logs \) \
        -exec chown -R www-data:www-data {} + || true

    [ -e "${APP_DIR}/config.php" ] && chown www-data:www-data "${APP_DIR}/config.php" || true
fi

exec docker-php-entrypoint "$@"
