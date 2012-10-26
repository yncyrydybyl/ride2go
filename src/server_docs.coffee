module.exports = (app, config) ->

  describe = (res, descr) ->
    descr.swaggerVersion = '1.1'
    descr.apiVersion     = '0.1'
    descr.basePath       = "http://#{config.server.host}:#{config.server.port}/api"
    res.send JSON.stringify descr

  app.get '/api/resources.json', (req, res) ->
    describe res, {
      apis: [
        {
          path: '/connectors.{format}'
          description: 'Access connectors in various ways'
        },
        {
          path: '/ridestream.html'
          description: 'Display a stream of continously updated rides'
        }
      ]
    }

  app.get '/api/connectors.json', (req, res) ->
    describe res, {
      resourcePath: '/connectors'
      apis: [
        {
          path: '/connectors/_all'
          description: 'Loaded connectors'
          operations: [
            {
              httpMethod: 'GET'
              nickname: 'getAllConnectorNames'
              parameters: []
              notes: ''
              errorResponses: []
              responseClass: 'void'
              summary: 'Get list of all loaded connectors'
            }
          ]
        },
        {
          path: '/connectors/_enabled'
          description: 'Enabled connectors'
          operations: [
            {
              httpMethod: 'GET'
              nickname: 'getEnabledConnectorNames'
              parameters: []
              notes: ''
              errorResponses: []
              responseClass: 'void'
              summary: 'Get list of enabled connectors'
            }
          ]
        },
        {
          path: '/connectors/_disabled'
          description: 'Disabled connectors'
          operations: [
            {
              httpMethod: 'GET'
              nickname: 'getDisabledConnectorNames'
              parameters: []
              notes: ''
              errorResponses: []
              responseClass: 'void'
              summary: 'Get list of disabled connectors'
            }
          ]
        },
        {
          path: '/connectors/{connName}'
          description: 'Named connectors'
          operations: [
            {
              httpMethod: 'GET'
              nickname: 'getConnectorDetails'
              parameters: [
                {
                  name: 'connName'
                  paramType: 'path'
                  description: 'Name of the connector'
                  dataType: 'string'
                  required: true
                }
              ]
              notes: ''
              errorResponses: []
              resonseClass: 'void'
              summary: 'Get detail information for a connector'
            }
          ]
        }
      ]
      models: {}
    }

  app.get '/api/ridestream.html', (req, res) ->
    describe res, {
      resourcePath: '/ridestream'
      apis: [
        {
          path: '/ridestream'
          description: 'Generate ridestream'
          operations: [
            {
              httpMethod: 'GET'
              nickname: 'getRidestream'
              parameters: []
              notes: ''
              errorResponses: []
              responseClass: 'void'
              summary: 'Produces ridestream page'
            }
          ]
        }
      ]
    }


