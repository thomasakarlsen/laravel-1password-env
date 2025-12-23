.PHONY: help build up down logs shell artisan test migrate fresh seed

help:
	@echo "Laravel Octane Docker Commands"
	@echo "=============================="
	@echo ""
	@echo "Build & Run:"
	@echo "  make build              Build Docker images"
	@echo "  make up                 Start all containers"
	@echo "  make down               Stop all containers"
	@echo ""
	@echo "Development:"
	@echo "  make shell              Open shell in app container"
	@echo "  make logs               View application logs"
	@echo "  make artisan CMD=...    Run artisan command"
	@echo "  make tinker             Start Laravel Tinker REPL"
	@echo ""
	@echo "Database:"
	@echo "  make migrate            Run migrations"
	@echo "  make fresh              Fresh migration (drop & recreate)"
	@echo "  make seed               Run seeders"
	@echo "  make db                 Connect to database shell"
	@echo ""
	@echo "Testing:"
	@echo "  make test               Run tests"
	@echo "  make test-unit          Run unit tests only"
	@echo "  make test-feature       Run feature tests only"
	@echo ""
	@echo "Frontend:"
	@echo "  make npm CMD=...        Run npm command"
	@echo "  make npm-install        Install npm dependencies"
	@echo "  make npm-build          Build frontend assets"
	@echo "  make npm-dev            Watch frontend assets"
	@echo ""
	@echo "Maintenance:"
	@echo "  make cache-clear        Clear all caches"
	@echo "  make config-cache       Cache configuration"
	@echo "  make route-cache        Cache routes"
	@echo "  make optimize           Run optimization commands"
	@echo ""

build:
	docker-compose build

up:
	docker-compose up -d
	@echo "Application started. Access it at http://localhost"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f app

shell:
	docker-compose exec app sh

artisan:
	docker-compose exec app php artisan $(CMD)

tinker:
	docker-compose exec app php artisan tinker

migrate:
	docker-compose exec app php artisan migrate --force

fresh:
	docker-compose exec app php artisan migrate:fresh --force

seed:
	docker-compose exec app php artisan db:seed

db:
	docker-compose exec db mysql -u laravel -psecret laravel

test:
	docker-compose exec app php artisan test

test-unit:
	docker-compose exec app php artisan test --testsuite=Unit

test-feature:
	docker-compose exec app php artisan test --testsuite=Feature

npm:
	docker-compose exec app npm $(CMD)

npm-install:
	docker-compose exec app npm install

npm-build:
	docker-compose exec app npm run build

npm-dev:
	docker-compose exec app npm run dev

cache-clear:
	docker-compose exec app php artisan cache:clear
	docker-compose exec app php artisan config:clear
	docker-compose exec app php artisan route:clear
	docker-compose exec app php artisan view:clear

config-cache:
	docker-compose exec app php artisan config:cache

route-cache:
	docker-compose exec app php artisan route:cache

optimize:
	docker-compose exec app php artisan optimize
	$(MAKE) config-cache
	$(MAKE) route-cache

ps:
	docker-compose ps

pull:
	docker-compose pull

stats:
	docker stats

clean:
	docker system prune -f

volume-list:
	docker volume ls

volume-remove:
	docker volume prune -f
