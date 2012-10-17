fs   = require 'fs'
log  = require './logging'

apikeys = {}

try
  content = fs.readFileSync './apikeys.json'
  apikeys = JSON.parse content
catch error
  log.error "Error reading ./apikeys.json: #{error}"

module.exports = {
  apikeys: apikeys
}