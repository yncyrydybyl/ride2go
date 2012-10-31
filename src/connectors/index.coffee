__      = require 'underscore'
log     = require '../logging'

# module.exports.mapquest = require('./mapquest').findRides

# loading connectors
files      = require('fs').readdirSync __dirname
connectors = {}

load_connector = (fname) ->
  log.debug "+ loading connector: #{fname}"
  connector      = require "./#{fname}"
  connector.name = fname if !connector.name
  connector

provide_connector = (connector) ->
  log.debug "+ initially enabled connector: #{connector.name}" if connector.enabled
  connectors[connector.name] = connector

for file in files when file != "index.js"
  if (fname = file.match(/(.+)\.js$/))
    provide_connector load_connector(fname[1])

module.exports.all_connectors = () ->
  __.keys connectors

module.exports.enabled_connectors = () ->
  result = []
  for k, v of connectors
    result.push(k) if v.enabled
  result

module.exports.scraping_connectors = () ->
  result = []
  for k, v of connectors
    result.push(k) if v.enabled && v.findRides
  result

module.exports.ingesting_connectors = () ->
  result = []
  for k, v of connectors
    result.push(k) if v.enabled && v.ingesting && v.ingestRides
  result

module.exports.disabled_connectors = () ->
  result = []
  for k, v of connectors
    result.push(k) if !v.enabled
  result

module.exports.connectors = connectors

log.notice "list of initially enabled connectors: [#{module.exports.enabled_connectors()}]"
