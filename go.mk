# Helpers for formatting, checking, building, testing, and benchmarking Go
# packages.
#
# Format all Go packages:
#
#   make fmt
#
# Check all packages for suspicious constructs:
#
#   make vet
#
# Build the package in the current directory:
#
#   make build
#
# Format, vet, and build the project:
#
#   make prepare
#
# Run all tests:
#
#   make test
#
# Run all benchmarks and report memory-allocation statistics:
#
#   make bench

.PHONY: fmt
# Format Go source files in all packages. This target modifies files in place.
fmt:
	go fmt ./...

.PHONY: vet
# Examine all packages and report suspicious constructs that may indicate
# programming errors.
vet:
	go vet ./...

.PHONY: build
# Build the package in the current directory without running tests.
build:
	go build

.PHONY: prepare
# Format, vet, and build the project in sequence.
prepare:
	$(MAKE) fmt
	$(MAKE) vet
	$(MAKE) build

.PHONY: test
# Run tests for all packages in the module.
test:
	go test ./...

.PHONY: bench
# Run benchmarks for all packages and report allocation counts and allocated
# bytes per operation.
bench:
	go test -bench=. -benchmem ./...
