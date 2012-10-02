fs                = require 'fs'
{spawn, execFile} = require 'child_process'

# active tests

# may break
active_tests      = ['test',
  'test/connectors/pts_test.coffee']

# should always work
active_tests      = ['test']

# binaries
bin_coffee = "coffee"
bin_mocha  = "mocha"
bin_sass   = "sass"

# ANSI Terminal Colors
bold  = '\x1B[0;1m'
red   = '\x1B[0;31m'
green = '\x1B[0;32m'
reset = '\x1B[0m'

option '-w', '--watch', 'continually build upon change'
option '-C', '--coffee-arg [ARG*]', 'pass extra arguments to coffee'
option '-r', '--reporter [STYLE]', 'set test reporter to be used by mocha'
option '-M', '--mocha-arg [ARG*]', 'pass extra arguments to mocha'

task 'build', 'compile coffee and sass', (options) ->
  watch_args  = if options.watch then ['--watch'] else []
  coffee_args = if options["coffee-arg"] then options["coffee-arg"].join(' ') else []

  server_args = watch_args.concat(['-o', 'lib', '--compile'])
  server_args = server_args.concat(coffee_args)
  server_args = server_args.concat(['src'])
  server      = spawn bin_coffee, server_args
  server.stdout.on 'data', (data) -> console.log data.toString().trim()

  client_args = watch_args.concat(['--join', 'public/js/ride2go.js', '--compile', '--bare'])
  client_args = client_args.concat(coffee_args)
  client_args = client_args.concat(['src/client/ride2go.coffee', 'src/client/autocomplete.coffee'])
  client      = spawn bin_coffee, client_args
  client.stdout.on 'data', (data) -> console.log data.toString().trim()

  sass_args   = watch_args.concat(['sass/main.sass:public/css/main.css'])
  execFile bin_sass, sass_args, null, (err, output) ->
    console.log "#{green}build complete#{reset}"
    throw err if err

task "test", "run all tests", (options) ->
  console.log options
  watch_args = if options.watch then ['--watch', '-G'] else []
  mocha_args = if options['mocha-arg'] then options['mocha-arg'].join(' ') else []

  test_args  = watch_args.concat(['--compilers', 'coffee:coffee-script'])
  test_args  = test_args.concat(['--colors', '--reporter',  options.reporter || 'spec'])
  test_args  = test_args.concat(['--ui', 'bdd'])
  test_args  = test_args.concat(['--require', 'coffee-script'])
  test_args  = test_args.concat(['--require', 'test/test_helper.coffee'])
  test_args  = test_args.concat(mocha_args)
  test_args  = test_args.concat(active_tests)
  test_env   = Object.create(process.env)
  test_env['NODE_ENV'] = 'test'
  test_opts  = { 'cwd': undefined, 'env': test_env }
  execFile bin_mocha, test_args, test_opts, (err, output) ->
    console.log output
    throw err if err
