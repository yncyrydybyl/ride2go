__ = require '../vendor/underscore'

exports.RideFromQueryBuilder = class RideFromQueryBuilder
  createFromQuery: (loc1, loc2) ->
    @wanted_input = "querystring"
exports.RideFromRideObjectBuilder = class RideFromRideObjectBuilder
  constructor: (params) ->
    @wanted_input = "object"


exports.RideFactory = class RideFactory
  createRide: (params, builder) ->
    if __.isString(params) and params.split("->").length == 2
      route = params.split("->")
      builder.createFromQuery(route[0], route[1])
    else if params.orig or params.dest
      new RideFromObjectBuilder (params)
