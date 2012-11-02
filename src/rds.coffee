# Copyright (c) 2011 ride2go contributors -- ride2go.com All rights reserved.
#                                                              AGPL licenced.

# # # # # # # # # # # # # # # #    RDS    # # # # # # # # # # # # # # # # # #
#                            ____  ____  ____                               #
#                           |  _ \|  _ \/ ___|                              #
#                           | |_) | | | \___ \                              #
#                           |  _ <| |_| |___) |                             #
#                           |_| \_\____/|____/                              #
#                                                                           #
# ReDiS Relational DatabaSe  Route Data Structure  RiDe ScrapeR coDe Store! #
# This is the central Ride Data Store where everything is cached & matched. #
# i.e. software transactional memory to sychonize distributed shared state. #
#                                                                           #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

io   = require 'node.io' # spin off workers for searching the web for rides
log  = require './logging' # logs nice to a console for seeing whats going on
mom  = require 'moment'

City  = require('./place').City
Place = require('./place').Place

class RiDeStore extends require('events').EventEmitter # pubsub style msges #

  constructor: () ->
    @api = require './connectors/'  # knows how to talk with different service apis
    @

  scraping: on # only local RiDeStore is queried if scraping is switched OFF

  get_connector: (name) ->
    @api.connectors[name]

  get_connector_details: (name) ->
    if connector = @get_connector(name)
      JSON.stringify
        name: name
        details: connector.details
        enabled: if connector.enabled then true else false
    else
      undefined

  redis: require('redis').createClient() # memory Ride Data structure Store #

  ## RDMS: Ride Data Matcher Scheduler is the core API of the RideDataStore #
  ## RiDeMatcher iS quite similar to Relational Database Management Systems #
  ## searches for rides that match a query
  ## returns matching rides asynchronously
  match: (query, callback) ->
    log.notice "RDS.scraping is OFF" unless @scraping
    log.notice "RDS: received query ride #{JSON.stringify(query)}"

    route = "#{query.orig}->#{query.dest}" # hash-key to identify the route #
    log.notice "route = #{route}"
    @redis.sadd "query:"+route, "time:"+new Date
    # register for any future rides on that route that might be found later #
    @on route, callback  # notify active browsers or other interested party #

    # return cached rides available in ReDiS RiDeStore
    @redis.hvals route, (err, rides) =>
      log.info "RDS has " + rides.length + " rides already in cache"
      for ride in rides
        log.debug "found cached ride: #{Ride.showcase(ride)}"
        @emit route, ride

    # schedule jobs to run and find even more matching RiDeS
    for job in @api.scraping_connectors()
      log.info "RDS starts connector for " + job
      io.start @api.connectors[job].findRides, query, ((someerror, rides) =>
        log.error someerror if someerror
        i = 0
        log.notice "RDS received "+ Ride.showcase(rides[0])
        for ride in (Ride.new(r) for r in rides) # store the RiDeS to cache #
          val = ride.toJson()
          log.debug "scraped ride: "+ Ride.showcase(val)
          @redis.hset route, ride.id, val, (anothererror, isNew) =>
            log.error anothererror if anothererror
            if isNew
              log.notice "discovered new ride: " + Ride.showcase(val)
              @emit route, Ride.new(rides[i]).toJson()  # ie. fiRst time DiScovered #
            i += 1
      ), true if @scraping # ToDo schedule some more smarter strategy #

  ingest: (name, conn, rides, cb) ->
    log.info "RDS ingesting rides for #{name}"
    io.start conn.ingestRides(rides), {}, ((err, rides) =>
      if err
        log.error err
      else
        i    = 0
        ret  = []
        done = (ride = undefined) =>
          i += 1
          ret.push ride if ride
          cb err, ret if i == rides.length
        for r in rides
          ride = null

          if r instanceof Ride
            ride       = r
          else
            r.provider = name if !r.provider
            r.orig     = City.new(r.orig) if r.orig && (!r.orig instanceof Place)
            r.rest     = City.new(r.dest) if r.dest && (!r.dest instanceof Place)
            r.orig     = City.new(r.orig_key) if !r.orig && r.orig_key
            r.dest     = City.new(r.dest_key) if !r.dest && r.dest_key
            r.dep      = mom().unix() if !r.dep
            r.arr      = mom().unix() if !r.arr
            r.price    = '' if !r.price

            if r.provider == name && r.orig && r.dest
              r.orig     = r.orig.key
              r.dest     = r.dest.key
              delete r.orig_key
              delete r.dest_key
              r.id       = "#{conn.details.mode}:#{r.orig}@#{r.dep}->#{r.dest}@#{r.arr}" if !r.id
              ride       = Ride.new(r)

          if ride
            route = "#{ride.orig}->#{ride.dest}"
            log.debug "ingesting new #{route} ride: #{Ride.showcase(ride)}"
            @redis.hset route, ride.id, ride.toJson(), (anothererror, isNew) =>
              log.error anothererror if anothererror
              if isNew
                log.notice "discovered new ride: #{Ride.showcase(ride)}"
              done(ride)
          else
            log.info "skipping ride: #{Ride.showcase(r)}"
            done()
      ), true

Ride           = require './ride' # convenience
RDS            = new RiDeStore    # the single one instance
module.exports = RDS
