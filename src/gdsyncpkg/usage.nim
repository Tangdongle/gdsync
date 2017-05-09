const usage = """
Usage: gdsync COMMAND [opts]

Commands:
  Not applicable at this time.


Options:
  -h, --help                Print this usage or help for the specified command.
  -v, --version             Print version information.

For more information read the Github readme:
  https://github.com/gdsync/gdsync#readme
"""

proc showUsage*() =
  echo(usage)
