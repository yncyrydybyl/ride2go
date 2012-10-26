# Cache of rides that have been delivered to the browser before,
# mainly used to filter out duplicates and rides that errorneously
# do not have a unique id
#
class Cache
  constructor: () ->
    @cache = {}

  addRide: (ride) ->
    if ride.id
      if @cache[ride.id]
        console.log "cache: skipped double ride #{ride.id}"
        false
      else
        console.log "cache: added new ride #{ride.id}"
        @cache[ride.id] = ride
        true
    else
      console.log 'cache: ignored ride without an id'
      false

Cache.default = new Cache()

initRidestreamTable = (query, table) ->
  # Builder for column renderers for column colNr that contain moments that should be displayed
  # using formatStr
  momColData = (colNr, formatStr) =>
    # Actual renderer for row arrays src
    (src, type, val) =>
      if type == 'set'
        src[colNr] = moment val, formatStr
      else
        if (type == 'display') || (type == 'filter')
          src[colNr].format formatStr
        else
          src[colNr]

  table.dataTable( {
    "sPaginationType": "full_numbers",
    "aaSorting": [[ 2, "asc" ]],
    "aoColumnDefs": [ {
      "aTargets": [ 2 ],
      "mData": momColData 2, 'DD.MM.YYYY HH:mm'
    }, {
      "aTargets": [ 3 ],
      "mData": momColData 3, 'DD.MM.YYYY HH:mm'
    }, {
      "aTargets": [ 4 ],
      "mData": momColData 4, 'HH:mm'
    } ],
    "oLanguage": {
      "sProcessing":   "Bitte warten...",
      "sLengthMenu":   "_MENU_ Einträge anzeigen",
      "sZeroRecords":  "Keine Einträge vorhanden.",
      "sInfo":         "_START_ bis _END_ von _TOTAL_ Einträgen",
      "sInfoEmpty":    "0 bis 0 von 0 Einträgen",
      "sInfoFiltered": "(gefiltert von _MAX_  Einträgen)",
      "sInfoPostFix":  "",
      "sSearch":       "Suche eingrenzen",
      "sUrl":          "",
      "oPaginate": {
        "sFirst":    "Erste",
        "sPrevious": "Zurück",
        "sNext":     "Nächste",
        "sLast":     "Letzte"
      },
    }
  } );
  socket = io.connect()
  socket.on 'connect', ->
    fromKey   = query.attr 'fromKey'
    toKey     = query.attr 'toKey'
    fromName  = query.attr 'fromName'
    toName    = query.attr 'toName'
    departure = parseInt query.attr('departure')
    leftcut   = parseInt query.attr('leftcut')
    rightcut  = parseInt query.attr('rightcut')
    logRides  = query.attr 'logRides'

    msg      =
      origin: fromKey
      destination: toKey
      departure: departure

    moment.lang 'de'

    socket.on 'ride', (rideJson) ->
      ride = JSON.parse rideJson
      # in backend: fail-fast
      # in frontend: fail-smooth
      if ride.arr < ride.dep
        swp      = ride.dep
        ride.dep = ride.arr
        ride.arr = swp

      console.log "received ride: #{JSON.stringify(ride)}" if logRides

      if ride.orig != fromKey
        console.log "Ride is not starting at #{fromKey}"
      else if ride.dest != toKey
        console.log "Ride is not leading to #{toKey}"
      else if ride.dep < leftcut
        console.log "Ride is too old: #{ride.dep} < #{leftcut}"
      else if ride.dep > rightcut
        console.log "Ride is to far out in the future: #{ride.dep} > #{rightcut}"
      else if Cache.default.addRide(ride)
        moment.lang 'de'
        dep     = moment.unix(ride.dep)
        arr     = moment.unix(ride.arr)
        dur     = moment.unix(ride.arr - ride.dep).utc()
        link    = ride.link
        link    = link && "<a href=\"#{link}\"><img class=\"logo\" src=\"/images/connectors/logo_#{ride.provider}.png\" /></a>"
        link    = '--' if !link
        price   = ride.price
        price   = undefined if price && price.length == 0
        dataRow = [
          fromName,               # Start
          toName,                 # Ziel
          dep,                    # Abfahrt
          arr,                    # Ankunft
          dur,                    # Dauer
          ride.price || 't.b.d.', # Kosten
          link                    # Details
        ]

        table.dataTable().fnAddData dataRow
        table.dataTable().fnSort [[ 2, "asc" ]]

    socket.emit 'query', msg
    table.dataTable().fnSort [[ 2, "asc" ]]
    return socket



