assert = require 'assert'
nodeio = require 'node.io'
connectors = require '../connectors'

exports['test sth'] = () ->
  query = 
    origin: "Berlin"
    destination: "Hamburg"
    date: "27.07.2011"
  nodeio.start connectors.raummobil, query, ((err, rides) ->
    #assert.eql true, rides.length > 0
    console.log rides
  ), true


