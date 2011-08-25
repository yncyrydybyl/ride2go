redis = require('redis').createClient()
csv = require "csv"

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
  
  importCountry: (filename) ->
    csv().fromPath filename,
      delimiter: "\t"
      escape: ""
    .transform (data) ->
        if data[7] == "ADM1"
          return data
        else
          return null
    .on "data", (data, index) ->
      console.log ("#" + data[1])
    .on "end", (count) ->
      console.log "Number of lines: " + count
    .on "error", (error) ->
      console.log error.message
