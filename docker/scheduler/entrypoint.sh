#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────────
# Laravel scheduler entrypoint
# Menjalankan `php artisan schedule:run` setiap 60 detik dalam loop.
# Alternatif lebih ringan daripada supercronic untuk jadwal menit-an.
# ──────────────────────────────────────────────────────────────────────────────
set -e

echo "==> [scheduler] Waiting for MySQL to be ready..."
until php artisan db:show --no-interaction > /dev/null 2>&1; do
    echo "    MySQL not ready yet — sleeping 2s"
    sleep 2
done
echo "    MySQL is ready."

echo "==> [scheduler] Starting schedule loop (every 60s)..."
while true; do
    php artisan schedule:run --verbose --no-interaction
    sleep 60
done
