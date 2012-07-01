assert = require 'assert'
nodeio = require 'node.io'
connectors = require '../connectors'
Ride = require 'ride'

#exports['test sth'] = () ->
#  query = Ride.new
#    orig: "DE:Berlin:Berlin"
#    dest: "DE:Bayern:München"
#  console.log "ooorig"
#  console.log query.orig
#  nodeio.start connectors.mitfahrzentrale.findRides, query, ((err, rides) ->
#    assert.eql true, rides.length > 0
#    console.log rides
#  ), true

exports['test foreign key'] = () ->
  query = Ride.new
    orig: "DE:Bayern:München"
    dest: "DE:Nordrhein-Westfalen:Köln"
  nodeio.start connectors.mitfahrzentrale.findRides, query, ((err, rides) ->
    console.log rides
  ), true
