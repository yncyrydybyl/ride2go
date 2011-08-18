place_factory = require '../lib/placefactory'

describe "PlaceFactory", ->
  describe 'createPlace', ->
    factory = {}

    beforeEach ->
      factory = place_factory.PlaceFactory

    describe 'city name', ->
      builder = {}

      beforeEach ->
        spyOn(builder = place_factory.builder.PlaceFromCityNameBuilder, 'create')

      it "should call the PlaceFromCityNameBuilder if param is a cityname", ->
        factory.createPlace("hamburg")
        expect(builder.create).toHaveBeenCalledWith("hamburg")

