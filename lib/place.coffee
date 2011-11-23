__ = require "../vendor/underscore"
redis = require("r2gredis").keymap()
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
      log.debug("city not found")
      return undefined

Place.find = (egal, callback) ->
  if __.isString(egal)
    log.debug "find parameter is a string"
    @findByKeyPattern egal, callback

  else if __.isObject(egal)
    log.debug "find parameter is an object"
    if egal.city and egal.country
      @findByKeyPattern "#{egal.country}:*:#{egal.city}", callback

    else if egal.address_components
      @fromGoogleGeocoder egal, callback

Place.findByName = (name,subkey,callback) ->
  redis.exists (key = subkey+":"+name), (err, exists) =>
    if exists == 1
      callback(@new(key))
    else
      log.debug "#{name} is no primary key trying alternatives"
      redis.smembers "geoname:alt:"+name, (err, alts) =>
        alts = (a for a in alts when a.indexOf(subkey) == 0)
        log.debug "the alterbatives are: #{alts}"
        if alts.length == 1
          callback(@new(alts[0]))
        else
          # TODO more determination of the place by coords or zip code
          callback undefined

Place.findByKeyPattern = (pattern,callback) ->
  redis.keys pattern, (err, keys) =>
    if keys.length == 0
      log.debug "no key found for "+pattern
      callback undefined
    else if keys.length == 1
      log.debug "exacly 1 key"
      redis.exists keys[0], (err, exists) =>
        if exists == 1
          callback(@new(keys[0]))
        else
          callback undefined

    else if keys.length >= 1
      log.debug "more than one key"
      @chooseByStrategy(keys,callback)

Place.chooseByStrategy = (keys,callback, strategy = "population") ->
  if strategy == "population"
    log.debug "population strategy"
    redis.multi(["HGET", k, "population"] for k in keys).exec (err, results) =>
      i = 0
      idx = 0
      max = 0
      for p in results
        p = p*1
        if p > max
          max = p
          idx = i
        i += 1
        log.debug "max: "+max+" "+keys[idx]
      @find(keys[idx],callback)

#Place.findByCityAndCountry city, country, callback
#  fromString "#{country}:*:#{city}"

# builderFromGeoObject
Place.fromGoogleGeocoder = (obj, callback) ->
  log.debug "using from Place.fromGoogleGeocoder"
  gcountry = gstate = gcity = {}
  stateterm = "administrative_area_level_1"
  cityterm = "locality"

  for component in obj.address_components
    gcountry = component.short_name if __.include(component.types, "country")
    gcity = component.long_name if __.include(component.types, cityterm)
    gstate = component.long_name if __.include(component.types, stateterm)
  Country.find (gcountry), (country) ->
    country.states.find gstate, (state) ->
      state.cities.find gcity, (city) ->
        callback city

class Country extends Place
  findState: (name, callback) ->
    State.findByName name, @key, callback
  findCity: (name, callback) ->
    City.findByKeyPattern @key+":*:"+name, callback

class State extends Place
  findCity: (name, callback) ->
    City.findByName name, @key, callback

class City extends Place


Place.new = (key)-> new Place(key)
Country.new = (key)-> new Country(key)
State.new = (key)-> new State(key)
City.new = (key)-> new City(key)

module.exports.Country = Country
module.exports.Place = Place
module.exports.State = State
module.exports.City = City
