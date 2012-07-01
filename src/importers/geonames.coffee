fs = require 'fs'
winston = require './lib/logging'
altis = NaN
nodeio = require 'node.io'
redis = require('redis').createClient()

COUNTRY = "DE"

module.exports = new nodeio.Job
  input: false
  run: (f) ->
    try
      fs.statSync("./redis/dumps/alts.rdb")
      fs.statSync("/tmp/alternateNames.txt")
      altis = require("redis").createClient(4175)
      winston.notice "alternative names import dump already exists.\n"
      importCountry COUNTRY, @emit
    catch error
      winston.log error
      winston.info "alternative names import dump does NOT exist.\n"
      start new NamesImport(), redis.save () =>
        fs.renameSync "dump.rdb", "redis/dumps/alts.rdb", () =>
          importCountry COUNTRY, @emit

importCountry = (country, done) ->
  # ToDo should be import all countries including currency, population etc.
  redis.hset COUNTRY.toUpperCase(), "shortname", "Germany", (err, result) ->
    winston.error err if err
  start new AdminImport(), () =>
    start new CityImport(), () =>
      importManualKeys(done)

importManualKeys = (done) ->
  redis.sadd "geoname:alt:Baden-Wurttemberg", "DE:Baden-Württemberg", (err, succ) =>
    redis.hset "DE:Hessen:Frankfurt am Main", "mitfahrzentrale:id", "Frankfurt/ Main", (err, succ) =>
      done("fertig.") # TODO find a better solution for manual keys https://www.pivotaltracker.com/story/show/21451669

start = (job, callback) ->
  winston.info "starting "+job.description
  nodeio.start job, {}, ((err) ->
      winston.error("Error! "+job.description+": "+err+"\n") if err
      winston.info(job.description+" finished.\n")
      callback()
  ), false


class NamesImport extends nodeio.JobClass
  input: "/tmp/alternateNames.txt"
  description: "import of tmp alternative geonames"
  run: (row) ->
    data = @parseValues(row,'\t')
    redis.sadd "alt:geoname:#{data[1]}",
      "#{data[2]}:#{data[4]}:#{data[5]}:#{data[3]}",
      (error, success) =>
        @emit 42
    null
  output: -> false

class AdminImport extends nodeio.JobClass
  input: "/tmp/#{COUNTRY}.txt"
  description: "import of administrative divisions in #{COUNTRY}"
  run: (row) ->
    place = @parseValues row, '\t'
    if place[7] && place[7].match /ADM1/ # featurecode
      store place[0], place[8], place[1], => @emit 1
    else
      @skip()
  output: false

class CityImport extends nodeio.JobClass
  input: "/tmp/#{COUNTRY}.txt"
  description: "import of cities in #{COUNTRY}"
  constructor: ->
    super()
    loadAdminCodes()
  run: (row) ->
    place = @parseValues row, '\t'
    #population = data[14]          #lon = data[4]        #lat = data[5]
    if place[7] && place[7].match /PPL.*/
      redis.get "geoname:id:#{adminCodes[place[10]]}", (err, admin_key) =>
        if admin_key && admin_key.substring(0,2) == place[8] # consistency
          store place[0], admin_key, place[1], (=> @emit 1), place[14], place[5], place[4]
        else
          winston.debug " - something Kompost in here: "+place[1] +
            "! adminCode is "+place[10]+", Key is "+admin_key
          @skip()
    else @skip()
  output: false


adminCodes = {}
loadAdminCodes = () ->
  require('csv')().fromPath("/tmp/admin1CodesASCII.txt", {delimiter: "\t"})
    .on "data", (line) =>
      if line[0].substring(0,2) == COUNTRY
        adminCodes[line[0].split(".")[1]] = line[3]


store = (geoname_id, sub_key, name, done, population=false, lat=false, lon=false) ->
  # we want the best available name as key
  altis.smembers "alt:geoname:#{geoname_id}", (err, alts) =>
    prefered = (a for a in alts when a.match(/^:1:1.*/))
    if prefered && prefered.length > 0
      winston.debug " prefered "+p for p in prefered if prefered.length > 1
      better_name = prefered[prefered.length-1].match(/:([^:]*)$/)[1]
      winston.debug "  FOUND prefered: "+better_name+" better than:"+name unless better_name == name
      name = better_name
    else
      regional = (a for a in alts when a.match(/^de:1:.*/))
      if regional && regional.length > 0
        winston.debug " regional "+p for p in regional if regional.length > 1
        better_name = regional[regional.length-1].match(/:([^:]*)$/)[1]
        winston.debug "  FOUND regional: "+better_name+" better than: "+name unless better_name == name
        name = better_name
      else
        shortest = null
        for n in (a for a in alts when a.match(/^de:.*/))
          shortest = n if not shortest or n.length < shortest.length
          better_name = shortest.match(/:([^:]*)$/)[1]
          winston.debug "  FOUND shortest: "+better_name+" beitter than: "+name unless better_name == name
          name = better_name
    primary_key = "#{sub_key}:#{name}"        # DE:Thueringen
    foreign_key = "geoname:id:#{geoname_id}"  # geoname:id:42
    
    #winston.debug "+stored "+primary_key
    for a in alts when not a.match(///.*:#{name}///)
      if a.match /.*wikipedia.*/
        #redis.set "wikipedia:#{a.match(/\/([^\/]*)$/)[1]}", primary_key
      else
        alt_key = "geoname:alt:#{a.match(/:([^:]*)$/)[1]}"
        redis.sadd alt_key, primary_key
    redis.set foreign_key, primary_key
    redis.hset(primary_key, "population", population) if population
    redis.hset(primary_key, "lat", lat) if lat
    redis.hset(primary_key, "lon", lon) if lon
    redis.hset primary_key, "geoname:id", geoname_id, (err, foo) =>
      done()


#@class = ImportCountrynamesAndAdminCodes
#@job = new ImportCountrynamesAndAdminCodes()
