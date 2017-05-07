import oauth2
import os
import typetraits
import strutils, httpclient
import json
import asyncnet, asyncdispatch
import streams
include secret.auth


proc main(argv: seq[string] = nil) {.async.} =
  ## Google Drive Syncer main function
  var clientID = OAUTH_CLIENT_ID
  var clientSecret = OAUTH_SECRET

  var client = newAsyncHttpClient()
  let openid_json = await client.getContent("https://accounts.google.com/.well-known/openid-configuration")

  echo openid_json
  let openid_urls = parseJson(openid_json)

  let authorizeURL = openid_urls["authorization_endpoint"]
  let accessTokenUrl = openid_urls["token_endpoint"]
  let html = "gdsyncpkg/resources/index.html".readFile()
  var gapiGetUrl = "https://www.googleapis.com/drive/v3/files/"
  var export_url_part = "/export?mimeType="
  echo authorizeURL
  echo accessTokenUrl

  var tokens = newFileStream("tokens", fmRead)
  var tokenType:string = ""
  var accessToken:string = ""
  var refreshToken:string = ""
  let url = "https://www.googleapis.com/drive/v3/files"

  if not isNil(tokens):
    accessToken = tokens.readLine()
    refreshToken = tokens.readLine()
    tokenType = tokens.readLine()
  else:
    let response = authorizationCodeGrant(
        getStr(authorizeURL),
        getStr(accessTokenUrl),
        clientId,
        clientSecret,
        html,
        scope = @["https://www.googleapis.com/auth/drive",
        "https://www.googleapis.com/auth/drive.metadata"])

    echo response.body

    var
      obj = parseJson(response.body)

    accessToken = obj["access_token"].str
    tokenType = obj["token_type"].str
    refreshToken = obj["refresh_token"].str

    echo obj
    var o = open("tokens", fmWrite)
    o.writeln(accessToken)
    o.writeln(refreshToken)
    o.writeln(tokenType)
    o.close()

  if tokenType == "Bearer":
    let r = bearerRequest(url, accessToken)
    let file_json = parseJson(r.body)
    var id_list: seq[string] = @[]
    var name_list: seq[string] = @[]
    var media_list: seq[string] = @[]
    var file_list = file_json["files"]
    for file in file_list:
      echo file
      if getStr(file["kind"]) == "drive#file":
        id_list.add(getStr(file["id"]))
        name_list.add(getStr(file["name"]))
        media_list.add(getStr(file["mimeType"]))
    echo id_list
    echo name_list
    echo media_list

    for media, id in media_list:
      for id in id_list:
        echo id.type.name
        echo media.type.name
        var id_url = gapiGetUrl & id & export_url_part & media
        echo id_url
        let resp = getContent(id_url)
        echo resp
        #let id_r = bearerRequest(id_url, accessToken)
        #echo id_r

  if argv == nil:
    echo "No Commands"

  echo argv
  quit()

when isMainModule:
  import os

  echo "GDSinkers"

  let argv = if paramCount() > 0: commandLineParams()
            else: nil

  asyncCheck main(argv)
  runForever()
