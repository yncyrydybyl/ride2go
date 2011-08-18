ride_factory = require '../lib/ridefactory'

describe "RideFactory", ->
  describe 'createRide', ->
    factory = {}

    beforeEach ->
      factory = ride_factory.RideFactory

    describe 'with query string', ->
      builder = {}
      beforeEach ->
        spyOn(builder = ride_factory.builder.RideFromStringBuilder, 'create')

      it "should call the RideFromStringBuilder when called with a string", ->
        factory.createRide("hamburg->berlin")
        expect(builder.create).toHaveBeenCalledWith("hamburg","berlin")

      it "should call the RideFromStringBuilder with empty origin", ->
        factory.createRide("->berlin")
        expect(builder.create).toHaveBeenCalledWith("","berlin")

      it "should call the RideFromStringBuilder with empty destination", ->
        factory.createRide("hamburg->")
        expect(builder.create).toHaveBeenCalledWith("hamburg","")

    describe 'with location objects', ->
      builder = {}

      beforeEach ->
        spyOn(builder = ride_factory.builder.RideFromRideObjectBuilder, 'create')

      it 'should call RideFromRideObjectBuilder with the location objects', ->
        ride = {orig:{title:"hamburg"},dest:{title:"berlin"}}
        factory.createRide(ride)
        expect(builder.create).toHaveBeenCalledWith(ride)

      it 'should call RideFromRideObjectBuilder with only orig', ->
        ride = {orig:{title:"hamburg"}}
        factory.createRide(ride)
        expect(builder.create).toHaveBeenCalledWith(ride)

      it 'should call RideFromRideObjectBuilder with only dest', ->
        ride = {dest:{title:"berlin"}}
        factory.createRide(ride)
        expect(builder.create).toHaveBeenCalledWith(ride)
