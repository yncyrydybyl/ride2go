$(document).ready ->
  table = $('#rides')
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
    query   = $('#query')
    fromKey = query.attr('fromKey')
    toKey   = query.attr('toKey')
    msg   = {
      origin: fromKey
      destination: toKey
      departure: query.attr('departure')
    }
    socket.on 'ride', (rideJson) ->
      ride    = JSON.parse rideJson

      moment.lang 'de'
      dep     = moment.unix(ride.dep).format('DD.MM.YYYY HH:MM')
      arr     = moment.unix(ride.arr).format('DD.MM.YYYY HH:MM')

      link    = ride.link
      link    = if link then "<a href=\"#{link}\"><img src=\"http://test.fahrgemeinschaft.de/gfx/ico/info.gif\" /></a>" else '--'

      dataRow = [
        ride.orig,        # Start
        ride.provider,    # Anbieter
        ride.dest,        # Ziel
        dep,              # Abfahrt
        arr,              # Ankunft
        ride.price || '', # Kosten
        link              # Details
      ]

      console.log dataRow
      table.dataTable().fnAddData dataRow

    socket.emit 'query', msg




