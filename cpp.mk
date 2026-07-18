# Common definitions, variables, functions, and other helpers for building
# C++ code.
#
# This file defines project-managed compiler flags. The standard Make
# variables CPPFLAGS and CXXFLAGS remain user-controlled and should be passed
# separately in compilation rules.
#
# CPPFLAGS contains preprocessor options, such as include paths and macro
# definitions:
#
#   make CPPFLAGS="-Iinclude -DFEATURE_ENABLED=1"
#
# CXXFLAGS contains additional user-supplied C++ compiler options:
#
#   make CXXFLAGS="-march=native"
#
# CXXFLAGS is placed after CXX_COMPILE_FLAGS so the user can override
# conflicting project defaults. For example:
#
#   make CXXFLAGS="-O3"
#
# Compile a regular object:
#
# %.o: %.cpp
#	$(CXX) $(CPPFLAGS) $(CXX_COMPILE_FLAGS) $(CXXFLAGS) -c $< -o $@
#
# Compile a position-independent object for a shared library:
#
# %.pic.o: %.cpp
#	$(CXX) $(CPPFLAGS) $(CXX_COMPILE_FLAGS) $(PIC_CXXFLAGS) \
#		$(LIB_VISIBILITY_CXXFLAGS) $(CXXFLAGS) -c $< -o $@
#
# Link a shared library:
#
# libexample.so: $(PIC_OBJECTS)
#	$(CXX) $(LDFLAGS) $(SHARED_LDFLAGS) $(SHARED_CHECK_LDFLAGS) \
#		-o $@ $^ $(LIB_LDLIBS) $(LDLIBS)
#
# The compiler and user flags can be selected together:
#
#   make CXX=g++ CPPFLAGS="-Iinclude -DLOG_LEVEL=2" \
#        CXXFLAGS="-march=x86-64-v3"

################################################################################
## General options
################################################################################

# Use Clang unless another compiler was explicitly selected
ifneq ($(filter default undefined,$(origin CXX)),)
CXX := clang++
endif

################################################################################
## C++ compiler flags
################################################################################

# Set the C++ language standard
export CXX_STD ?= -std=gnu++23

# Enable strict C++ compiler warnings
export CXX_WARN_FLAGS ?=      \
	-Wall                 \
	-Wextra               \
	-Wno-unused-parameter \
	-Wpedantic            \
	-Wformat=2            \
	-Wundef               \
	-Wnon-virtual-dtor    \
	-Woverloaded-virtual  \
	-Wvla

# Enable additional strict warnings when requested
CXX_STRICT_WARN_FLAGS :=
ifeq ($(STRICT_WARNINGS),1)
CXX_STRICT_WARN_FLAGS :=                \
	-Wshadow                        \
	-Wcast-qual                     \
	-Wold-style-cast                \
	-Wzero-as-null-pointer-constant \
	-Wswitch-enum
endif

# Treat compiler warnings as errors when requested
CXX_WERROR_FLAGS :=
ifeq ($(WARNINGS_AS_ERRORS),1)
CXX_WERROR_FLAGS := -Werror
endif

# Select the build configuration
BUILD ?= debug
ifeq ($(BUILD),debug)
CXX_OPT_FLAGS   ?= -Og
CXX_DEBUG_FLAGS ?= -g -fno-omit-frame-pointer
else ifeq ($(BUILD),release)
CXX_OPT_FLAGS   ?= -O2
CXX_DEBUG_FLAGS ?=
else
$(error Unsupported BUILD mode: $(BUILD))
endif

# Resulting flags for the C++ compiler
export CXX_COMPILE_FLAGS :=      \
	$(CXX_STD)               \
	$(CXX_WARN_FLAGS)        \
	$(CXX_STRICT_WARN_FLAGS) \
	$(CXX_WERROR_FLAGS)      \
	$(CXX_DEBUG_FLAGS)       \
	$(CXX_OPT_FLAGS)

################################################################################
## Library flags
################################################################################

# Generate position-independent code for shared-library objects
PIC_CXXFLAGS ?= -fPIC

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

# Optional symbol-visibility flags for shared-library objects
LIB_VISIBILITY_CXXFLAGS ?=
