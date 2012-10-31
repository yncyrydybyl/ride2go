redis  = require('redis').createClient()
nodeio = require 'node.io'
Ride   = require '../ride'
log    = require '../logging'
Place  = require('../place').Place
moment = require 'moment'
moment.lang 'de'

module.exports.enabled   = true
module.exports.details = details =
  mode: "bus"
  ingesting: true
  name: "bus_ingestor" # uniq primary key
  source: "http://en.wikipedia.org/wiki/Internet"
  author: ["boggle"]
  icon: "logo_deinbus.de.png"
  update_frequenz: "10" # in minutes
  expires: ""
  #defaults
  price: "0"
  seats: "1" # free seats
  driver: ""
  telefon: ""

module.exports.ingestRides = (rides) ->
  new nodeio.Job
    input: false
    run: ->
      @emit rides
