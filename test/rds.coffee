RDS = require '../lib/rds'
Ride = require '../lib/ride'

connector = {} # a connector is a plain object to be required
query = {orig: "DE:Bayern:München", dest: "DE:Berlin:Berlin"}


describe "RDS", ->

  it "should find stored rides", (done) ->
    ride = Ride.new
      id: "foo"
      orig: "München"
      dest: "Berlin"
    RDS.find ride, (result) ->
      expect(result).to.equal ride.toJson()
      done()
    RDS.store ride


# How To
describe "Write a simple straight-forward connector", ->


  it "should be simple and straight-forward", (done) ->
    connector =
      name: "mfz.de"
      make_url: (query) ->
        "http://www.mitfahrzentrale.de/suche.php?art=100&frmpost=1&" +
        "STARTLAND=D&START=#{escape(query.origin().city())}&" +
        "ZIELLAND=D&ZIEL=#{escape(query.ziel().city())}&"
      read_html: ($) ->
        $('div#dres tr.tabbody').each (tr) =>
          row = []
          $('td', tr).each (td) -> row.push td
          @found 'ride',
            orig: row[2].text
            dest: row[3].text
            departure: row[1].text+" "+row[4].text
            link: "http://www.mitfahrzentrale.de"+$('a', row[5]).attribs.href
        $('div#dres a').each (a) => # pagination
          @found 'url', "http://www.mitfahrzentrale.de#{a.attribs.href}" if a.text == '>'
    RDS.search query, connector, () -> 42
    RDS.find query, (ride) ->
      console.log ride
      done()


  xit "should fail gracefully", (done) ->
    query = {orig: "DE:Bayern:Oachkatzelzhausen", dest: "DE:Berlin:Berlin"}
    RDS.search query, connector, done



describe "Resolve disambiguous place keys", ->


  xit "should report alternative place names/keys", (done) ->
    connector =
      name: "bahn.de"
      make_url: (query) ->
        "http://mobile.bahn.de/bin/mobil/query.exe/dox?&" +
        "s=#{query.origin().city()}&z=#{query.destination().city()}&" +
        "t=1200&d=260712&&start=Suchen"
      read_html: ($) ->
        $('select').each (select) =>
          names = []
          what = 'alternative_origs' if select.attribs.name == "REQ0JourneyStopsS0K"
          what = 'alternative_dests' if select.attribs.name == "REQ0JourneyStopsZ0K"
          $('option', select).each (name) =>
            names.push name.text
          @found what, names
    RDS.search
      orig:"DE:Bayern:Kirchheim"
      dest:"DE:Berlin:Kolumbusplatz"
      , connector, done

  
  xit "should choose the first alternative if it matches", (done) ->

    RDS.search {orig:"DE:Bayern:Kirchheim", dest:"DE:Berlin:Kolumbusplatz"}, connector, done



afterEach (done) ->
  redis = require('redis').createClient()
  redis.del "München->Berlin"
  RDS.removeAllListeners()
  console.log "CLEANED UP"
  done()
