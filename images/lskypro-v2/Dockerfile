# ========================================
# 1) 构建阶段：编译 PHP 扩展
# ========================================
FROM php:8.3-fpm-bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    ca-certificates \
    libzip-dev \
    libpq-dev \
    libsqlite3-dev \
    libicu-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    libmagickwand-dev \
    imagemagick \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libwebp-dev \
    libxpm-dev \
    libffi-dev \
    libvips \
    libvips-dev \
    pkg-config \
    build-essential \
    autoconf \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        curl \
        dom \
        exif \
        fileinfo \
        gd \
        intl \
        ftp \
        mbstring \
        mysqli \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pdo_sqlite \
        pgsql \
        xml \
        zip \
        opcache \
        ffi

RUN pecl install imagick \
    && docker-php-ext-enable imagick

RUN pecl install vips \
    && docker-php-ext-enable vips || true

RUN PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') \
    && mkdir -p /tmp/sourceguardian \
    && cd /tmp/sourceguardian \
    && curl -fsSL -o loaders.tar.gz https://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.tar.gz \
    && tar xzf loaders.tar.gz \
    && EXT_DIR="$(php -i | grep '^extension_dir => ' | awk '{print $3}')" \
    && cp "ixed.${PHP_VERSION}.lin" "${EXT_DIR}/sourceguardian.so" \
    && echo "extension=sourceguardian.so" > /usr/local/etc/php/conf.d/15-sourceguardian.ini \
    && rm -rf /tmp/sourceguardian

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && { \
        echo "memory_limit=512M"; \
        echo "upload_max_filesize=100M"; \
        echo "post_max_size=100M"; \
        echo "max_execution_time=300"; \
        echo "max_input_time=300"; \
        echo "date.timezone=${TZ}"; \
        echo "cgi.fix_pathinfo=0"; \
        echo "ffi.enable=1"; \
        echo "disable_functions="; \
      } > /usr/local/etc/php/conf.d/99-custom.ini


# ========================================
# 2) 运行阶段
# ========================================
FROM php:8.3-fpm-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV APP_DIR=/var/www/html
ENV DEFAULT_SITE_DIR=/opt/default-site

RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    curl \
    ca-certificates \
    procps \
    libzip4 \
    libpq5 \
    libsqlite3-0 \
    libicu72 \
    libxml2 \
    libcurl4 \
    libonig5 \
    libmagickwand-6.q16-6 \
    imagemagick \
    libpng16-16 \
    libjpeg62-turbo \
    libfreetype6 \
    libwebp7 \
    libxpm4 \
    libffi8 \
    libvips42 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php /usr/local/etc/php

COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/default-static.conf /etc/nginx/templates/default-static.conf
COPY docker/default-lsky.conf /etc/nginx/templates/default-lsky.conf

COPY docker/supervisord.conf /etc/supervisor/supervisord.conf
COPY docker/supervisord-lsky-queue.conf /etc/supervisor/conf.d/supervisord-lsky-queue.conf
COPY docker/supervisord-lsky-schedule.conf /etc/supervisor/conf.d/supervisord-lsky-schedule.conf

COPY docker/entrypoint.sh /entrypoint.sh
COPY docker/index.html ${DEFAULT_SITE_DIR}/index.html

RUN chmod +x /entrypoint.sh \
    && mkdir -p /run /var/run /run/php /var/log/nginx /var/log/supervisor /etc/nginx/conf.d /etc/nginx/templates ${APP_DIR} ${DEFAULT_SITE_DIR} \
    && chown -R www-data:www-data ${APP_DIR}

WORKDIR ${APP_DIR}

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
