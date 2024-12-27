# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) 2024 Tomas Paukrt

# basic compiler flags
CFLAGS   += -Wall -Wextra

# extra compiler flags and settings for debug and release build
ifeq ($(DEBUG),1)
OBJDIR   := OBJ.debug
CFLAGS   += -O0 -ggdb
else
OBJDIR   := OBJ.release
CFLAGS   += -O2
LDFLAGS  += -s
endif
