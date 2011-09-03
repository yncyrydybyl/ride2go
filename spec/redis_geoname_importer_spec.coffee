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
      @nextstep = @somethingtodo = true
      go = =>
        @nextstep = false
        @somethingtodo = true
      go()

      waitsFor "waited to long", 1000, ->
        if @somethingtodo
          f = importer.storeCountryAndAdminDivision "DE", =>
            @nextstep = true
          @somethingtodo = false
        go() if @nextstep

      waitsFor "waited to long", 1000, ->
        if @somethingtodo
          redis.exists "DE:Berlin", (err, exists) =>
            expect(exists).toEqual 1
            @nextstep = true
          @somethingtodo = false
        go() if @nextstep

      waitsFor "waited to long", 1000, ->
        if @somethingtodo
          redis.keys "DE:*", (err, value) =>
            expect(value).toInclude "DE:Berlin"
            @nextstep = true
          @somethingtodo = false
        go() if @nextstep

  describe "admin division", ->
    it "should read admin data from deTXT and store it into redis", ->

once = (initialRetVal, thunk) =>
  @triggered = false
  @retval = initialRetVal
  wrapper = =>
    if not @triggered
      @triggered = true
      thunk( (result) =>
        @retval = result )
    @retval
