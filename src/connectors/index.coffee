__      = require '../../vendor/underscore'
log     = require '../logging'

# module.exports.mapquest = require('./mapquest').findRides

# loading connectors
files   = require('fs').readdirSync __dirname

load_connector = (connector_name) ->
  log.debug "+ loading connector: #{connector_name}"
  require "./#{connector_name}"

provide_connector = (connector_name, connector) ->
  log.debug "+ providing connector: #{connector_name}"
  module.exports[connector_name] = connector

for file in files when file != "index.js"
  if (fname = file.match(/(.+)\.js$/))
    connector_name = fname[1]
    connector      = load_connector connector_name
    provide_connector connector_name, connector if connector.enabled

module.exports.active_connectors = __.keys module.exports

# !!! overwrite list of active connectors manually here
# module.exports.active_connectors = ['deinbus']

log.notice "list of active connectors: [#{__.map(module.exports.active_connectors, (x) -> " '#{x}'" )} ]"
