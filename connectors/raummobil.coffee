nodeio = require 'node.io'


url = (query) -> "http://www.raumobil.de/index.php?
commodities_type=supply&commodity_type=mobile
&mobile_locations_country%5B0%5D=germany&mobile_locations_city%5B0%5D=#{query.orig}
&mobile_locations_country%5B99%5D=germany&mobile_locations_city%5B99%5D=#{query.dest}
&frequencies_start_date_na=0&search_start_date=#{query.date || ''}&x=62&y=13&module=Search
&action=Mobile&current_view=input&next_view=results&mobile_locations_radius%5B0%5D=10
&mobile_locations_radius%5B99%5D=10&results_per_page=100"


regex = ///                   # HEREGEX:
      (Angebot|Gesuch)\)      #1    type
      ([\d\.]+\s€|a\.A\.)     #2   price
      D-(\w+)     D-(\w+)     #3/4 route
      (\d{2}\.\d{2}\.\d{2})   #5    date
      (\d+:\d+)               #6    time
      ///

module.exports = new nodeio.Job
  input: false
  run: ->
    rides = []
    @getHtml url(@options), (err, $, data) =>
      console.log url(@options)
      $('#mobile_search_result_data tr').has('td').each (tr) ->
        link =  $('a', tr).last?().attribs.href
        if (r = tr.fulltext.match regex) and r[1] == "Angebot"
          rides.push
            orig: r[3]
            dest: r[4]
            date: r[5]
            time: r[6]
            price: r[2]
            link: "http://www.raumobil.de"+link
      @emit rides

