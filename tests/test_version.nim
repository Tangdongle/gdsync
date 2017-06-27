import unittest
import gdsyncpkg/version

suite "version output testing"
  echo "suite setup: Executing"

  setup:
    echo "Running setup"

  teardown:
    echo "Running teardown"

  test "first test":
    let version = "0.1.0"
    check getVersion() == version
