nodeio = require 'node.io'
log = require 'logging'


url = (query) ->
  "http://www.mitfahrzentrale.de/suche.php?art=100&frmpost=1&
STARTLAND=D&START=#{query.orig}&
ZIELLAND=D&ZIEL=#{query.dest}&
abdat=#{query.date || ''}"

module.exports.findRides = new nodeio.Job
  input: false
  run: ->
    @getHtml url(@options), (err, $, data) =>
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

