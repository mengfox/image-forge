FROM php:7.3-fpm

ARG TZ=Asia/Shanghai

ENV APP_DOCUMENT_ROOT=/var/www/html/public \
    APP_SEED_DIR=/opt/mofang-finance-seed \
    APP_PACKAGE_FILE=/tmp/mofang-finance.zip \
    DEBIAN_FRONTEND=noninteractive \
    TZ=${TZ}

COPY images/mofang-finance/source/mofang-finance-3.7.0.zip /tmp/mofang-finance.zip
COPY images/mofang-finance/files/swoole_loader_73_zts.so /tmp/swoole_loader_73_zts.so

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libgmp-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libonig-dev \
        libpng-dev \
        libssl-dev \
        libxml2-dev \
        libzip-dev \
        nginx \
        supervisor \
        unzip \
        tzdata; \
    rm -rf /var/lib/apt/lists/*; \
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime; \
    echo "${TZ}" > /etc/timezone

RUN set -eux; \
    mkdir -p /tmp/app-src "${APP_SEED_DIR}"; \
    unzip -q "${APP_PACKAGE_FILE}" -d /tmp/app-src; \
    src_dir="$(find /tmp/app-src -mindepth 1 -maxdepth 1 -type d | head -n 1)"; \
    [ -n "${src_dir}" ]; \
    cp -a "${src_dir}/." "${APP_SEED_DIR}/"; \
    test -f "${APP_SEED_DIR}/public/index.php"; \
    rm -rf /tmp/app-src

RUN set -eux; \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; \
    docker-php-ext-install -j"$(nproc)" \
        bcmath \
        curl \
        exif \
        ftp \
        gd \
        gettext \
        gmp \
        intl \
        mbstring \
        mysqli \
        pdo_mysql \
        soap \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        xml \
        zip; \
    php -m | grep -Ei '^fileinfo$' >/dev/null; \
    php -m | grep -Ei '^bcmath$' >/dev/null; \
    php -m | grep -Ei '^curl$' >/dev/null; \
    php -m | grep -Ei '^gd$' >/dev/null; \
    php -m | grep -Ei '^gmp$' >/dev/null; \
    php -m | grep -Ei '^intl$' >/dev/null; \
    php -m | grep -Ei '^mbstring$' >/dev/null; \
    php -m | grep -Ei '^mysqli$' >/dev/null; \
    php -m | grep -Ei '^pdo_mysql$' >/dev/null; \
    php -m | grep -Ei '^soap$' >/dev/null; \
    php -m | grep -Ei '^xml$' >/dev/null; \
    php -m | grep -Ei '^zip$' >/dev/null; \
    php -r "exit(extension_loaded('gd') && !empty(gd_info()['FreeType Support']) ? 0 : 1);"

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "${arch}" in \
        amd64) ioncube_arch='x86-64' ;; \
        arm64) ioncube_arch='aarch64' ;; \
        *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_${ioncube_arch}.tar.gz" -o /tmp/ioncube.tar.gz; \
    tar -xzf /tmp/ioncube.tar.gz -C /tmp; \
    ext_dir="$(php-config --extension-dir)"; \
    cp "/tmp/ioncube/ioncube_loader_lin_7.3.so" "${ext_dir}/ioncube_loader_lin_7.3.so"; \
    cp /tmp/swoole_loader_73_zts.so "${ext_dir}/swoole_loader_73_zts.so"; \
    echo "zend_extension=${ext_dir}/ioncube_loader_lin_7.3.so" > /usr/local/etc/php/conf.d/00-ioncube.ini; \
    echo "extension=swoole_loader_73_zts.so" > /usr/local/etc/php/conf.d/01-swoole-loader.ini; \
    test -f "${ext_dir}/ioncube_loader_lin_7.3.so"; \
    test -f "${ext_dir}/swoole_loader_73_zts.so"

RUN set -eux; \
    apt-get purge -y \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libgmp-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libonig-dev \
        libpng-dev \
        libssl-dev \
        libxml2-dev \
        libzip-dev; \
    rm -rf /var/lib/apt/lists/* /tmp/ioncube /tmp/ioncube.tar.gz /tmp/mofang-finance.zip /tmp/swoole_loader_73_zts.so; \
    rm -f /etc/nginx/sites-enabled/default /etc/nginx/conf.d/default.conf

COPY images/mofang-finance/files/php.ini /usr/local/etc/php/conf.d/99-mofang-finance.ini
COPY images/mofang-finance/files/entrypoint.sh /usr/local/bin/mofang-finance-entrypoint

RUN set -eux; \
    if [ "$(head -c 3 /usr/local/bin/mofang-finance-entrypoint | od -An -t x1 | tr -d ' \n')" = "efbbbf" ]; then \
        tail -c +4 /usr/local/bin/mofang-finance-entrypoint > /usr/local/bin/mofang-finance-entrypoint.clean; \
        mv /usr/local/bin/mofang-finance-entrypoint.clean /usr/local/bin/mofang-finance-entrypoint; \
    fi; \
    sed -i 's/\r$//' /usr/local/bin/mofang-finance-entrypoint; \
    chmod +x /usr/local/bin/mofang-finance-entrypoint; \
    mkdir -p /run/php /var/log/supervisor /var/www/html; \
    printf '%s\n' \
        'server {' \
        '    listen 80;' \
        '    listen [::]:80;' \
        '    server_name _;' \
        '' \
        '    root /var/www/html/public;' \
        '    index index.php index.html index.htm;' \
        '' \
        '    client_max_body_size 100m;' \
        '    server_tokens off;' \
        '' \
        '    access_log /var/log/nginx/access.log;' \
        '    error_log /var/log/nginx/error.log warn;' \
        '' \
        '    location ~ /\.(?!well-known).* {' \
        '        deny all;' \
        '    }' \
        '' \
        '    location / {' \
        '        try_files $uri $uri/ /index.php?s=$uri&$query_string;' \
        '    }' \
        '' \
        '    location ~ \.php$ {' \
        '        include fastcgi_params;' \
        '        fastcgi_pass 127.0.0.1:9000;' \
        '        fastcgi_index index.php;' \
        '        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;' \
        '        fastcgi_param DOCUMENT_ROOT $document_root;' \
        '        fastcgi_read_timeout 3600;' \
        '    }' \
        '' \
        '    location ~* \.(?:css|js|jpg|jpeg|gif|png|bmp|ico|svg|webp|ttf|woff|woff2)$ {' \
        '        expires 7d;' \
        '        access_log off;' \
        '    }' \
        '}' \
        > /etc/nginx/conf.d/default.conf; \
    printf '%s\n' \
        '[supervisord]' \
        'nodaemon=true' \
        'user=root' \
        'logfile=/dev/null' \
        'pidfile=/run/supervisord.pid' \
        '' \
        '[program:php-fpm]' \
        'command=docker-php-entrypoint php-fpm --nodaemonize' \
        'priority=10' \
        'autorestart=true' \
        'stdout_logfile=/dev/fd/1' \
        'stdout_logfile_maxbytes=0' \
        'stderr_logfile=/dev/fd/2' \
        'stderr_logfile_maxbytes=0' \
        '' \
        '[program:nginx]' \
        'command=/usr/sbin/nginx -g "daemon off;"' \
        'priority=20' \
        'autorestart=true' \
        'stdout_logfile=/dev/fd/1' \
        'stdout_logfile_maxbytes=0' \
        'stderr_logfile=/dev/fd/2' \
        'stderr_logfile_maxbytes=0' \
        > /etc/supervisor/conf.d/supervisord.conf; \
    chown -R www-data:www-data "${APP_SEED_DIR}" /var/www/html

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/mofang-finance-entrypoint"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]