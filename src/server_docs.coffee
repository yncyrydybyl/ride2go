module.exports = (app, config) ->

  describe = (res, descr) ->
    descr.swaggerVersion = '1.1'
    descr.apiVersion     = '0.1'
    descr.basePath       = "http://#{config.server.host}:#{config.server.port}"
    res.send JSON.stringify descr

  app.get '/resources.json', (req, res) ->
    describe res, {
      apis: [
        {
          path: '/api/connectors.{format}'
          description: 'Access connectors in various ways'
        },
        {
          path: '/ridestream.{format}'
          description: 'Display a stream of continously updated rides'
        }
      ]
    }

  app.get '/api/connectors.json', (req, res) ->
    describe res, {
      resourcePath: '/api/connectors'
      apis: [
        {
          path: '/api/connectors/_all'
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
          path: '/api/connectors/_enabled'
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
          path: '/api/connectors/_disabled'
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
          path: '/api/connectors/_ingesting'
          description: 'Ingesting connectors'
          operations: [
            {
              httpMethod: 'GET'
              nickname: 'getIngestingConnectorNames'
              parameters: []
              notes: ''
              errorResponses: []
              responseClass: 'void'
              summary: 'Get list of ingesting connectors'
            }
          ]
        },
        {
          path: '/api/connectors/{connName}'
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
        },
        {
          path: '/api/connectors/{connName}/rides'
          description: 'Rides of named connectors'
          operations: [
            {
              httpMethod: 'POST'
              nickname: 'ingestConnectorRides'
              parameters: [
                {
                  name: 'connName'
                  paramType: 'path'
                  description: 'Name of the connector'
                  dataType: 'string'
                  required: true
                },
                {
                  name: 'rideArray'
                  paramType: 'body'
                  description: 'JSON Array of ride objects'
                  dataType: 'string'
                  required: true
                }
              ]
              notes: ''
              errorResponses: []
              resonseClass: 'string'
              summary: 'Ingest externally provided rides'
            }
          ]
        }
      ]
    }

  app.get '/ridestream.json', (req, res) ->
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
              parameters: [
                {
                  name: 'fromLat',
                  paramType: 'query',
                  description: 'Latitude of origin'
                  dataType: 'string',
                  required: false
                },  
                {
                  name: 'fromLon',
                  paramType: 'query',
                  description: 'Longitude of origin'
                  dataType: 'string',
                  required: false
                }  
                {
                  name: 'fromKey',
                  paramType: 'query',
                  description: 'Place key of origin'
                  dataType: 'string',
                  required: false
                },              
                {
                  name: 'fromStr',
                  paramType: 'query',
                  description: 'Place descriptor of origin (key or pos)'
                  dataType: 'string',
                  required: false
                },
                {
                  name: 'fromplacemark',
                  paramType: 'query',
                  description: 'JSON encoded google geocode placemark of origin that is used to obtain the pos of origin'
                  dataType: 'string',
                  required: false
                },              
                {
                  name: 'toLat',
                  paramType: 'query',
                  description: 'Latitude of destination'
                  dataType: 'string',
                  required: false
                },  
                {
                  name: 'toLon',
                  paramType: 'query',
                  description: 'Longitude of destination'
                  dataType: 'string',
                  required: false
                }  
                {
                  name: 'toKey',
                  paramType: 'query',
                  description: 'Place key of destination'
                  dataType: 'string',
                  required: false
                },              
                {
                  name: 'toStr',
                  paramType: 'query',
                  description: 'Place descriptor of destination (key or pos)'
                  dataType: 'string',
                  required: false
                },
                {
                  name: 'toplacemark',
                  paramType: 'query',
                  description: 'JSON encoded google geocode placemark of destination that is used to obtain the pos of destination'
                  dataType: 'string',
                  required: false
                },              
                {
                  name: 'tolerancedays',
                  paramType: 'query',
                  description: 'Number of days to add/substract from departure to calculate left and right sided cuts'
                  dataType: 'number',
                  required: false
                },
                {
                  name: 'departure',
                  paramType: 'query',
                  description: 'Desired departure time as UNIX timestamp'
                  dataType: 'string',
                  required: false
                },
                {
                  name: 'leftcut',
                  paramType: 'query',
                  description: 'Minimum departure time as UNIX timestamp'
                  dataType: 'string',
                  required: false
                },
                {
                  name: 'rightcut',
                  paramType: 'query',
                  description: 'Maximum departure time as UNIX timestamp'
                  dataType: 'string',
                  required: false
                }
              ]
              notes: ''
              errorResponses: []
              responseClass: 'void'
              summary: 'Produces ridestream page'
            }
          ]
        }
      ]
    }


