geoname = require "../lib/geonames"
redis = require("redis").createClient()

describe "geonames", ->
  describe ".cityExits", ->
    beforeEach ->
      redis.select 15
      redis.sadd "DE:Rheinland Pfalz:Mainz", "geonames:place"

      waits("500")
    it "should return true if a city exits", ->
      city = geoname.cityExits("Mainz",redis)
      waits("500")
      expect(city).toBeTruthy()
    it "should return false if a city is´nt existing.", ->
      city = geoname.cityExits("laberrababerstadtdienichtexistier")
      expect(city).toBeFalsy()

  xdescribe ".alternativeName", ->
    it "should return the internal name if existed", ->
      alternative = "Mayence"
      internal = "Mainz"
      expect(geoname.alternativeName(alternative).toEqual(internal))
    it "should return null if there is no internal key for it", ->
      alternative = "larifaristadt"
      expect(geoname.alternativeName(alternative).toBeNull())

