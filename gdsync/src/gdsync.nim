import oauth2

proc main*(argv: seq[string] = nil): int =
  ## Google Drive Syncer main function
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

