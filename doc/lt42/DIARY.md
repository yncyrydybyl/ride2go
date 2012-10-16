2012-10-16

* TODO Write standalone route for new UI
* TODO Adapt for fg integration
* DONE Document REDIS structure

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

* DONE Visit rejectjs
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

