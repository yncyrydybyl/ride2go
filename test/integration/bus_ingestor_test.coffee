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

  it.only 'should ingest rides', (done) ->
    chai.request(app.app)
    .post('/api/connectors/bus_ingestor/rides')
    .req (req) ->
      req.set 'Content-Type', 'application/json'
      req.write JSON.stringify [{
        "orig_key": "DE:Berlin:Berlin",
        "dest_key": "DE:Hamburg:Hamburg",
        "provider": "bus_ingestor"
      }]
    .res (res) ->
      expect(res).to.have.status(200)
      done()

  after stop_server