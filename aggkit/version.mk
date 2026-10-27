# Each value can be injected from outside (make VERSION=..., environment variable or Docker build arg).
# When it is unset or empty it is derived from git. This lets builds without a .git directory
# (e.g. a Docker build whose context is this folder) stamp the correct version.
VERSION ?=
ifeq ($(strip $(VERSION)),)
VERSION := $(shell git describe --tags --always)
endif
GITREV ?=
ifeq ($(strip $(GITREV)),)
GITREV := $(shell git rev-parse --short HEAD)
endif
GITBRANCH ?=
ifeq ($(strip $(GITBRANCH)),)
GITBRANCH := $(shell git rev-parse --abbrev-ref HEAD)
endif
DATE ?=
ifeq ($(strip $(DATE)),)
DATE := $(shell LANG=US date +"%a, %d %b %Y %X %z")
endif
