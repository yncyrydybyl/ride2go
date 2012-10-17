Structure of Redis Database
===========================


## Primary Keys

Unique strings that describe places of the form 'Country:State:City' where Country is a two letter country code.


## Provider Names

Unique strings for data providers scraped by connectors ('foursquare', 'bahn')


## Foreign Keys

Unique identifiers for places as understood by a specific data provider ('provider-name:id-type:provider-place-id')

The 'id-type' typically is 'id' unless a data provider supports multiple ids for the same location


## Data Structures in Redis

* We use database 0
* We map primary keys to a key-value property map (aka place object)

    'DE:Bayern:München' -> {
        lat: 1234,
        lon: 4567,
        population: 5,
        geoname:id: 'geoname-id',
        hafas:id: 'hafas-id'
        provider:id-type: 'provider-place-id'
    }

* Additionally, we map foreign keys ('provider-name:provider-place-ids') individually to a single primary key

    'geoname:id:1234' -> 'DE:Bayern:München'


## Special case: deinbus

* 'deinbus' uses different ids for the same location depending on wether it is an origin or a destination
* This is encoded by using 'deinbus:orig' and 'deinbus:dest' fake providers


## Special case: altnames

altnames are alternative names for primary keys. It is of the form

    'geoname:alt:name' -> Set of primary keys
