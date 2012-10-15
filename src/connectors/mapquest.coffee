nodeio = require 'node.io'
log    = require '../logging'
qs     = require 'querystring'

buildApiUrl = (query) ->
  params = qs.stringify { from: query.orig, to: query.dest }
  "http://open.mapquestapi.com/directions/v0/route?outFormat=json&unit=k&narrativeType=none&shapeFormat=cmp&#{params}"

module.exports.enabled   = true
module.exports.findRides = new nodeio.Job
  input: false

  run: () ->
    self  = this
    rides = []
    url   = buildApiUrl @options
    log.notice url
    @get url, (err, data) =>
      if data
        data  = JSON.parse data
        route = if data then data.route else null
        if route
          route.url = url
          rides.push route
      @emit rides


