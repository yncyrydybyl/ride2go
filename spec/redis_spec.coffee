require('./spec_helper')
log = require "../lib/logging"
describe "redis", ->
  describe ".client" , ->
    it "should return a redis client", ->
      redis_module = require "redis"

      redis = require "../lib/r2gredis"
      mod = spyOnModule "redis", ["createClient"]
      #mod.createClient = ->

      spyOn(mod,"createClient").andReturn(c = "")

      r = redis.client()
      #log.debug("",r)
      #console.log(mod) 
      #rorig = require("redis").createClient()
      #expect(redis_module.createClient).toHaveBeenCalled()
      expect(mod.createClient).toHaveBeenCalled()
      expect(r).toEqual("")
      #expect(rorig).toEqual(r)
