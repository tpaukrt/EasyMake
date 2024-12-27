# EasyMake

## Introduction

  EasyMake is an extension of GNU Make designed to simplify its usage for
  C/C++ projects. It allows users to control the entire build process solely
  through variable definitions, eliminating the need to write custom rules.

  In the simplest case, only two lines of code are sufficient to create a functional
  Makefile that supports parallel compilation of multiple files. Don't believe it?
  Then check out the first included example to see how easy it can be.

## Features

  * Fully parallel compilation and linking
  * Automatic discovery of source files
  * Automatic dependency resolution
  * Automatic detection and use of `ccache` (compiler cache)
  * Separate source and build directories
  * Optional verbose mode (`make V=1`)
  * Entire functionality contained in a single file

## Prerequisites

  * GNU Make 3.81+
  * GCC 4.9+

## Usage

  EasyMake requires that the source codes of each program or library be organized
  into separate subdirectories. The lists of programs, static libraries and
  shared libraries to be built must be defined using the custom variables
  `PROGRAMS`, `STATIC_LIBS` and `SHARED_LIBS` in the main `Makefile`.

  Compilation, linking and installation are affected by the standard variables
  `AR`, `CC`, `CXX`, `CFLAGS`, `CXXFLAGS`, `CPPFLAGS`, `LDFLAGS` and `LDLIBS`
  as well as the custom variables `DEPENDS`, `OBJDIR`, `BINDIR`, `LIBDIR` and `INCDIR`
  which can be defined either in the main `Makefile` or in an optional file `Setup.mk`.

  It is also possible to override the default behaviour or settings for each
  subdirectory using custom variables like `<dir>_CFLAGS` which can be defined
  in optional files `<dir>/Setup.mk`.

  | Variable               | Default      | Description                           |
  |------------------------|--------------|---------------------------------------|
  | `PROGRAMS`             |              | list of programs to be built          |
  | `STATIC_LIBS`          |              | list of static libraries to be built  |
  | `SHARED_LIBS`          |              | list of shared libraries to be built  |
  | `DEPENDS`              |              | list of global dependencies           |
  | `OBJDIR`               | OBJ          | subdirectory for object files         |
  | `BINDIR`               | /usr/bin     | directory for installing programs     |
  | `LIBDIR`               | /usr/lib     | directory for installing libraries    |
  | `INCDIR`               | /usr/include | directory for installing header files |
  | `AR`                   | ar           | archiver tool                         |
  | `CC`                   | cc           | C compiler                            |
  | `CXX`                  | g++          | C++ compiler                          |
  | `CFLAGS`               |              | global C compiler flags               |
  | `CXXFLAGS`             |              | global C++ compiler flags             |
  | `CPPFLAGS`             |              | global preprocessor flags             |
  | `LDFLAGS`              |              | global linker flags                   |
  | `LDLIBS`               |              | global library flags                  |
  | `<dir>_NAME`           | `<dir>`      | target file base name                 |
  | `<dir>_MODE`           | autoselect   | target file permission mode           |
  | `<dir>_PATH`           | autoselect   | target installation path              |
  | `<dir>_DEPENDS`        |              | list of additional dependencies       |
  | `<dir>_HEADERS`        | autodetect   | list of header files                  |
  | `<dir>_SOURCES`        | autodetect   | list of source files                  |
  | `<dir>_LIBS`           |              | list of libraries                     |
  | `<dir>_COMPILER`       | autoselect   | compiler                              |
  | `<dir>_LINKER`         | autoselect   | linker                                |
  | `<dir>_CFLAGS`         |              | additional C compiler flags           |
  | `<dir>_CXXFLAGS`       |              | additional C++ compiler flags         |
  | `<dir>_CPPFLAGS`       |              | additional preprocessor flags         |
  | `<dir>_LDFLAGS`        |              | additional linker flags               |
  | `<dir>_LDLIBS`         |              | additional library flags              |
  | `<dir>_INSTALL`        | copy files   | install command                       |
  | `<dir>_UNINSTALL`      | remove files | uninstall command                     |
  | `<dir>_PRE_INSTALL`    |              | pre-install command                   |
  | `<dir>_PRE_UNINSTALL`  |              | pre-uninstall command                 |
  | `<dir>_POST_INSTALL`   |              | post-install command                  |
  | `<dir>_POST_UNINSTALL` |              | post-uninstall command                |

## Directory structure

  ```
  EasyMake
   |
   |--example1               Basic example
   |
   |--example2               Advanced example
   |
   |--LICENSE                BSD 3-clause license
   |--NEWS.md                Version history
   |--README.md              This file
   +--Rules.mk               Build rules
  ```

## License

  The code is available under the BSD 3-clause license.
  See the `LICENSE` file for the full license text.
