import oauth

proc main*(argv: seq[string] = nil) =
  if argv == nil:
    echo "No Commands"
    return -1

  echo argv
  return 1

when isMainModule:
  import os

  echo "GDSinkers"

  let argv = if paramCount() > 0: commandLineParams()
            else nil

  echo main(argv)

