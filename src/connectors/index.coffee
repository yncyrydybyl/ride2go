
# loading connectors
exports = module.exports
log = require '../logging'
exports.foo = "bar"
files = require("fs").readdirSync(__dirname)
console.log "hi"+files
for file in files when file != "index.js"
  if (connector = file.match(/(.+)\.js$/))
    log.debug " + loading connector: '#{connector[1]}'"
    exports[connector[1]] = require("./"+connector[1])

# module.exports.mapquest = require('./mapquest').findRides
