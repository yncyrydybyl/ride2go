Ride = require '../ride'
RideFactory = require '../lib/ridefactory'
factory = new RideFactory
beforeEach ->


describe "Ride", ->
  it "should created with query string as parameter", ->
    r = new Ride "hamburg->leipzig"
    r2 = new Ride
    r2.orig = "hamburg"
    r2.dest = "leipzig"
    expect(r).toEqual(r2)
  xit "should be created without parameters", ->

describe "ridefactory", ->
  it "should call the RideFromQueryBuilder with its argument", ->
    factory.createRide("hamburg->berlin")
    expect(RideFromQueryBuilder).toHaveBeenCalledWith("hamburg","berlin")
  xit "should call the RideFromQueryBuilder with its arguments", ->
    factory.createRide("hamburg->")
    expect(RideFromQueryBuilder).toHaveBeenCalledWith("","berlin")
  xit "should call the RideFromQueryBuilder with its arguments", ->
    factory.createRide("->berlin")
    expect(RideFromQueryBuilder).toHaveBeenCalledWxith("hamburg","")
  xit "should call the RideFromObjectBuilder with its arguments", ->
    ride = {orig:{txitle:"hamburg"},dest:{title:"berlin"}}
    factory.createRide(ride)
    expect(RideFromRideObjectBuilder).toHaveBeenCalledWxith(ride)
