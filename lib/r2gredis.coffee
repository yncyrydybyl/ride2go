
client = undefined

module.exports = {
  kill: ->
    client.quit()
  client: (db = 0) ->
    redis = require "redis"
    client = redis.createClient() unless client
    if process.env.NODE_ENV == "test"
      client.select 15
    return client
}
