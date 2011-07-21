assert = require 'assert'
nodeio = require 'node.io'
scrapers = require '../scrapers'

exports['test sth'] = () ->
  query = 
    origin: "Berlin"
    destination: "Hamburg"
    date: "Thu+21.07.2011"
  nodeio.start scrapers.mitfahrzentrale, query, ((err, rides) ->
    assert.eql true, rides.length > 0
  ), true


