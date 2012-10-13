__       = NaN

libRedis = require 'redis'
libPlace = require '../lib/place'

GeoStore = libPlace.GeoStore
Place    = libPlace.Place

redis    = NaN
store    = NaN

# TODO Pull into separate tests
describe 'GeoStore', () ->
  
  beforeEach ->
    redis = libRedis.createClient()
    store = new GeoStore(redis)

  it 'should constructy proper placeProps callbacks', () ->
    cb = store.placePropsCallback (props) ->
      expect(props.gs_country).to.equal('DE')
      expect(props.gs_state).to.equal('Brandenburg')
      expect(props.gs_city).to.equal('Potsdam')
    cb 'DE:Brandenburg:Potsdam'

  describe 'Place', () ->

    it 'should handle city keys correctly', ->
      place = new Place(store.keyToPlaceProps('DE:Hessen:Frankfurt am Main'))
      expect(place).to.be.ok
      expect(place.hasCountry()).to.be.true
      expect(place.hasState()).to.be.true
      expect(place.hasCity()).to.be.true
      expect(place.isCountry()).to.be.true
      expect(place.isState()).to.be.true
      expect(place.isCity()).to.be.true

    it 'should construct proper update callbacks', () ->
      place = new Place(store.keyToPlaceProps('DE:Hessen:Frankfurt am Main'))
      cb    = place.updateCallback (newPlace) ->
        expect(newPlace.state()).to.equal('Babbel')
      cb { 'gs_state': 'Babbel' }

    it 'should handle state keys correctly', ->
      place = new Place(store.keyToPlaceProps('DE:Hessen'))
      expect(place).to.be.ok
      expect(place.hasCountry()).to.be.true
      expect(place.hasState()).to.be.true
      expect(place.hasCity()).to.be.false
      expect(place.isCountry()).to.be.true
      expect(place.isState()).to.be.true
      expect(place.isCity()).to.be.false

    it 'should know that is a country', ->
      place = new Place(store.keyToPlaceProps('DE'))
      expect(place).to.be.ok
      expect(place.hasCountry()).to.be.true
      expect(place.hasState()).to.be.false
      expect(place.hasCity()).to.be.false
      expect(place.isCountry()).to.be.true
      expect(place.isState()).to.be.false
      expect(place.isCity()).to.be.false

    it 'should have a convenience getter for state from city', ->
      place = new Place(store.keyToPlaceProps('DE:Bayern:München'))
      place = place.asState()
      key   = store.placeToStateKey(place)
      expect(place.isState()).to.be.true
      expect(place.hasCity()).to.be.false
      expect(key).to.equal 'DE:Bayern'

    it 'should have a convenience getter for state from state', ->
      place = new Place(store.keyToPlaceProps('DE:Bayern'))
      place = place.asState()
      key   = store.placeToStateKey(place)
      expect(place.isState()).to.be.true
      expect(place.hasCity()).to.be.false
      expect(key).to.equal 'DE:Bayern'

    it 'should construct proper key', ->
      place     = new Place(store.keyToPlaceProps('DE:Hessen:Frankfurt am Main'))
      key       = store.placeToCityKey(place)
      expect(key).to.be.equal('DE:Hessen:Frankfurt am Main')

  describe 'Resolving', () ->

    describe 'DefaultResolver', () ->

      it.only 'should find a country by key', (done) ->
        debugger;
        place    = new Place(store.keyToPlaceProps('DE'))
        resolver = new libPlace.DefaultResolver store
        resolver.resolve place, (newPlace) ->
          expect(newPlace.country).to.equal('DE')
          done()

    xit "should find a city by key", (done) ->
      City.find "DE:Berlin:Berlin", (city) ->
        expect(city.key).to.equal("DE:Berlin:Berlin")
        expect(city).instanceOf(City)
        done()
    
    xit "should find a state in a country", (done) ->
      new Country("DE").states.find "Berlin", (state) ->
        expect(state.key).to.equal("DE:Berlin")
        expect(state).instanceOf(State)
        done()
        
    xit "should find a city in a country", (done) ->
      new Country("DE").cities.find "Hamburg", (city) ->
        expect(city.key).to.equal("DE:Hamburg:Hamburg")
        expect(city).instanceOf(City)
        done()
    
    xit "should choose the city with max population if not unique", (done) ->
      new Country("DE").cities.find "München", (city) ->
        expect(city.key).to.equal("DE:Bayern:München")
        done()

    xit "should find a city in a state", (done) ->
      new State("DE:Berlin").cities.find "Berlin", (city) ->
        expect(city.key).to.equal("DE:Berlin:Berlin")
        done()

    xit "should find a city in a state with enc�ding �rrors in its name", (done) ->
      new State("DE:Berlin").cities.find "B�rlin", (city) ->
        expect(city.key).to.equal("DE:Berlin:Berlin")
        done()

    xit "should pick by population if more cities match the enc�ding �rror", (done) ->
      new State("DE:Bayern").cities.find "N�rnberg", (city) ->
        expect(city.key).to.equal("DE:Bayern:Nürnberg")
        done()

    xit "should find a city in a state by alternative name", (done) ->
      new State("DE:Rheinland-Pfalz").cities.find "Mayence", (city) ->
        expect(city.key).to.equal("DE:Rheinland-Pfalz:Mainz")
        done()

    xit "should find by google geocoder object", (done) ->
      go = require("./fixtures/googleobject").results[0]
      City.find go, (city) ->
        expect(city.key).to.equal("DE:Rheinland-Pfalz:Mainz")
        done()
 
    xit "should return undefined if place does not exist", (done) ->
      new State("DE:Bayern").cities.find "Oachkatzleschwoafhausen", (city) ->
        expect(city).to.equal(undefined)
        done()

    xit "should find Baden-Wurttemberg (manual foreign key)", (done) ->
      new Country("DE").states.find "Baden-Wurttemberg", (state) ->
        expect(state.key).to.equal("DE:Baden-Württemberg")
        done()

    xit "should find Stuttgart", (done) ->
      new State("DE:Baden-Württemberg").cities.find "Stuttgart", (city) ->
        expect(city.key).to.equal("DE:Baden-Württemberg:Stuttgart")
        done()


    xit "should find by geoip geocoder objects", (done) ->
      go = require("./fixtures/geoipobject")
      City.find go, (city) ->
        expect(city.key).to.equal("DE:Berlin:Berlin")


    xit "should work with search parameters", (done) ->
      params =
        city: "München"
        country: "DE"
      Place.find params , (p) ->
        expect(p.key).to.equal("DE:Bayern:München")
        done()

    describe 'ForeignKeyResolver', () ->

      it 'should return foreign key for a city', (done) ->
        place     = new Place(store.keyToPlaceProps('DE:Hessen:Frankfurt am Main'))
        resolver  = new libPlace.ForeignKeyResolver(store, 'mitfahrzentrale:id')
        resolver.resolve place, (fkoc) ->
          expect(fkoc).to.equal('Frankfurt/ Main')
          done()

      it 'should return city if foreign key does not exits', (done) ->
        place     = new Place(store.keyToPlaceProps('DE:Hessen:Frankfurt am Main'))
        resolver  = new libPlace.ForeignKeyResolver(store, 'nonexistent:id')
        resolver.resolve place, (fkoc) ->
          expect(fkoc).to.equal('Frankfurt am Main')
          done()

  afterEach ->
    redis.quit()




#geoname = require "../lib/geonames"
#redis = require("redis").createClient()
#
#describe "geonames", (done) ->
#  describe ".cityExits", (done) ->
#    beforeEach ->
#      redis.select 15 # using the a test db
#      redis.set "gn:Mainz" "DE:RP:Mainz" # setting alternative name 1
#      redis.set "gn:Mayence" "DE:RP:Mainz" # setting alternative name 2
#      redis.hset "DE:RP:Mainz", "type", "city" # setting primary key as hash and defining the type 
#      waits("500")
#    afterEach ->
#      redis.flushdb
#    it "should return true if a city exits", (done) ->
#      city = geoname.cityExits("Mainz",redis)
#      waits("500")
#      expect(city).to.equalTruthy()
#    it "should return false if a city is´nt existing.", (done) ->
#      city = geoname.cityExits("laberrababerstadtdienichtexistier")
#      expect(city).to.equalFalsy()
#
#  xdescribe ".alternativeName", (done) ->
#    it "should return the internal name if existed", (done) ->
#      alternative = "Mayence"
#      internal = "Mainz"
#      expect(geoname.alternativeName(alternative).toEqual(internal))
#    it "should return null if there is no internal key for it", (done) ->
#      alternative = "larifaristadt"
#      expect(geoname.alternativeName(alternative).to.equalNull())
#
