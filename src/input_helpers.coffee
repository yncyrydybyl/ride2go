__ = require 'underscore'

intify = (val, cb) ->
  if val then parseInt(val) else cb()

parseFiniteFloat = (str) ->
  f = parseFloat str
  if f && isFinite(f) then f else undefined

parsePos = (str) ->
  arr = str.split ','
  if arr.length == 2
    lat = parseFiniteFloat arr[0]
    lon = parseFiniteFloat arr[1]
    if lat && lon
      { lat: lat, lon: lon }
    else
      undefined
  else
    undefined

mkPos = (lat, lon, str, placemarkStr) ->
  lat = parseFiniteFloat(lat) if lat
  lon = parseFiniteFloat(lon) if lon
  if lat && lon
    { lat: lat, lon: lon}
  else if placemarkStr && (pm = JSON.parse(placemarkStr))
    { lat: pm.Latitude, lon: pm.Longitude }
  else if str && __.isString(str)
    parsePos str
  else
    undefined


module.exports = {
  intify: intify
  parseFiniteFloat: parseFiniteFloat
  parsePos: parsePos
  mkPos: mkPos
}