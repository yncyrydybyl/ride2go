__ = require '../vendor/underscore'

builder =
  PlaceFromCityNameBuilder: {
    create: (cityname) ->
      place =
        city: cityname
      return place
  }
  PlaceFromLocationObjectBuilder: {
    create: (params) ->
  }


PlaceFactory =
  createPlace: (params) ->
    if params == "hamburg"
      builder.PlaceFromCityNameBuilder.create(params)
    else
      builder.PlaceFromLocationObjectBuilder.create(params)

module.exports = {PlaceFactory, builder}
