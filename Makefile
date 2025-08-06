USE_SUDO := $(shell which docker >/dev/null && docker ps 2>&1 | grep -q "permission denied" && echo sudo)
DOCKER := $(if $(USE_SUDO), sudo docker, docker)
DIRNAME := $(notdir $(CURDIR))

build:
	$(DOCKER) build . --tag $(DIRNAME)

run:
	$(DOCKER) run -v ./csv:/home/uv/csv --rm $(DIRNAME)
