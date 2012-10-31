describe 'bus_ingestor', () ->

  app         = undefined
  start_server = (done) ->
    app = require '../../lib/server'
    done()

  stop_server  = (done) ->
    app.server.on 'close', done
    app.server.close()

  before start_server

  it 'should create the server', () ->
    expect(app).to.be.ok

  it 'should ingest rides', (done) ->
    r = chai.request(app.app)
    r = r.post('/api/connectors/bus_ingestor/rides')
    r = r.req (req) ->



  after stop_server