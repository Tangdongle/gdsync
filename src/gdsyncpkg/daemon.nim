import posix
import strutils

var pid: Pid
var pid_file_path: string
var fi, fo, fe, pid_file: File

proc unlinkPidFile {.noconv.} = discard unlink pid_file_path

proc c_signal(sig: cint, handler: proc (a: cint) {.noconv.})
  {.importc: "signal", header: "<signal.h>".}

proc onStop(sig: cint) {.noconv.} =
  close(fi)
  close(fo)
  close(fe)
  quit(QuitSuccess)

proc lockFileByHandle(fd: FileHandle): bool =
  var fl = TFlock(lType: F_WRLCK.cshort, lWhence: SEEK_SET.cshort)
  result = fcntl(fd, F_SETLK, addr fl) >= 0

template forke() =
  pid = fork()
  if pid > 0:
    quit(QuitSuccess)
  elif pid < 0:
    stderr.writeLine("Failed to fork process.")
    quit(1)

template daemonize*(pid_path, si, so, se, cd: string, body: untyped): untyped =
  pid_file_path = pid_path
  pid_file = pid_file_path.open(fmReadWrite)

  let pid_file_handle = getFileHandle(pid_file)

  if not lockFileByHandle(pid_file_handle):
    stderr.writeLine "Daemon is already running"
    quit(1)

  # fork, allowing parent process to terminate
  forke()

  # start a new session for the daemon
  discard setsid()

  # fork again, allowing parent process to terminate
  forke()

  # set current working directory
  if isNilOrEmpty(cd):
    discard chdir("/")
  else:
    discard chdir(cd)

  # set the user file creation mask to 0 (usual for daemons)
  discard umask(0)

  # reopen pid_file and reacquire lock
  close(pid_file)
  pid_file = pid_file_path.open(fmReadWrite)

  if not lockFileByHandle(pid_file_handle):
    stderr.writeLine("Daemon failed to lock pid file")
    quit(1)

  # call proc on exit
  addQuitProc unlinkPidFile

  # flush and reopen standard file descriptors
  flushFile(stdout)
  flushFile(stderr)

  if not isNilOrEmpty(si):
    fi = open(si, fmRead)
    discard dup2(getFileHandle(fi), getFileHandle(stdin))
  else:
    fi = open("/dev/null", fmRead)

  if not isNilOrEmpty(se):
    fe = open(se, fmAppend)
    discard dup2(getFileHandle(fe), getFileHandle(stderr))
  else:
    fe = open("/dev/null", fmReadWrite)

  if not isNilOrEmpty(so):
    fo = open(so, fmAppend)
    discard dup2(getFileHandle(fo), getFileHandle(stdout))
  else:
    fo = open("/dev/null", fmWrite)

  # allow daemon to handle signals
  c_signal(SIGINT, onStop)
  c_signal(SIGTERM, onStop)
  c_signal(SIGHUP, onStop)
  c_signal(SIGQUIT, onStop)

  # write pid to file
  pid_file.writeLine($getpid())
  pid_file.flushFile()

  body
