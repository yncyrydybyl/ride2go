socketIO = require 'socket.io'
express = require 'express'
Ride = require './ride'
RDS = require './rds'

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

io.sockets.on 'connection', (socket) ->
  l "connected"
  socket.on 'query', (query) ->
    RDS.match new Ride(query), (matching_rides) ->
      socket.emit 'rides', matching_rides

app.get "/", (req,res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from ? "rungestrasse berlin" ,
      to: req.params.to ? "hauptstrasse 42 panketal"
  }}

app.get "/rides/:from/:to", (req, res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from , to: req.params.to }}

app.post "/rides", (req, res) ->
  l 'posted ride '+req.body.ride
  browser.emit 'ride', {some: req.body.ride}
  res.send "foo"
