__ = require "../vendor/underscore"
redis = require("redis").createClient()

Place = ->
Place.prototype =

  toJson: ->
    JSON.stringify @
  
  country: -> @key.substring(0,2)

  city: -> @key.match(/^\w{2}:[^:]*:([^:]*).*/)[1]
  
  redislookupcountry: ->
    # existiert @country im redis
  redislookupaal1: ->
    # existiert @country:aal1 im redis

    
#class Place
#  fooString: -> @orig+"---->"+@dest
#  longstring: ->
    
# generic factory
Place.new = (egal, callback) ->
  if __.isString(egal)
    Place.fromString egal, callback
  else if __.isObject(egal)
    if egal.geoobject
      Place.fromGoogleGeocoder egal.geoobject, callback
    if egal.results[0].address_components
      Place.fromGoogleGeocoder egal.results[0], callback

# builderFromString
Place.fromString = (string, callback) ->
  p = new Place()
  redis.exists string, (err, exists) ->
    if exists == 1
      p.key = string
      callback(p)

# builderFromGeoObject
Place.fromGoogleGeocoder = (obj, callback) ->
  p = new Place
  if obj.address_components
    for component in obj.address_components
   #   console.log(component)
      for type in ['country', 'street_number', 'route', 'postal_code','locality']
        if __.include(component.types, type)
          p[type] = component.short_name
      if __.include(component.types, 'political')
        p.political or= {} 
        p.political[component.types[0]]=component.short_name
  else
    console.log("no address objects")
  #new Place(obj.orig.title,obj.dest.title)
  #obj.__proto__ = Place.prototype
  #obj
  return p

module.exports = Place

#a=new Place()
#sys = require "sys"
#console.log (sys.inspect(a.fooString())) #console.log Place.new("irgend->was").toString()
#console.log Place.new({orig:{title:"hamburg"},dest:{title:"berlin"}}).toString()

#console.log Place.fromString("bar").fooString()
#console.log(new Place("fooo").toString())
