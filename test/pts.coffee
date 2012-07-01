connectors = require "../lib/connectors"
io = require "node.io"

describe "Connectors", ->

  it 'PTE should work and not crash', (done) ->
    query =
      orig: "DE:Berlin:Berlin"
      dest: "DE:Hamburg:Hamburg"
    io.start connectors.pts.findRides, query, ((err, rides) ->
      expect(rides.length).to.equal 1
      done()
    ), true

  it 'there should be 42 tests in total!', ->
    expect(42).to.exist
