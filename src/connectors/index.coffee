
# loading connectors
log     = require '../logging'

load_connector = (connector) ->
  log.debug "+ loading connector: #{connector}"
  require "./#{connector}"

module.exports = {
  deinbus: load_connector 'deinbus'
}

# either require all active
#files = require("fs").readdirSync(__dirname)
#for file in files when file != "index.js"
#  if (connector = file.match(/(.+)\.js$/))
#    log.debug " + loading connector: '#{connector[1]}'"
#    exports[connector[1]] = require("./"+connector[1])

# or specify manually


# module.exports.mapquest = require('./mapquest').findRides
