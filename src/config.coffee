fs   = require 'fs'
log  = require './logging'

apikeys = {}
server  = { port: 3000 }

readConfig: (name, default) ->
  try
    content = fs.readFileSync fname
    return JSON.parse content
  catch error
    log.error "Error reading #{fname}: #{error}"
  default

module.exports = {
  apikeys: readConfig "./config/apikeys.json", {}
  server: readConfig "./config/server.json", {port: 3000}
}