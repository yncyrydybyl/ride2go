redis  = require('redis')
nodeio = require 'node.io'
log    = require 'logging'

Ride   = require 'ride'
Place  = require('place').Place

module.exports.details = details =
  mode: "car" # kind of vehicle
  name: "starcar.de" # uniq primary key, should be a domain name
  country: "DE" # upper case two letter short code
  source: "http://www.starcar.de/kostenlos_mieten.php"
  author: ["boggle"]
  icon: "starcar.de.png"
  update_freq: "500" # in minutes, currently unused
  expires: ""
  # defaults
  price: "0" # as string, e.g. "EUR 10"
  seats: "1" # free seats
  driver: "" # name of driver (real person steering the vehicle, if known)
  tel: ""
  # specifics
  match_strategy: "population" # used for matching places
  tz: "" # timezone of all times returns by connector (unimplemented)

module.exports.findRides = new nodeio.Job
  # Construct service url
  #
  # Should return false unless i == 0
  #
  # Needs to finish by calling run with the constructed url
  #
  input: (i, j, run) ->
    return false unless i == 0 # only run once
    run [details.source]

  run: (url) ->
    rides = []
    log.notice url
    # orig = Place.new(@options.orig).city()
    # dest = Place.new(@options.dest).city()
    # log.notice "orig: #{orig} dest: #{dest}"

    @getHtml url, (err, $) =>
      $('div.kostenlos_uebersicht_item_content').each (div) ->
        route = $('div.kostenlos_uebersicht_item_link a', div).text
        route = route.split('-')
        times = $('div.kostenlos_uebersicht_item_extra a', div).text
        times = times.replace("-","").split('.')
        link  = $('div.kostenlos_uebersicht_item_extra a', div).attribs.href
        link  = link.split('=')[1]
        rides.push
          dep_window_start: times[0]+"."+times[1]+"."
          dep_window_end: times[2]+"."+times[3]+"."
          id: link
          price: "EUR 0"
          orig: route[0].trim()    # you may want to replace this
          dest: route[1].trim()    # with better matches from your query result
          provider: "#{details.name}"

      @emit rides


# import city ids into redis
class Import extends nodeio.JobClass
  input: (a,b,run) ->
    return false if a != 0  # only once
    log.notice "importing #{details.name} city ids"
    url = "" # should return json with service city definitions
    @get url, (err, url) ->
      for city in JSON.parse(url)
        # cf dummy-city.json for format
        @run [city]

  run: (city) ->
    # FIXME check that client is disposed after use
    store = redis.createClient()

    # FIXME turn into compact DSL of lookup strategies or
    # hide behind subclass hierarchy and strategy pattern
    foreign_key = "#{details.name}:#{city.type}:#{city.id}"
    store.keys "#{details.country}:*:#{city.name}", (err, keys) =>
      Place.chooseByStrategy keys, "#{details.match_strategy}", (place) =>
        store.sadd foreign_key, place.key, (err, result) =>
          store.hset place.key, "#{details.name}:#{city.type}", city.id, (err, succ) =>
            log.debug " + stored #{city.name} automatically"
            @emit()

# these imports allow to run this connector under node.io from the cmd line
@class = Import
@job = new Import()


