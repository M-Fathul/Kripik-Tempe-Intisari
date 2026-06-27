COMPOSE        = docker compose
COMPOSE_PROD   = docker compose -f docker-compose.yml -f docker-compose.prod.yml
APP_CONTAINER  = kti_app

.PHONY: help up up-prod down build rebuild logs shell artisan tinker fresh \
        migrate seed flask-logs queue-logs

help:
	@echo ""
	@echo "  Kripik Tempe Intisari — Docker Commands"
	@echo "  ────────────────────────────────────────"
	@grep -E '^## ' Makefile | sed 's/## /  /'
	@echo ""

up:
	$(COMPOSE) up -d --build

up-prod:
	$(COMPOSE_PROD) up -d --build

down:
	$(COMPOSE) down

build:
	$(COMPOSE) build

rebuild:
	$(COMPOSE) build --no-cache

logs:
	$(COMPOSE) logs -f

logs-app:
	$(COMPOSE) logs -f app

logs-flask:
	$(COMPOSE) logs -f flask

logs-queue:
	$(COMPOSE) logs -f queue

shell:
	$(COMPOSE) exec $(APP_CONTAINER) bash

artisan:
	$(COMPOSE) exec $(APP_CONTAINER) php artisan $(CMD)

tinker:
	$(COMPOSE) exec $(APP_CONTAINER) php artisan tinker

migrate:
	$(COMPOSE) exec $(APP_CONTAINER) php artisan migrate --force

seed:
	$(COMPOSE) exec $(APP_CONTAINER) php artisan db:seed --force

fresh:
	$(COMPOSE) down -v
	$(COMPOSE) up -d --build

ps:
	$(COMPOSE) ps

health:
	@docker ps --format "table {{.Names}}\t{{.Status}}" | grep kti_
