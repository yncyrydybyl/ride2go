Place    = require('./../place').Place
City     = require('./../place').City
Country  = require('./../place').Country

class PlaceResolver

  constructor: (aDataSource = undefined) ->
    @dataSource = aDataSource
    @dataSource = @ if !@dataSource
    @

  resolve: (cb) ->
    source      = @dataSource
    countryName = source.countryName()
    stateName   = source.stateName()
    cityName    = source.cityName()
    Country.find countryName, (resolvedCountry) =>
      if resolvedCountry
        resolvedCountry.states.find stateName, (resolvedState) =>
          if resolvedState
            resolvedState.cities.find cityName, cb
          else
            resolvedCountry.cities.find cityName, cb
      else
        City.find cityName, cb


module.exports.new          = (aDataSource = undefined) -> new PlaceResolver(aDataSource)
module.exports.fromObject   = (obj) -> new PlaceResolver(obj)
module.exports.fromDetails  = (country, state, city) ->
  resolver           = module.exports.new()
  resolver.country   = country
  resolver.stateName = state
  resolver.city      = city
  resolver
