import asyncdispatch
import gdsyncpkg/common,
       gdsyncpkg/options,
       gdsyncpkg/usage,
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

proc doAction(options: Options) =
  case options.action.typ
  of actionNil:
    if options.showHelp:
      showUsage()

  else:
    echo options


when isMainModule:
  import os

  try:
    parseCmdLine().doAction()
    quit(0)
  except:
    echo getCurrentExceptionMsg()
    quit(1)

  echo "GDSinkers"

  let argv = if paramCount() > 0: commandLineParams()
            else: nil

  echo main(argv)
  runForever()
