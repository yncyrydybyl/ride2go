io = require "node.io"
spawn = require('child_process').spawn
fs = require 'fs'

module.exports = new io.Job
  input: false 
  run: -> 
    console.log("download started")
    url = "http://download.geonames.org/export/dump/DE.zip"
    targetfile = "/tmp/DE.zip"
    spawn('curl', ['-o', targetfile, url]).on 'exit', (code) =>
      fs.stat targetfile, (err, stats) => 
        throw new Error(err) unless stats.isFile()
        @emit "done"
    

