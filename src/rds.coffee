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
api  = require './connectors/' # knows how to talk with different service apis
log  = require './logging' # logs nice to a console for seeing whats going on


class RiDeStore extends require('events').EventEmitter # pubsub style msges #

  scraping: on # only local RiDeStore is queried if scraping is switched OFF
  get_connector: (name) ->  JSON.stringify api[name.details]
  redis: require('redis').createClient() # memory Ride Data structure Store #

  ## RDMS: Ride Data Matcher Scheduler is the core API of the RideDataStore #
  ## RiDeMatcher iS quite similar to Relational Database Management Systems #
  ## searches for rides that match a query
  ## returns matching rides asynchronously
  match: (query, callback) ->
    
    RDS.find query, callback
    for connector in ['pts']
      RDS.search api[connector], query


  ## subscribe to a channel
  find: (query, callback) ->
    
    route = "#{query.orig}->#{query.dest}" # hash-key to identify the route #
    
    # register for any future rides on that route that might be found later #
    @on route, callback  # notify active browsers or other interested party #

    # return cached rides available in ReDiS RiDeStore
    @redis.hvals route, (err, rides) ->
      log.debug "RDS has " + rides.length + " rides already in cache"
      callback ride for ride in rides


  ## publish to a channel
  store: (ride, callback) ->
     
    route = "#{ride.orig}->#{ride.dest}" # hash-key to identify the route #
    log.debug "storing ride: " + route
    @redis.hset route, ride.link(), ride.toJson(), (anothererror, isNew) =>
      log.error anothererror if anothererror
      @emit route, ride.toJson() if isNew # ie. fiRst time DiScovered #
      callback?()


  ## start node.io job to run connector to fetch and store rides
  search: (query, connector, done) ->
    log.debug "connecting " + connector.name
    query = Ride.new query
    io.start (new io.Job
      input: (i, j, go) ->
        return false unless i == 0
        go [ connector.make_url query ]
      run: (url) ->
        log.debug "reading " + url
        @getHtml url, (err, $, data) =>
          try
            connector.read_html $
            @emit null
          catch error
            log.info error
            @fail()
        connector.found = (what, thing) =>
          switch what
            when 'ride' then RDS.store(Ride.new(thing))
            when 'url' then @add thing.replace /&amp;/g, '&'
        null
    ), query, ((e,r) -> done()), true


RDS = new RiDeStore
module.exports = RDS
Ride = require './ride'
