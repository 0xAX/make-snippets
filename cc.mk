# Common definitions, variables, functions, and other helpers for building
# C code.
#
# This file defines project-managed compiler flags. The standard Make
# variables CPPFLAGS and CFLAGS remain user-controlled and should be passed
# separately in compilation rules.
#
# CPPFLAGS contains preprocessor options, such as include paths and macro
# definitions:
#
#   make CPPFLAGS="-Iinclude -DFEATURE_ENABLED=1"
#
# CFLAGS contains additional user-supplied C compiler options:
#
#   make CFLAGS="-march=native"
#
# CFLAGS is placed after CC_COMPILE_FLAGS so the user can override conflicting
# project defaults. For example:
#
#   make CFLAGS="-O3"
#
# Compile a regular object:
#
# %.o: %.c
#	$(CC) $(CPPFLAGS) $(CC_COMPILE_FLAGS) $(CFLAGS) -c $< -o $@
#
# Compile a position-independent object for a shared library:
#
# %.pic.o: %.c
#	$(CC) $(CPPFLAGS) $(CC_COMPILE_FLAGS) $(PIC_CFLAGS) \
#		$(LIB_VISIBILITY_CFLAGS) $(CFLAGS) -c $< -o $@
#
# The compiler and user flags can be selected together:
#
#   make CC=gcc CPPFLAGS="-Iinclude -DLOG_LEVEL=2" \
#        CFLAGS="-march=x86-64-v3"

################################################################################
## General options
################################################################################

# Use Clang unless another compiler was explicitly selected
ifneq ($(filter default undefined,$(origin CC)),)
CC := clang
endif

################################################################################
## C compiler flags
################################################################################

# Set the C language standard
export CC_STD ?= -std=gnu23

# Enable strict C compiler warnings
export CC_WARN_FLAGS ?=       \
	-Wall                 \
	-Wextra               \
	-Wno-unused-parameter \
	-pedantic             \
	-Wformat=2            \
	-Wundef               \
	-Wstrict-prototypes   \
	-Wmissing-prototypes  \
	-Wvla

# Enable additional strict warnings when requested
CC_STRICT_WARN_FLAGS :=
ifeq ($(STRICT_WARNINGS),1)
CC_STRICT_WARN_FLAGS := \
	-Wshadow        \
	-Wcast-qual     \
	-Wswitch-enum
endif

# Treat compiler warnings as errors when requested
CC_WERROR_FLAGS :=
ifeq ($(WARNINGS_AS_ERRORS),1)
CC_WERROR_FLAGS := -Werror
endif

# Select the build configuration
BUILD ?= debug
ifeq ($(BUILD),debug)
CC_OPT_FLAGS   ?= -Og
CC_DEBUG_FLAGS ?= -g -fno-omit-frame-pointer
else ifeq ($(BUILD),release)
CC_OPT_FLAGS   ?= -O2
CC_DEBUG_FLAGS ?=
else
$(error Unsupported BUILD mode: $(BUILD))
endif

# Resulting flags for the C compiler
export CC_COMPILE_FLAGS =       \
	$(CC_STD)               \
	$(CC_WARN_FLAGS)        \
	$(CC_STRICT_WARN_FLAGS) \
	$(CC_WERROR_FLAGS)      \
	$(CC_DEBUG_FLAGS)       \
	$(CC_OPT_FLAGS)

################################################################################
## Lib flags
################################################################################

# Generate position-independent code for shared-library objects
PIC_CFLAGS ?= -fPIC

# Link a shared library
SHARED_LDFLAGS ?= -shared

# Libraries required by library targets
LIB_LDLIBS ?=

# Create static-library archives
AR ?= ar

# Create or update an archive and its symbol index
ifneq ($(filter default undefined,$(origin ARFLAGS)),)
ARFLAGS := rcs
endif

################################################################################
## ELF library flags
################################################################################

# Reject unresolved symbols in shared libraries
SHARED_CHECK_LDFLAGS ?= -Wl,-z,defs

# Hide symbols unless explicitly exported
LIB_VISIBILITY_CFLAGS ?=
