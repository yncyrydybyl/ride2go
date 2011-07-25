assert = require 'assert'
nodeio = require 'node.io'
scrapers = require '../scrapers'

exports['test sth'] = () ->
  query = 
    origin: "Berlin"
    destination: "Hamburg"
    date: "27.07.2011"
  nodeio.start scrapers.raummobil, query, ((err, rides) ->
    #assert.eql true, rides.length > 0
    console.log rides
  ), true


