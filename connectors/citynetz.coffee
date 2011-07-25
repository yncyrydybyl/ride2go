nodeio = require 'node.io'

sessionId = "7cdf6b20d2219a85d4d5431c7ef3a0ce"

url = (query) -> 
  "http://www.citynetz-mitfahrzentrale.de
/suche-nach-mitfahrgelegenheiten/index.php/search
/1/#{"?CITYNETZSESSID="+sessionId if sessionId}"

urlAll = (query) -> # get all rides available
  "http://www.citynetz-mitfahrzentrale.de
/suche-nach-mitfahrgelegenheiten/index.php
/manual/1/land_von/D/land_nach/D/#content"

body = (query) ->
  "mode=selectbox&mid=11&fid=0
&datum_tag=#{query.date?.getDate() || 0}
&datum_monat=#{query.date?.getMonth()+1 || 0}
&land_von=D&ort_von=#{query.origin}
&land_nach=D&ort_nach=#{query.destination}
&search=suche"

module.exports = new nodeio.Job
  input: false
  run: ->
    @options.encoding = "binary" # "iso-8859-1"
    @post urlAll(@options), body(@options), (err, data) =>
      rides = []
      regex = ///                       # HEREGEX:
          <TD>([^<]+)</TD>\s{3}         #1 orig
          <TD>([^<]*)</TD>\s{3}         #2 dest
          <TD>(\d+\.\d+\.\d+)</TD>\s{3} #3 date
          <TD>(\d+:\d+)</TD>\s{3}       #4 time
          <TD>(\d+)</TD>[\s\S]*?        #5 seat
          HREF="(.*?)"                  #6 link
          ///g
      while match = regex.exec data
        rides.push
          orig: match[1]
          dest: match[2]
          date: match[3]
          time: match[4]
          link: match[6]
      console.log "found #{rides.length} rides at citynetz-mitfahrzentrale.de"
      if rides.length == 0
        @get "http://citynetz-mitfahrzentrale.de", (err, data) =>
          console.log data
          sessionId = data.match(/CITYNETZSESSID=([0-9a-f]+)/)[1]
          console.log "session refreshed: #{sessionId} -> retry..."
          @retry()
      else @emit rides
  

