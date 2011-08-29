redis = require('../../lib/r2gredis').client()
csv = require "csv"
__ = require "../../vendor/underscore"

module.exports =
  storeCountry: (line) ->

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
  waiter: ->
    setTimeout((-> 
      console.log("jdsak")
      return false
    ),4000)
      
  importData: (filename, importfunction,callback) ->
    csv().fromPath filename,
      delimiter: "\t"
      escape: ""
    .transform (data) ->
      importfunction data
    .on "data", (data, index) ->
      importfunction data
    .on "end", (count) ->
      console.log "Number of lines: " + count
      callback(count)
      return true
    .on "error", (error) ->
      console.log error.message
  storeCountryAndAdminDivision: (countrycode = "DE",callback = ->) ->
    importfunction = (data) ->
      doo = "DE"+":"+data[1]
      #console.log(doo)
      redis.set doo, "foo"
    return @importData("./spec/fixtures/admin1CodesASCII.txt", importfunction, callback)
