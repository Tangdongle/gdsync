import options

proc watch*(options: Options) =
  echo "Added folder to watch list: " & options.action.path
