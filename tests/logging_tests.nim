## Logging test
import os
import unittest
import system
import strutils
import typetraits
import gdsyncpkg/logging
import gdsyncpkg/config

suite "gdsync logging tests":
  
  setup:
    echo "Setting up"
    # Try and use default when testing
    var config = defaultConfig()

  test "logging info test":
    let file_path = getTempDir() / "log_test.log"
    var fd = open(file_path, fmReadWrite)
    addLogger(fd) 
    info("Test Info Log")
    check existsFile(file_path)
    echo(readFile(file_path))

  echo "Finishing"
  removeFile(getTempDir() / "log_test.log")

