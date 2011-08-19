__ = require '../vendor/underscore'

constructors =
  FromString: {
    new: (loc1, loc2) ->
      params =
        orig:
          title: loc1
        dest:
          title: loc2
      return params
  }
  FromRideObject: {
    new: (params) ->
  }


Ride =
  new: (params) ->
    if __.isString(params) and params.split("->").length == 2
      route = params.split("->")
      constructors.FromString.new(route[0], route[1])
    else if params.orig or params.dest
      constructors.FromRideObject.new(params)

module.exports = {Ride, constructors}
