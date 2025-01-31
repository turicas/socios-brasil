bash:					# Run bash inside `main` container
	docker compose run --rm -it main bash

bash-root: 				# Run bash as root inside `main` container
	docker compose run --rm -itu root main bash

build: fix-permissions	# Build containers
	docker compose build

clean: stop				# Stop and clean orphan containers
	docker compose down -v --remove-orphans

fix-permissions:		# Fix volume permissions on host machine
	userID=$${UID:-1000}
	groupID=$${UID:-1000}
	mkdir -p docker/data/main docker/data/db
	chown -R $$userID:$$groupID docker/data/main docker/data/db
	touch docker/env/main.local docker/env/db.local

help:					# List all make commands
	@awk -F ':.*#' '/^[a-zA-Z_-]+:.*?#/ { printf "\033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sort

kill:					# Force stop (kill) and remove containers
	docker compose kill
	docker compose rm --force

lint:					# Run linter script
	docker compose run --rm -it main /app/lint.sh

logs:					# Show all containers' logs (tail)
	docker compose logs -tf

psql: 					# Connect to database shell using `main` container
	docker compose run --rm -it main bash -c "psql \$$DATABASE_URL"

restart: stop start		# Stop all containers and start all containers in background

run: 					# Run main ELT pipeline
	docker compose run --rm -it main bash -c "./run.sh"

start: fix-permissions	# Start all containers in background
	docker compose up -d

stop:					# Stop all containers
	docker compose down

.PHONY: bash bash-root build clean fix-permissions help kill lint logs psql restart run start stop
