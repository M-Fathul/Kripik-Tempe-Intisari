# ──────────────────────────────────────────────────────────────────────────────
# Makefile — Shortcut commands untuk Docker Compose
#
# Penggunaan:
#   make up          → start development
#   make up-prod     → start production
#   make down        → stop semua containers
#   make logs        → tail semua logs
#   make build       → rebuild images tanpa start
#   make artisan CMD="migrate --seed"
#   make shell       → bash ke app container
#   make fresh       → hapus semua + rebuild dari awal
# ──────────────────────────────────────────────────────────────────────────────

COMPOSE        = docker compose
COMPOSE_PROD   = docker compose -f docker-compose.yml -f docker-compose.prod.yml
APP_CONTAINER  = kti_app

.PHONY: help up up-prod down build rebuild logs shell artisan tinker fresh \
        migrate seed flask-logs queue-logs

## help: tampilkan daftar command ini
help:
	@echo ""
	@echo "  Kripik Tempe Intisari — Docker Commands"
	@echo "  ────────────────────────────────────────"
	@grep -E '^## ' Makefile | sed 's/## /  /'
	@echo ""

## up: start development environment
up:
	$(COMPOSE) up -d --build

## up-prod: start production environment
up-prod:
	$(COMPOSE_PROD) up -d --build

## down: stop dan hapus containers (data volumes tetap aman)
down:
	$(COMPOSE) down

## build: rebuild semua images
build:
	$(COMPOSE) build

## rebuild: rebuild tanpa cache (full rebuild)
rebuild:
	$(COMPOSE) build --no-cache

## logs: tail semua service logs
logs:
	$(COMPOSE) logs -f

## logs-app: tail Laravel app logs
logs-app:
	$(COMPOSE) logs -f app

## logs-flask: tail Flask ML service logs
logs-flask:
	$(COMPOSE) logs -f flask

## logs-queue: tail queue worker logs
logs-queue:
	$(COMPOSE) logs -f queue

## shell: buka bash ke app container
shell:
	$(COMPOSE) exec $(APP_CONTAINER) bash

## artisan: jalankan artisan command. Contoh: make artisan CMD="migrate --seed"
artisan:
	$(COMPOSE) exec $(APP_CONTAINER) php artisan $(CMD)

## tinker: buka Laravel Tinker REPL
tinker:
	$(COMPOSE) exec $(APP_CONTAINER) php artisan tinker

## migrate: jalankan database migrations
migrate:
	$(COMPOSE) exec $(APP_CONTAINER) php artisan migrate --force

## seed: jalankan database seeder
seed:
	$(COMPOSE) exec $(APP_CONTAINER) php artisan db:seed --force

## fresh: hapus semua containers + volumes + rebuild dari awal (HATI-HATI: data hilang!)
fresh:
	$(COMPOSE) down -v
	$(COMPOSE) up -d --build

## ps: lihat status semua containers
ps:
	$(COMPOSE) ps

## health: cek health status semua containers
health:
	@docker ps --format "table {{.Names}}\t{{.Status}}" | grep kti_
