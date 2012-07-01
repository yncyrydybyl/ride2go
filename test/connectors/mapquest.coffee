assert = require 'assert'
nodeio = require 'node.io'
connectors = require '../connectors'

exports['test sth'] = () ->
  query =
    orig: "48.1,11.5"
    dest: "52.1,13.5"
  nodeio.start connectors.mapquest, query, ((err, rides) ->
    console.log rides
  ), true


