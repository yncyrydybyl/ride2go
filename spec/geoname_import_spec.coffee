__ = NaN
redis = NaN
describe "geonames import", ->
  
  beforeEach ->
    __ = require("underscore")
    redis = require("redis").createClient()

  it "should happen at all ;-)", ->
    redis.keys "geonames:*", (err, keys) ->
      expect(keys.size).not.toEqual(0)
      asyncSpecDone()
    asyncSpecWait()

  it "should import Berlin", ->
    redis.exists "DE", (err, exists) ->
      expect(exists).toEqual 1
    redis.exists "DE:Berlin", (err, exists) ->
      expect(exists).toEqual 1
    redis.exists "DE:Berlin:Berlin", (err, exists) ->
      expect(exists).toEqual 1
    redis.exists "geoname:id:2950157", (err, exists) ->
      expect(exists).toEqual 1
    redis.exists "geoname:id:2950159", (err, exists) ->
      expect(exists).toEqual 1
    redis.hget "DE:Berlin:Berlin", "population", (err, pp) ->
      expect(pp).toEqual "3426354"
    redis.hget "DE:Berlin:Berlin", "lat", (err, lat) ->
      expect(lat).toEqual "13.41053"
      asyncSpecDone()
    asyncSpecWait()

  it "should map geoname ids as foreign keys to internal keys", ->
    redis.get "geoname:id:2950157", (err, internal_key) ->
      expect(internal_key).toEqual("DE:Berlin")
    redis.get "geoname:id:2950159", (err, internal_key) ->
      expect(internal_key).toEqual("DE:Berlin:Berlin")
      asyncSpecDone()
    asyncSpecWait()

  it "should map geoname names as internal keys to foreign keys", ->
    redis.hget "DE:Berlin", "geoname:id", (err, foreign_key) ->
      expect(foreign_key).toBe("2950157")
    redis.hget "DE:Berlin:Berlin","geoname:id", (err, foreign_key) ->
      expect(foreign_key).toBe("2950159")
      asyncSpecDone()
    asyncSpecWait()
  
  it "should replace internal keys by better (prefered) alternative names", ->
    redis.get "geoname:id:2951839", (err, internal_key) ->
      expect(internal_key).toEqual("DE:Bayern") # and not "Freistaat Bayern"
      asyncSpecDone()
    asyncSpecWait()
 
  it "should import Beieren as alternative name", ->
    redis.smembers "geoname:alt:Beieren", (err, alts) ->
      expect(__.include(alts, "DE:Bayern")).toBe(true)
      asyncSpecDone()
    asyncSpecWait()
  it "should import Baian as alternative name", ->
    redis.smembers "geoname:alt:Baian", (err, alts) ->
      expect(__.include(alts, "DE:Bayern")).toBe(true)
      asyncSpecDone()
    asyncSpecWait()
  it "should import Berliini names as alternative name", ->
    redis.smembers "geoname:alt:Berliini", (err, alts) ->
      expect(__.include(alts, "DE:Berlin")).toBe(true)
      asyncSpecDone()
    asyncSpecWait()
  it "should not import Oachkatzeltshausen names as alternative name for ottobrunn", ->
    redis.smembers "geoname:alt:Oachkatzeltshausen", (err, alts) ->
      expect(__.include(alts, "DE:Bayern:Ottobrunn")).toBe(false)
      asyncSpecDone()
    asyncSpecWait()
  it "should import Bad Gernrode as alternative name", ->
    redis.smembers "geoname:alt:Bad Gernrode", (err, alts) ->
      expect(__.include(alts, "DE:Sachsen-Anhalt:Gernrode")).toBe(true)
      asyncSpecDone()
    asyncSpecWait()
  it "should import Foehrenwald as alternative name", ->
    redis.smembers "geoname:alt:Foehrenwald", (err, alts) ->
      expect(__.include(alts, "DE:Bayern:Waldram")).toBe(true)
      asyncSpecDone()
    asyncSpecWait()

  afterEach ->
    redis.quit()
