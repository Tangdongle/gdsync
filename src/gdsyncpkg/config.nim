import os
import tables
import json
import strutils
import logging

const config_file_name = "config.json"
let config_dir = joinPath(getConfigDir(), "gdsync")
let config_file_path = joinPath(config_dir, config_file_name)

type Config* = object
  PidFile*: string
  DaemonLogFile*: string
  LogLevel*: LogLevel

proc defaultConfig*(): Config =
  ## Return a default config object
  result.PidFile = joinPath(config_dir, "gdsync.pid")
  result.DaemonLogFile = joinPath(config_dir, "daemon.log")
  result.LogLevel = LogLevel.info

proc configToJsonString(config: Config): string =
  ## Parses config to a JSON string
  var t = initOrderedTable[string, JsonNode]()
  t.add("PidFile", newJString(config.PidFile))
  t.add("DaemonLogFile", newJString(config.DaemonLogFile))
  t.add("LogLevel", newJString($config.LogLevel))

  var jobj = newJObject()
  jobj.fields = t

  result = pretty(jobj) & "\n"

proc readConfig(): Config =
  ## Load config from a file into memory
  var json_node: JsonNode
  json_node = parseFile(config_file_path)
  result.PidFile = json_node["PidFile"].str
  result.DaemonLogFile = json_node["DaemonLogFile"].str
  result.LogLevel = parseEnum[LogLevel](json_node["LogLevel"].str)

proc loadConfig*(): Config =
  ## Sets up your config
  let first_run = not existsOrCreatedir(config_dir)
  let config_exists = existsFile(config_file_path)
  
  if first_run or not config_exists:
    writeFile(config_file_path, configToJsonString(defaultConfig()))

  try:
    result = readConfig()
  except:
    echo("Failed to read config file from: " & config_file_path)
    raise
