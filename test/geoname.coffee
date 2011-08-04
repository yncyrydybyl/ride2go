assert = require 'assert'
nodeio = require 'node.io'
connectors = require '../connectors'
exports['import geoname into redis'] = () ->
  # download geonames file
  # redis checken das nix drin is
  # importen
  # checken das was drin is

  redis = require("redis").createClient()
  redis.hkeys "places", (err, keys) ->
    console.log(keys)
  

