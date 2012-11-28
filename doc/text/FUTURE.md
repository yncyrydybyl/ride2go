Futue development of ride2go
----------------------------


## Places and locations

Locations already convey a notion using different addressing schemes.
This should be explored further up to the point where connectors
are free to use one addressing scheme or another (geo, nominatim, etc.)
-> These addressing schemes have been called "keys" so far.


### Higher granularity

The current Place/State/City abstraction needs a higher level of
granularity.  In fact, it can be seen as a very primitive geocoder.
It may be worthwhile to switch to using nominatim addresses or
a derived thereof abstraction instead and rebuild rds around it.
-> Country:State:City:* is a geocoding/geohashing scheme. One that "coincidentally" naturally matches transport network graph hierarchies (in many cases)
A potentially useful extension would be IBNS (station ids) at a
low level.
-> IBNS ids are just another "addressing/geocoding/geohashing scheme". 
A string representation can be used as "key" in any key/value-store
to map between different "addressing/geocoding/geohashing schemes".

More practically, this would give various fields per address with an
implied hierarchy (e.g. "Country > State") that may be directly mapped
on complex redis keys.  Searching for rides would happen by dropping
detail information iteratively until enough rides are found.


### Multilingual names

Concerning multilingual names, it is neccessary to differentiate between
country and language, i.e. `DE/DE:*:Köln` and `EN/DE:*:Cologne`
-> alternative language names are just various "addressing/geocoding/geohashing schemes" aka "keys"

### Multiple address schemes for *rds*

A potential future step would be to not only support diverse addressing
schemes on the scraping level but down to the rds level.  This would
require a means of mapping between them.
-> yes mapping between keys e.g in a key/value store:
either by mapping all pairs of corresponding keys (quadratic storage complexity)
or by mapping all keys to one single "primary key" and from that "primary key" to all other keys/schemes (linear complexoty).
If the most common key is chosen as the "primary key", a lot of mappings can be made implicitly in many cases
because foreign key and primary key are then often identical.
Since a lot of input comes from users typing it or from websites writing it, maby schemes are initially strings.
So why not use these commonly used "names" as understood by humans as the "primary adressing scheme" and then update...


A potentially highly relevant scheme for this are geocoordinates. Thus
by moving the stack in this direction, we move towards a geocoordinate
(or geohash) based store.


## Architecture and Features

### Storage

Extract all redis logic from connectors and other modules into a
pure datastore api and a set of services for accesing it.
-> There is no redis logic in connectors. The RDS datastore abstracts it away behind a pure api.

### REST API

There currently is a tension between socket.io and the REST API.
This needs to be solved mid-term, perhaps using browserver.
-> socket.io and http are just different transports. The question is: What protocol is to be transported?
The same ride-exchange-protocol can then be used via socket.io (behind NATS) or via web-hook based REST.

### Eviction and duplicate detection

Meaning an efficient method for deletion old rides and detecting duplicates
rides have been stored with the detail-page-url as key. this should make them unique.
If the same ride is found on a different connector, the detail-page-link could be followed to find that "Unique Ride Locator"

### Better handling of time

* Time information is important and needs to be considered properly
* Relevant searched time window may differ per mode and/or provider

### Access control for ingestion

We need an answer for who may ingest what when how.

### Scraping and Connectors

* Move scraping towards using zombie.js
* Remove all redis dependencies from connectors
-> where are redis dependencies in connectors?
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
* single command build +1
* single command deployment +1
* using EventEmitter (or EventEmitter2) consequently +1
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
-> ReDiS has been a thoroughly deliberate choice.
ReDiS absolutely perfectly fits storing rides and mapping place keys.
Only a very thin abstraction is required atop to make it a RiDe Store (RDS).
+ ReDiS has HashMaps (implemented as fast small arrays) -> perfect for a large key map.
+ ReDiS has pub/sub and automatic expiration -> perfect for ridematching 
+ ReDiS has self-updating sorted lists -> for statistical prediction / autocompletion / ride suggestion filtering

## Prepare for distribution

This should not happen until the quality has matured and the story around
locations has settled. After that has happened, it boils down to

* Eliminate global state
* Move towards a "few dummy node processes atop big store model"
* Move further towards some partitioning scheme for the node processes
* Come up with own specialized storage
* Implement multi modal routing atop of that :)   +1




