nodeio = require 'node.io'
redis = require('redis').createClient()

module.exports = new nodeio.Job
  input: '/tmp/DE.txt',
  run: (row) ->
    data = @parseValues(row,'\t')
    place = {}
    place.id = data[0]
    place.name = data[1]
    place.lon = data[4]
    place.lat = data[5]
    place.featurecode = data[7]
    place.state_id = data[10]
    place.population = data[14]
    place.country_iso = data[8]
    if place.featurecode.match /PPL.*/
      redis.sadd "places:"+place.country_iso+":stateid="+place.state_id+":"+place.name, "geonames:id"+place.id+"geonames:latlon:"+place.lat+" "+place.lon
    @exit
  output: false
