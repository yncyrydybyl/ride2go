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
        builder = new factories.RideFromQueryBuilder

      it "should call the RideFromQueryBuilder when called with a string", ->
        spyOn(builder, 'createFromQuery')
        factory.createRide("hamburg->berlin", builder)
        expect(builder.createFromQuery)
          .toHaveBeenCalledWith("hamburg","berlin")

      it "should call the RideFromQueryBuilder with empty origin", ->
        spyOn(builder, 'createFromQuery')
        factory.createRide("->berlin", builder)
        expect(builder.createFromQuery)
          .toHaveBeenCalledWith("","berlin")

      it "should call the RideFromQueryBuilder with empty destination", ->
        spyOn(builder, 'createFromQuery')
        factory.createRide("hamburg->", builder)
        expect(builder.createFromQuery)
          .toHaveBeenCalledWith("hamburg","")
  #
  # xit "should call the RideFromQueryBuilder with its arguments", ->
  #   factory.createRide("hamburg->")
  #   expect(factory.RideFromQueryBuilder).toHaveBeenCalledWith("","berlin")
  #
  # xit "should call the RideFromQueryBuilder with its arguments", ->
  #   factory.createRide("->berlin")
  #   expect(factory.RideFromQueryBuilder).toHaveBeenCalledWxith("hamburg","")
  #
  # xit "should call the RideFromObjectBuilder with its arguments", ->
  #   ride = {orig:{txitle:"hamburg"},dest:{title:"berlin"}}
  #   factory.createRide(ride)
  #   expect(factory.RideFromRideObjectBuilder).toHaveBeenCalledWxith(ride)
