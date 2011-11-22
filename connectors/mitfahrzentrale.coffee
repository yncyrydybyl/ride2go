nodeio = require 'node.io'
log = require 'logging'
Place = require('place').Place
Ride = require('ride')
url = (ride) ->
  console.log(ride)
  "http://www.mitfahrzentrale.de/suche.php?art=100&frmpost=1&
STARTLAND=D&START=#{escape(ride.origin().city())}&
ZIELLAND=D&ZIEL=#{escape(ride.ziel().city())}&
abdat=#{ride.date || ''}"

module.exports.findRides = new nodeio.Job
  input: false
  run: ->
    @getHtml url(Ride.new(@options)), (err, $, data) =>
      rides = []
      for tr in $('tr .tabbody')
        $('td', tr).each (td) -> 0
        row = $('td', tr)
        rides.push
          date: row[1].text
          time: row[4].text
          origin: row[2].text
          destination: row[3].text
          link: "http://www.mitfahrzentrale.de"+$('a', row[5]).attribs.href
      log.notice "found #{rides.length} rides at mitfahrzentrale.de"
      @emit rides

