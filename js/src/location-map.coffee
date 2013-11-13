# Get things organized, fool!
Coals = {}
Coals.Model = {}
Coals.Collection = {}
Coals.View = {}

# The Map model
Coals.Model.Map = Backbone.Model.extend
	defaults:
		id: ''
		currentLatLng: {}
		mapOptions: {}
		map: {}
		position: {}
		zoom: 2
		maxZoom: 10
		minZoom: 2

	initMap: (position) ->
		this.set 'position', position
		currentLatLng = new google.maps.LatLng position.coords.latitude, position.coords.longitude
		this.set 'currentLatLng', currentLatLng

		mapOptions = 
			zoom: this.get('zoom')
			minZoom: this.get('minZoom')
			maxZoom: this.get('maxZoom')
			center: currentLatLng
			mapTypeId: google.maps.MapTypeId.ROADMAP
			mapTypeControl: false

		this.set 'mapOptions', mapOptions

# The map view. This is what's called to render the map.
Coals.View.Map = Backbone.View.extend
	defaults:
		region: 'us'
		language: 'en'

	id: 'study-abroad-map'

	initialize: ->
		this.model.set( 'map', new google.maps.Map this.el, this.model.get('mapOptions'))

	render: ->
		$("#" + this.id).replaceWith(this.el)
		return this

# The location model
Coals.Model.Location = Backbone.Model.extend {}

# The location collection. This is what contains all of the
# locations and corresponding data when fetched.
Coals.Collection.Location = Backbone.Collection.extend
	model: Coals.Model.Location
	url: url.ajax

# The location collection-view. Takes care of the iteration over
# the location collection
Coals.View.LocationList = Backbone.View.extend
	initialize: ->
		this.collection.on 'add', this.addMarker, this

	render: ->
		this.collection.forEach this.addMarker, this

	addMarker: (location) ->
		locationView = new Coals.View.Location
			model: location
		locationView.render(this.options.map)

# The individual view for each location.
Coals.View.Location = Backbone.View.extend
	render: (map)->
		# assignedMap = map.get('map')
		coords = this.model.get('coordinates').split(", ")
		markerLatLng = new google.maps.LatLng coords[0], coords[1]
		marker = new google.maps.Marker
			position: markerLatLng
			title: this.model.get('title')

		marker.setMap(map)

$ ->
	# Setup the map
	map = new Coals.Model.Map
		zoom: 2

	# Initialize the map model
	map.initMap
		coords:
			latitude: 23.241346
			longitude: 24.609375

	# Setup the map view
	mapView = new Coals.View.Map
		model: map

	# Show the map on the page!
	mapView.render()

	# Setup the location collection and get locations from the server
	locationList = new Coals.Collection.Location
	locationList.fetch
		data:
			action: 'get_locations'

	# Setup the location collection-view.
	# This renders each location as a marker on the map
	# Any non-core attribute will be accessible through this.options.<name>
	locationListView = new Coals.View.LocationList
		collection: locationList
		map: map.get('map')