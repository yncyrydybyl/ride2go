__ = require '../vendor/underscore'

builder =
  RideFromQueryBuilder: {
    create: (loc1, loc2) ->
  }
  RideFromRideObjectBuilder: {
    create: (params) ->
  }


class RideFactory
  createRide: (params) ->
    if __.isString(params) and params.split("->").length == 2
      route = params.split("->")
      builder.RideFromQueryBuilder.create(route[0], route[1])

module.exports = {RideFactory, builder}