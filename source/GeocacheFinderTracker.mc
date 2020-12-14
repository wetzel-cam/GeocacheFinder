using Toybox.Position as GPS;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Math;

class GeocacheFinderTracker {
	enum {
		LOCATION_DEGREES,
		LOCATION_RADIANS,
		LOCATION_GEO_STRING
	}
	
	// An approximate value for r in haversine formula
	// Value in kilometers
	static const RADIUS_EARTH = 6367.5165;

	// Toybox.Position.Location objects
	hidden var destinationData;
	hidden var locationData;
	
	hidden var radiusOfScreen;
	
	hidden var distanceFromDestination;
	
	var mArrow;
	
	// test data
	static var cacheLocation = new GPS.Location(
		{
			:latitude => 39.205205d,
			:longitude => -76.694262d,
			:format => :degrees
		}
	);
	static var myLocation = new GPS.Location(
		{
			:latitude => 39.206246d,
			:longitude => -76.690612d,
			:format => :degrees
		}
	);
	
	function initialize() {
		locationData = null;
		distanceFromDestination = null;		
		
		destinationData = cacheLocation;
		radiusOfScreen = 218 / 2;
	}
	
	function start() {
		GPS.enableLocationEvents(GPS.LOCATION_CONTINUOUS, method(:onPosition));
	}
	
	function stop() {
		GPS.enableLocationEvents(GPS.LOCATION_DISABLE, method(:onPosition));
	}
	
	// used so that the distance isn't calculated multiple times if getDistance
	// is called more than once and for other update shit
	function update(dc) {
		if (hasPosition() & hasDestination()) {
			distanceFromDestination = haversineFormula(locationData, destinationData);
		}
		
		var coords = positionArrow(getHeading());
		
		dc.drawCircle(coords[0] + 109, coords[1] + 109, 10);
	}
	
	// Testing location data from geocache
	// 39.205205, -76.694262
	function onPosition(info) {
		locationData = info.position;
		WatchUi.requestUpdate();
	}
	
	function hasPosition() {
		if (self.locationData != null) {
			return true;
		} else {
			return false;
		}
	}
	
	function getPosition(data) {
		if (self.locationData != null) {
			if (data == LOCATION_DEGREES) {
				return locationData.position.toDegrees();
			} else if (data == LOCATION_RADIANS) {
				return locationData.position.toRadians();
			}
		}
	}
	
	function getHeading() {
		var heading = GPS.getInfo().heading;
		if (heading != null) {
			return GPS.getInfo().heading;
		} else {
			return 0;
		}
	}
	
	function positionArrow(heading) {
		return [radiusOfScreen * Math.cos(heading), radiusOfScreen * Math.sin(heading)];
	}
	
	// hav(theta) = sin^2(theta/2) = 1 - cos(theta)
	static function hav(theta) {
		return Math.sin(theta/2) * Math.sin(theta/2);
	}
	
	// Haversine formula maps the spherical distance between two points
	// https://en.wikipedia.org/wiki/Haversine_formula
	// -- Not as accurate as other formula for calculating geographic distance but should suffice
	// All values in radians
	static function haversineFormula(locationOne, locationTwo) {
		// Broke these apart to make two "sepertate" readable functions
		// hav(theta) = hav(lat2-lat1) + cos(lat1)cos(lat2)hav(lon2-lon1)
		var tmpVal = hav(locationTwo.toRadians()[0] - locationOne.toRadians()[0]) + Math.cos(locationOne.toRadians()[0])
			* Math.cos(locationTwo.toRadians()[0]) * hav(locationTwo.toRadians()[1] - locationOne.toRadians()[1]);
		// Have h = hav(theta):
		// 2r*arcsin(sqrt(h)), where r = radius of a sphere (in this case, the earth)
		var distance = 2 * RADIUS_EARTH * Math.asin(Math.sqrt(tmpVal));
		
		// returns in kilometers
		return distance;
	}
	
	function checkNull(object, exception) {
	
	}
	
	function hasDestination() {
		if (destinationData != null) {
			return true;
		} else {
			return false;
		}
	}
	
	function getDistance() {
		if (distanceFromDestination != null) {
			return distanceFromDestination;
		} else {
			return "error";
		}
	}
	
}