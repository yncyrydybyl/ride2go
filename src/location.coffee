__       = require 'underscore'
log      = require('./logging')
resolver = require './services/place_resolver'

# Helper class for the server that encapsulates key
# resolving and reverse geocoding
#
class Location
  constructor: (obj, lat, lon, placemark_str = undefined) ->
    @resolved = false
    @obj      = obj if obj
    @lat      = lat if lat
    @lon      = lon if lon
    if placemark_str && (placemark = JSON.parse(placemark_str))
      @lat = placemark.Latitude if !@lat
      @lon = placemark.Longitude if !@lon
    if @obj || (@lat && @lon) then @ else undefined

  putIntoLocals: (locals, keyName, latName, lonName) ->
    locals[keyName] = @obj.key if @obj
    locals[latName] = @lat if @lat
    locals[lonName] = @lon if @lon

  resolve: (revGeocoder, cb) ->
    resolveCb = (city) =>
      @obj      = city
      @resolved = true
      cb()

    if @resolved
      cb()
    else
      if @obj
        resolver.fromObject(@obj).resolve resolveCb
      else
        revGeocoder.reverseGeocode @lat, @lon, (omqObj) ->
          resolver.fromObject(omqObj).resolve resolveCb

Location.new = (key, lat, lon, placemark_str = undefined) ->
  new Location key, lat, lon, placemark_str

module.exports.Location = Location
