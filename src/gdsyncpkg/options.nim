import parseopt2

type ActionType* = enum
  actionNil

type Action* = object
  case typ*: ActionType
  of actionNil:
    nil

type Options* = object
  action*: Action
  showHelp*: bool

proc parseCommand(key: string, result: var Options) =
  echo "parseCommand"
  echo key

proc parseArgument(key: string, result: var Options) =
  echo "parseArgument"
  echo key

proc parseFlag(flag: string, val: string, result: var Options, kind = cmdLongOption) =
  echo "parseFlag"
  echo flag
  echo val
  echo kind

proc parseCmdLine*(): Options =
  result.action.typ = actionNil   # set default action

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


  # show usage if no action is specified
  if result.action.typ == actionNil:
    result.showHelp = true
