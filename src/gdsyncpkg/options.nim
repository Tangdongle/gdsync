type ActionType* = enum
  actionNil

type Action* = object
  case typ*: ActionType
  of actionNil:
    nil

type Options* = object
  action*: Action

proc parseCmdLine*(): Options =
  result.action.typ = actionNil
