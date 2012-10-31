__ = require 'underscore'

###
Render json but skip some properties

@param [Object] json a json object
@param [Array<String>] skip array of fields that should not be included in the returned json
@return [String] JSON representation
###
module.exports.without = (json, skip) ->
  ###
  Render json but skip some properties
  ###
  return json if !json
  json    = json.asJson() if json && json.asJson
  json    = JSON.parse(json) if __.isString(json)

  result  = {}
  for k, v of json
    result[k] = if skip.indexOf(k) < 0 then v else '<hidden>'

  JSON.stringify result