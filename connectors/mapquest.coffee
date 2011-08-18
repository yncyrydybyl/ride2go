nodeio = require 'node.io'
log = require '../lib/logging'

url = (query) -> "http://open.mapquestapi.com/directions/v0/route?
outFormat=json&unit=k&narrativeType=none&shapeFormat=cmp&
from=#{query.orig}&
to=#{query.dest}"

module.exports = nodeio.Job
  input: false
  run: ->
    rides = []
    log.notice url(@options)
    @get url(@options), (err, data) =>
      log.debug data
      log.debug require('util').inspect(JSON.parse(data).route)
      @emit rides

