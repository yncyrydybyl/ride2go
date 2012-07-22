RDS = require '../lib/rds'

connector = {} # a connector is a plain object to be required
query = {orig: "DE:Bayern:München", dest: "DE:Berlin:Berlin"}

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
    RDS.search query, connector, done


  it "should fail gracefully", (done) ->
    query = {orig: "DE:Bayern:Oachkatzelzhausen", dest: "DE:Berlin:Berlin"}
    RDS.search query, connector, done
