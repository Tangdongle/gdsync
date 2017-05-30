# Async Logger implementation from
# https://hookrace.net/blog/writing-an-async-logger-in-nim/
# https://github.com/hookrace/hookrace/
import strutils, times

type
  LogLevel* {.pure.} = enum
    debug, info, warn, error, fatal

  Logger = object
    file: File

  MessageKind = enum
    write, update, stop

  Message = object
    case kind: MessageKind
    of write:
      module, text: string
    of update:
      loggers: seq[Logger]
    of stop:
      nil

var
  loggers = newSeq[Logger]()
  channel: Channel[Message]
  thread: Thread[void]

proc addLogger*(file: File) =
  loggers.add Logger(file: file)
  channel.send Message(kind: update, loggers: loggers)

proc threadLog {.thread.} =
  var
    loggers = newSeq[Logger]()
    lastTime: Time
    timeStr = ""

  while true:
    let msg = recv channel
    case msg.kind
    of write:
      let newTime = getTime()
      if newTime != lastTime:
        timeStr = getLocalTime(newTime).format "yyyy-MM-dd HH:mm:ss"
        lastTime = newTime

      let str = "[$#] [$#]: $#\n" % [timeStr, msg.module, msg.text]

      for logger in loggers:
        logger.file.write str
        # Only flush when we're fast enough to keep up with the channel,
        # otherwise let the OS buffer
        if channel.peek == 0:
          logger.file.flushFile

    of update:
      loggers = msg.loggers

    of stop:
      # Make sure we flush rest of text when we're done
      for logger in loggers:
        logger.file.flushFile
      break

proc stopLog {.noconv.} =
  channel.send Message(kind: stop)
  joinThread thread
  close channel

  for logger in loggers:
    if logger.file notin [stdout, stderr]:
      close logger.file

var msg = Message(kind: write, module: "", text: "")
proc send(module, levelName: string, args: varargs[string]) =
  msg.module = module
  msg.text.setLen(0)

  if not isNilOrWhitespace(levelName):
    msg.text.add levelName & ": "

  for arg in args:
    msg.text.add arg
  channel.send msg

template log*(args: varargs[string, `$`]) =
  const module = instantiationInfo().filename[0 .. ^5]
  send module, "", args

template debug*(args: varargs[string, `$`]) =
  if config.LogLevel <= LogLevel.debug:
    const module = instantiationInfo().filename[0 .. ^5]
    send module, "DEBUG", args

template info*(args: varargs[string, `$`]) =
  if config.LogLevel <= LogLevel.info:
    const module = instantiationInfo().filename[0 .. ^5]
    send module, "INFO", args

template warn*(args: varargs[string, `$`]) =
  if config.LogLevel <= LogLevel.warn:
    const module = instantiationInfo().filename[0 .. ^5]
    send module, "WARN", args

template error*(args: varargs[string, `$`]) =
  if config.LogLevel <= LogLevel.error:
    const module = instantiationInfo().filename[0 .. ^5]
    send module, "ERROR", args

template fatal*(args: varargs[string, `$`]) =
  if config.LogLevel <= LogLevel.fatal:
    const module = instantiationInfo().filename[0 .. ^5]
    send module, "FATAL", args

# Initialize module
open channel
thread.createThread threadLog
addQuitProc stopLog
