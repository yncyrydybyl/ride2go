setgeotypes = (boxname, types) ->
  $.each types, (i, b) ->
    $("input[name='" + boxname + "'][value='" + b + "']").attr "checked", true
geotypes = (direction) ->
  $("input[name=where" + direction + "]:checked").map(->
    @value
  ).get()
initInputBox = (params) ->
  params = (if typeof (params) != "undefined" then params else 
    region: "de"
    direction: "to"
  )
  params.region = (if typeof (params.region) != "undefined" then params.region else "de")
  params.direction = (if typeof (params.direction) != "undefined" then params.direction else "to")
  inputbox = $("#where" + params.direction + "box").geo_autocomplete(
    geocoder_region: params.region
    geocoder_address: true
    geocoder_types: geotypes(params.direction).join(",")
    mapheight: 100
    mapwidth: 200
    MapTypeIdaptype: "hybrid"
    select: (event, ui) ->
      l ui.item
      setchannel()
      inputdone params.direction
  )
  $(inputbox).autocomplete "search"
inputdone = (d) ->
  $("#where" + d).text d + ": " + $("#where" + d + "box").val()
setchannel = ->
  socket = io.connect()
  socket.on "rides", (rides) ->
    $("#rides").append $("<div>" + rides + "</div>")
    l (ride: rides)
  
  socket.on "connect", ->
    $("#rides").append $("<p>connected</p>")
    # only for debug we fire the query instantly
    socket.emit "query", {origin:"hamburg", destination: "berlin"}
#l = (msg) ->
#  console.log msg
`function l(msg) {console.log(msg)};`

$().ready ->
  setgeotypes "whereto", [ "locality", "premise", "subpremise", "route" ]
  setgeotypes "wherefrom", [ "locality", "route", "premise", "subpremise", "locality" ]
  setchannel()
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
