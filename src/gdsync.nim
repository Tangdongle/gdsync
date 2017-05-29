import asyncdispatch
import gdsyncpkg/common,
       gdsyncpkg/logging,
       gdsyncpkg/config,
       gdsyncpkg/options,
       gdsyncpkg/usage,
       gdsyncpkg/version,
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

proc doAction(options: Options, config: Config) =
  case options.action.typ
  of actionNil:
    if options.showHelp:
      showUsage()

    if options.showVersion:
      showVersion()

  of actionWatch:
    watch(options)

  else:
    echo "Unhandled option: " & $(options)


when isMainModule:
  import os

  try:
    let config = loadConfig()
    logLevel = config.LogLevel
    parseCmdLine().doAction(config)
    quit(0)
  except:
    echo getCurrentExceptionMsg()
    quit(1)

  echo "GDSinkers"

  let argv = if paramCount() > 0: commandLineParams()
            else: nil

  echo main(argv)
  runForever()
