# Package

version       = "0.1.0"
author        = "ryancotter,ashleybroughton"
description   = "Google Drive sync application for linux"
license       = "GNU"

srcDir           = "gdsync/src"
binDir          = "gdsync/bin"
bin              = @["gdsync"]
# Dependencies
requires "nim >= 0.16.0"
when defined(nimdistros):
    import distros
    if detectOs(Ubuntu):
        foreignDep "libssl-dev"
    else:
        foreignDep "openssl"

requires "oath >= 0.4"

