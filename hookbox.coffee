express = require 'express'
nodeio = require 'node.io'
scrapers = require './scrapers'
socketIO = require 'socket.io'

app = express.createServer()
app.set 'views', __dirname
app.set 'view engine', 'jade'
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
    nodeio.start scrapers.dummy, {timeout:100}, ((err, rides) -> 
      socket.emit 'rides', rides
      l rides
    ), true



app.get "/", (req,res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from ? "unkown" , to: req.params.to ? "unkown" }}

app.get "/rides/:from/:to", (req, res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from , to: req.params.to }}

app.post "/rides", (req, res) ->
  l 'posted ride '+req.body.ride
  browser.emit 'ride', {some: req.body.ride}
  res.send "foo"
