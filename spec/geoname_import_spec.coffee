#import kann complex sein
#lookups sollen schnell und simple sein
#
#internal keys == place.descriptor_string
#(erstellen aus geonames datensatz)
#
#<COUNTRY>:<ADMIN1>:...:<CITY>:<PLZ>:<STREET>:<NR>
#
#foreign keys mappen aud sets von internal keys
#<SOURCE>:<TYPE>:<ID>
#  GOOGLE:LOCALITY:MAYENCE ->
#  HAFAS:TRAMHALT:28436    ->
#  GEONAMES:ID:345687      ->
#  GEONAME:PPL:MAINZ       ->
#  GEONAME:PPL:MAYENCE     -> [DE:RF:MAINZ, AT:OÖ:MIANZO]
#  MFGDE:CITY:123          ->
#  OSM:STREET:HAUPTSTRAßE  -> [DE:RF:MAINZ:HAUPSTR, DE:BY:MÜNCHEN:HAUPTSTR, ...] # worst case
#  FOUSQUARE:CAFE:876543   ->
#
#----
#internal?
#  DE -> DE # internal key found :)
#  DE:RF -> DE:RF # internal key found :)
#  DE:RF:Mayence -> false # internal key NOT found :(
#    foreign?
#      *:MAYENCE -> [DE:RF:MAINZ, AT:OÖ:MIANZO]
#        wenn mehrere dann die rauspicken, die sinn machen
#        - selber anfang
#        - first guess
#      -> DE:RF:MAINZ # internal key found
#    :)
#

#deTxt = require ("fixtures/geonames").deTxt

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
    redis.exists "DE:Berlin", (err, exists) ->
      expect(exists).toBeTrue
    redis.exists "geoname:id:2950157", (err, exists) ->
      expect(exists).toEqual 1
    redis.exists "DE:Berlin:Berlin", (err, exists) ->
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
    redis.smembers "DE:Berlin", (err, foreign_keys) ->
      expect(__.include(foreign_keys,"geoname:id:2950157")).toBeTrue
    redis.smembers "DE:Berlin:Berlin", (err, foreign_keys) ->
      expect(__.include(foreign_keys,"geoname:id:2950159")).toBeTrue
      asyncSpecDone()
    asyncSpecWait()
  
  it "should replace internal keys by better (prefered) alternative names", ->
    redis.get "geoname:id:2951839", (err, internal_key) ->
      expect(internal_key).toEqual("DE:Bayern") # and not "Freistaat Bayern"
      asyncSpecDone()
    asyncSpecWait()
 
  it "should import alternative names as foreign keys", ->
    redis.smembers "geoname:alt:Beieren", (err, alts) ->
      expect(__.include(alts, "DE:Bayern")).toBeTrue
    redis.smembers "geoname:alt:Baian", (err, alts) ->
      expect(__.include(alts, "DE:Bayern")).toBeTrue
    redis.smembers "geoname:alt:Berliini", (err, alts) ->
      expect(__.include(alts, "DE:Berlin:Berlin")).toBeTrue
    redis.smembers "geoname:alt:Bad Gernrode", (err, alts) ->
      expect(__.include(alts, "DE:Sachsen-Anhalt:Gernrode")).toBeTrue
    redis.smembers "geoname:alt:Foehrenwald", (err, alts) ->
      expect(__.include(alts, "DE:Bayern:Waldram")).toBeTrue

  afterEach ->
    redis.quit()
