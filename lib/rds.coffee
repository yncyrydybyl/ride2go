# Copyright (c) 2011 ride2go contributors -- ride2go.com All rights reserved.
#                                                              AGPL Licenced.

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
api  = require 'connectors' # knows how to talk with different service apis
log  = require 'logging' # logs nice to a console for seeing whats going on


class RiDeStore extends require('events').EventEmitter # pubsub style msges #

  scraping: off # only local RiDeStore is queried if scraping is switched OFF

  redis: require('redis').createClient() # memory Ride Data structure Store #

  ## RDMS: Ride Data Matcher Scheduler is the core API of the RideDataStore #
  ## RiDeMatcher iS quite similar to Relational Database Management Systems #
  ## searches for rides that match a query
  ## returns matching rides asynchronously
  match: (query, callback) ->
    log.notice "RDS.scraping is off" unless @scraping

    route = "#{query.orig}->#{query.dest}" # hash-key to identify the route #
    @redis.sadd "query:"+route, "time:"+new Date
    # register for any future rides on that route that might be found later #
    @on route, callback  # notify active browsers or other interested party #

    # return cached rides available in ReDiS RiDeStore
    @redis.hvals route, (err, rides) ->
      log.info "RDS has " + rides.length + " rides already in cache"
      callback rides

    # schedule jobs to go get find some matching RiDeS
    for search in ['mitfahrzentrale', 'raummobil'] # ToDo
      log.info "RDS starts connector for " + search
      io.start api[search], query, ((someerror, rides) =>
        log.error someerror if someerror
        for ride in (Ride.new(r) for r in rides) # store the RiDeS to cache #
          @redis.hset route, ride.link, ride.json(), (anothererror, isNew) =>
            log.error anothererror if anothererror
            @emit route, [ride.json()] if isNew # ie. fiRst time DiScovered #
      ), true if @scraping # ToDo schedule some more smarter strategy #


module.exports = RDS ||= new RiDeStore # singleton
Ride = require 'ride' # convenience
RDS = NaN # the single one instance
