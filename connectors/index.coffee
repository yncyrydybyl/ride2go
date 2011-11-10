
# loading connectors
exports = module.exports
log = require 'logging'

files = require("fs").readdirSync(__dirname)
for file in files when file != "index.coffee"
  if (connector = file.match(/(.+)\.coffee$/))
    log.debug " + loading connector: '#{connector[1]}'"
    exports[connector[1]] = require("./"+connector[1]).findRides

# module.exports.mapquest = require('./mapquest').findRides




