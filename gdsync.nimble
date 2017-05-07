#
# Package

version       = "0.1.0"
author        = "ryancotter,ashleybroughton"
description   = "Google Drive sync application for linux"
license       = "GNU"

#srcDir        = "gdsync/src"
#binDir        = "gdsync/bin"
bin           = @["gdsync"]
skipDirs      = @["private"]
# Dependencies
requires "nim >= 0.16.0"

# Tasks
task compile_main, "Compiles the project":
    exec "nim c -d:ssl -r gdsync/src/gdsync.nim --out gdsync/bin/gdsync"
