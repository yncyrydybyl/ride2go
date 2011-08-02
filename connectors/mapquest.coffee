nodeio = require 'node.io'


url = (query) -> "http://open.mapquestapi.com/directions/v0/route?
outFormat=json&unit=k&narrativeType=none&shapeFormat=cmp&
from=#{query.orig}&
to=#{query.dest}"

module.exports = nodeio.Job
  input: false
  run: ->
    rides = []
    console.log url(@options)
    @get url(@options), (err, data) =>
      console.log data
      console.log require('util').inspect(JSON.parse(data).route)
      @emit rides

