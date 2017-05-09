const usage = """
Usage: gdsync COMMAND [opts]

Commands:
  watch        [path]       Add current path to watch list.


Options:
  -h, --help                Print this usage or help for the specified command.
  -v, --version             Print version information.

For more information read the Github readme:
  https://github.com/gdsync/gdsync#readme
"""

proc showUsage*() =
  echo(usage)
