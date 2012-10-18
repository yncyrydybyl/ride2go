class Cache
  constructor: () ->
    @cache = {}

  addRide: (ride) ->
    console.log 'cache: new ride'
    console.log ride

    if ride.id
      if @cache[ride.id]
        console.log "cache: skipped double ride #{ride.id}"
        false
      else
        @cache[ride.id] = ride
        true
    else
      console.log 'cache: ride has no id'
      false
Cache.default = new Cache()

$(document).ready ->
  table = $ '#rides'
  table.dataTable( {
    "sPaginationType": "full_numbers",
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
      "aSorting": [[ 3, "desc" ]]
    }
  } );
  socket = io.connect()
  socket.on 'connect', ->
    query    = $ '#query'
    fromKey  = query.attr 'fromKey'
    toKey    = query.attr 'toKey'
    fromName = query.attr 'fromName'
    toName   = query.attr 'toName'
    msg      =
      origin: fromKey
      destination: toKey
      departure: query.attr 'departure'

    socket.on 'ride', (rideJson) ->
      ride = JSON.parse rideJson
      # in backend: fail-fast
      # in frontend: fail-smooth
      if ride.arr < ride.dep
        swp      = ride.dep
        ride.dep = ride.arr
        ride.arr = swp

      if ride.orig != fromKey
        console.log "Ride is not starting at #{fromKey}"
      else if ride.dest != toKey
        console.log "Ride is not leading to #{toKey}"
      else if Cache.default.addRide(ride)
        moment.lang 'de'
        dep     = moment.unix(ride.dep)
        dep_str = dep.format 'DD.MM.YYYY HH:mm'
        arr     = moment.unix(ride.arr)
        arr_str = arr.format 'DD.MM.YYYY HH:mm'
        dur     = ride.arr - ride.dep
        dur_str = moment.unix(dur).utc().format 'HH:mm'
        link    = ride.link
        link    = link && "<a target=\"_blank\" href=\"#{link}\"><img class=\"logo\" src=\"/images/connectors/logo_#{ride.provider}.png\" /></a>"
        link    = '--' if !link
        price   = ride.price
        price   = undefined if price && price.length == 0
        dataRow = [
          fromName,               # Start
          toName,                 # Ziel
          dep_str,                # Abfahrt
          arr_str,                # Ankunft
          dur_str,                # Dauer
          ride.price || 't.b.d.', # Kosten
          link                    # Details
        ]

        table.dataTable().fnAddData dataRow

    socket.emit 'query', msg




