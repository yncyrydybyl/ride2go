Ride = require '../ride'
assert = require 'assert'

exports['create empty ride'] = () ->
  assert.eql new Ride, new Ride({})

exports['creating a ride from string'] = () ->
  r = new Ride("hamburg->leipzig")

  r2 = new Ride
  r2.orig = "hamburg" 
  r2.dest = "leipzig"
  assert.eql r2,r
