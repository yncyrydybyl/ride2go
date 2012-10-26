

* TODO New place api
* TODO Docs
* TODO Subscribe to rides
* TODO Ingest rides
* TODO mail an sven, flo, t

2012-10-26

* DONE Enable swagger based docs
* DONE Enable codo based docs

2012-10-25

* DONE Proper input handling for minimalistic ui
* DONE Fixing new resolution implementation

2012-10-24

* POSTPONED Nominatim completion for minimalistic ui
* DONE Very minimalistic standalone ui
* DONE Review documentation solutions for coffescript: coda, yui, docco, coffeedoc, jsdoc
  * jsdoc: supported by webstorm, but needs java :-( #fail
  * docco: feels to unstructured #fail
  * coffeedoc: feels to unmaintained #maybe
  * coda: feels to structured, but used by neo, chaplin, ... #try
  * yuidoc: feels to structured and is not coffee friendly #fail

2012-10-23

* DONE Better logging of rides (skips links)
* DONE Refactor ridestream code for separate use


2012-10-22

* DONE Filter times
* DONE Abfahrtssort
* DONE Correct sorting in datatable
* DONE Arbitrary left/rightcut

2012-10-18

* DONE Zeiten bei deinbus
* DONE Fake Route @me
* DONE BS - Wolfsburg
* DONE Lokale Anbieter (?) - WVG
* DONE Filter wrong keys
* DONE Dauer stimmt nicht (tbd.)
* DONE Kosten tbd.
* DONE Anbieter raus -> Logos
* DONE Ankunftszeit stimmt nicht
* POSTPONED Filter too many entries
* DONE Proper error when unresolvable
* DONE Why resolve fails second time
* DONE Unique ride ids
* DONE Remove double entries
* DONE Dauer anzeigen
* DONE Language preference openmapquest api
* DONE Bahn link
* DONE replaced nginx with simpleproxy
* DONE nginx redirect to port 3000
* DONE Integration
* DONE Remove wrong entries
* DONE ausfaktorieren von place lookup
* DONE altnames lookup


2012-10-17

* DONE Made server port configurable
* DONE Revamp javascript asset management with bower
* DONE Implement reverse geocoding via mapquest
* DONE Add configuration method for apikeys
* DONE Add better error handling


2012-10-16

* DONE javascript assets get symlinked by cake link
* DONE details links for deinbus
* DONE new ids for pts and deinbus
* DONE Use moments in ridestream
* DONE Write standalone route for new UI
* DONE Adapt for fg integration
* DONE Document REDIS structure in REDIS.md
* DONE Lots of help from flo. Thanks!


2012-10-15

* DONE Setup server
* DONE Fix mapquest


2012-10-14

* DONE Repair master and merge what is ready from platzhirsch
* DONE Fix pts
* DONE Fix deinbus


2012-10-12

* DONE Work on rides tests for new places API


2012-10-11

* DONE Fix places tests for new places API


2012-10-10

* DONE Seprate places and geostore api

2012-10-09

* DONE Finish leafy

2012-10-08

* DONE Integrate traits.js
* DONE Write cloneable sets with traits.js
* TODO Write leafy as a precondition for new location/place instances

2012-10-07

* DONE Design leafy structure
* DONE Meeting: sven, t, flo, boggle

2012-10-06

* DONE Meeting: sven, flo, t, schatz, boggle


2012-10-05

* DONE Review plan and ride and usage of redis
* DONE Research datalog papers and think about how this maps on blackboard idea


2012-10-04

* DONE Visit rejectjs conference
* DONE Talk about core feature set and blackboard approach


2012-10-02

* DONE moved most tests to mocha
* DONE added AGPL
* DONE rewrote build script
* DONE switche to using styl instead of sass, prolly broke the css


2012-10-01

* DONE repaired geoname import
* DONE made tests run again


2012-09-30

* DONE updates to stable version of nodes.js (0.6) and updates packages
* DONE convert docs to markdown


2012-09-26

* DONE rethought models, wrote down fancy diagrams, identified key problem:
  Which voyages should be kept? (all: O(n^2) storage, doable but huge)
  How much route information should be replicated in the graph?
  Remark: 
  We actually compute the transitive closure over all potential routes.
  Even with subroutes, alot of information will move into the graph.
  This is tricky. We need to rethink voyages.

2012-09-25

* DONE skimmed existing code @boggle
* DONE discussed architecture proposal @boggle @t
* DONE setup daily log @boggle


2012-09-24

* DONE setup trello @boggle @t
* DONE discussed overall schedules and key problems @boggle @t

