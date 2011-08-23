#import kann complex sein
#lookups sollen schnell und simple sein
#
#internal keys == place.descriptor_string
#(erstellen aus geonames datensatz)
#
#<COUNTRY>:<ADMIN1>:...:<CITY>:<PLZ>:<STREET>:<NR>
#
#foreign keys mappen aud sets von internal keys
#<SOURCE>:<TYPE>:<ID>
#  GOOGLE:LOCALITY:MAYENCE -> 
#  HAFAS:TRAMHALT:28436    ->
#  GEONAMES:ID:345687      ->
#  GEONAME:PPL:MAINZ       ->
#  GEONAME:PPL:MAYENCE     -> [DE:RF:MAINZ, AT:OÖ:MIANZO]
#  MFGDE:CITY:123          -> 
#  OSM:STREET:HAUPTSTRAßE  -> [DE:RF:MAINZ:HAUPSTR, DE:BY:MÜNCHEN:HAUPTSTR, ...] # worst case
#  FOUSQUARE:CAFE:876543   ->
#
#----
#internal?
#  DE -> DE # internal key found :)
#  DE:RF -> DE:RF # internal key found :)
#  DE:RF:Mayence -> false # internal key NOT found :(
#    foreign? 
#      *:MAYENCE -> [DE:RF:MAINZ, AT:OÖ:MIANZO]
#        wenn mehrere dann die rauspicken, die sinn machen
#        - selber anfang
#        - first guess
#      -> DE:RF:MAINZ # internal key found
#    :)
#

deTxt = require ("fixtures/geonames").deTxt
deTxt = """
  2874224	Hauptbahnhof Mainz	Hauptbahnhof Mainz	Hauptbahnhof Mainz	50.00111	8.25778	S	RSTN	DE		08				0		96	Europe/Berlin	2011-08-07
  2874225	Mainz	Mainz	Magonza,Maguncia,Magúncia,Mainca,Maints,Mainz,Majenco,Majnc,Mayence,Mogontiacum,Moguncja,Moguntiacum,Mohuc,Mohuč,maincheu,maintsi,maintsu,maynz,mei yin ci,myynz,Μάιντς,Майнц,Мајнц,מיינץ,ماينز,მაინცი,マインツ,美因茨,마인츠	50	8.27111	P	PPLA	DE		08				184997		98	Europe/Berlin	2011-08-07
2847618 Rheinland-Pfalz Rheinland-Pfalz Renania-Palatinato,Rheinland Pfalz,Rheinland-Pfalz,Rhenanie-Palatinat,Rhineland-     Palatinate,Rhénanie-Palatinat      49.66667        7.5     A       ADM1    DE              08                                4012675               325     Europe/Berlin   2011-07-16
""".split("\n")

countryInfoTxt = require ("fixtures/geonames").countryInfoTxt

"""
# The column 'languages' lists the languages spoken in a country ordered by the number of speakers. The language code is a 'locale'                                     
# where any two-letter primary-tag is an ISO-639 language abbreviation and any two-letter initial subtag is an ISO-3166 country code.                                    
    #                                   
# Example : es-AR is the Spanish variant spoken in Argentina.                                   
    #                                   
#ISO  ISO3  ISO-Numeric fips  Country Capital Area(in sq km)  Population  Continent tld CurrencyCode  CurrencyName  Phone Postal Code Format Postal Code Regex Languages geonameid neighbours  EquivalentFipsCode
    AD  AND 020 AN  Andorra Andorra la Vella  468 84000 EU  .ad EUR Euro  376 AD### ^(?:AD)*(\d{3})$  ca  3041565 ES,FR 
    AE  ARE 784 AE  United Arab Emirates  Abu Dhabi 82880 4975593 AS  .ae AED Dirham  971     ar-AE,fa,en,hi,ur 290557  SA,OM 
    AF  AFG 004 AF  Afghanistan Kabul 647500  29121286  AS  .af AFN Afghani 93      fa-AF,ps,uz-AF,tk 1149361 TM,CN,IR,TJ,PK,UZ""".split("\n")

describe "geonames importer", ->
  redis = {}
  beforeEach ->
    redis = require("redis").createClient()
    importer = require ("../lib/importers/geonames")

  describe "country codes" , ->

    it "should read data countryInfo.txt and store it into redis", ->
      for line in countryInfoTxt
        importer.storeCountry line
      redis.exists "AD", (err, exists) -> expect(exists).toEqual 1
      redis.key "AD", (err, value) -> expect(value).toEqual "Andorra"
      waits 500

  describe "admin division", ->
    it "should read admin data from deTXT and store it into redis", ->
      
