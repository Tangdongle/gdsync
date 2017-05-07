import oauth2
import strutils, httpclient
import json
include secret.auth

const 
  authorizeURL = "https://accounts.google.com/o/oauth2/v2/auth"
  accessTokenUrl = "https://accounts.google.com/o/oauth2/v2/token"

proc main*(argv: seq[string] = nil): int =
  ## Google Drive Syncer main function
  var clientID = OAUTH_CLIENT_ID
  var clientSecret = OAUTH_SECRET
  
  let html = "resources/index.html".readFile()
  
  let response = authorizationCodeGrant(
      authorizeUrl,
      accessTokenUrl,
      clientId,
      clientSecret,
      html,
      scope = @["https://www.googleapis.com/auth/drive",
      "https://www.googleapis.com/auth/drive.metadata"])


  if argv == nil:
    echo "No Commands"
    return -1

  echo argv
  return 1

when isMainModule:
  import os

  echo "GDSinkers"

  let argv = if paramCount() > 0: commandLineParams()
            else: nil

  echo main(argv)

