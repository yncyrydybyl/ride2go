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
    $("#start_splash").hide()
  else if mode == "result"
    $("#middle_overlay, #to_input, #from_input").hide()
    $("#options").show()
    $("#rides").show()

  App.mode = mode
 
  # for debugging
  console.log("switching from "+lastmode+" to " +mode)
  $("#mode ul li."+mode).addClass("mode_active")
  $("#mode ul li."+lastmode).removeClass("mode_active")
  #console.log($("#mode ul li."+mode))


initInputBox = (params = {region:"de",direction:"to",selector:"#from_input_field", showpanel:true}) ->
  if not $("#"+params.direction+"_panel").is(":visible") and params.showpanel
    $("#"+params.direction+"_panel").fadeTo "20000", 0.33
    console.log("showing panel")
  console.log "initInputBox called with parameter: "
  #removing any autocomplete functionality 
  console.log($(params.selector))
  inputbox = $(params.selector).geo_autocomplete
    geocoder_region: params.region
    geocoder_address: true
    geocoder_types: App.geotypes.join(",")
    mapheight: 200
    mapwidth: 200
    noCache: true
    MapTypeIdaptype: "hybrid"
    select: (event, ui) ->
      inputdone params.direction, ui.item
      #console.log ui.item.viewport.getCenter()
    params: params
  $(params.selector).focus()
  $(params.selector).keydown ->
    if not $("#"+params.direction+"_panel").is(":visible")
      $("#"+params.direction+"_panel").fadeTo "20000", 0.33 
  
  #$(inputbox).autocomplete "search"

displayride = (ride) ->
  ride = JSON.parse(ride)
  $("#ride").append $("<div>provider: #{ride.provider} <a target='_blank' href='#{ride.link}'>visit</a></div>")

inputdone = (d, item) ->
  console.log(d+" selected")
  # show the panel as selected
  $("#"+d+"_panel").fadeTo("slow", 1)
  if d is "to"
    App.to = item
    $("#to_input").hide()
    switchmode "from"
    initInputBox
      region: "de"
      direction: "from"
      selector: "#from_input_field"
      showpanel: true
  if d is "from"
    App.from = item
    switchmode "result"


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
  setupsocket()
  # manual switcher for debugging
  $("#mode .to").click -> switchmode "to", App.mode
  $("#mode .from").click -> switchmode "from", App.mode
  $("#mode .splash").click -> switchmode "splash", App.mode
  $("#mode .result").click -> switchmode "result", App.mode
  $("#to_input_field").focus()
  initInputBox({region:"de",direction:"to",selector:"#to_input_field",showpanel:false})
