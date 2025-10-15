.PHONY: up up-prod down logs test config stop

# Allow passing extra flags, e.g. START_FLAGS=--skip-pull
START_FLAGS ?=
# Service for the logs target
LOG_SERVICE ?= evolution-api
# Optional path to .env when running docker compose config
ENV_FILE ?= .env

up:
	./start.sh $(START_FLAGS)

up-prod:
	./start.sh --with-prod $(START_FLAGS)

down stop:
	./stop.sh

logs:
	docker compose logs -f $(LOG_SERVICE)

test:
	./start.test.sh $(START_FLAGS)

config:
	docker compose --env-file $(ENV_FILE) config
