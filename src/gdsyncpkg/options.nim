import parseopt2
import strutils

type ActionType* = enum
  actionNil

type Action* = object
  case typ*: ActionType
  of actionNil:
    nil

type Options* = object
  action*: Action
  showHelp*: bool
  showVersion*: bool

proc initOptions(): Options =
  result.action.typ = actionNil
  result.showHelp = false
  result.showVersion = false

proc parseCommand(key: string, result: var Options) =
  echo "parseCommand"
  echo key

proc parseArgument(key: string, result: var Options) =
  echo "parseArgument"
  echo key

proc parseFlag(flag: string, val: string, result: var Options, kind = cmdLongOption) =
  let f = flag.normalize()

  case f
  of "help", "h": result.showHelp = true
  of "version", "v": result.showVersion = true
  else:
    echo "parseFlag"
    echo flag
    echo val
    echo kind

proc parseCmdLine*(): Options =
  result = initOptions()

  for kind, key, val in getOpt():
    case kind
    of cmdArgument:
      if result.action.typ == actionNil:
        parseCommand(key, result)
      else:
        parseArgument(key, result)
    of cmdLongOption, cmdShortOption:
      parseFlag(key, val, result, kind)
    else:
      echo kind


  # show usage if no action is specified and version was not requested
  if result.action.typ == actionNil and not result.showVersion:
    result.showHelp = true
