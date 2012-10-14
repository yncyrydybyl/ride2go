assert = require 'assert'
nodeio = require 'node.io'
connectors = require '../../lib/connectors'

describe 'connectors', () ->

  describe 'deinbus', () ->

    it 'should not crash if no rides are found', (done) ->
      query =
        orig: "DE:Nordrhein-Westfalen:Köln"
        dest: "DE:Bayern:Nürnberg"
      nodeio.start connectors.deinbus.findRides, query, ((err, rides) ->
        expect(err || rides.length == 0).to.be.true
        done()
      ), true


    it 'should find rides', (done) ->
      query =
        orig: "DE:Nordrhein-Westfalen:Köln"
        dest: "DE:Hessen:Frankfurt am Main"
      nodeio.start connectors.deinbus.findRides, query, ((err, rides) ->
        expect(rides).to.be.ok
        expect(rides.length > 0).to.be.true
        expect(rides[0].orig).to.equal('Köln')
        expect(rides[0].dest).to.equal('Frankfurt am Main')
        for ride in rides
          expect(ride.arr).to.be.ok
          expect(ride.arr > 0).to.be.true
          expect(ride.dep).to.be.ok
          expect(ride.dep > 0).to.be.true
        done()
      ), true

