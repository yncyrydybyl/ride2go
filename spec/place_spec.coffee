Place = require '../lib/place'
describe "Place", ->
  v = {}
  r = {}


  describe 'factory: Place.new("DE:Bayern:München)', ->
    it "should work with primary keys", ->
      Place.new "DE:Bayern:München", (p) ->
        expect(p.city()).toEqual("München")
        expect(p.country()).toEqual("DE")
        asyncSpecDone()
      asyncSpecWait()

    xit "should work with formated address strings from google street addresses", ->
      p = Place.new "Kopernikusstraße 23, 10245 Berlin, Germany"
      expect(p.city()).toEqual("München")
      expect(p.country()).toEqual("DE")
    
    xit "should work with arbitrary address strings", ->
      p = Place.new "Kopernikusstraße 23, Berlin"
      expect(p.city).toEqual("München")
      expect(p.country).toEqual("DE")

      p2 = Place.new "Berlin, Kopernikusstraße 23"
      expect(p.city).toEqual("München")
      expect(p.country).toEqual("DE")
  xdescribe 'factory: Place.new(whatever)', ->

    it "should call Place.fromString when it is called with string", ->
      spyOn(Place,'fromString')
      Place.new "some place string"
      expect(Place.fromString).toHaveBeenCalled()
      
    it "should call Place.fromGoogleGeocoder when called with google geocoder result", ->
      spyOn(Place,'fromGoogleGeocoder')
      Place.new require './fixtures/v'
      expect(Place.fromGoogleGeocoder).toHaveBeenCalled()

  xdescribe "function city", ->
    beforeEach ->
      v = require './fixtures/v'
    it "should return the proper cityname", ->
      p = Place.new(v)
      city = p.city()
      expect(city).toEqual("Mainz")



  xdescribe '.fromGoogle', ->
    beforeEach ->
      v = require './fixtures/v'
      r = require('redis')
      redis = r.createClient()
      redis.select 15
      redis.set("DE","foo")
      redis.sadd "DE:RP","2847618"
      redis.sadd "DE:RP:Mainz", ["2874225","Mainz","Mayence","Mogontiacum","Moguncja"]
      redis.smembers "DE:RP", (er,data) -> console.log("foo"+data+er)
      waits 2000
    it "should assign a proper key if geonames exist in redis", ->
       # im redis 
      #   SELECT 99
      #   SET DE foo
      #   SADD DE:RP 2847618 
      #   SADD DE:RP Rheinland-Pfalz
      #   SADD DE:RP:Mainz 2874225 Mainz Mayence Mogontiacum Moguncja
      #   SET DE:RP:Mayence DE:RP:Mainz

      p=Place.new(v)
      expect(p.key()).toEqual("DE:RP:Mainz")
    it "should put it into conflicts if geonames not exist in redis", ->

#geoname = require "../lib/geonames"
#redis = require("redis").createClient()
#
#describe "geonames", ->
#  describe ".cityExits", ->
#    beforeEach ->
#      redis.select 15 # using the a test db
#      redis.set "gn:Mainz" "DE:RP:Mainz" # setting alternative name 1
#      redis.set "gn:Mayence" "DE:RP:Mainz" # setting alternative name 2
#      redis.hset "DE:RP:Mainz", "type", "city" # setting primary key as hash and defining the type 
#      waits("500")
#    afterEach ->
#      redis.flushdb
#    it "should return true if a city exits", ->
#      city = geoname.cityExits("Mainz",redis)
#      waits("500")
#      expect(city).toBeTruthy()
#    it "should return false if a city is´nt existing.", ->
#      city = geoname.cityExits("laberrababerstadtdienichtexistier")
#      expect(city).toBeFalsy()
#
#  xdescribe ".alternativeName", ->
#    it "should return the internal name if existed", ->
#      alternative = "Mayence"
#      internal = "Mainz"
#      expect(geoname.alternativeName(alternative).toEqual(internal))
#    it "should return null if there is no internal key for it", ->
#      alternative = "larifaristadt"
#      expect(geoname.alternativeName(alternative).toBeNull())
#
