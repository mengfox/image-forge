#!/bin/bash
set -e

APP_DIR=/var/www/html
DEFAULT_SITE_DIR=/opt/default-site
NGINX_CONF=/etc/nginx/conf.d/default.conf
APP_ROOT="${APP_DIR}"

mkdir -p /run /var/run /run/php
mkdir -p /var/log/nginx /var/log/supervisor
mkdir -p "${APP_DIR}" "${DEFAULT_SITE_DIR}"
mkdir -p /etc/nginx/conf.d /etc/nginx/templates

rm -f /etc/supervisor/conf.d/zz-lsky-queue.conf || true
rm -f /etc/supervisor/conf.d/zz-lsky-schedule.conf || true

# 先检查根目录
if [ -f "${APP_DIR}/artisan" ] && [ -f "${APP_DIR}/public/index.php" ]; then
    APP_ROOT="${APP_DIR}"
else
    # 自动识别一层子目录项目
    FOUND_DIR="$(find "${APP_DIR}" -mindepth 1 -maxdepth 2 -type f -name artisan 2>/dev/null | head -n 1 | xargs -r dirname)"
    if [ -n "${FOUND_DIR}" ] && [ -f "${FOUND_DIR}/public/index.php" ]; then
        APP_ROOT="${FOUND_DIR}"
    fi
fi

if [ -f "${APP_ROOT}/artisan" ] && [ -f "${APP_ROOT}/public/index.php" ]; then
    echo "[entrypoint] Detected Lsky project at: ${APP_ROOT}"

    mkdir -p "${APP_ROOT}/storage/logs"
    mkdir -p "${APP_ROOT}/bootstrap/cache"

    chown -R www-data:www-data "${APP_ROOT}" || true
    chmod -R 775 "${APP_ROOT}/storage" || true
    chmod -R 775 "${APP_ROOT}/bootstrap/cache" || true

    sed "s#__APP_ROOT__#${APP_ROOT}#g" /etc/nginx/templates/default-lsky.conf > "${NGINX_CONF}"

    cp -f /etc/supervisor/conf.d/supervisord-lsky-queue.conf /etc/supervisor/conf.d/zz-lsky-queue.conf
    cp -f /etc/supervisor/conf.d/supervisord-lsky-schedule.conf /etc/supervisor/conf.d/zz-lsky-schedule.conf
else
    echo "[entrypoint] No project detected, enabling static placeholder page..."
    cp -f /etc/nginx/templates/default-static.conf "${NGINX_CONF}"
fi

exec "$@"