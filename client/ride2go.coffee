#global variables
App =
  to: {}
  from: {}
  socket: {}

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
      #console.log ui.item.viewport.getCenter()
  )
  $(inputbox).autocomplete "search"

#setting up the ui
fillfrom = (place) ->
  $("#whereto").hide()
  $("#wherefrom").show()
  $("#from .address").html(place)

fillto = (place) ->
  $("#to .address").html(place)

displayride = (ride) ->
  ride = JSON.parse(ride)
  $("#ride").append $("<div>provider: #{ride.provider} <a target='_blank' href='#{ride.link}'>visit</a></div>")


inputdone = (d, item) ->
  if d is "to" then toselected(item)
  if d is "from" then fromselected(item)

setupsocket = ->
  App.socket = io.connect()
  App.socket.on "ride", (ride) ->
    console.log(ride)
    displayride(ride)
   
  App.socket.on "connect", ->
    $("#status").html("connected")
    $("#status").effect("pulsate")
    #socket.emit "query", {origin:"hamburg", destination: "berlin"}
  App.socket.on "disconnect", ->
    $("#status").html("disconnected")
    $("#status").effect("pulsate")
    # only for debug we fire the query instantly
  return App.socket

toselected = (item) =>
    fillto item.value
    console.log("to selected")
    console.log(item)
    App.to = item
    initInputBox
      region: "de"
      direction: "from"
    sendquery()

    
fromselected = (item) ->
    App.from = item
    $("#wherefrom").hide()
    fillfrom item.value
    console.log "from selected"
    sendquery()

fuck = (msg) -> 
    App.socket.emit "debug", msg 

sendquery = ->
    console.log("send query to server")
    fuck App.from
    fuck App.to
    #socket.emit "query", {origin:from, destination: to}
    payload = {origin:App.from, destination:App.to}
    console.log("payload: VVV ")
    console.log(payload)
    App.socket.emit "query",payload 

displayRide = (ride) ->
      $("#rides").append $("<div>provider: #{ride.provider} <a target='_blank' href='#{ride.link}'>visit</a></div>")

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
