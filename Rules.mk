# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) 2024 Tomas Paukrt
#
# EasyMake requires that the source codes of each program or library be organized
# into separate subdirectories. The lists of programs, static libraries and
# shared libraries to be built must be defined using the custom variables
# PROGRAMS, STATIC_LIBS and SHARED_LIBS in the main Makefile.
#
# Compilation, linking and installation are affected by the standard variables
# AR, CC, CXX, CFLAGS, CXXFLAGS, CPPFLAGS, LDFLAGS and LDLIBS as well as
# the custom variables DEPENDS, OBJDIR, BINDIR, LIBDIR and INCDIR which can
# be defined either in the main Makefile or in an optional file Setup.mk.
#
# It is also possible to override the default behaviour or settings for each
# subdirectory using custom variables like <dir>_CFLAGS which can be defined
# in optional files <dir>/Setup.mk.
#
# |----------------------|--------------|---------------------------------------|
# | Variable             | Default      | Description                           |
# |----------------------|--------------|---------------------------------------|
# | PROGRAMS             |              | list of programs to be built          |
# | STATIC_LIBS          |              | list of static libraries to be built  |
# | SHARED_LIBS          |              | list of shared libraries to be built  |
# | DEPENDS              |              | list of global dependencies           |
# | OBJDIR               | OBJ          | subdirectory for object files         |
# | BINDIR               | /usr/bin     | directory for installing programs     |
# | LIBDIR               | /usr/lib     | directory for installing libraries    |
# | INCDIR               | /usr/include | directory for installing header files |
# | AR                   | ar           | archiver tool                         |
# | CC                   | cc           | C compiler                            |
# | CXX                  | g++          | C++ compiler                          |
# | CFLAGS               |              | global C compiler flags               |
# | CXXFLAGS             |              | global C++ compiler flags             |
# | CPPFLAGS             |              | global preprocessor flags             |
# | LDFLAGS              |              | global linker flags                   |
# | LDLIBS               |              | global library flags                  |
# | <dir>_NAME           | <dir>        | target file base name                 |
# | <dir>_MODE           | autoselect   | target file permission mode           |
# | <dir>_PATH           | autoselect   | target installation path              |
# | <dir>_DEPENDS        |              | list of additional dependencies       |
# | <dir>_HEADERS        | autodetect   | list of header files                  |
# | <dir>_SOURCES        | autodetect   | list of source files                  |
# | <dir>_LIBS           |              | list of libraries                     |
# | <dir>_COMPILER       | autoselect   | compiler                              |
# | <dir>_LINKER         | autoselect   | linker                                |
# | <dir>_CFLAGS         |              | additional C compiler flags           |
# | <dir>_CXXFLAGS       |              | additional C++ compiler flags         |
# | <dir>_CPPFLAGS       |              | additional preprocessor flags         |
# | <dir>_LDFLAGS        |              | additional linker flags               |
# | <dir>_LDLIBS         |              | additional library flags              |
# | <dir>_INSTALL        | copy files   | install command                       |
# | <dir>_UNINSTALL      | remove files | uninstall command                     |
# | <dir>_PRE_INSTALL    |              | pre-install command                   |
# | <dir>_PRE_UNINSTALL  |              | pre-uninstall command                 |
# | <dir>_POST_INSTALL   |              | post-install command                  |
# | <dir>_POST_UNINSTALL |              | post-uninstall command                |
# |----------------------|--------------|---------------------------------------|

# global settings for build and installation
-include Setup.mk

# default subdirectory for object files
OBJDIR ?= OBJ

# default directories for installation
BINDIR ?= /usr/bin
LIBDIR ?= /usr/lib
INCDIR ?= /usr/include

# ccache command
CCACHE ?= $(shell command -v ccache 2> /dev/null)

# build verbosity
ifeq ($(V),1)
Q :=
E := @true
else
Q := @
E := @echo
endif

# if the specified goals cannot be executed in parallel
ifneq ($(and $(filter clean%, $(MAKECMDGOALS)),$(filter-out clean%, $(MAKECMDGOALS))),)

# auxiliary targets for the specified goals
$(MAKECMDGOALS): goals
	@true

# auxiliary target for successive execution of the specified goals
goals:
	@$(MAKE) --no-print-directory $(filter clean%, $(MAKECMDGOALS))
	@$(MAKE) --no-print-directory $(filter-out clean%, $(MAKECMDGOALS))

# if the specified goals can be executed in parallel
else

# default target
all: build

# target for building all binary files
build:

# target for installing all binary and header files
install:

# target for uninstalling all binary and header files
uninstall:

# target for cleaning all binary and temporary files
clean:
	$(Q) rm -rf $(firstword $(subst ., ,$(OBJDIR)))*

# target for cleaning all files generated by the build process
distclean: clean

# function to generate rules for building, installing and uninstalling a target binary file
define generate-rules
build: build-$(1)

install: install-$(1)

uninstall: uninstall-$(1)

build-$(1): $(OBJDIR)/$(1)/$($(1)_FILE)

install-$(1): build-$(1)
	$(Q) $($(1)_PRE_INSTALL)
	$(Q) $($(1)_INSTALL)
	$(if $(if $($(1)_INSTALL),,$($(1)_PATH)),
	  $(E) "  CP  $(1)/$($(1)_FILE)"
	  $(Q) install -D -m $($(1)_MODE) $(OBJDIR)/$(1)/$($(1)_FILE) $(DESTDIR)$($(1)_PATH)/$($(1)_FILE)
	  $(foreach FILE, $($(1)_HEADERS),
	    $(E) "  CP  $(1)/$(FILE)"
	    $(Q) install -D -m 644 $(1)/$(FILE) $(DESTDIR)$(INCDIR)/$(FILE)
	  )
	)
	$(Q) $($(1)_INSTALL)
	$(Q) $($(1)_POST_INSTALL)

uninstall-$(1):
	$(Q) $($(1)_PRE_UNINSTALL)
	$(Q) $($(1)_UNINSTALL)
	$(if $(if $($(1)_UNINSTALL),,$($(1)_PATH)),
	  $(E) "  RM  $(1)/$($(1)_FILE)"
	  $(Q) rm -f $(DESTDIR)$($(1)_PATH)/$($(1)_FILE)
	  $(foreach FILE, $($(1)_HEADERS),
	    $(E) "  RM  $(1)/$(FILE)"
	    $(Q) rm -f $(DESTDIR)$(INCDIR)/$(FILE)
	  )
	)
	$(Q) $($(1)_POST_UNINSTALL)

clean-$(1):
	$(Q) rm -rf $(OBJDIR)/$(1)

$($(1)_OBJDIRS):
	$(Q) mkdir -p $$@

$(OBJDIR)/$(1)/%.o: $(1)/%.c $(wildcard Makefile Setup.mk $(1)/Setup.mk $($(1)_DEPENDS) $(DEPENDS)) | $($(1)_OBJDIRS)
	$(E) "  CC  $$(patsubst $(OBJDIR)/%,%,$$@)"
	$(Q) $(CCACHE) $($(1)_COMPILER) -MMD -MP $(CPPFLAGS) $($(1)_CPPFLAGS) -I$(1) -fPIC $(CFLAGS) $($(1)_CFLAGS) -c $$< -o $$@

$(OBJDIR)/$(1)/%.o: $(1)/%.cc $(wildcard Makefile Setup.mk $(1)/Setup.mk $($(1)_DEPENDS) $(DEPENDS)) | $($(1)_OBJDIRS)
	$(E) "  CC  $$(patsubst $(OBJDIR)/%,%,$$@)"
	$(Q) $(CCACHE) $($(1)_COMPILER) -MMD -MP $(CPPFLAGS) $($(1)_CPPFLAGS) -I$(1) -fPIC $(CXXFLAGS) $($(1)_CXXFLAGS) -c $$< -o $$@

$(OBJDIR)/$(1)/%.o: $(1)/%.cpp $(wildcard Makefile Setup.mk $(1)/Setup.mk $($(1)_DEPENDS) $(DEPENDS)) | $($(1)_OBJDIRS)
	$(E) "  CC  $$(patsubst $(OBJDIR)/%,%,$$@)"
	$(Q) $(CCACHE) $($(1)_COMPILER) -MMD -MP $(CPPFLAGS) $($(1)_CPPFLAGS) -I$(1) -fPIC $(CXXFLAGS) $($(1)_CXXFLAGS) -c $$< -o $$@

$(OBJDIR)/$(1)/$($(1)_NAME): $($(1)_OBJECTS)
	$(E) "  LD  $$(patsubst $(OBJDIR)/%,%,$$@)"
	$(Q) $(CCACHE) $($(1)_LINKER) -pie $(LDFLAGS) $($(1)_LDFLAGS) -o $$@ $$(filter %.o, $$^) $($(1)_LDLIBS) $(LDLIBS)

$(OBJDIR)/$(1)/$($(1)_NAME).so: $($(1)_OBJECTS)
	$(E) "  LD  $$(patsubst $(OBJDIR)/%,%,$$@)"
	$(Q) $(CCACHE) $($(1)_LINKER) -shared $(LDFLAGS) $($(1)_LDFLAGS) -o $$@ $$(filter %.o, $$^) $($(1)_LDLIBS) $(LDLIBS)

$(OBJDIR)/$(1)/$($(1)_NAME).a: $($(1)_OBJECTS)
	$(E) "  AR  $$(patsubst $(OBJDIR)/%,%,$$@)"
	$(Q) rm -f $$@
	$(Q) $(AR) rcs $$@ $$(filter %.o, $$^)

-include $($(1)_GENDEPS)
endef

# auxiliary function to load specific settings for building and installing a target binary file
define load-setup
-include $(1)/Setup.mk
endef

# auxiliary function to set basic properties of a target binary file
define set-properties
$(eval $(1)_NAME     ?= $(1))
$(eval $(1)_PATH     ?= $(2))
$(eval $(1)_MODE     ?= $(3))
$(eval $(1)_FILE     := $($(1)_NAME)$(4))
$(eval $(1)_HEADERS  ?= $(if $(4), $(foreach EXT, h hh hpp, $(patsubst $(1)/%, %, $(foreach DIR, $(1) $(1)/*, $(wildcard $(DIR)/*.$(EXT)))))))
$(eval $(1)_SOURCES  ?= $(foreach EXT, c cc cpp, $(patsubst $(1)/%, %, $(foreach DIR, $(1) $(1)/*, $(sort $(wildcard $(DIR)/*.$(EXT)))))))
$(eval $(1)_GENDEPS  := $(foreach EXT, c cc cpp, $(patsubst %.$(EXT), $(OBJDIR)/$(1)/%.d, $(filter %.$(EXT), $($(1)_SOURCES)))))
$(eval $(1)_OBJECTS  := $(foreach EXT, c cc cpp, $(patsubst %.$(EXT), $(OBJDIR)/$(1)/%.o, $(filter %.$(EXT), $($(1)_SOURCES)))))
$(eval $(1)_OBJDIRS  := $(sort $(dir $(addprefix $(OBJDIR)/$(1)/, $($(1)_SOURCES)))))
$(eval $(1)_COMPILER ?= $(if $(filter %.cc %.cpp, $($(1)_SOURCES)), $(CXX), $(CC)))
$(eval $(1)_LINKER   ?= $($(1)_COMPILER))
endef

# auxiliary function to set dependencies of a target binary file on internal and external libraries
define set-dependencies
$(foreach LIB, $(filter $(wildcard *), $($(1)_LIBS)),
  $(OBJDIR)/$(1)/$($(1)_FILE) : $(OBJDIR)/$(LIB)/$($(LIB)_FILE)
  $(eval $(1)_CPPFLAGS += -I$(LIB))
  $(eval $(1)_LDFLAGS  += -L$(OBJDIR)/$(LIB))
  $(eval $(1)_LDLIBS   += $(patsubst lib%, -l%, $($(LIB)_NAME)))
)
$(foreach LIB, $(filter-out $(wildcard *), $($(1)_LIBS)),
  $(eval $(1)_LDLIBS   += $(patsubst lib%, -l%, $(LIB)))
)
endef

# generate auxiliary variables and build rules for each target binary file
$(foreach DIR, $(STATIC_LIBS) $(SHARED_LIBS) $(PROGRAMS), $(eval $(call load-setup,$(DIR))))
$(foreach DIR, $(STATIC_LIBS), $(eval $(call set-properties,$(DIR),$(LIBDIR),644,.a)))
$(foreach DIR, $(SHARED_LIBS), $(eval $(call set-properties,$(DIR),$(LIBDIR),755,.so)))
$(foreach DIR, $(PROGRAMS), $(eval $(call set-properties,$(DIR),$(BINDIR),755)))
$(foreach DIR, $(STATIC_LIBS) $(SHARED_LIBS) $(PROGRAMS), $(eval $(call set-dependencies,$(DIR))))
$(foreach DIR, $(STATIC_LIBS) $(SHARED_LIBS) $(PROGRAMS), $(eval $(call generate-rules,$(DIR))))

endif
