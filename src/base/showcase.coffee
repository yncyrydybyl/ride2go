__ = require 'underscore'

module.exports.without = (json, skip) ->
  return json if !json
  json    = json.asJson() if json && json.asJson
  json    = JSON.parse(json) if __.isString(json)

  result  = {}
  for k, v of json
    result[k] = if skip.indexOf(k) < 0 then v else '<hidden>'

  JSON.stringify result