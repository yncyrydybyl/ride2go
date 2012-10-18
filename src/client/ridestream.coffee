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
      "sSearch":       "Suchen",
      "sUrl":          "",
      "oPaginate": {
        "sFirst":    "Erste",
        "sPrevious": "Zurück",
        "sNext":     "Nächste",
        "sLast":     "Letzte"
      },
      "aSorting": [[ 3, "asc" ]]
    }
  } );
  socket = io.connect()
  socket.on 'connect', ->
    query   = $ '#query'
    fromKey = query.attr 'fromKey'
    toKey   = query.attr 'toKey'
    msg     =
      origin: fromKey
      destination: toKey
      departure: query.attr 'departure'

    socket.on 'ride', (rideJson) ->
      ride = JSON.parse rideJson
      if Cache.default.addRide(ride)
        moment.lang 'de'
        mom_dep = moment.unix ride.dep
        dep     = mom_dep.format 'DD.MM.YYYY HH:MM'
        mom_arr = moment.unix ride.arr
        arr     = mom_arr.format 'DD.MM.YYYY HH:MM'
        mom_dur = moment.unix mom_dep.diff(mom_arr)
        dur     = mom_dur.format 'HH:MM'

        link    = ride.link
        link    = if link then "<a href=\"#{link}\"><img src=\"http://test.fahrgemeinschaft.de/gfx/ico/info.gif\" /></a>" else '--'

        dataRow = [
          ride.orig,        # Start
          ride.provider,    # Anbieter
          ride.dest,        # Ziel
          dep,              # Abfahrt
          arr,              # Ankunft
          dur,              # Dauer
          ride.price || '', # Kosten
          link              # Details
        ]

        table.dataTable().fnAddData dataRow

    socket.emit 'query', msg




