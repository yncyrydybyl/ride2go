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


initInputBox = (params) ->
  alert "dsjka"
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
    params: params

displayride = (ride) ->
  console.log("foook")
  ride = JSON.parse(ride)
  console.log(ride)
  arr=new Date(ride.arr)
  dep=new Date(ride.dep)
  #$("#rides ul").append $("<li>#{dep.toLocaleDateString()}:#{dep.toLocaleTimeString()}:#{ride.orig} -> #{ride.dest} provider: #{ride.provider} <a target='_blank' href='#{ride.id}'>visit</a></li>")
  $("#rides").dataTable().fnAddData( [
    ride.dep
    ride.orig
    ride.dest
    ride.provider
    ride.arr
  ]
  )

inputdone = (d, item) ->
  # show the panel as selected
  if d is "to"
    App.to = item
    App.to_choosen = true
  if d is "from"
    App.from_choosen = true
    App.from = item

  console.log("from and to")
  sendquery()
setupsocket = ->
  App.socket = io.connect()
  App.socket.on "ride", (ride) ->
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
  $("#rides").dataTable(
    "bPaginate": false
    "bLengthChange": false
    "bFilter": false
    "bSort": false
    "bInfo": false
    "bAutoWidth": false
  )
  $("#to_input_field").focus()
  initInputBox({region:"de",direction:"to",selector:"#to_input_field",showpanel:false})
  initInputBox({region:"de",direction:"from",selector:"#from_input_field",showpanel:false})
