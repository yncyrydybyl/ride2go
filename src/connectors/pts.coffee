redis   = require 'redis'
nodeio  = require 'node.io'
request = require 'request'
log     = require '../logging'

Ride    = require '../ride'
Place   = require('../place').Place

module.exports.details = details =
  mode: "train" # kind of vehicle
  name: "pts" # uniq primary key, should be a domain name
  country: "DE" # upper case two letter short code
  source: "http://public-transport-enabler.googlecode.com"
  author: ["andy"]
  icon: "pts.png"
  update_freq: "10" # in minutes, currently unused
  expires: ""
  # defaults
  price: "0" # as string, e.g. "EUR 10"
  seats: "1" # free seats
  driver: "" # name of driver (real person steering the vehicle, if known)
  tel: ""
  # specifics
  url_host: "localhost"
  url_port: 8082
  url_path: "public-transport-service-1.0-SNAPSHOT"
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
    ride     = Ride.new(@options)
    # cf the Import class below on how to import destinations into
    # the data store (redis)
    ride.origin().foreignKeyOrCity "#{details.name}:orig", (orig) =>
      console.log("dsai")
      # TODO escape this
      orig_path = "#{details.url_path}/location/suggest?q=#{orig}"
      orig_url  = "http://#{details.url_host}:#{details.url_port}/#{orig_path}"
      log.notice orig_url
      request orig_url, (err, req, body) =>
        if (err || req.statusCode != 200)
          log.error "DOOF orig: #{err} #{req}"
          return
        log.notice "call http"
        stations = JSON.parse(body)
        orig_id  = stations[0].id
        log.notice orig_id
        ride.destination().foreignKeyOrCity "#{details.name}:dest", (dest) =>
          dest_path = "#{details.url_path}/location/suggest?q=#{dest}"
          dest_url  = "http://#{details.url_host}:#{details.url_port}/#{dest_path}"
          log.notice dest_url
          request dest_url, (err, req, body) =>
            if (err || req.statusCode != 200)
              log.error "DOOF dest: #{err} #{req}"
              return false
            log.notice "call http"
            stations   = JSON.parse(body)
            dest_id    = stations[0].id
            log.notice dest_id
            fin_url = "http://#{details.url_host}:#{details.url_port}/#{details.url_path}/connection?fromId=#{orig_id}&toId=#{dest_id}&fromType=STATION&toType=STATION&num=1"
            log.notice fin_url
            run [fin_url]
#        run ["http://.../?"+"fromn=#{orig}&"+"to=#{dest}"]

  run: (url) ->
    rides = []
    log.notice url
    orig = Place.new(@options.orig).city()
    dest = Place.new(@options.dest).city()
    log.notice "orig: #{orig} dest: #{dest}"

    request url, (err, req, body) =>
      if (err || req.statusCode != 200)
        log.error "DOOF conn: #{err} #{req}"
        return false
      routes = JSON.parse(body)

      log.notice body

      for route in routes.connections
        dep_date = route.firstTripDepartureTime
        arr_date = route.lastTripArrivalTime
        rides.push
          dep: dep_date
          arr: arr_date
          price: "EUR 10"
          orig: orig       # you may want to replace this
          dest: dest       # with better matches from your query result
          provider: "#{details.name}"

      log.notice ">>>>> #{JSON.stringify(rides)}"
      @emit rides
