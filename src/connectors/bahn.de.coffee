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
          log.error "bahn.de: failed sending request: #{err} #{req}"
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
              log.error "bahn.de: failed sending request: #{err} #{req}"
              return false
            stations   = JSON.parse(body)
            dest_id    = stations[0].id
            #log.notice dest_id
            if orig_id != dest_id
              fin_url = "http://#{details.url_host}:#{details.url_port}/#{details.url_path}/connection?fromId=#{orig_id}&toId=#{dest_id}&fromType=STATION&toType=STATION&num=9"
              log.debug fin_url
              run [fin_url]
            else
              log.notice "bahn.de: skipped searching self-loop ride for #{orig_id}"
#        run ["http://.../?"+"fromn=#{orig}&"+"to=#{dest}"]

  run: (url) ->
    rides = []
    dest_key = @options.dest
    dest     = Place.new(dest_key)
    orig_key = @options.orig
    orig     = Place.new(orig_key)

    @get url, (err, body) =>
      log.error "bahn.de: failed retrieving connections: #{err}" if err
      
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
          #        link     = "http://reiseauskunft.bahn.de/bin/query2.exe/dn?#{params}"
          link = "http://reiseauskunft.bahn.de/bin/query.exe/dn?REQ0JourneyDate=#{dep_date.format('DDMMYY')}&REQ0JourneyTime=#{dep_date.format('HH')}%3A#{dep_date.format('mm')}&REQ0HafasSearchForw=1&REQ1JourneyDate=&REQ1JourneyTime=&REQ1HafasSearchForw=1&REQ0JourneyStopsSA=1&REQ0JourneyStopsSG=#{orig.cityName()}&REQ0JourneyStopsZA=1&REQ0JourneyStopsZG=#{dest.cityName()}&REQ0JourneyStops1A=1&REQ0JourneyStops1G=&REQ0JourneyStopover1=&REQ0JourneyStops2A=1&REQ0JourneyStops2G=&REQ0JourneyStopover2=&existReverseVias=yes&REQ0JourneyRevia=on&REQ0JourneyProduct_prod_section_0_list=1%3A11111111110000&REQ0JourneyProduct_opt_section_0_list=0%3A0000&REQ0JourneyProduct_prod_section_1_list=1%3A11111111110000&REQ0JourneyProduct_opt_section_1_list=0%3A0000&REQ0JourneyProduct_prod_section_2_list=1%3A11111111110000&REQ0JourneyProduct_opt_section_2_list=0%3A0000&existProductAutoReturn=yes&REQ0JourneyDep__enable=Foot&REQ0JourneyDest__enable=Foot&REQ0HafasChangeTime=0&REQ0Tariff_Class=2&REQ0Tariff_TravellerType.1=E&REQ0Tariff_TravellerReductionClass.1=0&REQ0Tariff_TravellerAge.1=&REQ0Tariff_TravellerType.2=NULL&REQ0Tariff_TravellerReductionClass.2=0&REQ0Tariff_TravellerAge.2=&REQ0Tariff_TravellerType.3=NULL&REQ0Tariff_TravellerReductionClass.3=0&REQ0Tariff_TravellerAge.3=&REQ0Tariff_TravellerType.4=NULL&REQ0Tariff_TravellerReductionClass.4=0&REQ0Tariff_TravellerAge.4=&REQ0Tariff_TravellerType.5=NULL&REQ0Tariff_TravellerReductionClass.5=0&REQ0Tariff_TravellerAge.5=&REQ0HafasOptimize1=1%3A2&existOptimizePrice=yes&start=+los+geht%27s+"
          rides.push
            dep: dep_date.unix()
            arr: arr_date.unix()
            price: ''
            orig: orig       # you may want to replace this
            dest: dest       # with better matches from your query result
            provider: "#{details.name}"
            link: link
            id: "#{module.exports.details.mode}:#{orig_key}@#{dep_date}->#{dest_key}@#{arr_date}"

      for ride in rides
        log.notice "bahn.de: emitting: #{Ride.showcase(ride)}"
      @emit rides
