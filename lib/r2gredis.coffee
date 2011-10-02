
module.exports = {
  client: (db = 0) ->
    redis = require "redis"
    r = redis.createClient()
    if process.env.NODE_ENV == "test"
      r.select 15
      r.on "idle", ->
        r.quit()
    return r
}
