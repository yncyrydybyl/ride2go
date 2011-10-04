__ = require "../vendor/underscore"
redis = require("r2gredis").client()
log = require("logging")

Place = ->
Place.prototype =

  toJson: ->
    JSON.stringify @
  
  country: -> @key.substring(0,2)

  city: ->
    if c = @key.match(/^\w{2}:[^:]*:([^:]*).*/)
      return c[1]
    else
      console.log("not found")
      return false
    
  
  redislookupcountry: ->
    # existiert @country im redis
  redislookupaal1: ->
    # existiert @country:aal1 im redis



    #  Place.find 42 #primary_key
    # Place.find :all, params
    #Place.find :first, params
    
#class Place
#  fooString: -> @orig+"---->"+@dest
#  longstring: ->
    
# generic factory
# this function determines which find method is used
Place.find = (egal, callback) ->
  if __.isString(egal)
    if egal.indexOf("DE:") == 0
      log.notice("starts with DE:")
      Place.findByPrimaryKey egal, callback

  else if __.isObject(egal)
    if egal.geoobject
      Place.fromGoogleGeocoder egal.geoobject, callback
    if egal.city and egal.country
      Place.findByKeyPattern "#{egal.country}:*:#{city}"

    if egal.results[0].address_components
      Place.fromGoogleGeocoder egal.results[0], callback


# builderFromString
Place.findByPrimaryKey = (key, callback) ->
  p = new Place()
  redis.exists key, (err, exists) ->
    if exists == 1
      p.key = key
      callback(p)
    else
      callback(false)

#Place.deinbusbottomuptemporaryname (keypattern, callback) ->
#  redis keypatter, callback

#Place.findByKeyPattern =

#Place.findByCityAndCountry city, country, callback
#  fromString "#{country}:*:#{city}"

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
