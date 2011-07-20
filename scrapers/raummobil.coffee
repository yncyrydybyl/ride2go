nodeio = require 'node.io'

class Raummobil extends nodeio.JobClass
  input: false
  run: ->
    @getHtml "http://raummobil.de", (err, $, data) =>
      console.log $('body')
      @emit "foobar"

module.exports.raummobil = new Raummobil
