Ride = require '../ride'
factories = require '../lib/ridefactory'

describe "Ride", ->
  it "should created with query string as parameter", ->
    r = new Ride "hamburg->leipzig"
    r2 = new Ride
    r2.orig = "hamburg"
    r2.dest = "leipzig"
    expect(r).toEqual(r2)

describe "RideFactory", ->
  describe 'createRide', ->
    factory = {}

    beforeEach ->
      factory = new factories.RideFactory

    describe 'with query string', ->
      builder = {}

      beforeEach ->
        spyOn(builder = factories.builder.RideFromQueryBuilder, 'create')

      it "should call the RideFromQueryBuilder when called with a string", ->
        factory.createRide("hamburg->berlin")
        expect(builder.create).toHaveBeenCalledWith("hamburg","berlin")

      it "should call the RideFromQueryBuilder with empty origin", ->
        factory.createRide("->berlin")
        expect(builder.create).toHaveBeenCalledWith("","berlin")

      it "should call the RideFromQueryBuilder with empty destination", ->
        factory.createRide("hamburg->")
        expect(builder.create).toHaveBeenCalledWith("hamburg","")

    describe 'with location objects', ->
      builder = {}

      beforeEach ->
        spyOn(builder = factories.builder.RideFromRideObjectBuilder, 'create')

      it 'should call RideFromRideObjectBuilder with the location objects', ->
        ride = {orig:{txitle:"hamburg"},dest:{title:"berlin"}}
        factory.createRide(ride)
        expect(builder.create).toHaveBeenCalledWith(ride)
