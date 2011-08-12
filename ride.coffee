log = require './lib/logging'
__ = require './vendor/underscore'

module.exports = class Ride

  ## principle of least surprise

  constructor: (o = {}) -> # convenience setter
    if __.isString(o) and o.split("->").length = 2
      orig = o.split("->")[0]
      dest = o.split("->")[1]

    log.debug "Ride constructor called", o
    if o
      @link = o.url || o.ref || undefined
      @dest = o.to || o.dest || o.destination || o.target || dest
      @orig = o.from || o.orig || o.origin || o.start || o.source || orig
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

