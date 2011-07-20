nodeio = require 'node.io'

class Dummy extends nodeio.JobClass
  input: false
  run: ->
      @emit [{
        provider:                      "duMmyrider",
        origin:                 {cityname:"berlin"},
        destination:           {cityname:"hamburg"},
        link:           "https://dummy.com/ride/42",
        price:          {amount:23, currency:"btc"},
        time:  { departure:  new Date('02/01/2011 05:20'), flexibility: "5h", duration: "4h"},
        mode : { vehicle: "citroen 2cv", type: "car", capacity: {people:2, storage: {amount: 0.3, unit: "m³"}}}
        } ]

module.exports.dummy = new Dummy
