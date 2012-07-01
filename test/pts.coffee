connectors = require "../lib/connectors"
io = require "node.io"

describe "Connectors", ->

  it 'PTE should work and not crash', (done) ->
    query =
      orig: "DE:Berlin:Berlin"
      dest: "DE:Hamburg:Hamburg"
    io.start connectors.pts.findRides, query, ((err, rides) ->
      console.log rides
      done()
    ), true
