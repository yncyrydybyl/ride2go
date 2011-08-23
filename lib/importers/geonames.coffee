redis = require('redis').createClient()

module.exports =

  storeCountry: (line) ->
    
  storeAdminDivision: (line) ->

  storePopulatedPlace: (line) ->

    data = line.split("\t")
    id = data[0]
    name = data[1]
    lon = data[4]
    lat = data[5]
    featurecode = data[7]
    state_id = data[10]
    population = data[14]
    country_iso = data[8]
    #if place.featurecode.match /PPL.*/


