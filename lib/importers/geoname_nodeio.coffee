nodeio = require 'node.io'
redis = require('redis').createClient()

COUNTRY = "DE"

module.exports = new nodeio.Job
  input: false
  run: (f) ->
    startJob new CityImport(), () =>
      startJob new NamesImport(), () =>
        @emit "geonames import finished."

startJob = (job, callback) ->
  nodeio.start job, {}, (
    (err) ->
      if err
        console.log("Error while "+job.description+": "+err+"\n")
      else
        console.log(job.description+" finished.\n")
      callback()
  ), false


class AdminImport extends nodeio.JobClass
  input: "/tmp/#{COUNTRY}.txt"
  description: "import of administrative divisions in #{COUNTRY}"
  run: (row) =>
    place = @parseValues(row,'\t')
    if place[7] && place[7].match /ADM1/
      foreign_key = "geonames:id:#{place[0]}"   # geoname:id:42
      primary_key = "#{place[8]}:#{place[1]}"   # DE:Thueringen
      redis.sadd primary_key, foreign_key
      redis.set foreign_key, primary_key
      console.log " + stored admin div: "+place[1]
    @exit
  output: false


adminCodes = {}

class CityImport extends nodeio.JobClass
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
    #population = data[14]
    #lon = data[4]
    #lat = data[5]
    if place[7] && place[7].match /PPL.*/
      redis.get "geonames:id:#{adminCodes[place[10]]}", (err, admin_key) ->
        if admin_key && admin_key.substring(0,2) == place[8] # consistency
          foreign_key = "geonames:id:#{place[0]}"     # geoname:id:1234567
          primary_key = "#{admin_key}:#{place[1]}"    # DE:Bavaria:München
          redis.sadd primary_key, foreign_key
          redis.set foreign_key, primary_key
          #console.log " + stored city: "+place[1]
        else
          console.log " - something Kompost here with "+place[1] +
            "! adminCode is "+place[10]+", Key is "+admin_key
    @exit
  output: false

class NamesImport extends nodeio.JobClass
  input: "/tmp/alternateNames.txt"
  description: "import of alternative names in #{COUNTRY}"
  run: (row) =>
    data = @parseValues(row,'\t')
    foreign_key = "geonames:id:#{data[1]}"
    redis.get foreign_key, (err, internal_key) =>
      if internal_key && (data[2] == "de" || data[2] == "") && data[4] == "1"  # prefered name
        better_internal_key = internal_key.match(/(.*:)[^:]+$/)[1]+data[3]
        redis.smembers internal_key, (err, foreign_keys) =>
          console.log "To update: "+foreign_keys.length
          redis.multi(["set", key, better_internal_key] for key in foreign_keys).exec()
          redis.multi(["sadd", better_internal_key, key] for key in foreign_keys)
            .exec (err, success) =>
              redis.del internal_key, (err, success) =>
                console.log " -/+ replaced internal key: "+internal_key +
                  " with a better internal key "+better_internal_key
                @emit true
      else if internal_key && data[2] != ""
        redis.set "geonames:alt:#{data[3]}", internal_key
        redis.sadd internal_key, "geonames:alt:#{data[3]}"
        console.log " + stored alt name: "+data[3] +
          " for internal key " + internal_key
        @emit true
  output: false


#@class = ImportCountrynamesAndAdminCodes
#@job = new ImportCountrynamesAndAdminCodes()
