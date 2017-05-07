# Tasks
task build, "Compiles the project":
    exec "nim c -d:ssl --out:gdsync gdsyncpkg/gdsync.nim"

task exec, "Execute the main binary":
    exec "./gdsync"

