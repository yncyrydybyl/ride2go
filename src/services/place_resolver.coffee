__      = require 'underscore'
Place   = require('./../place').Place
State   = require('./../place').State
Country = require('./../place').Country

class PlaceResolver

  constructor: (@dataSource = undefined) ->
    @

  resolve: (cb) ->
    if @dataSource
      countryName = @dataSource.countryName()
      stateName   = @dataSource.stateName()
      cityName    = @dataSource.cityName()
      Country.find countryName, (resolvedCountry) =>
        if resolvedCountry
          resolvedCountry.states.find stateName, (resolvedState) =>
            if resolvedState
              resolvedState.cities.find cityName, cb
            else
              resolvedCountry.cities.find cityName, cb
        else
          City.find cityName, cb
    else
      cb undefined

module.exports.new         = (aDataSource = undefined) -> new PlaceResolver(aDataSource)
module.exports.fromObject  = (obj) -> new PlaceResolver(obj)
module.exports.fromDetails = (country, state, city) ->
  resolver           = module.exports.new()
  resolver.country   = country
  resolver.stateName = state
  resolver.city      = city
  resolver
