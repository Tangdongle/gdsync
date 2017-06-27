const version = "0.1.0"

proc showVersion*() =
  echo "Version: " & version

proc getVersion*() : string =
  result = version
