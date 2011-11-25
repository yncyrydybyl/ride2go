assert = require 'assert'
nodeio = require 'node.io'
connectors = require '../connectors'

exports['test sth'] = () ->
  query =
    orig: "DE:Nordrhein-Westfalen:Köln"
    dest: "DE:Hessen:Frankfurt am Main"
  nodeio.start connectors.deinbus.findRides, query, ((err, rides) ->
    console.log rides
  ), true


