socketIO = require 'socket.io'
express = require 'express'
Ride = require './ride'
RDS = require './rds'
winston = require 'winston'

app = express.createServer()
app.set 'views', __dirname
app.set 'view engine', 'jade'
app.set 'view options', {pretty:true}
app.use express.bodyParser()
app.use express.static __dirname+'/public'

log = new winston.Logger
  levels: winston.config.syslog.levels
  transports: [
    new winston.transports.Console
      level: "debug" 
      colorize: on
    new winston.transports.File
       level: "error"
       filename: 'logs/error.log'
       colorize: on
  ]

app.listen 3000, ->
  addr = app.address()
  log.info '  app listening on http://' + addr.address + ':' + addr.port

io = socketIO.listen app

io.sockets.on 'connection', (socket) ->
  l "connected"
  socket.on 'query', (query) ->
    console.log "QUERY: "+query
    RDS.match new Ride(query), (matching_rides) ->
      for ride in matching_rides
        console.log ride
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
  l 'posted ride '+req.body.ride
  browser.emit 'ride', {some: req.body.ride}
  res.send "foo"
