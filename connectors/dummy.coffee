redis  = require('redis')
nodeio = require 'node.io'
log    = require 'logging'

Ride   = require 'ride'
Place  = require('place').Place

module.exports.details = details =
  mode: "bus" # kind of vehicle
  name: "your.domain" # uniq primary key, should be a domain name
  country: "DE" # upper case two letter short code
  source: "http://www.your.domain"
  author: ["you"]
  icon: "your.domain.png"
  update_freq: "10" # in minutes, currently unused
  expires: ""
  # defaults
  price: "0" # as string, e.g. "EUR 10"
  seats: "1" # free seats
  driver: "" # name of driver (real person steering the vehicle, if known)
  tel: ""
  # specifics
  match_strategy: "default" # used for matching places when importing city ids
  tz: ""     # timezone of all times returns by connector (unimplemented)

module.exports.findRides = new nodeio.Job
  # Construct service url
  #
  # Should return false unless i == 0
  #
  # Needs to finish by calling run with the constructed url
  #
  input: (i, j, run) ->
    return false unless i == 0 # only run once
    ride = Ride.new(@options)
    # cf the Import class below on how to import destinations into
    # the data store (redis)
    ride.origin().foreignKeyOrCity "#{details.name}:orig", (orig) =>
      ride.destination().foreignKeyOrCity "#{details.name}:dest", (dest) =>
        run ["http://.../?"+"fromn=#{orig}&"+"to=#{dest}"]

  run: (url) ->
    rides = []
    log.notice url
    orig = Place.new(@options.orig).city()
    dest = Place.new(@options.dest).city()
    log.notice "orig: #{orig} dest: #{dest}"

    @getHtml url, (err, $, data) =>

      # push example ride to result array
      rides.push
        dep_date: 0.0    # ms since epoch
        price: "EUR 10"
        orig: orig       # you may want to replace this
        dest: dest       # with better matches from your query result
        provider: "#{details.name}"

      @emit rides


# import city ids into redis

# FIXME check that client is disposed after use
#store = redis.createClient()
#
#class Import extends nodeio.JobClass
#  input: (a,b,run) ->
#    log.notice "importing #{details.name} city ids"
#    url = "" # should return json with service city definitions
#    @get url, (err, url) ->
#      for city in JSON.parse(url)
#        # cf dummy-city.json for format
#        run [city]
#
#  run: (city) ->
#    # FIXME turn into compact DSL of lookup strategies or
#    # hide behind subclass hierarchy and strategy pattern
#    foreign_key = "#{details.name}:#{city.type}:#{city.id}"
#    store.keys "#{details.country}:*:#{city.name}", (err, keys) =>
#      Place.chooseByStrategy(keys, "#{details.match_strategy}", (place) =>
#        store.sadd foreign_key, place.key
#        store.hset place.key, "#{details.name}:#{city.type}", city.id, (err, succ) =>
#          log.debug " + stored #{city.name} automatically"
#          @emit()
#
## these imports allow to run this connector under node.io from the cmd line
#@class = Import
#@job = new Import()
