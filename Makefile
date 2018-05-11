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

DOCKER_REGISTRY ?= https://index.docker.io/v1/
DOCKER_REGISTRY_AUTH ?=

.PHONY: test build release clean tag buildtag login logout publish

test:
	${INFO} "Creating cache volume..."
	@ docker volume create --name cache
	${INFO} "Pulling latest images..."
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) pull
	${INFO} "Building images..."
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) build --pull test
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
	@ docker-compose -p $(TES_PROJECT) -f $(TES_COMPOSE_FILE) down -v
	${INFO} "Cleaning release environment..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) down -v
	${INFO} "Cleaning dangling images and volumes..."
	@ docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS docker rmi -f ARGS
	${INFO} "Clean complete"

tag:
	${INFO} "Tagging release image with tags $(TAG_ARGS)..."
	@ $(foreach tag,$(TAG_ARGS), docker tag $(IMAGE_ID) $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME):$(tag);)
	${INFO} "Tagging complete"

buildtag:
	${INFO} "Tagging release image with suffix $(BUILD_TAG) and build tags $(BUILDTAG_ARGS)..."
	@ $(foreach tag, $(BUILDTAG_ARGS), docker tag $(IMAGE_ID) $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME):$(tag).$(BUILD_TAG);)
	${INFO} "Tagging complete"

login:
	${INFO} "Logging into Docker registry $$DOCKER_REGISTRY..."
	@ docker login -u $$DOCKER_USER -p $$DOCKER_PASSWORD $(DOCKER_REGISTRY_AUTH)
	${INFO} "Logged into Docker registry $$DOCKER_REGISTRY"

logout:
	${INFO} "Logging out of Docker registry $$DOCKER_REGISTRY..."
	@ docker logout
	${INFO} "Logged out of Docker registry $$DOCKER_REGISTRY"

publish:
	${INFO} "Publishing release image $(IMAGE_ID) to $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME)..."
	@ $(foreach tag, $(shell echo $(REPO_EXPR)), docker push $(tag);)
	${INFO} "Publish complete"

YELLOW := "\e[1;33m"
NC := "\e[0m"

INFO := @bash -c '\
	printf $(YELLOW); \
	echo "=> $$1"; \
	printf $(NC)' VALUE

APP_CONTAINER_ID := $$(docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) ps -q $(APP_SERVICE_NAME))

IMAGE_ID := $$(docker inspect -f '{{ .Image }}' $(APP_CONTAINER_ID))

ifeq ($(DOCKER_REGISTRY), docker.io)
	REPO_FILTER := $(ORG_NAME)/$(REPO_NAME)[^[:space:]|\$$]*
else
	REPO_FILTER := $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME)[^[:space:]|\$$]*
endif

REPO_EXPR := $$(docker inspect -f '{{range .RepoTags}}{{.}} {{end}}' $(IMAGE_ID) | grep -oh "$(REPO_FILTER)" | xargs)

ifeq (tag,$(firstword $(MAKECMDGOALS)))
  TAG_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  ifeq ($(TAG_ARGS),)
    $(error You must specify a tag)
  endif
  $(eval $(TAG_ARGS):;@:)
endif

ifeq (buildtag,$(firstword $(MAKECMDGOALS)))
	BUILDTAG_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  ifeq ($(BUILDTAG_ARGS),)
  	$(error You must specify a tag)
  endif
  $(eval $(BUILDTAG_ARGS):;@:)
endif
