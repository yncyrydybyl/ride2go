log = require("../lib/logging")
#log.transports.console.level = "debug"

geoname_place = "geonames:place"

cityExits =(city, redis = require("redis").createClient()) ->
  log.debug "desterming for city existence"
  redis.keys "*:"+city, (err, keys) ->
    if keys.length = 1
      redis.type keys[0], (err, type) ->
        console.log("foo",keys)
        if type = "set"
          # just one key exits and it is a set
          redis.sismember keys[0],geoname_place, (err, reply) ->
            if reply==1
              log.debug "looks good"
            else
              log.debug "looks shit"
    else if keys.length > 1
      console.log("foo")
      #something shitty

alternativeName = (city, redis = require("redis").createClient()) ->
  "doo"

module.exports = {cityExits,alternativeName}
