assert = require 'assert'
nodeio = require 'node.io'
scrapers = require '../scrapers'

exports['test sth'] = () ->
  query = 
    origin: "B"
    destination: "HH"
    #date: new Date("Jul 28, 2011")
  nodeio.start scrapers.citynetz, query, ((err, rides) ->
    assert.eql true, rides.length > 0
    console.log rides
  ), true


