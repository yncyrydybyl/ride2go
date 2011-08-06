assert = require 'assert'
nodeio = require 'node.io'
connectors = require '../connectors'

exports['test sth'] = () ->
  query = 
    orig: "Berlin"
    dest: "Hamburg"
    date: "Fr+05.08.2011"
  nodeio.start connectors.mitfahrzentrale, query, ((err, rides) ->
    assert.eql true, rides.length > 0
    console.log rides
  ), true


