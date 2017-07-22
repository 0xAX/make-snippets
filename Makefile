# gcc-version - returns version of installed gcc
#
# Usage:
#
# $(call gcc-version)
#
# ifeq "$(GCC_VERSION)" "7.1.1"
#	CFLAGS += -Wexpansion-to-defined
# endif
define gcc-version
	$(eval GCC_VERSION = $(shell gcc --version | sed -n -e 's/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/p'))
endef

# clang-version - returns version of installed clang
#
# Usage:
#
# $(call clang-version)
#
# ifeq "$(CLANG_VERSION)" "4.0.0"
#	CFLAGS += -fstrict-vtable-pointers
# endif
define clang-version
	$(eval CLANG_VERSION = $(shell clang --version | sed -n -e 's/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/p'))
endef

# gcc-supports-flags - returns 0 if the passed flag is not supported by gcc.
#
# Usage:
#
# $(call gcc-supports-flag,EXPANSION_TO_DEFINED_WARN,-Wexpansion-to-defined)
#
# ifeq "$(EXPANSION_TO_DEFINED_WARN)" "1"
#	CFLAGS += -Wexpansion-to-defined
# endif
define gcc-supports-flag
	$(eval $1 = $(shell echo "" | gcc $2 2>&1 | grep -q "unrecognized command"; echo "$$?"))
endef

# g++-supports-flag - returns 0 if the passed flag is not supported by g++.
#
# Usage:
#
# $(call g++-supports-flag,EXPANSION_TO_DEFINED_WARN,-Wexpansion-to-defined)
#
# ifeq "$(EXPANSION_TO_DEFINED_WARN)" "1"
#	CFLAGS += -Wexpansion-to-defined
# endif
define g++-supports-flag
	$(eval $1 = $(shell echo "" | g++ $2 2>&1 | grep -q "unrecognized command"; echo "$$?"))
endef

# clang-supports-flag - returns 0 if the passed flag is not supported by clang.
#
# Usage:
#
# $(call clang-supports-flag,EXPANSION_TO_DEFINED_WARN,-Wexpansion-to-defined)
#
# ifeq "$(EXPANSION_TO_DEFINED_WARN)" "1"
#	CFLAGS += -Wexpansion-to-defined
# endif
define clang-supports-flag
	$(eval $1 = $(shell echo "" | clang -E -c -Wfd - 2>&1 | grep -q unknown; echo "$$?"))
endef

# clang++-supports-flags - returns 0 if the passed flag is not supported by clang++.
#
# Usage:
#
# $(call clang++-supports-flag,EXPANSION_TO_DEFINED_WARN,-Wexpansion-to-defined)
#
# ifeq "$(EXPANSION_TO_DEFINED_WARN)" "1"
#	CFLAGS += -Wexpansion-to-defined
# endif
define clang++-supports-flag
	$(eval $1 = $(shell echo "" | clang++ -E -c -Wfd - 2>&1 | grep -q unknown; echo "$$?"))
endef

# print_success - prints the given message with green color.
#
# Usage:
#
# $(call print_success,"Done...")
define print_success
	@echo -e "\033[0;32m$1\033[0m"
endef

# print_success - prints the given message with red color.
#
# Usage:
#
# $(call print_error,"Error: ...")
define print_error
	@echo -e "\033[0;31m$1\033[0m"
endef

# print_success - prints the given message with yellow color.
#
# Usage:
#
# $(call print_warning,"Warning: ...")
define print_warning
	@echo -e "\033[0;33m$1\033[0m"
endef

#
# make-snippets test
#
test:
	$(call print_error,"Error: ...")
	$(call print_warning,"Warning: ...")
	$(call print_success,"Done...")
	@echo "Test..."

clean:
	@echo "Clean..."

.PHONY: test clean
