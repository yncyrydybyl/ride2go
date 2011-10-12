#global variables
App =
  to: {}
  from: {}
  socket: {}
  geotypes: ["locality","sublocality","street_address","route"]
  # "locality", "premise", "subpremise", "route", "street_address
  mode: "splash"


switchmode = (mode, lastmode) ->
  if mode == "to"
    $("#to_input, #to_panel").show()
    $("#start_splash").hide()
  else if mode == "from"
    $("#from_input, #from_panel").show()
  else if mode == "result"
    $("#options").show()
    $("#rides").show()
  else if mode == "splash"
    $("#start_splash").show()
    $("#from_input,#from_panel,#from_panel,#to_input,#to_panel").hide()

  App.mode = mode
 
  # for debugging
  console.log("switching from "+lastmode+" to " +mode)
  $("#mode ul li."+mode).addClass("mode_active")
  $("#mode ul li."+lastmode).removeClass("mode_active")
  console.log($("#mode ul li."+mode))


initInputBox = (params = {region:"de",direction:"to",selector:"#to_input input"}) ->
  inputbox = $(params.selector).geo_autocomplete
    geocoder_region: params.region
    geocoder_address: true
    geocoder_types: App.geotypes.join(",")
    mapheight: 200
    mapwidth: 200
    MapTypeIdaptype: "hybrid"
    select: (event, ui) ->
      inputdone params.direction, ui.item
      #console.log ui.item.viewport.getCenter()
    params: params
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
  console.log(d+" selected")
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
  App.socket.on "disconnect", ->
    $("#status").html("disconnected")
    $("#status").effect("pulsate")
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

send = (msg) -> 
    App.socket.emit "debug", msg 

sendquery = ->
    console.log("send query to server")
    send App.from
    send App.to
    #socket.emit "query", {origin:from, destination: to}
    payload = {origin:App.from, destination:App.to}
    console.log("payload: VVV ")
    console.log(payload)
    App.socket.emit "query",payload 

displayRide = (ride) ->
      $("#rides").append $("<div>provider: #{ride.provider} <a target='_blank' href='#{ride.link}'>visit</a></div>")

$().ready ->
  socket = setupsocket()
  # manual switcher for debugging
  $("#mode .to").click -> switchmode "to", App.mode
  $("#mode .from").click -> switchmode "from", App.mode
  $("#mode .splash").click -> switchmode "splash", App.mode
  $("#mode .result").click -> switchmode "result", App.mode

  initInputBox({region:"de",direction:"to",selector:"#inputbox input"})
