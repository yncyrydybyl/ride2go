fs   = require 'fs'
log  = require './logging'

###
Read json config file
@private
@param [String] fname file name of config file
@param [Object] defaults defaults to be used for properties that are missing in the config file
@return [Object] configuration
###
_readConfig = (fname, defaults) ->
  try
    content = fs.readFileSync fname
    result  = JSON.parse content
    for k, v in defaults
	    result[k] = v if !result[k]
    return result
  catch error
    log.error "Error reading #{fname}: #{error}"
  defaults

###
apikeys config
###
module.exports.apikeys = _readConfig './config/apikeys.json', {}

###
server config
###
module.exports.server = _readConfig './config/server.json', {port: 3000, host: 'localhost', tolerancedays: 3}
