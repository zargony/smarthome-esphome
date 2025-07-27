IMAGE := ghcr.io/esphome/esphome:2025.7.3

DOCKER := docker
DOCKER_RUN_OPTS := -it --rm -v $(PWD):/config -v $(PWD)/cache:/cache

NODES := metering

default: compile

update: force
	$(DOCKER) pull $(IMAGE)

help: force
	$(DOCKER) run $(DOCKER_RUN_OPTS) $(IMAGE) --help

server: force
	$(DOCKER) run $(DOCKER_RUN_OPTS) -p 6052:6052 $(IMAGE) dashboard /config

clean: force
	rm -rf .esphome cache

config: $(NODES:%=config-%)
config-%: %.yaml force
	$(DOCKER) run $(DOCKER_RUN_OPTS) $(IMAGE) config /config/$<

compile: $(NODES:%=compile-%)
compile-%: %.yaml force
	$(DOCKER) run $(DOCKER_RUN_OPTS) $(IMAGE) compile /config/$<

upload: $(NODES:%=upload-%)
upload-%: %.yaml force
	$(DOCKER) run $(DOCKER_RUN_OPTS) $(IMAGE) upload /config/$<

logs: $(NODES:%=logs-%)
logs-%: %.yaml force
	$(DOCKER) run $(DOCKER_RUN_OPTS) $(IMAGE) logs /config/$<

run: $(NODES:%=run-%)
run-%: %.yaml force
	$(DOCKER) run $(DOCKER_RUN_OPTS) $(IMAGE) run /config/$<

%.bin: compile-%
	cp .esphome/build/$(@:%.bin=%)/.pioenvs/$(@:%.bin=%)/firmware.factory.bin $@

flash-%: compile-% force
	esptool write-flash 0x0 .esphome/build/$(@:flash-%=%)/.pioenvs/$(@:flash-%=%)/firmware.factory.bin

force:
