socketIO = require 'socket.io'
express = require 'express'
Ride = require './ride'
RDS = require './rds'
log = require './lib/logging'
sys = require 'sys'

app = express.createServer()
app.set 'views', __dirname
app.set 'view engine', 'jade'
app.set 'view options', {pretty:true}
app.use express.bodyParser()
app.use express.static __dirname+'/public'

app.listen 3000, ->
  addr = app.address()
  log.info '  app listening on http://' + addr.address + ':' + addr.port

io = socketIO.listen app
io.set('log level', 1)

io.sockets.on 'connection', (socket) ->
  log.debug "socket connected"
  socket.on 'query', (query) ->
    log.info "query received -> #{sys.inspect(query)}"
    RDS.match new Ride(query), (matching_rides) ->
      log.info "callback from RDS for ", matching_rides.length
      log.debug "callback from RDS", matching_rides
      for ride in matching_rides
        socket.emit 'ride', ride

app.get "/", (req,res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from ? "rungestrasse berlin" ,
      to: req.params.to ? "hauptstrasse 42 panketal"
  }}

app.get "/rides/:from/:to", (req, res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from , to: req.params.to }}

app.post "/rides", (req, res) ->
  browser.emit 'ride', {some: req.body.ride}
  res.send "foo"
