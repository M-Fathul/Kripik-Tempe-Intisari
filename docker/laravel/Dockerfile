# ──────────────────────────────────────────────────────────────────────────────
# Laravel PHP-FPM Dockerfile
# Base: php:8.2-fpm-alpine (kecil, cepat, production-ready)
# ──────────────────────────────────────────────────────────────────────────────

FROM php:8.2-fpm-alpine AS base

# ── System dependencies ───────────────────────────────────────────────────────
# libpng/libjpeg/freetype → GD  |  icu → intl  |  libzip → zip
RUN apk add --no-cache \
        bash \
        curl \
        git \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        icu-dev \
        libzip-dev \
        oniguruma-dev \
        unzip \
        nodejs \
        npm

# ── PHP extensions ────────────────────────────────────────────────────────────
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        gd \
        intl \
        zip \
        bcmath \
        mbstring \
        opcache \
        pcntl

# Redis extension via PECL (tidak ada di docker-php-ext-install)
RUN pecl install redis && docker-php-ext-enable redis

# ── php.ini production tweaks ─────────────────────────────────────────────────
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i \
        -e 's/^;opcache.enable=.*/opcache.enable=1/' \
        -e 's/^;opcache.memory_consumption=.*/opcache.memory_consumption=128/' \
        -e 's/^;opcache.validate_timestamps=.*/opcache.validate_timestamps=0/' \
        "$PHP_INI_DIR/php.ini"

# ── Composer ──────────────────────────────────────────────────────────────────
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# ── Install PHP dependencies (cache-friendly: copy lock files first) ──────────
COPY kripik_tempe_intisari/composer.json kripik_tempe_intisari/composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction

# ── Install JS dependencies & build assets ────────────────────────────────────
COPY kripik_tempe_intisari/package.json kripik_tempe_intisari/package-lock.json ./
RUN npm ci --ignore-scripts

COPY kripik_tempe_intisari/ .

RUN npm run build \
    && rm -rf node_modules

# ── Run composer scripts that need the full app (post-autoload-dump) ──────────
RUN composer run-script post-autoload-dump --no-interaction || true

# ── Fix storage/bootstrap permissions ────────────────────────────────────────
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# ── Entrypoint ────────────────────────────────────────────────────────────────
COPY docker/laravel/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
