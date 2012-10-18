socketIO = require 'socket.io'
express  = require 'express'
sys      = require 'util'
mom      = require 'moment'

Ride     = require './ride'
Place    = require('./place').Place
City     = require('./place').City
Country  = require('./place').Country
RDS      = require './rds'
log      = require './logging'
config   = require './config'
omqapi   = require './services/openmapquest_api'
Location = require('./location').Location

app = express()
app.set 'views', "view"
app.set 'view engine', 'jade'
app.locals.pretty = true
app.use express.bodyParser()
app.use express.static 'public'

log.notice "ride2go: starts with config: \n#{JSON.stringify(config, null, 2)}"
server = app.listen config.server.port
io     = socketIO.listen server
#io.set('log level', 1)

io.sockets.on 'connection', (socket) ->
  log.debug "socket connected"
  socket.on 'query', (query) ->
    try
      log.info "query received -> #{JSON.stringify(query)}"
      unless query.origin
        query.origin = new City("DE:Berlin:Berlin")
      City.find query.origin, (orig) ->
        try
          log.info "found orig: #{orig.key} "
          City.find query.destination, (dest) ->
            try
              log.info "found dest: #{dest.key}"
              RDS.match Ride.new(orig:orig,dest:dest), (matching_ride) ->
                log.debug "emitting ride to client: #{matching_ride}"
                socket.emit 'ride', matching_ride
            catch error
              log.notice "on connection: found dest: #{error}"
        catch error
          log.notice "on connection: found orig: #{error}"
    catch error
      log.notice "on connection: #{error}"

app.get "/", (req,res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from ? "rungestrasse berlin" ,
      to: req.params.to ? "hauptstrasse 42 panketal"
  }}

app.get "/connectors/:name", (req, res) ->
  res.send RDS.get_connector(req.params.name)

app.get "/rides/:from/:to", (req, res) ->
  res.render 'index',  { layout: false, locals: {
      from: req.params.from , to: req.params.to }}

app.post "/rides", (req, res) ->
  browser.emit 'ride', {some: req.body.ride}
  res.send "foo"

app.get '/ridestream', (req, res) ->
  q             = req.query
  departure     = q.departure
  departure     = if departure then parseInt(departure) else mom().utc().unix()
  tolerancedays = q.tolerancedays
  tolerancedays = if tolerancedays then parseInt(tolerancedays) else config.tolerancedays

  placed = (key) -> if key then City.new(key) else undefined
  from   = new Location placed(q.fromKey), q.fromLat, q.fromLon, q.fromplacemark
  to     = new Location placed(q.toKey), q.toLat, q.toLon, q.toplacemark

  locals =
    departure: departure,
    tolerancedays: tolerancedays

  rendered   = false
  sendOutput = () ->
    if from.resolved && to.resolved && !rendered
      if !from.obj
        res.send 500, 'Could not resolve origin'
      else if !to.obj
        res.send 500, 'Could not resolve destination'
      else
        from.putIntoLocals locals, 'fromKey', 'fromLat', 'fromLon'
        to.putIntoLocals locals, 'toKey', 'toLat', 'toLon'

        # console.log "server/ridestream: locals: #{JSON.stringify(locals)}"

        res.render 'ridestream', {
          layout: false,
          locals: locals
        }
        rendered = true

  from.resolve omqapi.default, sendOutput
  to.resolve omqapi.default, sendOutput
