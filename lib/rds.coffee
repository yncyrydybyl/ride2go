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

  scraping: on # only local RiDeStore is queried if scraping is switched OFF
  get_connector: (name) ->  JSON.stringify api[name].details
  redis: require('redis').createClient() # memory Ride Data structure Store #

  ## RDMS: Ride Data Matcher Scheduler is the core API of the RideDataStore #
  ## RiDeMatcher iS quite similar to Relational Database Management Systems #
  ## searches for rides that match a query
  ## returns matching rides asynchronously
  match: (query, callback) ->
    log.notice "RDS.scraping is off" unless @scraping
    log.notice "RDS: received query ride #{JSON.stringify(query)}"

    route = "#{query.orig}->#{query.dest}" # hash-key to identify the route #
    log.notice "route = #{route}"
    @redis.sadd "query:"+route, "time:"+new Date
    # register for any future rides on that route that might be found later #
    @on route, callback  # notify active browsers or other interested party #

    # return cached rides available in ReDiS RiDeStore
    @redis.hvals route, (err, rides) ->
      log.info "RDS has " + rides.length + " rides already in cache"
      callback ride for ride in rides

    # schedule jobs to go get find some matching RiDeS
    for job in ['deinbus', 'mitfahrzentrale'] # ToDo
      log.info "RDS starts connector for " + job
      io.start api[job].findRides, query, ((someerror, rides) =>
        log.error someerror if someerror
        i = 0
        for ride in (Ride.new(r) for r in rides) # store the RiDeS to cache #
          console.log ride.link()
          @redis.hset route, ride.link(), ride.toJson(), (anothererror, isNew) =>
            log.error anothererror if anothererror
            @emit route, Ride.new(rides[i]).toJson() if isNew # ie. fiRst time DiScovered #
            i += 1
      ), true if @scraping # ToDo schedule some more smarter strategy #


module.exports = RDS ||= new RiDeStore # singleton
Ride = require 'ride' # convenience
RDS = NaN # the single one instance
