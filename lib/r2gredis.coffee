
client = keymap =  undefined
redis = require "redis"

module.exports = {
  client: (db = 0) ->
    client = redis.createClient() unless client
    if process.env.NODE_ENV == "test"
      client.select 15
    return client
  # keymap consists of primary key
  keymap: ->
    keymap = redis.createClient() unless client
    return keymap
  kill: ->
    client.quit()
    keymap.quit()

}
