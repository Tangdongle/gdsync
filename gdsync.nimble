# Package

version       = "0.1.0"
author        = "ryancotter,ashleybroughton"
description   = "Google Drive sync application for linux"
license       = "GNU"

bin           = @["gdsync"]
srcDir        = "src"
skipDirs      = @["private"]

# Dependencies
requires "nim >= 0.16.0"
requires "oauth >= 0.4.0"

when defined(nimdistros):
  import distros
  if detectOs(Ubuntu):
    foreignDep "libssl-dev"
  else:
    foreignDep "openssl"

# Tasks
task co, "Compile only":
  exec "nim c -d:ssl --out:build/gdsync src/gdsync.nim"

task cr, "Compile and run":
  exec "nim c -d:ssl --out:build/gdsync -r src/gdsync.nim"

task test, "Run the tester":
  withDir "tests":
    exec "nim c -r tester"

#Hooks
before co:
  exec "mkdir build"

before cr:
  exec "mkdir build"
