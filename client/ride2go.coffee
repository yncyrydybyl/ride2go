#global variables
App =
  to: {}
  from: {}
  socket: {}
  from_choosen: false
  to_choosen: false
  geotypes: ["locality","sublocality","street_address","route"]
  # "locality", "premise", "subpremise", "route", "street_address
  mode: "splash"


switchmode = (mode, lastmode=App.mode) ->
  if mode is lastmode
    console.log("switchmode changed nothin'. because lastmode was: "+ lastmode + " and new mode is " +mode)
    return
  if mode == "to"
    $("#from_input").hide()
    $("#to_input, #middle_overlay").show()
    activatepanel("#to_panel")
    $("to_input_field").autocomplete "search"
  else if mode == "from"
    $("#to_input").hide()
    $("#from_input, #middle_overlay").show()
    activatepanel("#from_panel")
    $("from_input_field").autocomplete "search"
  else if mode == "result"
    $("#middle_overlay, #to_input, #from_input").hide()
    $("#options").show()
    $("#rides").show()
  if lastmode is "to" or lastmode is "from"
    deactivatepanel "##{lastmode}_panel"
  App.mode = mode
 
  # for debugging
  console.log("switching from "+lastmode+" to " +mode)
  $("#mode ul li."+mode).addClass("mode_active")
  $("#mode ul li."+lastmode).removeClass("mode_active")
  #console.log($("#mode ul li."+mode))

activatepanel = (panel_id) ->
  $(panel_id).fadeTo "20000", 0.33 
deactivatepanel = (panel_id) ->
  console.log(panel_id + " deactivated")
  $(panel_id).fadeTo "20000" ,1 


initInputBox = (params = {region:"de",direction:"to",selector:"#from_input_field", showpanel:true}) ->
  if not $("#"+params.direction+"_panel").is(":visible") and params.showpanel
    activatepanel("#"+params.direction+"_panel")
    console.log("showing panel")
  console.log "initInputBox called with parameter: "
  #removing any autocomplete functionality 
  console.log($(params.selector))
  inputbox = $(params.selector).geo_autocomplete
    geocoder_region: params.region
    geocoder_address: true
    geocoder_types: App.geotypes.join(",")
    mapheight: 120
    mapwidth: 120
    noCache: true
    MapTypeIdaptype: "hybrid"
    select: (event, ui) ->
      inputdone params.direction, ui.item
      #console.log ui.item.viewport.getCenter()
    params: params
  $(params.selector).focus()
  $(params.selector).keydown ->
    if not $("#"+params.direction+"_panel").is(":visible")
      activatepanel("#"+params.direction+"_panel")
  
  $(params.selector).autocomplete "search"

displayride = (ride) ->
  ride = JSON.parse(ride)
  $("#rides ul").append $("<li>#{ride.orig} -> #{ride.dest} provider: #{ride.provider} <a target='_blank' href='#{ride.id}'>visit</a></li>")

inputdone = (d, item) ->
  console.log(d+" selected")
  # show the panel as selected
  $("#"+d+"_panel").fadeTo("slow", 1)
  if d is "to"
    App.to = item
    App.to_choosen = true
    $("#to_input").hide()
    if not App.from_choosen
      switchmode "from", "to"
      initInputBox
        region: "de"
        direction: "from"
        selector: "#from_input_field"
        showpanel: true
  if d is "from"
    App.from_choosen = true
    App.from = item
    switchmode "result", "from"

  console.log("from and to")
  sendquery()
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
    return unless App.from.geoobject and App.to.geoobject
    console.log("send query to server")
    #send App.from
    #send App.to.geoobject
    #socket.emit "query", {origin:from, destination: to}
    payload = {origin:App.from.geoobject, destination:App.to.geoobject}
    App.socket.emit "query",payload

$().ready ->
  setupsocket()
  # manual switcher for debugging
  $("#mode .to").click -> switchmode "to", App.mode
  $("#mode .from").click -> switchmode "from", App.mode
  $("#mode .splash").click -> switchmode "splash", App.mode
  $("#mode .result").click -> switchmode "result", App.mode
  $("#edit_from_input").click -> switchmode "from", App.mode
  $("#edit_to_input").click -> switchmode "to", App.mode
  $("#to_input_field").focus()
  initInputBox({region:"de",direction:"to",selector:"#to_input_field",showpanel:false})
