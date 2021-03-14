REGISTRY ?= ghcr.io
OWNER ?= racklet
IMAGE_NAME ?= render-plantuml-action
IMAGE = $(REGISTRY)/$(OWNER)/$(IMAGE_NAME)
TAG ?= 

all: build
resolve-git-version:
ifeq ($(shell git rev-parse --is-shallow-repository),true)
	# actions/checkout does a shallow clone; unshallow and make sure we're up-to-date before running git describe
	git fetch --unshallow
endif

GIT_VERSION=$(shell git describe --tags HEAD 2>/dev/null || echo "v0.0.0")
ifeq ($(shell git status -s),)
GIT_STATUS=
else
GIT_STATUS=-dirty
endif
GIT_TAG=$(GIT_VERSION)$(GIT_STATUS)
GIT_MAJOR=$(shell echo $(GIT_VERSION) | cut -d. -f1)

build:
	docker build -t $(IMAGE):$(GIT_TAG) --pull .

push: build
	docker push $(IMAGE):$(GIT_TAG)
ifneq ($(TAG),)
	docker tag $(IMAGE):$(GIT_TAG) $(IMAGE):$(TAG)
	docker push $(IMAGE):$(TAG)
endif

push-major: push
ifeq ($(GIT_STATUS),)
	docker tag $(IMAGE):$(GIT_TAG) $(IMAGE):$(GIT_MAJOR)
	docker push $(IMAGE):$(GIT_MAJOR)
endif

test: build
	docker run -it -v $(shell pwd):/files $(IMAGE):$(GIT_TAG) --formats=svg,png --log-level=debug
	$(MAKE) verify

verify:
	@[ -f test/foo.svg ] && [ -f test/foo.png ] && echo "Files generated!" || (echo "e2e files not generated" && exit 1)
