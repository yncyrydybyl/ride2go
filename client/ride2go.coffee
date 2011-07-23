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

inputdone = (d, item) ->
  if d is "to" then toselected(item)
  if d is "from" then fromselected(item)

  #$("#where" + d).text d + ": " + $("#where" + d + "box").val()

setupsocket = ->
  socket = io.connect()
  socket.on "rides", (rides) ->
    $("#rides").append $("<div>" + rides + "</div>")
  
  socket.on "connect", ->
    $("#rides").append $("<p>connected</p>")
    # only for debug we fire the query instantly
    # socket.emit "query", {origin:"hamburg", destination: "berlin"}
  return socket

toselected = (item) ->
    console.log "'to:' "+item.value+" selected"
    console.log item
    $("#whereto").hide()
    $("#to").show()
    socket.emit "query", {origin:$("#wherefrom").val(), destination: $("#wheretobox").val()}

fromselected = ->
    console.log "from selected"

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
  
  initInputBox 
    region: "de"
    direction: "from"
 
  $.each [ "to", "from" ], (i, d) ->
    $("#where" + d + " input").change ->
      initInputBox direction: d
    
    $("#where" + d + " .switcher").toggle (->
      $(this).html "- hide options"
      $(this).parent().children(".details").show 100
    ), ->
      $(this).html "+ show options"
      $(this).parent().children(".details").hide 200
