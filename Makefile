export VER ?= $(shell git describe --tags)
REPOSITORY := gravitational.io
NAME := monitoring-app
OPS_URL ?= https://opscenter.localhost.localdomain:33009
OUT ?= $(NAME).tar.gz
GRAVITY ?= gravity
export

.PHONY: package
package:
	$(MAKE) -C watcher
	$(MAKE) -C images all

.PHONY: deploy
deploy:
	$(MAKE) -C images deploy

.PHONY:
what-version:
	@echo $(VER)

.PHONY: hook
hook:
	$(MAKE) -C images hook

.PHONY: import
import: package
	-$(GRAVITY) app delete --ops-url=$(OPS_URL) $(REPOSITORY)/$(NAME):$(VER) \
		--force --insecure
	$(GRAVITY) app import --vendor --glob=**/*.yaml \
		--set-image=monitoring-hook:$(VER) --ops-url=$(OPS_URL) --repository=$(REPOSITORY) --name=$(NAME) \
		--set-image=watcher:$(VER) --version=$(VER) --insecure .
