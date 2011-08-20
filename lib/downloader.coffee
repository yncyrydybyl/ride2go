sys = require "sys"
http = require "http"
url = require "url"
path = require "path"
fs = require "fs"
events = require "events"

download = (requestUrl) ->
  host = url.parse(requestUrl).hostname
  filename = url.parse(requestUrl).pathname.split("/").pop()
  theurl = http.createClient(80, host)

  startdownload = ->
    request = http.request (
      host: host
      port: 80
      path: url.parse(requestUrl).pathname
      method: 'GET')

    request.end()
    dlprogress = 0
    interval= setInterval (->
      sys.puts "Download progress: " + dlprogress + " bytes"
    ), 1000

    request.addListener "response", (response) ->
      #check for existence
      downloadfile = fs.createWriteStream(filename, flags: "a")
      sys.puts "File size " + filename + ": " + response.headers["content-length"] + " bytes."
      response.addListener "data", (chunk) ->
        dlprogress += chunk.length
        downloadfile.write chunk, encoding = "binary"
    
      response.addListener "end", ->
        downloadfile.end()
        clearInterval interval
        sys.puts "Finished downloading " + filename

  sys.puts "Downloading file: " + filename
  sys.puts "Before download request"

  try
    stat = fs.statSync filename
    console.log("file is already there")
  catch e 
    console.log("file is not there, lets download")
    startdownload()

module.exports = download 
