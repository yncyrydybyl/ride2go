express = require 'express'
nodeio = require 'node.io'
connectors = require './connectors'
socketIO = require 'socket.io'

app = express.createServer()
app.set 'views', __dirname
app.set 'view engine', 'jade'
app.set 'view options', {pretty:true}
app.use express.bodyParser()
app.use express.static __dirname+'/public'

#debug
l = console.log

app.listen 3000, -> 
  addr = app.address()
  l '  app listening on http://' + addr.address + ':' + addr.port


io = socketIO.listen app
ridesearches = {}
#browser = 0

io.sockets.on 'connection', (socket) ->
  l "connected"
  socket.on 'query', (query)->
    nodeio.start connectors.raummobil, query, ((err, rides) -> 
      socket.emit 'rides', rides
      console.log(rides)
    ), true

app.get "/", (req,res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from ? "berlin" , to: req.params.to ? "hamburg" }}

app.get "/rides/:from/:to", (req, res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from , to: req.params.to }}

app.post "/rides", (req, res) ->
  l 'posted ride '+req.body.ride
  browser.emit 'ride', {some: req.body.ride}
  res.send "foo"
