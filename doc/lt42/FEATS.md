план
-------

## rewrite rds into bb

* Locations
* Lookup
* Tie into socket.io
* node.io (?)
* 2-3d


## ride store

* City->City


## connector 

* run separately from commandline with parameters

* connectors 
  * berlinienbus (0.5d)
  * bahn (2d)
  * fahrgemeinschaft (1d)
  * deinbus (0.5d)
  * routen-auto-connector (km, ?)

## HTTP API

* GET / = searchform (**)
* GET /rides - list of rides

* POST /rides <- list of rides (?)

** 0.5 d 
* GET /admin/clients -> list of active queriers
* GET /connectors -> list of known connectors
* GET /connectors/active -> list of active connectors
* GET /connectors/disable -> list of disabled connectors


## socket.io API

Communcation between UI and BE using websockets 

* 1-2d
* query params <-
* log messages <-
* rides ->
* user messages ->


## Additional components

* completion sanitizer 
* something which converts strings to "LOCATIONS"
