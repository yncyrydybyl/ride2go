__ = require "../vendor/underscore"
redis = require("r2gredis").keymap()
#redis = require("redis").createClient()
log = require("logging")
log.transports.console.level="debug"

#Place = ->
#Place.prototype =
class Place
  
  constructor: (@key) -> # syntactig sugar to ignore
    (@states={}).find = (name, done) => @findState(name, done)
    (@cities={}).find = (name, done) => @findCity(name, done)

  toJson: ->
    JSON.stringify @
  
  country: -> @key.substring(0,2)

  city: ->
    if c = @key.match(/^\w{2}:[^:]*:([^:]*).*/)
      return c[1]
    else
      console.log("not found")
      return false
    

Place.pattern = ""

Place.find = (egal, callback) ->
  if __.isString(egal)
    log.debug "find parameter is a string"
    if egal.indexOf("DE:") == 0
      log.debug("starts with DE:")
      Place.findByPrimaryKey egal, callback
    else # it must be a name of some place
      Place.findByKeyPattern @pattern+egal, (place) ->

  else if __.isObject(egal)
    log.debug "find parameter is an object"
    if egal.geoobject
      Place.fromGoogleGeocoder egal.geoobject, callback
    if egal.city and egal.country
      Place.findByKeyPattern "#{egal.country}:*:#{egal.city}", callback

    if egal.results and egal.results[0].address_components
      Place.fromGoogleGeocoder egal.results[0], callback

Place.findByName = (name, callback) ->
  Place.findByKeyPattern @pattern+name, (place) ->
    if place
      callback place
    else
      Place.findByKeyPattern "geoname:alt:"+name, callback

# builderFromString
Place.findByPrimaryKey = (key, callback) ->
  p = new Place()
  redis.exists key, (err, exists) ->
    if exists == 1
      callback(new Place(key))
    else
      callback(false)

#Place.deinbusbottomuptemporaryname (keypattern, callback) ->
#  redis keypatter, callback

Place.findByKeyPattern = (pattern,callback) ->
  redis.keys pattern, (err, keys) ->
    #none
    if keys.length == 0
      log.debug "no key found for "+pattern
      callback false
    else if keys.length == 1
      log.debug "exacly 1 key"
      Place.findByPrimaryKey(keys[0], callback)
    else if keys.length >= 1
      log.debug "more than one key"
      Place.chooseByStrategy(keys,callback)

Place.chooseByStrategy = (keys,callback, strategy = "population") ->
  if strategy == "population"
    log.debug "population strategy"
    redis.multi(["HGET", k, "population"] for k in keys).exec (err, results) =>
      i = 0
      idx = 0
      max = 0
      for p in results
        console.log(keys[i] + "---  "+p)
        p = p*1
        console.log(keys[i] + "---  "+p)
        if p > max
          max = p
          idx = i
        i += 1
        console.log "max: "+max+" "+keys[idx]
      Place.find(keys[idx],callback)
  else if strategy == "icke"
    log.debug "icke strategy"
    log.debug "icke here we go"
    p = new Place()
    p.key = "DE:Berlin:Berlin"
    console.log(callback)
    callback(p)

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


class Country extends Place
  findState: (name, callback) ->
    Place.findByKeyPattern @key+":"+name, callback
  findCity: (name, callback) ->
    Place.findByKeyPattern @key+":*:"+name, callback
  
  states:
    find: (name, callback) -> @key

module.exports.Country = Country
module.exports.Place = Place
