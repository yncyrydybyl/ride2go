assert = require 'assert'
nodeio = require 'node.io'
connectors = require '../connectors'

exports['test that it dows not crash if no rides are found'] = () ->
  query =
    orig: "DE:Nordrhein-Westfalen:Köln"
    dest: "DE:Bayern:Nürnberg"
  nodeio.start connectors.deinbus.findRides, query, ((err, rides) ->
  ), true


exports['test that it can find rides'] = () ->
  query =
    orig: "DE:Nordrhein-Westfalen:Köln"
    dest: "DE:Hessen:Frankfurt am Main"
  nodeio.start connectors.deinbus.findRides, query, ((err, rides) ->
    console.log rides.length
  ), true

