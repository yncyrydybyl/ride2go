Place = require '../lib/place'
describe "Place", ->
  v = {} 
  r = {} 
  describe 'factory: Place.new(whatever)', ->

    it "should call Place.fromString when it is called with string", ->
      spyOn(Place,'fromString')
      Place.new "some place string"
      expect(Place.fromString).toHaveBeenCalled()
      
    it "should call Place.fromGoogleGeocoder when called with google geocoder result", ->
      spyOn(Place,'fromGoogleGeocoder')
      Place.new require './fixtures/v'
      expect(Place.fromGoogleGeocoder).toHaveBeenCalled()

  describe "function city", ->
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

