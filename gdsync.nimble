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
requires @["nim >= 0.16.0", "oauth >= 0.04.0"]

# Tasks
task compile_main, "Compiles the project":
    exec "nim c -d:ssl --out:gdsync gdsyncpkg/gdsync.nim"

task exec, "Execute the main binary":
    exec "./gdsync"

