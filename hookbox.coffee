express = require 'express'
socket = require 'socket.io'

app = express.createServer()
app.set 'views', __dirname
app.set 'view engine', 'jade'
app.use express.static __dirname+'/public'

app.listen 3000

io = socket.listen app
browser = 0

io.sockets.on 'connection', (client) ->
  console.log "connected"
  client.emit 'ride', {ride: 'foobar'}
  browser = client
  #f()
 
app.get "/rides/:from/:to", (req, res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from, to: req.params.to }}

app.post "/rides", (req, res) ->
  console.log 'posted ride'
  browser.emit 'ride', {some: 'foobar'}
  res.send "foo"

f = () ->
  setTimeout (() -> f(); browser.emit 'ride', 'foo'), 2000
