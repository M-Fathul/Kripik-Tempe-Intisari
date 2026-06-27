#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────────
# Laravel app container entrypoint
# Runs database migrations and caches config/routes/views before starting
# PHP-FPM. Designed to be idempotent — safe to run on every container start.
# ──────────────────────────────────────────────────────────────────────────────
set -e

echo "==> [entrypoint] Waiting for MySQL to be ready..."
until php artisan db:show --no-interaction > /dev/null 2>&1; do
    echo "    MySQL not ready yet — sleeping 2s"
    sleep 2
done
echo "    MySQL is ready."

echo "==> [entrypoint] Running migrations..."
php artisan migrate --force --no-interaction

echo "==> [entrypoint] Caching configuration..."
php artisan config:cache

echo "==> [entrypoint] Caching routes..."
php artisan route:cache

echo "==> [entrypoint] Caching views..."
php artisan view:cache

echo "==> [entrypoint] Publishing Filament assets..."
php artisan filament:assets --no-interaction 2>/dev/null || true

echo "==> [entrypoint] Done. Starting PHP-FPM..."
exec "$@"
