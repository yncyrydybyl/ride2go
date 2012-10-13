__    = require "../vendor/underscore"
log   = require("./logging")

class Place

  constructor: (@props = {}) ->
    @

  update: (update) ->
    result = {}
    for k, v of @props
      result[k] = v if v != undefined
    for k, v of update
      if v == undefined then delete result[k] else result[k] = v

    new Place(result)

  updateCallback: (callback) ->
    self = @
    (batch) ->
      callback self.update(batch)

  toJSON: ->
    JSON.stringify @props

  userText: ->
    @props.user_text

  textKey: ->
    user_text = @userText()
    orig_key  = @props.gs_orig_key
    if orig_key && orig_key.indexOf('*') < 0
      orig_key
    else
      user_text

  addressComponents: ->
    @props.addr_components

  country: ->
    @props.gs_country || log.debug('country not found')

  state: ->
    @props.gs_state || log.debug('state not found')

  city: ->
    @props.gs_city || log.debug('city not found')

  hasCountry: ->
    if @props.gs_country then true else false

  hasState: ->
    if @props.gs_state then true else false

  hasCity: ->
    if @props.gs_city then true else false

  isCountry: ->
    @hasCountry()

  isState: ->
    @hasCountry() && @hasState()

  isCity: ->
    @hasCountry() && @hasState() && @hasCity()

  asCountry: ->
    @update({ gs_state: undefined, gs_city: undefined })

  asState: ->
    @update({ gs_city: undefined })

Place.fromGeoIpObj = (geo_ip_obj) ->
  new Place({addr_components: geo_ip_obj.address_components})


class GeoStore

  constructor: (@redis) ->
    @

  placeToCountryKey: (place) ->
    throw new Error("Not a country") if !place.isCountry()
    place.props.gs_country

  placeToCityPattern: (place, gs_city) ->
    throw new Error("Not a country") if !place.isCountry()
    "#{place.props.gs_country}:*:#{gs_city}"

  placeToStateKey: (place) ->
    throw new Error("Not a state") if !place.isState()
    gs_country = place.props.gs_country
    gs_state   = place.props.gs_state
    "#{gs_country}:#{gs_state}"

  placeToCityKey: (place, missing = '') ->
    gs_country = place.props.gs_country || missing
    gs_state   = place.props.gs_state || missing
    gs_city    = place.props.gs_city || missing
    "#{gs_country}:#{gs_state}:#{gs_city}"

  keyToPlaceProps: (key, target = {}) ->
    result = key.split ':'
    len    = result.length
    if len > 0
      target.user_text   = key if len == 1
      target.gs_orig_key = key
      target.gs_country  = result[0] if result[0] != '*'
      target.gs_state    = result[1] if len > 1 && result[1].length > 0 && result[1] != '*'
      target.gs_city     = result[2] if len > 2 && result[2].length > 0 && result[2] != '*'
    target

  placePropsCallback: (callback) ->
    self = @
    (key) ->
      callback self.keyToPlaceProps(key)

  keyToPlace: (key) ->
    new Place keyToProps(key)

  keyWithoutFirstEncodingError: (key) ->
    i = key.indexOf '�'
    if i >= 0
      "#{key.substr(0, i)}*#{key.substr(i+1, key.length)}"
    else
      null

  findByKey: (key_prefix, name, strategy, callback) ->
    key = "#{key_prefix}:#{name}"
    @redis.exists key, (err, exists) =>
      if exists == 1
        log.debug "#{key} is a primary key."
        callback key
      else
        log.debug "#{key} is NO primary key."
        if newKey = keyWithoutFirstEncodingError(key)
          log.debug "#{key} contains enc�ding �rrors; trying #{newKey}"
          @redis.keys newKey, (err, matches) =>
            if matches.length == 1
              log.debug "found #{matches[0]}"
              callback matches[0]
            else
              if matches.length > 1
                log.debug "found more primary keys matching #{newKey}"
                strategy matches, callback
              else
                log.debug "no matches found for #{newKey}"
                callback undefined
        else
          log.debug "trying alternatives"
          @redis.smembers "geoname:alt:#{name}", (err, alts) =>
            alts = (a for a in alts when a.indexOf(subkey) == 0)
            if alts.length == 1
              log.debug "found geoname:alt:#{name} mapping to #{alts[0]}"
              callback alts[0]
            else 
              if alts.length > 1
                log.debug "found more primary keys for geoname:alt:#{name}"
                # TODO more determination of the place by coords or zip code
                log.debug "NOT handled yet: #{alts}"
                callback undefined
              else # alts.length == 0
                log.debug "no alternative name for geoname:alt:#{name}"
                callback undefined

  findByKeyPattern: (pattern, strategy, callback) =>
    log.debug "trying key pattern #{pattern}"
    @redis.keys pattern, (err, keys) =>
      if keys.length == 0
        log.debug "..no key"
        callback undefined
      else
        if keys.length == 1
          log.debug "..exactly 1 key"
          @redis.exists keys[0], (err, exists) =>
            callback (if exists == 1 then keys[0] else undefined)
        else
          log.debug "more than one key"
          strategy keys, callback

  chooseByPopulation: (keys, callback) ->
    log.debug "population strategy"
    @redis.multi(["HGET", k, "population"] for k in keys).exec (err, results) =>
      i   = 0
      idx = 0
      max = 0
      for p in results
        p = p*1
        if p > max
          max = p
          idx = i
        i += 1
      callback keys[idx]

  foreignKeyOrCity: (key, namespace_prefix, city_name, done) ->
    @redis.hget key, namespace_prefix, (err, foreign_key) =>
      if foreign_key == null
        log.debug "no #{namespace_prefix} foreign key for #{key}"
        done city_name
      else
        log.debug "found #{foreign_key} foreign key for #{key}"
        done foreign_key


class ForeignKeyResolver
  constructor: (@geoStore, @namespace_prefix) ->
    @

  resolve: (place, callback) ->
    @geoStore.foreignKeyOrCity @geoStore.placeToCityKey(place), @namespace_prefix, place.city(), callback


class CountryStateResolver
  constructor: (@geoStore, @name) ->
    @

  resolve: (place, callback) ->
    placeCallback = @geoStore.placePropsCallback(place.updateCallback(callback))
    @geoStore.findByName @geoStore.placeToCountryKey(place), @name, placeCallback


class CountryCityResolver
  constructor: (@geoStore, @name) ->
    @

  resolve: (place, callback) ->
    placeCallback = @geoStore.placePropsCallback(place.updateCallback(callback))
    @geoStore.findByKeyPattern @geoStore.placeToCityPattern(place, @name), placeCallback


class StateCityResolver
  constructor: (@geoStore, @name) ->
    @

  resolve: (place, callback) ->
    placeCallback = @geoStore.placePropsCallback(place.updateCallback(callback))
    @geoStore.findByName @geoStore.placeToStateKey(place), @name, placeCallback


class DefaultResolver
  constructor: (@geoStore, @strategy = null) ->
    @strategy = @geoStore.chooseByPopulation if !@strategy
    @

  resolve: (place, placeCallback) ->
    keyCallback = @geoStore.placePropsCallback(place.updateCallback(placeCallback))
    textKey     = place.textKey()
    if textKey
      @geoStore.findByKeyPattern textKey, @strategy, keyCallback
    else
      if place.hasCity() && place.hasCountry()
        @geoStore.findByKeyPattern @geoStore.placeToCityPattern(place, place.city()), @strategy, keyCallback
      else
        if place.addressComponents()
          new GoogleGeocoder().resolve(place, placeCallback)


class GoogleGeocoder
  constructor: (@geoStore) ->
    @

  resolve: (place, callback) ->
    log.debug "using from Place.fromGoogleGeocoder"
    gcountry = gstate = gcity = {}
    stateterm = "administrative_area_level_1"
    cityterm = "locality"

    for component in place.addressComponents()
      gcountry = component.short_name if __.include(component.types, "country")
      gcity = component.long_name if __.include(component.types, cityterm)
      gstate = component.long_name if __.include(component.types, stateterm)

    Country.find (gcountry), (country) ->
      log.debug "found country #{country.key}"
      country.states.find gstate, (state) ->
        log.debug "found state #{state.key}"
        state.cities.find gcity, (city) ->
          log.debug "found city #{city.key}"
          callback city

module.exports = {
  Place: Place
  GeoStore: GeoStore
  DefaultResolver: DefaultResolver
  ForeignKeyResolver: ForeignKeyResolver
  GoogleGeocoder: GoogleGeocoder
  CountryStateResolver: CountryStateResolver
  CountryCityResolver: CountryCityResolver
  StateCityResolver: StateCityResolver
}