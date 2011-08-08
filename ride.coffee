log = require './lib/logging'
module.exports = class Ride

  ## principle of least surprise

  constructor: (o) -> # convenience setter
    log.debug "Ride constructor called", o
    @link = o.id || o.url || o.ref || o.link
    @dest = o.to || o.dest || o.destination || o.target
    @orig = o.from || o.orig || o.origin || o.start || o.source
    @date = o.date || o.datum || o.published_at || o.last_modified

  json: -> JSON.stringify(@)

  # convenience getters
  destination: -> @dest
  origin: -> @orig
  target: -> @dest
  start: -> @orig
  date: -> @date
  from: -> @orig
  ziel: -> @dest
  to: -> @dest

