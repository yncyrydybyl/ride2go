
module.exports = {
  client: (db = 0) ->
    redis = require "redis"
    r = redis.createClient()
    return r
}
