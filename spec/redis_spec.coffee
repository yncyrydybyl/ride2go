require('./spec_helper')
log = require "../lib/logging"

describe "redis", ->
  mod = redis = redis_module = redis_client_spy = {}

  beforeEach ->
    redis_module = require "redis"
    redis = require "../lib/r2gredis"
    redis_client_spy = createSpyObj("my redis client", ["select","on"])

    mod = spyOnModule "redis", ["createClient"]
    spyOn(mod,"createClient").andReturn(redis_client_spy)

  describe ".client" , ->
    xit "should return a redis client", ->

      #spyOn(mod,"createClient").andReturn(redis_client_spy)

      r = redis.client()
      
      expect(mod.createClient).toHaveBeenCalled()
      expect(r).toEqual(redis_client_spy)

  describe ".client in testmode" , ->
    xit "should select the testdatabase if running in test enviroment", ->
      #process.env.NODE_ENV = "test" // because we are in test 
      r = redis.client()
      expect(redis_client_spy.select).toHaveBeenCalledWith(15)

describe "redis database ", ->
  redis = {}
  beforeEach ->
    redis = require "../lib/r2gredis"
  it "should be a empty database" , ->
    r = redis.client()
    r.dbsize (err, numberofkeys) ->
      expect(numberofkeys).toBe(0)
      asyncSpecDone()
    asyncSpecWait()
