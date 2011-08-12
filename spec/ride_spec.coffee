Ride = require '../ride'
describe "Ride", ->
  it "should be create without parameters", ->
      r = new Ride "hamburg->leipzig"
      r2 = new Ride
      r2.orig = "hamburg"
      r2.dest = "leipzig"
      expect(r).toEqual(r2)
