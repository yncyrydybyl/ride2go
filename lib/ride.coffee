__ = require "../vendor/underscore"

class Ride
  # create
  constructor: (orig, dest) ->
    @orig = orig
    @dest = dest
  toString: -> this.orig+"---->"+this.dest

# generic factory
Ride.new = (egal) ->
  if __.isString(egal)
    Ride.fromString egal
  if __.isObject(egal) and egal.dest and egal.orig
    console.log("object")
    Ride.fromObject egal 

# builderFromString
Ride.fromString = (string) ->
  new Ride(string.split("->"))
# builderFromSimpleObject
Ride.fromString = (obj) ->
  new Ride(obj.orig.title,obj.dest.title)

#console.log Ride.prototype
#console.log (new Ride()).toString()
console.log Ride.new("irgend->was").toString()
console.log Ride.new({orig:{title:"hamburg"},dest:{title:"berlin"}}).toString()

#console.log Ride.fromString("bar").__proto__
#console.log(new Ride("fooo").toString())
