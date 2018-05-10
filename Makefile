# Project variables
PROJECT_NAME ?= apiissuestracker
ORG_NAME ?= abeego
REPO_NAME ?= apiissuestracker

# Filenames
TES_COMPOSE_FILE := ci/test/docker-compose.yml
REL_COMPOSE_FILE := ci/release/docker-compose.yml

# Docker compose project names
REL_PROJECT := $(PROJECT_NAME)$(BUILD_ID)
TES_PROJECT := $(REL_PROJECT)test

APP_SERVICE_NAME := app

BUILD_TAG_EXPRESSION ?= date -u +%Y%m%d%H%M%S
BUILD_EXPRESSION := $(shell $(BUILD_TAG_EXPRESSION))
BUILD_TAG ?= $(BUILD_EXPRESSION)

INSPECT := $$(docker-compose -p $$1 -f $$2 ps -q $$3 | xargs -I ARGS docker inspect -f "{{ .State.ExitCode }}" ARGS)

CHECK := @bash -c '\
	if [[ $(INSPECT) -ne 0 ]]; \
	then exit $(INSPECT); fi' VALUE

.PHONY: test build release clean tag buildtag

test:
	${INFO} "Pulling latest images..."
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) pull
	${INFO} "Building images..."
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) build --pull test
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) build cache
	${INFO} "Ensuring database is ready..."
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) run --rm agent
	${INFO} "Running tests..."
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) up test
	@ docker cp $$(docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) ps -q test):/reports/. reports
	${CHECK} $(TES_PROJECT) $(TES_COMPOSE_FILE) test
	${INFO} "Testing complete"

build:
	${INFO} "Creating builder image..."
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) build builder
	${INFO} "Building application artefacts..."
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) up builder
	${CHECK} $(TES_PROJECT) $(TES_COMPOSE_FILE) builder
	${INFO} "Copying application artefacts..."
	@ docker cp $$(docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) ps -q builder):/wheelhouse/. target
	${INFO} "Build complete"

release:
	${INFO} "Pulling latest images..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) pull test
	${INFO} "Building images..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) build app
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) build webroot
	${INFO} "Ensuring database is ready..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm agent
	${INFO} "Running database migration..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm app manage.py migrate --noinput
	${INFO} "Running acceptance tests..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) up test
	@ docker cp $$(docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) ps -q test):/reports/. reports
	${CHECK} $(REL_PROJECT) $(REL_COMPOSE_FILE) test
	${INFO} "Acceptance testing complete"

clean:
	${INFO} "Cleaning testing environment..."
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) kill
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) rm -f -v
	${INFO} "Cleaning release environment..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) kill
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) rm -f -v
	${INFO} "Cleaning dangling images and volumes..."
	@ docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS docker rmi -f ARGS
	${INFO} "Clean complete"

tag:
	${INFO} "Tagging release image with tags $(TAG_ARGS)..."
	@ $(foreach tag, $(TAG_ARGS), docker tag $(IMAGE_ID) $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME):$(tag);)
	${INFO} "Tagging complete"

buildtag:
	${INFO} "Tagging release image with suffix $(BUILD_TAG) and build tags $(BUILDTAG_ARGS)..."
	@ $(foreach tag, $(BUILDTAG_ARGS), docker tag $(IMAGE_ID) $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME):$(tag).$(BUILD_TAG);)
	${INFO} "Tagging complete"

YELLOW := "\e[1;33m"
NC := "\e[0m"

INFO := @bash -c '\
	printf $(YELLOW); \
	echo "=> $$1"; \
	printf $(NC)' VALUE

APP_CONTAINER_ID := $$(docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) ps -q $(APP_SERVICE_NAME))

IMAGE_ID := $$(docker inspect -f '{{ .Image }}' $(APP_CONTAINER_ID))

ifeq (tag, $(firstword $(MAKECMDGOALS)))
	TAG_ARGS := $(wordlist 2, $(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
	ifeq ($(TAG_ARGS),)
		$(error You must specify a tag)
	endif
	$(eval $(TAG_ARGS):;@:)
endif
