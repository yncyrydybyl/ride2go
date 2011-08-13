__ = require '../vendor/underscore'
Ride = require '../ride'

builder =
  RideFromQueryBuilder: {
    create: (loc1, loc2) ->
      params =
        orig:
          title: loc1
        dest:
          title: loc2
      return params
  }
  RideFromRideObjectBuilder: {
    create: (params) ->
  }


RideFactory =
  createRide: (params) ->
    if __.isString(params) and params.split("->").length == 2
      route = params.split("->")
      builder.RideFromQueryBuilder.create(route[0], route[1])
    else if params.orig or params.dest
      builder.RideFromRideObjectBuilder.create(params)

module.exports = {RideFactory, builder}
