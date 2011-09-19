nodeio = require 'node.io'
log = require 'logging'


IdMap = {}
url = (query) -> "http://www.deinbus.de/fs/result/?
bus_von=#{IdMap[query.orig];"9"}&
bus_nach=#{IdMap[query.dest]}&
passengers=1"

regex = ///
        ab\s(\w{2},\s\d{2}\.\d{2}\.\d{4})
        \s(\d{2}:\d{2}\s)Uhr\n
        an\s(\w{2},\s\d{2}\.\d{2}\.\d{4})
        \s(\d{2}:\d{2}\s)Uhr
        (?:Preis:)?(\d+,\d+\s€)
        (?:Sonderpreis:(\d+,\d+\s€))?
        ///

module.exports.findRides = nodeio.Job
  input: (a, b, run) ->
    log.debug "input"
    return false unless a == 0
    if true
      @get updateIdMapUrl, (err, idMap) ->
        for c in JSON.parse(idMap)
          IdMap[c.name] = c.id
        log.debug "idMap updated."
        run [0]
    else
      run [0]
  run: ->
    rides = []
    log.debug url(@options)
    @getHtml url(@options), (err, $, data) =>
      $('#product-serach-list tr').even (tr) ->
        link = $('td.buchenbutton a', tr).attribs.onclick.split("'")[1]
        if (r = tr.fulltext.match regex)
          rides.push
            dep_date: r[1]
            dep_time: r[2]
            arr_date: r[3]
            arr_time: r[4]
            price: r[6] || r[5]
            link: link
        else log.debug "NOT matched!!! "+tr.fulltext
      @emit rides

updateIdMapUrl = "http://api.scraperwiki.com/api/1.0/datastore/sqlite?format=jsondict&name=deinbusde_city-ids&query=select%20*%20from%20swdata"
