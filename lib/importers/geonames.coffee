nodeio = require 'node.io'
redis = require('redis').createClient()

COUNTRY = "DE"

module.exports = new nodeio.Job
  input: false
  run: (f) ->
    console.log "arg1: " + @options.args[0]
    start new NamesImport(), () =>
      start new AdminImport(), () =>
        start new CityImport(), () =>
          @emit "geoname import finished."

start = (job, callback) ->
  nodeio.start job, {}, (
    (err) ->
      if err
        log.error("Error while "+job.description+": "+err+"\n")
      else
        console.log(job.description+" finished.\n")
      callback()
  ), false


class NamesImport extends nodeio.JobClass
  input: "/tmp/alternateNames.txt"
  description: "tmp import of alternative geonames"
  run: (row) ->
    data = @parseValues(row,'\t')
    redis.sadd "alt:geoname:#{data[1]}",
      "#{data[2]}:#{data[4]}:#{data[5]}:#{data[3]}",
      (error, success) =>
        @emit 42
    null
  output: false

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


adminCodes = {}

class CityImport extends nodeio.JobClass
  input: "/tmp/#{COUNTRY}.txt"
  description: "import of cities in #{COUNTRY}"
  constructor: ->
    super()
    require('csv')().fromPath("/tmp/admin1CodesASCII.txt", {delimiter: "\t"})
    .on "data", (line) =>
      if line[0].substring(0,2) == COUNTRY
        adminCodes[line[0].split(".")[1]] = line[3]
  run: (row) ->
    place = @parseValues row, '\t'
    #population = data[14]          #lon = data[4]        #lat = data[5]
    if place[7] && place[7].match /PPL.*/
      redis.get "geoname:id:#{adminCodes[place[10]]}", (err, admin_key) =>
        if admin_key && admin_key.substring(0,2) == place[8] # consistency
          store place[0], admin_key, place[1], => @emit 1
        else
          console.log " - something Kompost in here: "+place[1] +
            "! adminCode is "+place[10]+", Key is "+admin_key
    else @skip()
  output: false


store = (geoname_id, sub_key, name, done) ->
  # we want the best available name as key
  redis.smembers "alt:geoname:#{geoname_id}", (err, alts) =>
    prefered = (a for a in alts when a.match(/^:1:1.*/))
    if prefered && prefered.length > 0
      console.log " prefered "+p for p in prefered if prefered.length > 1
      better_name = prefered[prefered.length-1].match(/:([^:]*)$/)[1]
      console.log "  FOUND prefered: "+better_name+" better than:"+name
      name = better_name
    else
      regional = (a for a in alts when a.match(/^de:1:.*/))
      if regional && regional.length > 0
        console.log " regional "+p for p in regional if regional.length > 1
        better_name = regional[regional.length-1].match(/:([^:]*)$/)[1]
        console.log "  FOUND regional: "+better_name+" better than: "+name
        name = better_name
      else
        #console.log "NO prefered alt names found for " + name
    primary_key = "#{sub_key}:#{name}"        # DE:Thueringen
    foreign_key = "geoname:id:#{geoname_id}"  # geoname:id:42
    redis.sadd primary_key, foreign_key
    redis.set foreign_key, primary_key
    #console.log "+stored "+primary_key
    for a in alts when not a.match(///.*:#{name}///)
      if a.match /.*wikipedia.*/
        redis.set "wikipedia:#{a.match(/\/([^\/]*)$/)[1]}", primary_key
      else
        redis.set "geoname:alt:#{a.match(/:([^:]*)$/)[1]}", primary_key
    done()


#@class = ImportCountrynamesAndAdminCodes
#@job = new ImportCountrynamesAndAdminCodes()
