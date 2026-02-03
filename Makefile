ifeq ($(CI),true)
    DOCKER_EXEC_FLAGS = -T
else
    DOCKER_EXEC_FLAGS = -it
endif
COMPOSE = docker compose
COMPOSE_EXEC = $(COMPOSE) exec $(DOCKER_EXEC_FLAGS)
COMPOSE_RUN = $(COMPOSE) run $(DOCKER_EXEC_FLAGS)

bash:					# Run bash inside `main` container
	$(COMPOSE_RUN) --rm main bash

bash-root: 				# Run bash as root inside `main` container
	$(COMPOSE_RUN) --rm -u root main bash

build: 					# Build containers
	$(COMPOSE) pull
	$(COMPOSE) build

clean: stop				# Stop and clean orphan containers
	$(COMPOSE) down -v --remove-orphans

help:					# List all make commands
	@awk -F ':.*#' '/^[a-zA-Z_-]+:.*?#/ { printf "\033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sort

kill:					# Force stop (kill) and remove containers
	$(COMPOSE) kill
	$(COMPOSE) rm --force

lint:					# Run linter script
	docker compose run --rm -it main /app/lint.sh

lint-check:				# Run the linter without changing files
	$(COMPOSE_EXEC) web /app/lint.sh --check

logs:					# Show all containers' logs (tail)
	$(COMPOSE) logs -tf

psql: 					# Connect to database shell using `main` container
	$(COMPOSE_RUN) --rm -it main bash -c "psql \$$DATABASE_URL"

restart: stop start		# Stop all containers and start all containers in background

run: 					# Run main ELT pipeline
	$(COMPOSE_RUN) --rm -it main bash -c "./run.sh"

start:					# Start all containers in background
	$(COMPOSE) up -d

stop:					# Stop all containers
	$(COMPOSE) down

tags:					# Generate tags file for the entire project (requires universal-ctags)
	@git ls-files | ctags -L - --tag-relative=yes --quiet --append -f "$(TAGS_FILE)"

test:					# Execute `pytest` and coverage report inside `web` container
	$(COMPOSE_RUN) --rm main bash -c 'pytest $(TEST_ARGS)'

.PHONY: bash bash-root build clean help kill lint lint-check logs psql restart run start stop tags test
