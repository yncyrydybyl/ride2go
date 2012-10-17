socketIO = require 'socket.io'
express  = require 'express'
sys      = require 'util'
mom      = require 'moment'

Ride    = require './ride'
City    = require('./place').City
RDS     = require './rds'
log     = require './logging'
config  = require './config'
omqapi  = require './services/openmapquest_api'

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
        query.origin = new City("DE:Berlin:Berlin") # geocoding serverbased
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
  getLocation = (key, lat, lon, placemark_str) ->
    return { key: key } if key
    return { lat: lat, lon: lon } if lat && lon
    return undefined if !placemark_str
    placemark = JSON.parse placemark_str
    return { lat: placemark.Latitude, lon: placemark.Longitude }

  putLocation = (locals, keyName, latName, lonName, location) ->
    locals[keyName] = location.key if location.key
    locals[latName] = location.lat if location.lat
    locals[lonName] = location.lon if location.lon

  departure     = req.query.departure
  departure     = if departure then parseInt(departure) else mom().utc().unix()
  tolerancedays = req.query.tolerancedays
  tolerancedays = if tolerancedays then parseInt(tolerancedays) else 3

  from   = getLocation req.query.fromKey, req.query.fromLat, req.query.fromLon, req.query.fromplacemark
  to     = getLocation req.query.toKey, req.query.toLat, req.query.toLon, req.query.toplacemark

  locals        = {
    departure: departure,
    tolerancedays: tolerancedays
  }

  fromKeyResolved = false
  toKeyResolved   = false

  sendOutput    = () =>
    if fromKeyResolved && toKeyResolved
      putLocation locals, 'fromKey', 'fromLat', 'fromLon', from
      putLocation locals, 'toKey', 'toLat', 'toLon', to

      console.log "server/ridestream: locals: #{JSON.stringify(locals)}"

      res.render 'ridestream', {
        layout: false,
        locals: locals
      }
      rendered = true

  if from.key
    fromKeyResolved   = true
  else
    omqapi.default.reverseGeocode from.lat, from.lon, (resolvedKey) =>
      from.key        = resolvedKey
      fromKeyResolved = true
      sendOutput()

  if to.key
    toKeyResolved = true
  else
    omqapi.default.reverseGeocode to.lat, to.lon, (resolvedKey) =>
      to.key        = resolvedKey
      toKeyResolved = true
      sendOutput()

  sendOutput()