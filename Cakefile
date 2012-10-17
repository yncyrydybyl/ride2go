fs                = require 'fs'
{spawn, execFile} = require 'child_process'

# configure tests
active_tests      = require './test/active_tests.js'

# css config
css_sources       = ['styl/main.styl']
css_target        = 'public/css'

# binaries
bin_coffee = "./node_modules/.bin/coffee"
bin_mocha  = "./node_modules/.bin/mocha"
bin_stylus = "./node_modules/.bin/stylus"

# ANSI Terminal Colors
bold  = '\x1B[0;1m'
red   = '\x1B[0;31m'
green = '\x1B[0;32m'
reset = '\x1B[0m'

option '-w', '--watch', 'continually build upon change'
option '-C', '--coffee-arg [ARG*]', 'pass extra arguments to coffee'
option '-r', '--reporter [STYLE]', 'set test reporter to be used by mocha'
option '-M', '--mocha-arg [ARG*]', 'pass extra arguments to mocha'

run_proc = (name, cmd, args) ->
  proc = spawn cmd, args
  proc.stdout.on 'data', (data) -> console.log data.toString().trim()
  proc.stderr.on 'data', (data) -> console.error data.toString().trim()
  proc.on 'exit', (code, signal) =>
    if code is 0
      console.log "#{green}#{name} has completed#{reset}"
    else
      console.error "#{red}#{name} has failed#{reset}"

task 'build', 'compile coffee and stylus', (options) ->
  invoke 'link'
  watch_args  = if options.watch then ['-w'] else []
  coffee_args = if options["coffee-arg"] then options['coffee-arg'] else []

  server_args = watch_args.concat(['-o', 'lib', '--compile'])
  server_args = server_args.concat(coffee_args)
  server_args = server_args.concat(['src'])
  run_proc 'compiling server code', bin_coffee, server_args

  client_args = watch_args.concat(['--join', 'public/js/ride2go.js', '--compile', '--bare'])
  client_args = client_args.concat(coffee_args)
  client_args = client_args.concat([
    'src/client/ride2go.coffee',
    'src/client/ridestream.coffee',
    'src/client/autocomplete.coffee'])
  run_proc 'compiling joint client code', bin_coffee, client_args

  client_args = watch_args.concat(['--join', 'public/js/ridestream.js', '--compile', '--bare'])
  client_args = client_args.concat(coffee_args)
  client_args = client_args.concat(['src/client/ridestream.coffee'])
  run_proc 'compiling ridestream client code', bin_coffee, client_args

  stylus_args = watch_args.concat(['-o', css_target])
  stylus_args = stylus_args.concat(css_sources)
  run_proc 'stylesheet building', bin_stylus, stylus_args

task "link", () ->
  updateLink = (src, dst) ->
    try
      stats = fs.lstatSync dst
    catch error
      console.log(error) if error.code != 'ENOENT'
      stats = null
    if stats && stats.isSymbolicLink()
      fs.unlinkSync dst
    console.log "Updating link #{dst} -> #{src}"
    fs.symlinkSync src, dst

  updateLink '../../components/DataTables', './public/js/DataTables'
  updateLink '../../components/jquery', './public/js/jquery'
  updateLink '../../components/jquery-ui', './public/js/jquery-ui'
  updateLink '../../components/moment', './public/js/moment'
  updateLink '../../components/underscore', './public/js/underscore'

task "test", "run all tests", (options) ->
  watch_args = if options.watch then ['--watch'] else []
  mocha_args = if options['mocha-arg'] then options['mocha-arg'] else []

  test_args  = watch_args.concat(['--compilers', 'coffee:coffee-script'])
  test_args  = test_args.concat(['--colors', '--reporter',  options.reporter || 'spec'])
  test_args  = test_args.concat(['--ui', 'bdd', '-G'])
  test_args  = test_args.concat(['--require', 'test/test_helper.js'])
  test_args  = test_args.concat(mocha_args)
  test_args  = test_args.concat(active_tests)
  test_env   = Object.create(process.env)
  test_env['NODE_ENV'] = 'test'
  test_opts  = { 'cwd': undefined, 'env': test_env }
  execFile bin_mocha, test_args, test_opts, (err, output) ->
    console.log output
    throw err if err
