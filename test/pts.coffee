assert = require 'assert'
nodeio = require 'node.io'
connectors = require '../connectors'

exports['test that it dows not crash if no rides are found'] = () ->
  query =
    orig: "DE:Berlin:Berlin"
    dest: "DE:Hamburg:Hamburg"
  nodeio.start connectors.pts.findRides, query, ((err, rides) ->
    console.log rides
  ), true
