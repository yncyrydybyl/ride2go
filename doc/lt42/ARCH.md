# ride2go architecture overview #

## description ##

ride2go is a service middleware and web-based front end that combines traffic information from route data providers to offer services like

* find possible rides from A to B, optimizing distance, speed, reliability,  or price by potentially using different means of transport by querying the available traffic information providers
* continously search for rides
* collect statistics on the use of frequently used rides or sub-rides (trips)
* publish ride offers from users

## concepts ##

provider
: information provider for traffic data of various modes
mode
: a generally understood means of travelling (car, bus, cab, plane)
graph model
: shared graph containing data aggregated over time from different providers
route
: a waypoint path for a specific provider that does not include time information
trip
: a route that does include time information
waypoint
: intermediary stops on routes found by an information provider
spot
: representation of waypoints in the shared graph model
location
: an object representing co-located waypoints/spots in the graph model
connector
: board component that supports resolving destination names and/or querying a provider for routes and connections
bowl
: shared space that allows connectors to jointly construct an answer
ride
: list of adjacent connections that solve the user's query
answer
: set if found trips that allow the construction of rides that match the user's query
query
: description of the ride the user was looking for, including start and stop location, times, preferred modes etc.


## architecture model ##

![][tech_arch]

[tech_arch]: diagrams/graph_model_tech_arch.jpg "technical architecture" width=1024

The graph model part is likely still in a bit of flux...


## interaction model ##

![][interaction]

[interaction]: diagrams/interaction.jpg "ride lookup and data ingestion interaction diagram" width=1024

![][logical_model]

[logical_model]: diagrams/logical_model.jpg "connector bus interaction and data structure draft" width=1024


## development plan ##

* Come up with a way to have a blackboard that allows subprocesses to generate new information
* Potentially remove node.io
* Come up with a simple-enough connector api that speaks in waypoints but does not preclude the possibility
  of switchting to locations
* Rewrite the architecure towards that api
* Rewrite connectors to use that new api
* Move API towards using locations,  that is waypoints linked up at multiple levels and accross providers/modes
* Come up with a shared graph model
* Build shared graph
* Integrate with connectors
* Write new resolving code that uses the shared graph to connect things


## data structure draft ##

* Blackboard contains data tuples
* Rules connect required data tuples to connectors that produce output tuples
* Asynchronicity is solved by registering outstanding tasks with the blackboard engine
* (opt.) Blackboard keeps track of dependencies
*

## scenario mit verb

* [EMPTY]
* [+StartPlace(string) +StartTime] UI
* [+StartLocation(...) +StartTime]

* ride(START, ZIEL, 'bus') :- bahn(START, M, MODE) if MODE=='bus', meinbus(M, ZIEL)


## execution model ##

* depends on node.io/blackboarding idea


