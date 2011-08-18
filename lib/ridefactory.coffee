__ = require '../vendor/underscore'

constructor =
  FromString: {
    create: (loc1, loc2) ->
      params =
        orig:
          title: loc1
        dest:
          title: loc2
      return params
  }
  FromRideObject: {
    create: (params) ->
  }


Ride =
  new: (params) ->
    if __.isString(params) and params.split("->").length == 2
      route = params.split("->")
      constructor.FromString.create(route[0], route[1])
    else if params.orig or params.dest
      constructor.FromRideObject.create(params)

module.exports = {RideFactory, builder}
