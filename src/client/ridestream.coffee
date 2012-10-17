$(document).ready ->
  table = $('#rides')
  table.dataTable( {
    "sPaginationType": "full_numbers"
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
      dep     = moment.unix(ride.dep).format('LLL')
      arr     = moment.unix(ride.arr).format('LLL')

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




