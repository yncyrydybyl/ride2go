__ = require "../vendor/underscore"
redis = require "redis"

Place = ->
Place.prototype =
  fooString: ->
    JSON.stringify @
  key: ->
    [@country,@route,@foo,@street_number].join(":")
  redislookupcountry: ->
    # existiert @country im redis
  redislookupaal1: ->
    # existiert @country:aal1 im redis
  city: ->
    # if @political["locality"] == geonames.CityExists?
    #   @political["locality"]
    # else 
    #   geonames.alternativeName
    null
    
#class Place
#  fooString: -> @orig+"---->"+@dest
#  longstring: ->
    
# generic factory
Place.new = (egal) ->
  if __.isString(egal)
    return Place.fromString egal
  else if __.isObject(egal) 
    if egal.geoobject
      Place.fromGoogleGeocoder egal.geoobject
    if egal.results[0].address_components
      return Place.fromGoogleGeocoder egal.results[0]

# builderFromString
Place.fromString = (string) ->
  r = new Place()
  r.orig = "foo"
  r.dest = "bar"
  r

# builderFromGeoObject
Place.fromGoogleGeocoder = (obj) ->
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
