assert     = require 'assert'
nodeio     = require 'node.io'
connectors = require '../../lib/connectors'

describe 'mapquest', () ->

  it 'should lookup distances by coordinate', (done) ->
    debugger;
    query =
      orig: '48.1,11.5'
      dest: '52.1,13.5'

    nodeio.start connectors.mapquest.findRides, query, ((err, rides) ->
      expect(rides).to.be.ok
      expect(rides).to.not.have.length(0)
      for ride in rides
        expect(ride.url).to.be.ok
        expect(ride.distance).to.be.ok
      done()
    ), true