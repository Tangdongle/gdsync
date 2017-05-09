import asyncdispatch
import gdsyncpkg/common,
       gdsyncpkg/options,
       gdsyncpkg/daemon,
       gdsyncpkg/fsmonitor,
       gdsyncpkg/oauth

proc main*(argv: seq[string] = nil): int =
  ## Google Drive Syncer main function
  asyncCheck oauth.oauth("OAUTH_CLIENT_ID", "OAUTH_CLIENT_SECRET")

  if argv == nil:
    echo "No Commands"
    return -1

  echo argv
  return 1

when isMainModule:
  import os

  echo "GDSinkers"

  let argv = if paramCount() > 0: commandLineParams()
            else: nil

  echo main(argv)
  runForever()
