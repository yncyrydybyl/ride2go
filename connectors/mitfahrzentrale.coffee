nodeio = require 'node.io'
log = require 'logging'
Place = require('place').Place
Ride = require('ride')
module.exports.details = details =
  mode: "rideshare"
  name: "mitfahrzentrale.de" # uniq primary key
  source: "http://mitfahrzentrale.de"
  author: "flo"
  icon: "mitfahrzentrale.de.png"
  update_frequenz: "10" # in minutes
  expires: ""
  #defaults
  price: "0"
  seats: "1" # free seats
  driver: ""
  telefon: ""
  #specifics
  prefix: "mitfahrzentrale:id"

make_date = (date) ->
  d = new Date(date)
  "#{d.getDay()}.#{d.getMonth()}.#{d.getFullYear()}"
make_url = (ride) ->
  "http://www.mitfahrzentrale.de/suche.php?art=100&frmpost=1&
STARTLAND=D&START=#{escape(ride.origin().city())}&
ZIELLAND=D&ZIEL=#{escape(ride.ziel().city())}&
abdat=#{make_date(ride.departure()) || ''}"

module.exports.findRides = new nodeio.Job
  input: (i, j, run) ->
    return false unless i == 0 # only run once
    ride = Ride.new(@options)
    ride.origin().foreignKeyOrCity "mitfahrzentrale:id", (orig) =>
      ride.destination().foreignKeyOrCity "mitfahrzentrale:id", (dest) =>
        url = "http://www.mitfahrzentrale.de/suche.php?art=100&frmpost=1&
STARTLAND=D&START=#{escape(orig)}&
ZIELLAND=D&ZIEL=#{escape(dest)}&
abdat=#{make_date(ride.departure()) || ''}"
        run [url]

  run: (url) ->
    log.notice url
    @getHtml url, (err, $, data) =>
      rides = []
      for tr in $('tr .tabbody')
        $('td', tr).each (td) -> 0
        row = $('td', tr)
        rides.push
          departure: row[1].text+" "+row[4].text
          origin: row[2].text
          destination: row[3].text
          link: "http://www.mitfahrzentrale.de"+$('a', row[5]).attribs.href
      log.notice "found #{rides.length} rides at mitfahrzentrale.de"
      @emit rides

