redis   = require 'redis'
nodeio  = require 'node.io'
request = require 'request'
log     = require '../logging'
qs      = require 'querystring'

Ride    = require '../ride'
Place   = require('../place').Place
moment  = require 'moment'

module.exports.enabled = true
module.exports.details = details =
  mode: "train" # kind of vehicle
  name: "bahn.de" # uniq primary key, should be a domain name
  country: "DE" # upper case two letter short code
  source: "http://public-transport-enabler.googlecode.com"
  author: ["andy", "boggle"]
  icon: "logo_bahn.de.png"
  update_freq: "10" # in minutes, currently unused
  expires: ""
  # defaults
  price: "0" # as string, e.g. "EUR 10"
  seats: "1" # free seats
  driver: "" # name of driver (real person steering the vehicle, if known)
  tel: ""
  # specifics
  url_host: "localhost"
  url_port: 8080
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
      # TODO escape this
      orig_path = "#{details.url_path}/location/suggest?q=#{orig}"
      orig_url  = "http://#{details.url_host}:#{details.url_port}/#{orig_path}"
      #log.notice orig_url
      request orig_url, (err, req, body) =>
        if (err || req.statusCode != 200)
          log.error "DOOF orig: #{err} #{req}"
          return
        stations = JSON.parse(body)
        orig_id  = stations[0].id 
        #log.notice orig_id
        ride.destination().foreignKeyOrCity "#{details.name}:dest", (dest) =>
          dest_path = "#{details.url_path}/location/suggest?q=#{dest}"
          dest_url  = "http://#{details.url_host}:#{details.url_port}/#{dest_path}"
          #log.notice dest_url
          request dest_url, (err, req, body) =>
            if (err || req.statusCode != 200)
              log.error "DOOF dest: #{err} #{req}"
              return false
            stations   = JSON.parse(body)
            dest_id    = stations[0].id
            #log.notice dest_id
            if orig_id != dest_id
              fin_url = "http://#{details.url_host}:#{details.url_port}/#{details.url_path}/connection?fromId=#{orig_id}&toId=#{dest_id}&fromType=STATION&toType=STATION&num=1"
              log.debug fin_url
              run [fin_url]
            else
              log.notice "skipped searching self-loop ride for #{orig_id}"
#        run ["http://.../?"+"fromn=#{orig}&"+"to=#{dest}"]

  run: (url) ->
    rides = []
    dest_key = @options.dest
    dest     = Place.new(dest_key)
    orig_key = @options.orig
    orig     = Place.new(orig_key)

    @get url, (err, body) =>
      log.error "DOOF conn: #{err}" if err
      
      routes = JSON.parse body

      if routes.connections
        for route in routes.connections
          dep_date = moment route.firstTripDepartureTime
          arr_date = moment route.lastTripArrivalTime

          params   = qs.stringify {
            country: 'DEU',
            f: 2,
            s: orig,
            o: 2,
            z: dest,
            d: dep_date.format 'DDMMYY'
            t: dep_date.format 'HHmm'
          }
          link     = "http://reiseauskunft.bahn.de/bin/query2.exe/dn?#{params}"

          rides.push
            dep: dep_date.unix()
            arr: arr_date.unix()
            price: ''
            orig: orig       # you may want to replace this
            dest: dest       # with better matches from your query result
            provider: "#{details.name}"
            link: link
            id: "#{module.exports.details.mode}:#{orig_key}@#{arr_date}->#{dest_key}@#{dep_date}"

      log.notice ">>>>> #{JSON.stringify(rides)}"
      @emit rides
