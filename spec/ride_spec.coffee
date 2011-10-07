Ride = require('ride').Ride
Place = require('place').Place

describe "\nClass 'Ride':", ->

  describe "'constructor'", ->

    # we use lightweight objects
    # we have:
    #     orig and dest as strings of the primary place keys
    #     arr and dep as number of the unix time stamp
    # various convenience methods provide objects of Place and Date
     
    it "should accept Place key strings", ->
      r = new Ride(orig:"DE:RP:Mainz", dest:"DE:Berlin:Berlin")
      expect(r.origin().constructor).toBe(Place)
      expect(r.orig).toBe("DE:RP:Mainz")
      expect(r.origin().city()).toBe("Mainz")

    it "should accept Place objects", ->
      r = new Ride(
        orig: new Place("DE:RP:Mainz"),
        dest: new Place("DE:Berlin:Berlin"))
      expect(r.origin().constructor).toBe(Place)
      expect(r.origin().city()).toBe("Mainz")
 
    it  "should accept timestamps", ->
      r = new Ride(
        orig:"DE:RP:Mainz", dest: "DE:Berlin:Berlin"
        dep: 959143320000, arr: 959157720000
      expect(r.departure()).toEqual(new Date(959143320000))
      expect(r.arrival()).toEqual(new Date(959157720000))

   
    it  "should accept date objects", ->
      r = new Ride(
        orig: new Place("DE:RP:Mainz"), dest: new Place("DE:Berlin:Berlin")
        dep: new Date(959143320000), arr: new Date(959157720000)
      expect(r.dep).toEqual(new Date(959143320000))
      expect(r.arr).toEqual(new Date(959157720000))

    it "should tolerate various terminology", ->
      r1 = new Ride(source:"DE:RP:Mainz", ziel:"DE:Berlin:Berlin")
      r2 = new Ride(from:"DE:RP:Mainz", to:"DE:Berlin:Berlin")
      r3 = new Ride(origin:"DE:RP:Mainz", target:"DE:Berlin:Berlin")
      expect(r1).toEqual(r2)
      expect(r2).toEqual(r3)

  describe 'methods', ->

    it "origin should have convienence accessors", ->
      r = new Ride(orig:"DE:RP:Mainz", dest:"DE:Berlin:Berlin")
      expect(r.source()).toEqual(r.origin())
      expect(r.start()).toEqual(r.origin())
      expect(r.from()).toEqual(r.origin())
      expect(r.origin()).toEqual(new Place(r.orig))
    it "destination should have convienence accessors", ->
      r = new Ride(orig:"DE:RP:Mainz", dest:"DE:Berlin:Berlin")
      expect(r.to()).toEqual(r.destination())
      expect(r.target()).toEqual(r.destination())
      expect(r.ziel()).toEqual(r.destination())
      expect(r.destination()).toEqual(new Place(r.dest))
      
  describe "json method", ->
    it "should serialise to a proper json string", ->
      r = new Ride(orig:"DE:RP:Mainz", dest:"DE:Berlin:Berlin")
      json = r.toJson()
      json_template = ""
      expect(r.toJson()).toBe('{"orig":"DE:RP:Mainz","dest":"DE:Berlin:Berlin"}')

  describe "details", ->
      r = new Ride
        orig: "DE:RP:Mainz"
        dest: "DE:Berlin:Berlin"
        provider: "deinbus.de"
        mode: "bus"
        id: "/checkout/cart/add/product/2100"
        price: 14
        currency: "€" # default is bitcoin
      expect(r.link()).toBe("http://www.deinbus.de/checkout/cart/add/product/2100")
      expect(r.image()).toBe("http://ride2go.com/images/provider/deinbus.de.png")
      expect(r.displayPrice()).toBe("14,00 €")
      expect(r.mode).toBe("bus")
      expect(r.toGo).toBe("ready to go :-)")

  xdescribe "expiration logic ... part of RDS?", ->

    xit "TODO: should serialise to a dycapo json string"
 
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

