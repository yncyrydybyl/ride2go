socketIO = require 'socket.io'
express  = require 'express'
sys      = require 'util'
mom      = require 'moment'
__       = require 'underscore'

Ride     = require './ride'
Place    = require('./place').Place
City     = require('./place').City
Country  = require('./place').Country
RDS      = require './rds'
log      = require './logging'
config   = require './config'
omqapi   = require './services/openmapquest_api'
Location = require('./location').Location
helpers  = require('./input_helpers')

app = express()
app.set 'views', "view"
app.set 'view engine', 'jade'
app.locals.pretty = true
app.use express.bodyParser()
app.use express.static 'public'

log.notice "ride2go: starts with config: \n#{JSON.stringify(config, null, 2)}"
server = app.listen config.server.port

# *** socket.io

cache = require('./socket_cache').instance

io = socketIO.listen server
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
              cache.registerSocket "#{orig.key}->#{dest.key}", socket
              RDS.match Ride.new(orig:orig, dest:dest), (matching_ride) ->
                log.debug "emitting ride to client: #{Ride.showcase(matching_ride)}"
                socket.emit 'ride', matching_ride
            catch error
              log.notice "on connection: found dest: #{error}"
        catch error
          log.notice "on connection: found orig: #{error}"
    catch error
      log.notice "on connection: #{error}"

# *** JSON API

require('./server_docs') app, config

# [X] documented in server_docs
app.get "/api/sockets/_all", (req, res) ->
  res.send JSON.stringify cache.asJson()

# [X] documented in server_docs
app.get "/api/sockets/:from/to/:to", (req, res) ->
  res.send JSON.stringify cache.asJson("#{req.params.from}->#{req.params.to}")

# [X] documented in server_docs
app.get "/api/connectors/_all", (req, res) ->
  res.send JSON.stringify(RDS.api.all_connectors())

# [X] documented in server_docs
app.get "/api/connectors/_enabled", (req, res) ->
  res.send JSON.stringify(RDS.api.enabled_connectors())

# [X] documented in server_docs
app.get "/api/connectors/_ingesting", (req, res) ->
  res.send JSON.stringify(RDS.api.ingesting_connectors())

# [X] documented in server_docs
app.get "/api/connectors/_scraping", (req, res) ->
  res.send JSON.stringify(RDS.api.scraping_connectors())

# [X] documented in server_docs
app.get "/api/connectors/_disabled", (req, res) ->
  res.send JSON.stringify(RDS.api.disabled_connectors())

# [X] documented in server_docs
app.get "/api/connectors/:name", (req, res) ->
  result = RDS.get_connector_details(req.params.name)
  if result then res.send(result) else res.send 404, 'Unknown connector'

# [X] documented in server_docs
app.post "/api/connectors/:name/rides", (req, res) ->
  name  = req.params.name
  conn  = RDS.get_connector name
  rides = req.body
  if !conn
    res.send 404, 'Unknown connector'
  else if !conn.details.ingesting
    res.send 500, 'Connector does not support ingestion'
  else if !rides || !__.isArray(rides)
    res.send 404, "Missing or invalid rides (body = #{req.body})"
  else
    RDS.ingest name, conn, rides, (err, result) ->
      if err then res.send(500, err) else res.send(JSON.stringify(result))


# *** HTML / UI

app.get "/", (req,res) ->
  res.render 'index', { layout: false, locals: {
      fromStr: req.params.fromStr ? "DE:Berlin:Berlin" ,
      toStr: req.params.toStr ? "DE:Hamburg:Hamburg"
  }}

app.get '/ridestream', (req, res) ->
  q         = req.query
  departure = helpers.intify q.departure, () -> mom().utc().unix()
  tdays     = helpers.intify q.tolerancedays, () -> config.server.tolerancedays
  leftcut   = helpers.intify q.leftcut, () => mom.unix(departure).subtract('days', tdays).unix()
  rightcut  = helpers.intify q.rightcut, () => mom.unix(departure).add('days', tdays).unix()

  fromObj   = Location.new q.fromKey || q.fromStr
  fromPos   = Location.new helpers.mkPos q.fromLat, q.fromLon, q.fromStr, q.fromplacemark
  from      = Location.choose [fromObj, fromPos]

  toObj     = Location.new q.toKey || q.toStr
  toPos     = Location.new helpers.mkPos q.toLat, q.toLon, q.toStr, q.toplacemark
  to        = Location.choose [toObj, toPos]

  locals    =
    departure: departure,
    leftcut: leftcut,
    rightcut: rightcut,

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

        log.notice "server/ridestream: locals: #{JSON.stringify(locals)}"

        locals.fromName = from.obj.cityName()
        locals.toName   = to.obj.cityName()
        res.render 'ridestream', {
          layout: false,
          locals: locals
        }
        rendered = true

  from.resolve undefined, omqapi.instance, sendOutput
  to.resolve undefined, omqapi.instance, sendOutput


module.exports =
  app: app
  server: server
  io: io

