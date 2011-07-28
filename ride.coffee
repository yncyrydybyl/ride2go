class Ride

  ## principle of least surprise

  constructor: (o) -> # convenience setters
    @link = o.id || o.url || o.ref || o.link
    if o.locations
      # looks like a dycapo trip
      for location in o.locations
        if location.point is "orig" then @orig = new Place({trip:location})
        if location.point is "dest" then @dest = new Place({trip:location})
    else 
      @orig = o.from || o.orig || o.origin || o.start || o.source
    @dest = o.to || o.dest || o.destination || o.target
    @date = o.date || o.datum || o.published_at || o.last_modified
    @locations = o.locations
    console.log(o)
  json: -> JSON.stringify(@)
  # convenience getters
  destination: -> @dest
  origin: -> @orig
  target: -> @dest
  start: -> @orig
  date: -> @date
  from: -> @orig
  ziel: -> @dest
  to: -> @dest

class Place
  constructor: (p) ->
    #@lon = p.long || p.geolocation.long || p.geolocation.longtitude 
    #@lat = p.lat || p.geolocation.lat || p.geolocation.latitude
    if p.trip
      console.log("called with a trip")

# a trip according to dycapo
class Trip
  constructor: (t) ->

# a location according to dycapo
class Location
  constructor: (l) -> 

r = new Ride (
  to:
    cityname: "hamburg"
    street: "reeperbahn"
    street_number: "21"
    country: "germany"
    geo: 
      lon: 9.962436
      lat: 53.549587
)

s = new Ride (
    locations: [
      town: "Bolzano"
      point: "orig"
      country: ""
      region: ""
      subregion: ""
      days: "",
      label: "Work"
      street: "Rom Strasse"
      postcode: 39100
      offset: 150
      leaves: ""
      recurs: ""
      georss_point: "46.490200 11.342294"
    ,
      town: "Bolzano"
      point: "dest"
      country: ""
      region: ""
      subregion: ""
      days: "",
      label: "Work"
      street: "Rom Strasse"
      postcode: 39100
      offset: 150
      leaves: ""
      recurs: ""
      georss_point: "46.490200 11.342294"
    ]
    
)
console.log(s.origin())
