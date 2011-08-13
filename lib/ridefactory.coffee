__ = require '../vendor/underscore'

module.exports = class RideFromQueryBuilder
  constructor: (query) ->
    @wanted_input = "querystring"
module.exports = class RideFromRideObjectBuilder
  constructor: (params) ->
    @wanted_input = "object"


module.exports = class RideFactory
  createRide: (params) ->
    if __.isString params and params.split("->").length == 2 
      new RideFromQueryBuilder (params)
    if params.orig or params.dest
      new RideFromObjectBuilder (params)
