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

Place.find = (egal, callback) ->
  if __.isString(egal)
    log.debug "find parameter is a string"
    if egal.indexOf("DE:") == 0
      log.debug("starts with DE:")
      Place.findByPrimaryKey egal, callback
    else # it must be a name of some place
      Place.findByKeyPattern egal, callback

  else if __.isObject(egal)
    log.debug "find parameter is an object"
    if egal.city and egal.country
      Place.findByKeyPattern "#{egal.country}:*:#{egal.city}", callback

    else if egal.address_components
      Place.fromGoogleGeocoder egal, callback

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
  log.notice "using from Place.fromGoogleGeocoder"
  gcountry = gstate = gcity = undefined
  stateterm = "administrative_area_level_1"
  cityterm = "locality"

  for component in obj.address_components
    gcountry = component.short_name if __.include(component.types, "country")
    gcity = component.long_name if __.include(component.types, cityterm)
    gstate = component.short_name if __.include(component.types, stateterm)
  
  c = Country.find (gcountry), (country) ->
    country.states.find gstate, (state) ->
      state.cities.find gcity, (city) ->
        callback place
        console.log("ßßßßßßßßßßßßßß"+place)


  p = Place.find([country,state,city].join(":")], callback)

  console.log(country)
  console.log(city)


class Country extends Place
  findState: (name, callback) ->
    Place.findByKeyPattern @key+":"+name, callback
  findCity: (name, callback) ->
    Place.findByKeyPattern @key+":*:"+name, callback
  
  states:
    find: (name, callback) -> @key

class State extends Place
  findCity: (name, callback) ->
    Place.findByKeyPattern @key+":"+name, callback

class City extends Place

module.exports.Country = Country
module.exports.Place = Place
module.exports.State = State
module.exports.City = City
