
Futue development of ride2go
----------------------------


## Places and locations

Locations already convey a notion using different addressing schemes.
This should be explored further up to the point where connectors
are free to use one addressing scheme or another (geo, nominatim, etc.)


### Higher granularity

The current Place/State/City abstraction needs a higher level of
granularity.  In fact, it can be seen as a very primitive geocoder.
It may be worthwhile to switch to using nominatim addresses or
a derived thereof abstraction instead and rebuild rds around it.
A potentially useful extension would be IBNS (station ids) at a
low level.

More practically, this would give various fields per address with an
implied hierarchy (e.g. "Country > State") that may be directly mapped
on complex redis keys.  Searching for rides would happen by dropping
detail information iteratively until enough rides are found.


### Multilingual names

Concerning multilingual names, it is neccessary to differentiate between
country and language, i.e. `DE/DE:*:Köln` and `EN/DE:*:Cologne`


### Multiple address schemes for *rds*

A potential future step would be to not only support diverse addressing
schemes on the scraping level but down to the rds level.  This would
require a means of mapping between them.

A potentially highly relevant scheme for this are geocoordinates. Thus
by moving the stack in this direction, we move towards a geocoordinate
(or geohash) based store.


## Architecture and Features

### Storage

Extract all redis logic from connectors and other modules into a
pure datastore api and a set of services for accesing it

### REST API

There currently is a tension between socket.io and the REST API.
This needs to be solved mid-term, perhaps using browserver.

### Eviction and duplicate detection

Meaning an efficient method for deletion old rides and detecting duplicates

### Better handling of time

* Time information is important and needs to be considered properly
* Relevant searched time window may differ per mode and/or provider

### Access control for ingestion

We need an answer for who may ingest what when how.

### Scraping and Connectors

* Move scraping towards using zombie.js
* Remove all redis dependencies from connectors
* After location, scraping and connectors have matured, enable client-based
scraping

## User interface

A more polished ui that has completion is mandatory.

There likely is the need to filter and group rides cleverly in order
to not be overwhelmed by too many offers from a single provider

Furthermore, preferred filter/grouping settings need to be remembered per
user


## General Software quality

ride2go needs

* a way more extensive and robust test suite
* single command build
* single command deployment
* using EventEmitter (or EventEmitter2) consequently
* moving to node 0.8 and using domains for error handling consequently
* extend documentation to be more complete


### Performance

There are quite a few places where the current implementation is using far from
optimal algorithms due to limitations of javascript or hackity hack, i.e.
measure and fix.  It may be a good idea to decide to use some ES Harmony
proposals already (sets, object-keyed hashes) etc.

#### Group sockets

Refactor the existing publish-subscribe mechanism into a hierachical
solution

#### Add internal caching

* for service lookups (resolved locations)
* for rides(?)

### Evaluate redis alternatives

REDIS is a bit of an arbitrary choice; we should look into alternatives.

## Prepare for distribution

This should not happen until the quality has matured and the story around
locations has settled. After that has happened, it boils down to

* Eliminate global state
* Move towards a "few dummy node processes atop big store model"
* Move further towards some partitioning scheme for the node processes
* Come up with own specialized storage
* Implement multi modal routing atop of that :)




