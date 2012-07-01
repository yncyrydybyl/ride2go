__ = NaN
redis = NaN
Ride = require('../lib/ride')
Place = require('../lib/place').Place
City = require('../lib/place').City

describe "Ride", ->

  beforeEach -> redis = require('redis').createClient()


  describe "Constructor", ->
  # we use lightweight objects
  # we have:
  #     orig and dest as strings of the primary place keys
  #     arr and dep as number of the unix time stamp
  # various convenience methods provide objects of Place and Date

    it "should accept Place key strings", ->
      r = Ride.new
        orig:"DE:RP:Mainz"
        dest:"DE:Berlin:Berlin"
      expect(r.origin()).instanceOf(Place)
      expect(r.orig).to.equal("DE:RP:Mainz")
      expect(r.origin().city()).to.equal("Mainz")
      expect(r.destination()).instanceOf(Place)
      expect(r.dest).to.equal("DE:Berlin:Berlin")
      expect(r.destination().city()).to.equal("Berlin")

    it "should accept Place objects", ->
      r = Ride.new
        orig: new Place("DE:RP:Mainz"),
        dest: new City("DE:Berlin:Berlin")
      expect(r.origin()).instanceOf(Place)
      expect(r.origin().city()).to.equal("Mainz")
      expect(r.dest).to.equal("DE:Berlin:Berlin")
 
    it  "should accept timestamps", ->
      r = Ride.new
        orig:"DE:RP:Mainz", dest: "DE:Berlin:Berlin"
        dep: 959143320000, arr: 959157720000
      expect(r.departure()).to.eql(new Date(959143320000))
      expect(r.arrival()).to.eql(new Date(959157720000))

    it  "should accept date objects", ->
      r = Ride.new
        orig: new Place("DE:RP:Mainz"), dest: new Place("DE:Berlin:Berlin")
        dep: new Date(959143320000), arr: new Date(959157720000)
      expect(r.dep).to.equal(959143320000)
      expect(r.arr).to.equal(959157720000)

    it "should tolerate various terminology", ->
      r1 = Ride.new(source:"DE:RP:Mainz", dep: 959143320000, ziel:"DE:Berlin:Berlin", arr: 959157720000)
      r2 = Ride.new(from:"DE:RP:Mainz", dep: 959143320000, to:"DE:Berlin:Berlin", arr: 959157720000)
      r3 = Ride.new(origin:"DE:RP:Mainz", dep: 959143320000, target:"DE:Berlin:Berlin", arr: 959157720000)
      expect(r1).to.eql(r2)
      expect(r2).to.eql(r3)

  describe 'Methods', ->

    it "origin should have convienence accessors", ->
      r = Ride.new(orig:"DE:RP:Mainz", dest:"DE:Berlin:Berlin")
      expect(r.source().key).to.equal(r.origin().key)
      expect(r.start().key).to.equal(r.origin().key)
      expect(r.from().key).to.equal(r.origin().key)
    it "destination should have convienence accessors", ->
      r = Ride.new(orig:"DE:RP:Mainz", dest:"DE:Berlin:Berlin")
      expect(r.to().key).to.equal(r.destination().key)
      expect(r.target().key).to.equal(r.destination().key)
      expect(r.ziel().key).to.equal(r.destination().key)
      
    it "should serialise to a proper json string", ->
      r = Ride.new(orig:"DE:RP:Mainz", dest:"DE:Berlin:Berlin", dep: 959143320000, arr: 959157720000)
      json = r.toJson()
      json_template = ""
      expect(r.toJson()).to.equal('{"dest":"DE:Berlin:Berlin","orig":"DE:RP:Mainz","arr":959157720000,"dep":959143320000}')

    it "should return details about a ride", ->
      r = Ride.new
        orig: "DE:RP:Mainz"
        dest: "DE:Berlin:Berlin"
        provider: "deinbus.de"
        mode: "bus"
        id: "http://www.deinbus.de/checkout/cart/add/product/2100"
        price: 14
        currency: "€" # default is bitcoin
      expect(r.link()).to.equal("http://www.deinbus.de/checkout/cart/add/product/2100")
      expect(r.image()).to.equal("http://ride2go.com/images/providers/deinbus.de.png")
      expect(r.displayPrice()).to.equal("14.00 €")
      expect(r.mode).to.equal("bus")
      expect(r.toGo).to.equal("ready to go :-)")

  
    it "should pts dingens..", ->
      r = Ride.new {dep:1341165060000, arr:1341200220000, price:"EUR 10", orig:"Ulm", dest:"Bremen", provider:"pts"}
      expect(r.toJson).not.to.equal '{"arr":1341161521057,"dep":1341161521057}'

  afterEach -> redis.quit()


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
