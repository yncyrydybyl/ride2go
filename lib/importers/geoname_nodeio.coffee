nodeio = require 'node.io'
redis = require('redis').createClient()

COUNTRY = "DE"

module.exports = new nodeio.Job
  input: false
  run: (f) =>
    #startJob new CityImport(), () =>
    start new NamesImport(), () =>
      @emit "geoname import finished."

start = (job, callback) ->
  nodeio.start job, {}, (
    (err) ->
      if err
        console.log("Error while "+job.description+": "+err+"\n")
      else
        console.log(job.description+" finished.\n")
      callback()
  ), false


class GeonameImport extends nodeio.JobClass
  findBetterName: (geoname_id) ->
    name = "foo" # as we want the best available name as key
    redis.smembers "alt:geoname:#{place[0]}", (err, alts) ->
      prefered = a for a in alts when a.match(/.*:1:.*/)
      console.log prefered.length
      console.log p for p in prefered
      if prefered.length > 1
        console.log "shorts:"
        short = a for a in alt when a.match(/^.*:1:1:.*/)
        console.log p for p in short
    name
  store: (primary_key, foreign_key) ->
    console.log "sure"

class AdminImport extends GeonameImport
  input: "/tmp/#{COUNTRY}.txt"
  description: "import of administrative divisions in #{COUNTRY}"
  run: (row) =>
    place = @parseValues(row,'\t')
    if place[7] && place[7].match /ADM1/
      name = @findBetterName(place[0])
      primary_key = "#{place[8]}:#{name}"   # DE:Thueringen
      foreign_key = "geoname:id:#{place[0]}"   # geoname:id:42
      redis.sadd primary_key, foreign_key
      redis.set foreign_key, primary_key
      console.log " + stored admin: "+place[1]
      @emit true
  output: false


adminCodes = {}

class CityImport extends GeonameImport
  input: "/tmp/#{COUNTRY}.txt"
  description: "import of cities in #{COUNTRY}"
  constructor: ->
    super()
    require('csv')().fromPath("tmp/admin1CodesASCII.txt", {delimiter: "\t"})
    .on "data", (line) =>
      if line[0].substring(0,2) == COUNTRY
        adminCodes[line[0].split(".")[1]] = line[3]
  run: (row) =>
    place = @parseValues(row,'\t')
    #population = data[14]          #lon = data[4]        #lat = data[5]
    if place[7] && place[7].match /PPL.*/
      redis.get "geoname:id:#{adminCodes[place[10]]}", (err, admin_key) =>
        if admin_key && admin_key.substring(0,2) == place[8] # consistency
          name = @findBetterName(place[0])
          primary_key = "#{admin_key}:#{name}"    # DE:Bavaria:München
          foreign_key = "geoname:id:#{place[0]}"     # geoname:id:1234567
          redis.sadd primary_key, foreign_key
          redis.set foreign_key, primary_key
          #console.log " + stored city: "+place[1]
        else
          console.log " - something Kompost in here: "+place[1] +
            "! adminCode is "+place[10]+", Key is "+admin_key
    @exit
  output: false

class NamesImport extends nodeio.JobClass
  input: "/tmp/alternateNames.txt"
  description: "tmp import of alternative geonames"
  run: (row) =>
    data = @parseValues(row,'\t')
    redis.sadd "alt:geoname:#{data[0]}",
      "#{data[2]}:#{data[4]}:#{data[5]}:#{data[3]}",
      (error, success) =>
        @emit true
  output: false


#@class = ImportCountrynamesAndAdminCodes
#@job = new ImportCountrynamesAndAdminCodes()
