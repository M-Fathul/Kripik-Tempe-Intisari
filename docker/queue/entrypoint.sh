#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────────
# Laravel queue worker entrypoint
# Menggunakan image yang sama dengan `app` container, hanya CMD-nya berbeda.
# ──────────────────────────────────────────────────────────────────────────────
set -e

echo "==> [queue] Waiting for MySQL to be ready..."
until php artisan db:show --no-interaction > /dev/null 2>&1; do
    echo "    MySQL not ready yet — sleeping 2s"
    sleep 2
done
echo "    MySQL is ready."

echo "==> [queue] Starting queue worker..."
exec php artisan queue:work \
    --sleep=3 \
    --tries=3 \
    --max-time=3600 \
    --timeout=120 \
    --verbose
