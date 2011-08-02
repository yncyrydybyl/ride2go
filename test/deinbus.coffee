assert = require 'assert'
nodeio = require 'node.io'
connectors = require '../connectors'

exports['test sth'] = () ->
  query =
    orig: "Frankfurt am Main"
    dest: "Köln"
  nodeio.start connectors.deinbus, query, ((err, rides) ->
    console.log rides
  ), true


