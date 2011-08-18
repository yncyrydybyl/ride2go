__ = require "../vendor/underscore"

#Ride = ->

#Ride.prototype = 
#  fooString: -> this.orig+"---->"+this.dest

class Ride
  fooString: -> @orig+"---->"+@dest

# generic factory
Ride.new = (egal) ->
  if __.isString(egal)
    return Ride.fromString egal
  if __.isObject(egal) and egal.dest and egal.orig
    console.log("object")
    Ride.fromVerifiedObject egal

# builderFromString
Ride.fromString = (string) ->
  r = new Ride()
  r.orig = "foo"
  r.dest = "bar"
  r

# builderFromVerifiedObject
Ride.fromVerifiedObject = (obj) ->
  #new Ride(obj.orig.title,obj.dest.title)
  obj.__proto__ = Ride.prototype
  obj


a=new Ride()
sys = require "sys"
console.log (sys.inspect(a.fooString())) #console.log Ride.new("irgend->was").toString()
#console.log Ride.new({orig:{title:"hamburg"},dest:{title:"berlin"}}).toString()

console.log Ride.fromString("bar").fooString()
#console.log(new Ride("fooo").toString())
