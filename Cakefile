fs = require 'fs'
{spawn, exec} = require 'child_process'

# ANSI Terminal Colors
bold  = '\x1B[0;1m'
red   = '\x1B[0;31m'
green = '\x1B[0;32m'
reset = '\x1B[0m'


option '-w', '--watch', 'continually build upon change'
option '-r', '--reporter', 'mocha test reporter'


task 'build', 'compile coffee and sass', (options) ->
  watch = if options.watch then ' --watch' else ''
  server = spawn "coffee", ['-o', 'lib', '--compile' + watch, 'src']
  server.stdout.on 'data', (data) -> console.log data.toString().trim()
  client = spawn "coffee", ['--join', 'public/js/ride2go.js',
    '--compile' + watch, '--bare',
    'src/client/ride2go.coffee',
    'src/client/autocomplete.coffee']
  client.stdout.on 'data', (data) -> console.log data.toString().trim()
  exec "sass #{watch} sass/main.sass:public/css/main.css", (err, output) ->
    throw err if err
    console.log green + "Alles gebuildet :)" +reset
  

task "test", "run tests", (options) ->
  exec "NODE_ENV=test 
    ./node_modules/.bin/mocha 
    --compilers coffee:coffee-script
    --reporter #{options.reporter || 'spec'}
    --require coffee-script 
    --require test/test_helper.coffee
    --colors
  ", (err, output) ->
    throw err if err
    console.log output


