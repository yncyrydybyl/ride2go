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

class RiDeStore extends require('events').EventEmitter # pubsub style msges #

  constructor: () ->
    @api = require './connectors/'  # knows how to talk with different service apis
    @

  scraping: on # only local RiDeStore is queried if scraping is switched OFF

  get_connector: (name) ->
    if connector = @api.connectors[name]
      JSON.stringify
        name: name
        details: connector.details
        enabled: connector.enabled
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
    for job in @api.enabled_connectors()
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


Ride               = require './ride' # convenience
RDS                = new RiDeStore # the single one instance
module.exports     = RDS
