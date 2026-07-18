# Common sanitizer instrumentation and runtime options for C and C++ builds.
#
# SANITIZERS contains a comma-separated list of sanitizers passed to
# -fsanitize. For example:
#
#   make SANITIZERS=address,undefined
#
# Sanitizers supported by both GCC and Clang:
#
#   address
#       Detects out-of-bounds accesses, use-after-free, use-after-scope,
#       double-free, and other invalid memory accesses.
#
#   leak
#       Detects leaked heap allocations. LeakSanitizer is commonly enabled
#       automatically by AddressSanitizer on supported platforms.
#
#   thread
#       Detects data races and some incorrect synchronization operations.
#
#   undefined
#       Detects many forms of undefined behavior, including invalid shifts,
#       signed integer overflow, misaligned accesses, null dereferences,
#       invalid array indexing, and division by zero.
#
# Additional sanitizers with compiler, architecture, operating-system, or
# runtime restrictions:
#
#   memory
#       Detects reads of uninitialized memory. Supported by Clang, but not GCC.
#       Most application code and its dependencies must be instrumented.
#
#   hwaddress
#       Hardware-assisted address checking using memory tags. Availability is
#       limited to supported architectures and operating systems.
#
#   kernel-address
#       AddressSanitizer instrumentation intended for supported kernels rather
#       than ordinary user-space applications.
#
#   kernel-hwaddress
#       Hardware-assisted address checking intended for supported kernels.
#
# Individual UndefinedBehaviorSanitizer checks may also be selected instead
# of the complete "undefined" group. Common checks include:
#
#   alignment
#   bool
#   bounds
#   builtin
#   enum
#   float-cast-overflow
#   float-divide-by-zero
#   integer-divide-by-zero
#   nonnull-attribute
#   null
#   object-size
#   pointer-overflow
#   return
#   returns-nonnull-attribute
#   shift
#   signed-integer-overflow
#   unreachable
#   vla-bound
#   vptr
#
# Support for individual checks can differ between GCC and Clang versions.
# The "vptr" check applies only to C++ and requires RTTI.
#
# Common combinations:
#
#   make SANITIZERS=address,undefined
#   make SANITIZERS=leak
#   make SANITIZERS=thread
#
# AddressSanitizer and ThreadSanitizer cannot be enabled in the same build.
# LeakSanitizer also cannot be combined with ThreadSanitizer.
# MemorySanitizer should be used in a separate Clang build.
#
# SANITIZER_COMPILE_FLAGS must be passed when compiling every instrumented
# source file. SANITIZER_LINK_FLAGS must be passed when linking the final
# executable or shared library.
#
# Compile a C source file:
#
# %.o: %.c
#	$(CC) $(CPPFLAGS) $(CC_COMPILE_FLAGS) \
#		$(SANITIZER_COMPILE_FLAGS) $(CFLAGS) -c $< -o $@
#
# Compile a C++ source file:
#
# %.o: %.cpp
#	$(CXX) $(CPPFLAGS) $(CXX_COMPILE_FLAGS) \
#		$(SANITIZER_COMPILE_FLAGS) $(CXXFLAGS) -c $< -o $@
#
# Link a C executable:
#
# application: $(OBJECTS)
#	$(CC) $(SANITIZER_LINK_FLAGS) $(LDFLAGS) \
#		-o $@ $^ $(LDLIBS)
#
# Link a C++ executable:
#
# application: $(OBJECTS)
#	$(CXX) $(SANITIZER_LINK_FLAGS) $(LDFLAGS) \
#		-o $@ $^ $(LDLIBS)

################################################################################
## Sanitizer flags
################################################################################

# Comma-separated list of enabled sanitizers
SANITIZERS ?=

SANITIZER_FLAGS :=
ifneq ($(strip $(SANITIZERS)),)
SANITIZER_FLAGS := -fsanitize=$(SANITIZERS)
endif

# Compile instrumented code and preserve useful stack information
SANITIZER_COMPILE_FLAGS :=
ifneq ($(strip $(SANITIZERS)),)
SANITIZER_COMPILE_FLAGS :=      \
	$(SANITIZER_FLAGS)      \
	-g                      \
	-fno-omit-frame-pointer \
	-fno-optimize-sibling-calls
endif

# Link the corresponding sanitizer runtime
SANITIZER_LINK_FLAGS :=
ifneq ($(strip $(SANITIZERS)),)
SANITIZER_LINK_FLAGS := $(SANITIZER_FLAGS)
endif

################################################################################
## Sanitizer runtime options
################################################################################

# Detect accesses to stack objects after their function has returned
export ASAN_OPTIONS ?= detect_stack_use_after_return=1

# Print a stack trace for undefined-behavior reports
export UBSAN_OPTIONS ?= print_stacktrace=1

