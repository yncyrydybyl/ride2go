redis  = require('redis')
nodeio = require 'node.io'
log    = require '../logging'
moment = require 'moment'
Ride   = require '../ride'
Place  = require('../place').Place

module.exports.enabled = true
module.exports.details = details =
  mode: "fake"
  fake: true
  name: "wvg.de"
  country: "DE"
  source: "http://www.wvg.de"
  author: ["boggle"]
  icon: "logo_wvg.de.png"
  update_freq: "10"
  expires: ""
  match_strategy: "default"
  tz: ""

module.exports.findRides = new nodeio.Job
  input: (i, j, run) ->
    return false

  run: () ->
    @

store = redis.createClient()
orig  = 'DE:Niedersachsen:Ehmen'
dest  = 'DE:Niedersachsen:Wolfsburg'

for year in [2013]
  for month in [10]
    for day in [18, 19, 20, 21, 22]
      for route in [[[5, 26], [6,1]], [[6, 39], [7, 14]], [[13, 23], [7, 14]], [[13, 23], [13, 58]]]
        dep = moment().year(year).month(month-1).date(day).hours(route[0][0]-1).minutes(route[0][1])
        arr = moment().year(year).month(month-1).date(day).hours(route[1][0]-1).minutes(route[1][1])
        key = "#{orig}->#{dest}"
        dep = dep.unix()
        arr = arr.unix()
        id  = "#{module.exports.details.mode}:#{orig}@#{dep}->#{dest}@#{arr}"
        val = {
          orig: orig
          dest: dest
          arr: arr
          dep: dep
          link: 'http://www.wvg.de'
          provider: module.exports.details.name
          id: id
        }
        val = JSON.stringify(val)
        store.hset key, id, val, () ->
          console.log "set #{key} #{id} #{val}"
