# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) 2024 Tomas Paukrt

libdemo_CFLAGS   := -Wformat-security
libdemo_CPPFLAGS := -D_FORTIFY_SOURCE=2
