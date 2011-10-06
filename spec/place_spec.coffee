log = require 'logging'
Place = require('place').Place
Country = require('place').Country
State = require('place').State
City = require('place').City

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
        expect(country.constructor).toBe(Country)
        asyncSpecDone()
      asyncSpecWait()
    
    it "should find a state in a country", ->
      new Country("DE").states.find "Berlin", (state) ->
        expect(state.key).toBe("DE:Berlin")
        expect(state.constructor).toBe(State)
        asyncSpecDone()
      asyncSpecWait()
        
    it "should find a city in a country", ->
      new Country("DE").cities.find "Hamburg", (city) ->
        expect(city.key).toBe("DE:Hamburg:Hamburg")
        expect(city.constructor).toBe(City)
        asyncSpecDone()
      asyncSpecWait()
    
    it "should choose the city with max population if not unique", ->
      new Country("DE").cities.find "München", (city) ->
        expect(city.key).toBe("DE:Bayern:München")
        asyncSpecDone()
      asyncSpecWait()

    it "should find a city in a state", ->
      new State("DE:Berlin").cities.find "Berlin", (city) ->
        expect(city.key).toBe("DE:Berlin:Berlin")
        asyncSpecDone()
      asyncSpecWait()

    it "should find a city in a state by alternative name", ->
      new State("DE:Rheinland-Pfalz").cities.find "Mayence", (city) ->
        expect(city.key).toBe("DE:Rheinland-Pfalz:Mainz")
        asyncSpecDone()
      asyncSpecWait()

    it "should find by google geocoder object", ->
      go = require("./fixtures/googleobject").results[0]
      City.find go, (city) ->
        expect(city.key).toBe("DE:Rheinland-Pfalz:Mainz")
        asyncSpecDone()
      asyncSpecWait()
 
    it "should return undefined if place does not exist", ->
      new State("DE:Bayern").cities.find "Oachkatzleschwoafhausen", (city) ->
        console.log("--------->"+city)
        expect(city).toBe(undefined)

        asyncSpecDone()
      asyncSpecWait()

    xit "should find by geoip geocoder objects", ->
      go = require("./fixtures/geoipobject")
      City.find go, (city) ->
        expect(city.key).toBe("DE:Berlin:Berlin")
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

  describe "left overs and feature wishes", ->
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
