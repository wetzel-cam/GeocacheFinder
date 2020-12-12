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
	static const RADIUS = 6367.5165;
	
	hidden var destinationLat;
	hidden var destinationLon;
	
	// Toybox.Position.Location objects
	hidden var destinationData;
	hidden var locationData;
	
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
		
		destinationData = cacheLocation;
	}
	
	function start() {
		GPS.enableLocationEvents(GPS.LOCATION_CONTINUOUS, method(:onPosition));
	}
	
	function stop() {
		GPS.enableLocationEvents(GPS.LOCATION_DISABLE, method(:onPosition));
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
		var distance = 2 * RADIUS * Math.asin(Math.sqrt(tmpVal));
		
		// returns in kilometers
		return distance;
	}
	
	function getDistance() {
		if (hasPosition()) {
			return haversineFormula(locationData, destinationData);
		} else {
			return "error";
		}
	}
	
}