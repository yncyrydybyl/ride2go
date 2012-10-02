__ = NaN
redis = NaN

describe "Geoname Import", (done) ->

  beforeEach ->
    __ = require("underscore")
    redis = require("redis").createClient()

  it "should happen at all", (done) ->
    redis.dbsize (err, size) ->
      expect(size).not.to.equal(0)
      done()

  it "should import Berlin", (done) ->
    redis.exists "DE", (err, exists) ->
      expect(exists).to.equal 1
    redis.exists "DE:Berlin", (err, exists) ->
      expect(exists).to.equal 1
    redis.exists "DE:Berlin:Berlin", (err, exists) ->
      expect(exists).to.equal 1
    redis.exists "geoname:id:2950157", (err, exists) ->
      expect(exists).to.equal 1
    redis.exists "geoname:id:2950159", (err, exists) ->
      expect(exists).to.equal 1
    redis.hget "DE:Berlin:Berlin", "population", (err, pp) ->
      expect(pp).to.equal "3426354"
    redis.hget "DE:Berlin:Berlin", "lat", (err, lat) ->
      expect(lat).to.equal "13.41053"
      done()

  it "should map geoname ids as foreign keys to internal keys", (done) ->
    redis.get "geoname:id:2950157", (err, internal_key) ->
      expect(internal_key).to.equal("DE:Berlin")
    redis.get "geoname:id:2950159", (err, internal_key) ->
      expect(internal_key).to.equal("DE:Berlin:Berlin")
      done()

  it "should map geoname names as internal keys to foreign keys", (done) ->
    redis.hget "DE:Berlin", "geoname:id", (err, foreign_key) ->
      expect(foreign_key).to.equal("2950157")
    redis.hget "DE:Berlin:Berlin","geoname:id", (err, foreign_key) ->
      expect(foreign_key).to.equal("2950159")
      done()

  it "should replace internal keys by better (prefered) alternative names", (done) ->
    redis.get "geoname:id:2951839", (err, internal_key) ->
      expect(internal_key).to.equal("DE:Bayern") # and not "Freistaat Bayern"
      done()

  it "should import Beieren as alternative name for DE:Bayern", (done) ->
    redis.smembers "geoname:alt:Beieren", (err, alts) ->
      expect(__.include(alts, "DE:Bayern")).to.equal(true)
      done()
  it "should import Baian as alternative name for DE:Bayern", (done) ->
    redis.smembers "geoname:alt:Baian", (err, alts) ->
      expect(__.include(alts, "DE:Bayern")).to.equal(true)
      done()
  it "should import Berliini names as alternative name for DE:Bayern", (done) ->
    redis.smembers "geoname:alt:Berliini", (err, alts) ->
      expect(__.include(alts, "DE:Berlin")).to.equal(true)
      done()
  it "should not import Oachkatzeltshausen names as alternative name for ottobrunn", (done) ->
    redis.smembers "geoname:alt:Oachkatzeltshausen", (err, alts) ->
      expect(__.include(alts, "DE:Bayern:Ottobrunn")).to.equal(false)
      done()
  it "should import Bad Gernrode as alternative name", (done) ->
    redis.smembers "geoname:alt:Bad Gernrode", (err, alts) ->
      expect(__.include(alts, "DE:Sachsen-Anhalt:Gernrode")).to.equal(true)
      done()
  it "should import Foehrenwald as alternative name", (done) ->
    redis.smembers "geoname:alt:Foehrenwald", (err, alts) ->
      expect(__.include(alts, "DE:Bayern:Waldram")).to.equal(true)
      done()

  afterEach -> redis.quit()

