Place    = require('./../place').Place
City     = require('./../place').City
Country  = require('./../place').Country

class PlaceResolver

  constructor: (aDataSource = undefined) ->
    @dataSource = aDataSource
    @dataSource = @ if !@dataSource
    @

  resolve: (cb) ->
    debugger;
    source = @dataSource
    Country.find source.countryName(), (resolvedCountry) =>
      if resolvedCountry
        resolvedCountry.states.find source.stateName(), (resolvedState) =>
          if resolvedState
            resolvedState.cities.find source.cityName(), cb
          else
            resolvedCountry.cities.find source.cityName(), cb
      else
        City.find source.cityName(), cb


module.exports.new          = (aDataSource = undefined) -> new PlaceResolver(aDataSource)
module.exports.fromObject   = (obj) -> new PlaceResolver(obj)
module.exports.fromDetails  = (country, state, city) ->
  resolver           = module.exports.new()
  resolver.country   = country
  resolver.stateName = state
  resolver.city      = city
  resolver
