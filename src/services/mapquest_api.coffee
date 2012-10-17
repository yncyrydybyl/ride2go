qs      = require 'querystring'
request = require 'request'
config  = require '../../lib/config'
log     = require '../../lib/logging'

class MapquestApi

  constructor: (@apikey) ->
    @

  reverseGeocode: (lat, lon, limit, cb) ->
    host   = 'www.mapquestapi.com'
    path   = 'geocoding/v1/address'
    params = qs.stringify {
      lat: lat,
      lng: lon,
      maxResults: limit,
      outFormat: 'json'
    }
    url     = "http://#{host}/#{path}?key=#{@apikey}&#{params}"
    log.debug url
    request url, (err, resp, body) =>
      if !err && resp.statusCode == 200
        try
          body = JSON.parse body
          cb body
        catch error
          cb undefined
      else
        cb undefined

module.exports         = MapquestApi
module.exports.default = new MapquestApi(config.apikeys.mapquest)

