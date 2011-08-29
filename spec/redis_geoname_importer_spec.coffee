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
require "./spec_helper"
geonames =  require "./fixtures/geonames"
countryInfoTxt = geonames.countryInfoTxt
deTxt = geonames.deTxt

describe "geonames importer", ->
  redis = {}
  importer = {}
  beforeEach ->
    redis = require("../lib/r2gredis").client()
    importer = require ("../lib/importers/geonames")
    __ = require("../vendor/underscore")
    @addMatchers({
      toInclude: (expected) ->
        __.include @actual, expected
    })
  afterEach ->
    redis.flushdb()
  describe "country codes" , ->

    it "should read data admin1CodesASCII.txt and store countries and administrative areas into redis", ->
      countrycode = "DE"
      @weiter = false
      waitsFor(->
        console.log("aiting")
        f = importer.storeCountryAndAdminDivision("DE", =>
          @weiter = true
        ,)
        console.log("aiting2")
        console.log(@weiter)
        return @weiter
      ,"waited to long",4000)
      runs ->
        console.log("wtf")
        redis.exists "DE:Berlin", (err, exists) -> expect(exists).toEqual 1
        redis.keys "DE:Berlin", (err, value) -> expect(value).toInclude "DE:Berlin"
        waits 100 

  describe "admin division", ->
    it "should read admin data from deTXT and store it into redis", ->
      
