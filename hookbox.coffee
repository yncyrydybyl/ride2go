express = require 'express'
socket = require 'socket.io'
nodeio = require 'node.io'
scrapers = require './scrapers'

app = express.createServer()
app.set 'views', __dirname
app.set 'view engine', 'jade'
app.use express.bodyParser()
app.use express.static __dirname+'/public'

app.listen 3000

io = socket.listen app
browser = 0

nodeio.start scrapers.raummobil, {timeout:100}, ((err, out) -> console.log out), true

io.sockets.on 'connection', (client) ->
  console.log "connected"
  client.emit 'ride', {ride: 'foobar'}
  browser = client
   
app.get "/rides/:from/:to", (req, res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from, to: req.params.to }}

app.post "/rides", (req, res) ->
  console.log 'posted ride '+req.body.ride
  browser.emit 'ride', {some: req.body.ride}
  res.send "foo"

f = () ->
  setTimeout (() -> f(); browser.emit 'ride', 'foo'), 2000
