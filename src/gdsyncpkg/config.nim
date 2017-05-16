import os
import tables
import json

const config_dir = joinPath(getConfigDir(), "gdsync")
const config_file_name = "config.json"
const config_file_path = joinPath(config_dir, config_file_name)

type Config* = object
  PidFile*: string

proc defaultConfig(): Config =
  result.PidFile = joinPath(config_dir, "gdsync.pid")

proc configToJsonString(config: Config): string =
  var t = initOrderedTable[string, JsonNode]()
  t.add("PidFile", newJString(config.PidFile))

  var jobj = newJObject()
  jobj.fields = t

  result = pretty(jobj) & "\n"

proc readConfig(): Config =
  var json_node: JsonNode
  json_node = parseFile(config_file_path)
  result.PidFile = json_node["PidFile"].str

proc loadConfig*(): Config =
  let first_run = not existsOrCreatedir(config_dir)
  let config_exists = existsFile(config_file_path)
  
  if first_run or not config_exists:
    writeFile(config_file_path, configToJsonString(defaultConfig()))

  try:
    result = readConfig()
  except:
    echo("Failed to read config file from: " & config_file_path)
    raise
