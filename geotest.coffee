gm = require("googlemaps")
sys = require("sys")
util = require('util')
Place = require('./lib/place')

__ = require './vendor/underscore'
gm.geocode "viktorstif 13 mainz", (err, data) ->
  identiti = []
  for type in data.results[0].address_components
    identiti.push type.short_name
  identiti = __.uniq identiti.reverse()
  #console.log(util.inspect(identiti.join(":"),true,9))
  console.log(util.inspect(data,true,9))
  #console.log(util.inspect(Place))
  #p = Place.new(data)
  #console.log(p.fooString())
  #console.log(p.idString())
  #console.log(data)

