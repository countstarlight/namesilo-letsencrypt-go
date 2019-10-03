DIST := dist
IMPORT := github.com/countstarlight/namesilo-letsencrypt-go

GO ?= env GO111MODULE=on CGO_ENABLED=0 go
SED_INPLACE := sed -i
EXTRA_GOFLAGS ?=
TAGS ?=
LDFLAGS ?=

ifeq ($(OS), Windows_NT)
	EXECUTABLE_AUTH := auth.exe
	EXECUTABLE_AUTH_RELEASE := auth-release.exe
	EXECUTABLE_CLEAN := clean.exe
    EXECUTABLE_CLEAN_RELEASE := clean-release.exe
	EXTRA_GOFLAGS = -tags 'netgo osusergo $(TAGS)' -ldflags '-linkmode external -extldflags "-static" $(LDFLAGS)'
else
	EXECUTABLE_AUTH := auth
    EXECUTABLE_AUTH_RELEASE := auth-release
    EXECUTABLE_CLEAN := clean
    EXECUTABLE_CLEAN_RELEASE := clean-release
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		SED_INPLACE := sed -i ''
		EXTRA_GOFLAGS = -tags 'netgo osusergo $(TAGS)' -ldflags '$(LDFLAGS)'
	else
	    GO ?= env GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go
		EXTRA_GOFLAGS = -tags 'netgo $(TAGS)' -ldflags '-linkmode external -extldflags "-static" $(LDFLAGS)'
	endif
endif

GOFILES := $(shell find . -name "*.go" -type f ! -path "./vendor/* ")
GOBINS := ${GOPATH}/bin
GOFMT ?= gofmt -s

GOFLAGS := -mod=vendor -v

PACKAGES ?= $(shell $(GO) list ./... | grep -v /vendor/)
SOURCES ?= $(shell find . -name "*.go" -type f)

.PHONY: all
all: build

.PHONY: rm
rm:
	$(GO) clean -i ./...; \
	rm -f $(EXECUTABLE_AUTH); \
	rm -f $(EXECUTABLE_CLEAN); \
	rm -f $(EXECUTABLE_AUTH_RELEASE); \
	rm -f $(EXECUTABLE_CLEAN_RELEASE)

.PHONY: fmt
fmt:
	$(GOFMT) -w $(GOFILES)

.PHONY: fmt-check
fmt-check:
	# get all go files and run go fmt on them
	@diff=$$($(GOFMT) -d $(GOFILES)); \
	if [ -n "$$diff" ]; then \
		echo "Please run 'make fmt' and commit the result:"; \
		echo "$${diff}"; \
		exit 1; \
	fi;

.PHONY: errcheck
errcheck:
	@hash errcheck > /dev/null 2>&1; if [ $$? -ne 0 ]; then \
		$(GO) get -u github.com/kisielk/errcheck; \
	fi
	errcheck $(PACKAGES)

.PHONY: lint
lint:
	@hash revive > /dev/null 2>&1; if [ $$? -ne 0 ]; then \
		$(GO) get -u github.com/mgechev/revive; \
	fi
	revive -config .revive.toml -exclude=./vendor/... ./... || exit 1

.PHONY: misspell-check
misspell-check:
	@hash misspell > /dev/null 2>&1; if [ $$? -ne 0 ]; then \
		$(GO) get -u github.com/client9/misspell/cmd/misspell; \
	fi
	misspell -error -i unknwon $(GOFILES)

.PHONY: misspell
misspell:
	@hash misspell > /dev/null 2>&1; if [ $$? -ne 0 ]; then \
		$(GO) get -u github.com/client9/misspell/cmd/misspell; \
	fi
	misspell -w -i unknwon $(GOFILES)

.PHONY: build
build: $(EXECUTABLE_AUTH) $(EXECUTABLE_CLEAN)

$(EXECUTABLE_AUTH): $(SOURCES)
	cd ./cmd/auth; \
	$(GO) build $(GOFLAGS) -o $@; \
	mv $@ ../../

$(EXECUTABLE_CLEAN): $(SOURCES)
	cd ./cmd/clean; \
	$(GO) build $(GOFLAGS) -o $@; \
	mv $@ ../../

.PHONY: release
release: $(EXECUTABLE_AUTH_RELEASE) $(EXECUTABLE_CLEAN_RELEASE)

$(EXECUTABLE_AUTH_RELEASE): $(SOURCES)
	cd ./cmd/auth; \
	$(GO) build $(GOFLAGS) -o $@; \
	mv $@ ../../

$(EXECUTABLE_CLEAN_RELEASE): $(SOURCES)
	cd ./cmd/clean; \
	$(GO) build $(GOFLAGS) -o $@; \
	mv $@ ../../