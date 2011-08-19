ride_factory = require '../lib/ride'

describe "RideFactory", ->
  describe 'createRide', ->
    Ride = {}

    beforeEach ->
      Ride = require('../lib/ride').Ride

    describe 'with query string', ->
      fromStringConstructor = {}
      beforeEach ->
        spyOn(fromStringConstructor = ride_factory.constructors.FromString, 'new')

      it "should call the FromString constructor when called with a string", ->
        Ride.new("hamburg->berlin")
        expect(fromStringConstructor.new).toHaveBeenCalledWith("hamburg","berlin")

      it "should call the FromString constructor when called with empty origin", ->
        Ride.new("->berlin")
        expect(fromStringConstructor.new).toHaveBeenCalledWith("","berlin")

      it "should call the FromString constructor when called with empty destination", ->
        Ride.new("hamburg->")
        expect(fromStringConstructor.new).toHaveBeenCalledWith("hamburg","")

    describe 'with ride objects', ->
      fromRideObjectConstructor = {}

      beforeEach ->
        spyOn(fromRideObjectConstructor = ride_factory.constructors.FromRideObject, 'new')

      it 'should call FromRideObject constructor when called  with the location objects', ->
        ride = {orig:{title:"hamburg"},dest:{title:"berlin"}}
        Ride.new(ride)
        expect(fromRideObjectConstructor.new).toHaveBeenCalledWith(ride)

      it 'should call RideFromRideObjectBuilder with only orig', ->
        ride = {orig:{title:"hamburg"}}
        Ride.new(ride)
        expect(fromRideObjectConstructor.new).toHaveBeenCalledWith(ride)

      it 'should call RideFromRideObjectBuilder with only dest', ->
        ride = {dest:{title:"berlin"}}
        Ride.new(ride)
        expect(fromRideObjectConstructor.new).toHaveBeenCalledWith(ride)
