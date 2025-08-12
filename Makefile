# Makefile for managing the Grafana Lab project

.PHONY: up down reset logs ps

up:
	@echo "Starting services..."
	docker compose up -d

down:
	@echo "Stopping services..."
	docker compose down

reset:
	@echo "Stopping services and removing volumes..."
	docker compose down --volumes

logs:
	@echo "Showing logs..."
	docker compose logs -f

ps:
	@echo "Checking container status..."
	docker compose ps
