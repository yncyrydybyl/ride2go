fs   = require 'fs'
log  = require './logging'

readConfig = (fname, defaults) ->
  try
    content = fs.readFileSync fname
    result  = JSON.parse content
    for k, v in defaults
	    result[k] = v if !result[k]
    return result
  catch error
    log.error "Error reading #{fname}: #{error}"
  defaults

module.exports = {
  apikeys: readConfig './config/apikeys.json', {}
  server: readConfig './config/server.json', {port: 3000, host: 'localhost', tolerancedays: 3}
}
