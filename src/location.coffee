__       = require 'underscore'
log      = require('./logging')
resolver = require './services/place_resolver'
City     = require('./place').City
Place    = require('./place').Place

# Helper class for the server that encapsulates key
# resolving and reverse geocoding
#
class Location
  constructor: (anObj = undefined) ->
    @obj      = anObj
    @typ      = Location.objType anObj
    @resolved = false

  putIntoLocals: (locals, keyName, latName, lonName) ->
    locals[keyName] = @obj.key if @obj
    if @obj.lat && @obj.lon
      locals[latName] = @obj.lat
      locals[lonName] = @obj.lon

  is: (typ) ->
    @typ == typ

  resolve: (geocoder, revGeocoder, cb) ->
    resolveCb = (city) =>
      @obj      = city
      @resolved = true
      cb()

    if @resolved
      cb()
    else
      switch @typ
        when 'city'
          resolver.fromObject(@obj).resolve resolveCb
          return
        when 'place'
          resolver.fromObject(@obj).resolve resolveCb
          return
        when 'key'
          resolver.fromObject(City.new(@obj)).resolve resolveCb
          return
        when 'pos'
          if revGeocoder
            revGeocoder.reverseGeocode @obj, (omqObj) ->
              resolver.fromObject(omqObj).resolve resolveCb
            return
        when 'obj'
          if geocoder
            geocoder.geocode @obj, (omqObj) ->
              resolver.fromObject(omqObj).resolve resolveCb
            return
        when 'str'
          log.notice "Could not handle string in resolver: #{@obj}"

      # upcall with undefined if we fall through the switch
      resolveCb undefined

Location.new = (obj) ->
  new Location obj

Location.objType = (obj) ->
    # This must match Location.choose
    if obj
      if __.isString(obj)
        idx = obj.indexOf ':'
        return 'key' if idx >= 0 && idx <= 3
        return 'str'
      else
        return 'city' if obj instanceof City
        return 'pos' if obj.lat && obj.lon
        return 'place' if obj instanceof Place
        return 'obj'
    else
      undefined


Location.choose = (locs) ->
  # TODO sort array instead with proper comparator
  return undefined if locs.length == 0
  for l in locs
    return l if l.is('city')
  for l in locs
    return l if l.is('key')
  for l in locs
    return l if l.is('place')
  for l in locs
    return l if l.is('pos')
  return l[0]

module.exports.Location = Location
