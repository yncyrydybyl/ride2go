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
        expect(rides[0].dep_date).to.be.ok
        expect(rides[0].dep_date.length > 0 ).to.be.true
        expect(rides[0].dep_time).to.be.ok
        expect(rides[0].dep_time.length > 0 ).to.be.true
        done()
      ), true

