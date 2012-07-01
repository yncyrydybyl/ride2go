__ = NaN
redis = NaN
Place = require('../lib/place').Place
Country = require('../lib/place').Country
State = require('../lib/place').State
City = require('../lib/place').City


describe "Place", (done) ->
  
  beforeEach ->
    redis = require("redis").createClient()


  it "should know that is a city", ->
    c = new City("DE:Hessen:Frankfurt am Main")
    expect(c.isCity()).to.equal(true)
    expect(c.isCountry()).to.equal(false)
    expect(c.isState()).to.equal(false)

  it "should know that is a state", ->
    s = new State("DE:Hessen")
    expect(s.isState()).to.equal(true)
    expect(s.isCity()).to.equal(false)
    expect(s.isCountry()).to.equal(false)
    
  it "should know that is a country", ->
    c = new Country("DE")
    expect(c.isCountry()).to.equal(true)
    expect(c.isCity()).to.equal(false)
    expect(c.isState()).to.equal(false)

  it "should have a convenience getter for state", ->
    p = new City("DE:Bayern:München")
    expect(p.state().key).to.equal "DE:Bayern"
    p = new City("DE:Bayern")
    expect(p.state().key).to.equal "DE:Bayern"


  describe "Find", (done) ->

    it "should find a country by key", (done) ->
      Country.find "DE", (country) ->
        expect(country.key).to.equal("DE")
        expect(country).instanceOf(Country)
        done()
    
    it "should find a city by key", (done) ->
      City.find "DE:Berlin:Berlin", (city) ->
        expect(city.key).to.equal("DE:Berlin:Berlin")
        expect(city).instanceOf(City)
        done()
    
    it "should find a state in a country", (done) ->
      new Country("DE").states.find "Berlin", (state) ->
        expect(state.key).to.equal("DE:Berlin")
        expect(state).instanceOf(State)
        done()
        
    it "should find a city in a country", (done) ->
      new Country("DE").cities.find "Hamburg", (city) ->
        expect(city.key).to.equal("DE:Hamburg:Hamburg")
        expect(city).instanceOf(City)
        done()
    
    it "should choose the city with max population if not unique", (done) ->
      new Country("DE").cities.find "München", (city) ->
        expect(city.key).to.equal("DE:Bayern:München")
        done()

    it "should find a city in a state", (done) ->
      new State("DE:Berlin").cities.find "Berlin", (city) ->
        expect(city.key).to.equal("DE:Berlin:Berlin")
        done()

    it "should find a city in a state with enc�ding �rrors in its name", (done) ->
      new State("DE:Berlin").cities.find "B�rlin", (city) ->
        expect(city.key).to.equal("DE:Berlin:Berlin")
        done()

    it "should pick by population if more cities match the enc�ding �rror", (done) ->
      new State("DE:Bayern").cities.find "N�rnberg", (city) ->
        expect(city.key).to.equal("DE:Bayern:Nürnberg")
        done()

    it "should find a city in a state by alternative name", (done) ->
      new State("DE:Rheinland-Pfalz").cities.find "Mayence", (city) ->
        expect(city.key).to.equal("DE:Rheinland-Pfalz:Mainz")
        done()

    it "should find by google geocoder object", (done) ->
      go = require("./fixtures/googleobject").results[0]
      City.find go, (city) ->
        expect(city.key).to.equal("DE:Rheinland-Pfalz:Mainz")
        done()
 
    it "should return undefined if place does not exist", (done) ->
      new State("DE:Bayern").cities.find "Oachkatzleschwoafhausen", (city) ->
        expect(city).to.equal(undefined)
        done()

    it "should find Baden-Wurttemberg (manual foreign key)", (done) ->
      new Country("DE").states.find "Baden-Wurttemberg", (state) ->
        expect(state.key).to.equal("DE:Baden-Württemberg")
        done()

    it "should find Stuttgart", (done) ->
      new State("DE:Baden-Württemberg").cities.find "Stuttgart", (city) ->
        expect(city.key).to.equal("DE:Baden-Württemberg:Stuttgart")
        done()


    xit "should find by geoip geocoder objects", (done) ->
      go = require("./fixtures/geoipobject")
      City.find go, (city) ->
        expect(city.key).to.equal("DE:Berlin:Berlin")


    it "should return foreign key for a city", (done) ->
      c = new City("DE:Hessen:Frankfurt am Main")
      c.foreignKeyOrCity "mitfahrzentrale:id", (fkoc) ->
        expect(fkoc).to.equal("Frankfurt/ Main")
        done()
    
    it "should return city if foreign key does not exists", (done) ->
      c = new City("DE:Hessen:Frankfurt am Main")
      c.foreignKeyOrCity "nonexistent:id", (fkoc) ->
        expect(fkoc).to.equal("Frankfurt am Main")
        done()

    xit "should work with search parameters", (done) ->
      params =
        city: "München"
        country: "DE"
      Place.find params , (p) ->
        expect(p.key).to.equal("DE:Bayern:München")
        done()

  
  afterEach -> redis.quit()




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
