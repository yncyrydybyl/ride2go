setgeotypes = (boxname, types) ->
  $.each types, (i, b) ->
    $("input[name='" + boxname + "'][value='" + b + "']").attr "checked", true

geotypes = (direction) ->
  $("input[name=where" + direction + "]:checked").map(->
    @value
  ).get()

initInputBox = (params) ->
  params ?=
    region: "de"
    direction: "to"
  params.region ?= "de"
  params.direction ?= "to"

  inputbox = $("#where" + params.direction + "box").geo_autocomplete(
    geocoder_region: params.region
    geocoder_address: true
    geocoder_types: geotypes(params.direction).join(",")
    mapheight: 200
    mapwidth: 200
    MapTypeIdaptype: "hybrid"
    select: (event, ui) ->
      inputdone params.direction, ui.item
      console.log ui.item.viewport.getCenter()
  )
  $(inputbox).autocomplete "search"

fillfrom = (place) -> 
  $("#from .address").html(place.cityname)
fillto = (place) -> 
  $("#to .address").html(place.cityname)

inputdone = (d, item) ->
  if d is "to" then toselected(item)
  if d is "from" then fromselected(item)

  #$("#where" + d).text d + ": " + $("#where" + d + "box").val()

setupsocket = ->
  socket = io.connect()
  socket.on "rides", (rides) ->
    for ride in rides
      alert ride.provider
      console.log(ride)
      $("#rides").append $("<div>provider: #{ride.provider} <a target='_blank' href='#{ride.link}'>visit</a></div>")
    
  socket.on "connect", ->
    $("#status").html("connected")
    $("#status").effect("pulsate")
  socket.on "disconnect", ->
    $("#status").html("disconnected")
    $("#status").effect("pulsate")
    # only for debug we fire the query instantly
    # socket.emit "query", {origin:"hamburg", destination: "berlin"}
  return socket

toselected = (item) ->
    fillto({cityname:item.value})
    $("#whereto").hide()
    $("#wherefrom").show()

    to = item.value
    initInputBox
      region: "de"
      direction: "from"
    sendquery()

    
fromselected = (item) ->
    from = item.value
    $("#wherefrom").hide()
    fillfrom({cityname:from})
    console.log "from selected"
    sendquery()

sendquery = ->
    socket.emit "query", {origin:from, destination: to}
    console.log("query"+ {origin:from, destination: to})

#global variables
to = {}
from = {}
socket = {}

$().ready ->
  setgeotypes "whereto", [ "locality", "premise", "subpremise", "route", "street_address" ]
  setgeotypes "wherefrom", [ "locality", "route", "premise", "subpremise", "locality" ]
  socket = setupsocket()
  initInputBox 
    region: "de"
    direction: "to"
 
  $.each [ "to", "from" ], (i, d) ->
    $("#where" + d + " input").change ->
      initInputBox direction: d
    
    $("#where" + d + " .switcher").toggle (->
      $(this).html "- hide options"
      $(this).parent().children(".details").show 100
    ), ->
      $(this).html "+ show options"
      $(this).parent().children(".details").hide 200