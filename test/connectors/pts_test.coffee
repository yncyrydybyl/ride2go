connectors = require "../../lib/connectors"
nodeio     = require "node.io"

describe 'connectors', () ->

  describe 'pts', () ->

    it 'should not crash if no rides are found', (done) ->
      query =
        orig: 'DE:Berlin:Berlin'
        dest: 'DE:Berlin:Hamburg'
      nodeio.start connectors.deinbus.findRides, query, ((err, rides) ->
        expect(err || rides.length == 0).to.be.true
        done()
      ), true


    it 'should find rides', (done) ->
      query =
        orig: 'DE:Berlin:Berlin'
        dest: 'DE:Berlin:Hamburg'
      nodeio.start connectors.pts.findRides, query, ((err, rides) ->
        expect(rides).to.be.ok
        expect(rides.length > 0).to.be.true
        expect(rides[0].orig).to.equal('Berlin')
        expect(rides[0].dest).to.equal('Hamburg')
        for ride in rides
          expect(ride.arr).to.be.ok
          expect(ride.arr > 0).to.be.true
          expect(ride.dep).to.be.ok
          expect(ride.dep > 0).to.be.true
        done()
      ), true

