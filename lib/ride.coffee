__ = require "../vendor/underscore"
log = require "logging"
Place = require("place").Place
log.transports.console.level="debug"

class Ride
  # convenience getters
  destination: -> new Place(@dest)
  origin: -> new Place @orig
  source: -> new Place @orig
  target: -> new Place @dest
  start: -> new Place @orig
  date: -> new Place @date
  from: -> new Place @orig
  ziel: -> new Place @dest
  to: -> new Place @dest
 
  toJson: -> JSON.stringify(@)
  departure: -> new Date(@dep)
  arrival: -> new Date(@arr)
 
  link: -> "http://www.#{@provider}/#{@id}"
  image: -> "http://ride2go.com/images/providers/#{@provider}.png"

  displayPrice: -> "#{@price.toFixed(2)} #{@currency}"

  toGo: "ready to go :-)"

# generic factory
Ride.new = (o) ->
  if __.isString o
    fromString o
  if __.isObject o
    r = new Ride()
    # normalize it (defensive copying)
    r.id   = o.link || o.url      || o.ref          || o.id

    r.dest = o.dest || o.to       || o.destination  || o.target || o.ziel
    r.orig = o.from || o.orig     || o.origin       || o.start || o.source
    r.arr  = o.arr  || o.arrival  || o.ankunft
    r.dep  = o.dep  || o.depature || o.abfahrt
     
    r.orig = r.orig.key if r.orig?.constructor == Place
    r.dest = r.dest.key if r.dest?.constructor == Place
    r.arr  = r.arr.getTime() if r.arr?.constructor == Date
    r.dep  = r.dep.getTime() if r.dep?.constructor == Date

    r.provider = o.provider if o.provider
    r.price = o.price if o.price
    r.currency = o.currency if o.currency
    r.mode = o.mode if o.mode
    return r


Ride.fromString = (string) ->
  r = new Ride()
  r.orig = "foo"
  r.dest = "bar"
  r


module.exports = Ride
