RDS = require '../rds'
Ride = require '../ride'
assert = require 'assert'

exports['test RDS'] = () ->

  query = {start: 'Hamburg', target: 'Berlin'}
  RDS.match new Ride(query), (matching_rides) ->
    for ride in  matching_rides
      console.log "found: "+ride
      assert.eql "not crashed yet", "not crashed yet"
    #RDS.redis.end()

