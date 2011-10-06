log = require 'logging'
Place = require('place').Place
Country = require('place').Country

describe "\nClass 'Place':", ->
  # the tests in here only work with a proper redis database running
  last_test = redis = undefined
  redizz = require('r2gredis')
  beforeEach ->
    redis = redizz.keymap()
  afterEach ->
    if last_test
      log.debug("last test -> killed redis")
      redizz.kill()

  
  describe "method 'find':", ->

    it "should find a country by key", ->
      Country.find "DE", (country) ->
        expect(country.key).toBe("DE")
    
    it "should find a state in a country", ->
      new Country("DE").states.find "Berlin", (state) ->
        expect(state.key).toBe("DE:Berlin")
        console.log "happened"
        
    it "should find a city in a country", ->
      new Country("DE").cities.find "Hamburg", (city) ->
        expect(city.key).toBe("DE:Hamburg:Hamburg")
        asyncSpecDone()
      asyncSpecWait()
    
    xit "should choose the city with max population if not unique", ->
      new Country("DE").cities.find "München", (city) ->
        expect(city.key).toBe("DE:Bayern:München")
        asyncSpecDone()
      asyncSpecWait()

    xit "should find a city in a state", ->
      new State("DE:Berlin").cities.find "Berlin", (city) ->
        expect(city.key).toBe("DE:Berlin:Berlin")
        asyncSpecDone()
      asyncSpecWait()

    xit "should find by google geocoder objects", ->
      go = require("./fixtures/googleobject")
      City.find go, (city) ->
        expect(city.key).toBe("DE:Rheinland-Pfalz:Mainz")
        asyncSpecDone()
      asyncSpecWait()
  
    xit "should find by geoip geocoder objects", ->
      go = require("./fixtures/geoipobject")
      City.find go, (city) ->
        expect(city.key).toBe("DE:Berlin:Berlin")
        asyncSpecDone()
      asyncSpecWait()
   
    it "should be the last test ", ->
      last_test = true

  
  
  xdescribe '.find ', ->
    it "should work with primary keys", ->
      redis.hset "DE:Bayern:München", "population", "1260391", (err, result) ->
        Place.find "DE:Bayern:München", (p) ->
          expect(p.city()).toEqual("München")
          expect(p.country()).toEqual("DE")
          asyncSpecDone()
      asyncSpecWait()
    it "should return false if primary key is not there", ->
      Place.find "DE:Bayern:Nonexistent", (p) ->
        expect(p).toBe(false)
        asyncSpecDone()
      asyncSpecWait()

    xit "should work with search parameters", ->
      params =
        city: "München"
        country: "DE"
      Place.find params , (p) ->
        expect(p.key).toBe("DE:Bayern:München")
        asyncSpecDone()
      asyncSpecWait()

  
    it "should be the last test ", ->
      last_test = true


# somehow broken i have no idea why
    xit "selection should be icke strategy ", ->

      Place.chooseByStrategy(["DE:Bayern:München","DE:Brandenburg:München"] , ((p) ->
        expect(p.key).toBe("DE:Berlin:Berlin")
        console.log("called")
        last_test = true
        asyncSpecDone()
        console.log("called")
      ), "icke")
      asyncSpecWait()



    xit "should work with alternative name", ->
      Place.new "DE:Rheinland-Pfalz:Mayence", (p) ->
        #  expect(p.city()).toEqual("Mainz")
      #  expect(p.country()).toEqual("DE")
        asyncSpecDone()
      asyncSpecWait()

    xit "should work with alternative name", ->
      Place.new "DE:ichbinnichtexistent", (p) ->
        


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
