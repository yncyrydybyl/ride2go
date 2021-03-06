redis  = require('redis').createClient()
nodeio = require 'node.io'
Ride   = require '../ride'
log    = require '../logging'
Place  = require('../place').Place
moment = require 'moment'
moment.lang 'de'

module.exports.enabled = true
module.exports.details = details =
  mode: "bus"
  name: "deinbus.de" # uniq primary key
  source: "http://deinbus.de"
  author: ["flo","t"]
  icon: "logo_deinbus.de.png"
  update_frequenz: "10" # in minutes
  expires: ""
  #defaults
  price: "0"
  seats: "1" # free seats
  driver: ""
  telefon: ""
  #specifics
  prefix: "mitfahrzentrale:id"

timeFormat = 'dddd, D. MMM YYYY hh:mm'

regexx = ///
        Ab\s(\w{2},\s\d{2}\.\d{2}\.\d{4})
        \s(\d{2}:\d{2}\s)Uhr\n
        An\s(\w{2},\s\d{2}\.\d{2}\.\d{4})
        \s(\d{2}:\d{2}\s)Uhr
        (?:Preis:)?(\d+,\d+\s€)
        (?:Sonderpreis:(\d+,\d+\s€))?
        ///

regex = ///
        Ab:\s(.+)Uhr\n    # Ab: Sonntag, 16. Okt 2011 15:30 Uhr
        An:\s(.+)Uhr      # An: Freitag, 14. Okt 2011 22:30 Uhr
        (?:.*Preis:)?(\d+,\d+\s€)         # ReguläPreis:15,50 €
        (?:Sonderpreis:(\d+,\d+\s€))?     # Sonderpreis:14,00 €
        ///

module.exports.findRides = new nodeio.Job
  input: (i, j, run) ->
    return false unless i == 0 # only run once
    ride = Ride.new(@options)
    ride.origin().foreignKeyOrCity "deinbus:orig", (orig) =>
      ride.destination().foreignKeyOrCity "deinbus:dest", (dest) =>
        run ["http://www.deinbus.de/fs/result/?"+
          "bus_von=#{orig}&"+
          "bus_nach=#{dest}&"+
          "passengers=1"]
  run: (url) ->
    rides = []
    log.notice url
    dest_key = @options.dest
    dest     = Place.new(dest_key)
    orig_key = @options.orig
    orig     = Place.new(orig_key)
    log.debug "orig: #{orig} dest: #{dest}"
    @getHtml url, (err, $, data) =>
      try
        $('#product-serach-list tbody tr').odd (tr) ->
          if (r = tr.fulltext.match regex)
            moment.lang 'de'
            dep = moment(r[1], timeFormat).unix()
            arr = moment(r[2], timeFormat).unix()
            rides.push
              dep: dep
              arr: arr
              price: r[3]
              sp_price: r[4]
              orig: orig
              dest: dest
              provider: details.name
              id: "#{module.exports.details.mode}:#{orig_key}@#{dep}->#{dest_key}@#{arr}"
          else
            log.error "Regex did NOT match! "+tr.fulltext
        i = 0
        $('#product-serach-list tbody tr').even (tr) ->
          rides[i].link = $('div.divbuchungsbtn a', tr).attribs.href
          i += 1
      @emit rides
  
  reduce: (rides) ->
    log.notice "deinbus found "+rides.length+" rides"
    @emit rides


module.exports.ingestRides = (rides) ->
  new nodeio.Job
    input: false
    run: ->
      @emit rides

# import city ids into redis

idMap = "http://api.scraperwiki.com/api/1.0/datastore/sqlite?format=jsondict&name=deinbusde_city-ids&query=select%20*%20from%20swdata"
redis = require("redis").createClient()

class Import extends nodeio.JobClass
  input: (a,b,run) ->
    return false if a != 0  # only once
    log.notice "importing deinbus city ids"
    @get idMap, (err, idMap) ->
      for city in JSON.parse(idMap)
        #log.notice city.name+"---->"+city.id+"  type "+city.type
        run [city]

  run: (city) ->
    # we could refactor this as Place.deinbustemporarynotaname(city, country) if we need it in more places
    foreign_key = "deinbus:#{city.type}:#{city.id}"
    redis.keys "DE:*:#{city.name}", (err, keys) =>
      if keys.length == 1
        redis.sadd foreign_key, keys[0]
        redis.hset keys[0], "deinbus:#{city.type}", city.id, (err, succ) =>
          log.debug " + stored #{city.name} automatically"
          @emit()
      else if keys.length > 1 # get by highest population of primary keys
        redis.multi(["HGET", k, "population"] for k in keys).exec (err, results) =>
          i = 0
          idx = 0
          max = 0
          for p in results
            if p > max
              max = p
              idx = i
            i += 1
          key = keys[idx]
          redis.sadd foreign_key, key
          redis.hset key, "deinbus:#{city.type}", city.id, (err, succ) =>
            log.debug " + stored #{city.name} because it has the highest population"
            @emit()
      else
        # ToDo: try to match alternative names
        #redis.smembers "geoname:alt:#{city.name}", (err, keys)
        log.notice "could not map "+city.name+": "+keys
        @skip()
    null
        

@class = Import
@job = new Import()


