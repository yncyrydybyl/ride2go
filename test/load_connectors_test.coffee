describe 'connector setup', () ->

  it.only 'should load all connectors', () ->
    api = require '../lib/connectors/index'
    expect(api).to.be.ok
    connector_index = api.active_connectors.indexOf('deinbus')
    expect(connector_index >= 0).to.be.true
    expect(api[api.active_connectors[connector_index]]).to.be.ok