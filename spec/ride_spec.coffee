Ride = require('ride').Ride
Place = require('place').Place

describe "\nClass 'Ride':", ->

  describe "'constructor'", ->

    it "should accept Place key strings", ->
      r = new Ride(orig:"DE:RP:Mainz", dest:"DE:Berlin:Berlin")
      expect(r.origin().constructor).toBe(Place)
      expect(r.origin().source()).toBe("Mainz")

    it "should accept Place objects", ->
      r = new Ride(
        orig: new Place("DE:RP:Mainz"),
        dest: new Place("DE:Berlin:Berlin"))
      expect(r.origin().constructor).toBe(Place)
      expect(r.origin().city()).toBe("Mainz")
    it  "should work with time of arrival", ->
      r

  describe 'constructor switcher', ->
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

