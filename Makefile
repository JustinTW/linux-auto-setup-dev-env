# HELP
.PHONY: help

PROJECT_NAME=rc

# alias
at: at-ubuntu
c: clean

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

up: create-network  ## Boot up all services
	@docker-compose -f docker-compose.yaml up --build -d

ps: create-network  ## Display current runing containers
	@docker-compose -f docker-compose.yaml ps

reboot: halt up ## Reboot all containers, alias: r

boot-up-mvn-container:

at-ubuntu: ## Attach to container, alias: at
	@docker exec -it $(PROJECT_NAME)-ubuntu bash

at-centos: ## Attach to container
	@docker exec -it $(PROJECT_NAME)-centos bash

at-alpine: ## Attach to container
	@docker exec -it $(PROJECT_NAME)-alpine sh

at-debian: ## Attach to container
	@docker exec -it $(PROJECT_NAME)-debian bash

logs: ## Display container logs
	@docker-compose -f docker-compose.yaml logs -f

halt: ## Halt
	@docker-compose -f docker-compose.yaml rm -sf
	@docker-compose -f docker-compose.yaml ps --services \
	 | xargs docker rm > /dev/null 2>&1 || true

clean: halt ## Halt and Clean Images
	@docker-compose -f docker-compose.yaml down
	@for dir in $(wildcard volumes/*/data); do \
		rm -rf $$dir; \
	done

images: ## List Docker Images, alias: img
	@docker images | grep $(PROJECT_NAME)

create-network:
	@docker network ls | grep $(PROJECT_NAME) > /dev/null 2>&1 \
	|| docker network create $(PROJECT_NAME) > /dev/null 2>&1
