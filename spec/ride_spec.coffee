Ride = require('ride')
Place = require('place').Place
City = require('place').City

describe "\nClass 'Ride':", ->

  describe "'constructor'", ->
    # we use lightweight objects
    # we have:
    #     orig and dest as strings of the primary place keys
    #     arr and dep as number of the unix time stamp
    # various convenience methods provide objects of Place and Date
     
    it "should accept Place key strings", ->
      r = Ride.new(orig:"DE:RP:Mainz")
      expect(r.origin().constructor).toBe(Place)
      expect(r.orig).toBe("DE:RP:Mainz")

      expect(r.origin().city()).toBe("Mainz")

    it "should accept different Place objects", ->
      r = Ride.new
        orig: new Place("DE:RP:Mainz"),
        dest: new City("DE:Berlin:Berlin")
      expect(r.origin().constructor).toBe(Place)
      expect(r.origin().city()).toBe("Mainz")
      expect(r.dest).toBe("DE:Berlin:Berlin")
 
    it  "should accept timestamps", ->
      r = Ride.new
        orig:"DE:RP:Mainz", dest: "DE:Berlin:Berlin"
        dep: 959143320000, arr: 959157720000
      expect(r.departure()).toEqual(new Date(959143320000))
      expect(r.arrival()).toEqual(new Date(959157720000))

    it  "should accept date objects", ->
      r = Ride.new
        orig: new Place("DE:RP:Mainz"), dest: new Place("DE:Berlin:Berlin")
        dep: new Date(959143320000), arr: new Date(959157720000)
      expect(r.dep).toEqual(959143320000)
      expect(r.arr).toEqual(959157720000)

    it "should tolerate various terminology", ->
      r1 = Ride.new(source:"DE:RP:Mainz", ziel:"DE:Berlin:Berlin")
      r2 = Ride.new(from:"DE:RP:Mainz", to:"DE:Berlin:Berlin")
      r3 = Ride.new(origin:"DE:RP:Mainz", target:"DE:Berlin:Berlin")
      expect(r1).toEqual(r2)
      expect(r2).toEqual(r3)

  describe 'methods', ->

    it "origin should have convienence accessors", ->
      r = Ride.new(orig:"DE:RP:Mainz", dest:"DE:Berlin:Berlin")
      expect(r.source().key).toEqual(r.origin().key)
      expect(r.start().key).toEqual(r.origin().key)
      expect(r.from().key).toEqual(r.origin().key)
    it "destination should have convienence accessors", ->
      r = Ride.new(orig:"DE:RP:Mainz", dest:"DE:Berlin:Berlin")
      expect(r.to().key).toEqual(r.destination().key)
      expect(r.target().key).toEqual(r.destination().key)
      expect(r.ziel().key).toEqual(r.destination().key)
      
  describe "json method", ->
    it "should serialise to a proper json string", ->
      r = Ride.new(orig:"DE:RP:Mainz", dest:"DE:Berlin:Berlin", dep: 959143320000, arr: 959157720000)
      json = r.toJson()
      json_template = ""
      expect(r.toJson()).toBe('{"dest":"DE:Berlin:Berlin","orig":"DE:RP:Mainz","arr":959157720000,"dep":959143320000}')

  describe "details", ->
    it "get and return details about a ride", ->
      r = Ride.new
        orig: "DE:RP:Mainz"
        dest: "DE:Berlin:Berlin"
        provider: "deinbus.de"
        mode: "bus"
        id: "http://www.deinbus.de/checkout/cart/add/product/2100"
        price: 14
        currency: "€" # default is bitcoin
      expect(r.link()).toBe("http://www.deinbus.de/checkout/cart/add/product/2100")
      expect(r.image()).toBe("http://ride2go.com/images/providers/deinbus.de.png")
      expect(r.displayPrice()).toBe("14.00 €")
      expect(r.mode).toBe("bus")
      expect(r.toGo).toBe("ready to go :-)")
#
#  xdescribe "expiration logic ... part of RDS?", ->
#
#    xit "TODO: should serialise to a dycapo json string"
# 
#  describe 'constructor switcher', ->
#    fromStringConstructor = {}
#    beforeEach ->
#      spyOn(fromStringConstructor = ride_factory.constructors.FromString, 'new')
#
#    it "should call the FromString constructor when called with a string", ->
#      Ride.new("hamburg->berlin")
#      expect(fromStringConstructor.new).toHaveBeenCalledWith("hamburg","berlin")
#
#    it "should call the FromString constructor when called with empty origin", ->
#      Ride.new("->berlin")
#      expect(fromStringConstructor.new).toHaveBeenCalledWith("","berlin")
#
#    it "should call the FromString constructor when called with empty destination", ->
#      Ride.new("hamburg->")
#      expect(fromStringConstructor.new).toHaveBeenCalledWith("hamburg","")
#
