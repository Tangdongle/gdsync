import oauth2
import os
import typetraits
import strutils, httpclient
import json
import asyncnet, asyncdispatch
import streams
#include secret.auth

proc oauth*(client_id: string, client_secret: string) {.async.} =
  # TODO: handling of secrets

  var client = newAsyncHttpClient()
  let openid_json = await client.getContent("https://accounts.google.com/.well-known/openid-configuration")
  echo openid_json

  let openid_urls = parseJson(openid_json)

  let authorize_url = openid_urls["authorization_endpoint"]
  let access_token_url = openid_urls["token_endpoint"]
  echo authorize_url
  echo access_token_url

  let html = "src/gdsyncpkg/resources/index.html".readFile()
  var gapi_get_url = "https://www.googleapis.com/drive/v4/files/"
  var export_url_part = "/export?mimeType="
  let url = "https://www.googleapis.com/drive/v3/files"

  var tokens = newFileStream("tokens", fmRead)
  var token_type:string = ""
  var access_token:string = ""
  var refresh_token:string = ""
  
  if not isNil(tokens):
    access_token = tokens.readLine()
    refresh_token = tokens.readLine()
    token_type = tokens.readLine()
  else:
    let response = authorizationCodeGrant(
      getStr(authorize_url),
      getStr(access_token_url),
      client_id,
      client_secret,
      html,
      scope = @["https://www.googleapis.com/auth/drive",
      "https://www.googleapis.com/auth/drive.metadata"])

    echo response.body

    var obj = parseJson(response.body)
    echo obj

    access_token = obj["access_token"].str
    token_type = obj["token_type"].str
    refresh_token = obj["refresh_token"].str

    var o = open("tokens", fmWrite)
    o.writeLine(access_token)
    o.writeLine(refresh_token)
    o.writeLine(token_type)
    o.close()

  if token_type == "Bearer":
    let r = bearerRequest(url, access_token)
    let file_json = parseJson(r.body)
    var id_list: seq[string] = @[]
    var name_list: seq[string] = @[]
    var media_list: seq[string] = @[]
    var file_list = file_json["files"]

    for file in file_list:
      echo file
      if getStr(file["king"]) == "drive#file":
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

          var id_url = gapi_get_url & id & export_url_part & intToStr(media)
          echo id_url

          let resp = await client.getContent(id_url)
          echo resp

          #let id_r = bearerRequest(id_url, access_token)
          #echo id_r
