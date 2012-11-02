__       = require 'underscore'
Ride     = require './server'
log      = require './logging'

class SocketCache
  constructor:  () ->
    @cache = {}

  registerSocket: (key, socket) ->
    @addSocket key, socket
    socket.on 'disconnect', () => @removeSocket key, socket

  asJson: (key = undefined) ->
    return @registeredSockets(key).length if key
    result = {}
    for k, v of @cache
      result[k] = v.length
    return result

  addSocket: (key, socket) ->
    sockets = @registeredSockets(key)
    return if sockets.indexOf(socket) >= 0
    log.debug "Added new #{key} socket"
    sockets.push socket

  removeSocket: (key, socket) ->
    sockets = @registeredSockets(key)
    index   = sockets.indexOf(socket)
    sockets.splice index, 1 if index >= 0
    log.debug "Removed #{key} socket"

  dispatchRide: (key, r) ->
    for socket in @registeredSockets(key)
      json = r.toJson()
      log.debug "dispatching ride to client: #{json}"
      socket.emit 'ride', json

  registeredSockets: (key) ->
    @cache[key] || (@cache[key] = [])


SocketCache.instance = new SocketCache()

module.exports.SocketCache = SocketCache
module.exports.instance    = SocketCache.instance
