# Copyright (c) 2011 Flo Detig <orangeman@teleportr.org> All rights reserved.
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

api  = require('./connectors')  # knows how to talk with different services #
io = require('node.io')  # spin off the workers to search all web for rides #


class RiDeStore extends require('events').EventEmitter # pubsub style msges #

  scraping: off # only local RiDeStore is queried if scraping is switched OFF

  redis: require('redis').createClient() # memory Ride Data structure Store #

  ## RDMS: Ride Data Matcher Scheduler is the core API of the RideDataStore #
  ## RiDeMatcher iS quite similar to Relational Database Management Systems #
  ## searches for rides that match a query
  ## returns matching rides asynchronously
  match: (query, callback) ->

    route = "#{query.orig}->#{query.dest}" # hash-key to identify the route #

    # register for any future rides on that route that might be found later #
    @on route, callback  # notify active browsers or other interested party #

    # return cached rides available in ReDiS RiDeStore
    @redis.hvals route, (err, rides) -> callback rides

    # schedule jobs to go get find some matching RiDeS
    for search in [api.mitfahrzentrale, api.raummobil]
      io.start search, query, ((shouldNotFail, rides) =>
        for ride in (new Ride(r) for r in rides) # store the RiDeS to cache #
          @redis.hset route, ride.link, ride.json(), (shouldNotFail, isNew) =>
            @emit route, [ride.json()] if isNew # ie. fiRst time DiScovered #
      ), true if @scraping is on # ToDo schedule some more smarter strategy #


module.exports = RDS ||= new RiDeStore # singleton
Ride = require './ride' # convenience
RDS = NaN # the instance
