using Toybox.Position as GPS;
using Toybox.Sensor;
using Toybox.Timer;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Math;

class GeocacheFinderTracker {
	// An approximate value for r in haversine formula
	// Value in kilometers
	static const RADIUS_EARTH = 6367.5165;
	
	static enum {
		QUADRANT_ONE = 1,
		QUADRANT_TWO,
		QUADRANT_THREE,
		QUADRANT_FOUR
	}
	
	// test data
	static var swLocation = new GPS.Location(
		{
			:latitude => 39.205143d,
			:longitude => -76.694812d,
			:format => :degrees
		}
	);
//	39.205249, -76.693789
	static var cLocation = new GPS.Location(
		{
			:latitude => 39.205249d,
			:longitude => -76.693789d,
			:format => :degrees
		}
	);
//	39.222103, -76.709498
	static var nwLocation = new GPS.Location(
		{
			:latitude => 39.222103d,
			:longitude => -76.709498d,
			:format => :degrees
		}
	);

// 	39.203192, -76.686766
	static var seLocation = new GPS.Location(
		{
			:latitude => 39.203192d,
			:longitude => -76.686766d,
			:format => :degrees
		}
	);
	
//	39.2094511,-76.6859241
	static var neLocation = new GPS.Location(
		{
			:latitude => 39.2094511d,
			:longitude => -76.6859241d,
			:format	=> :degrees
		}
	);
	
	var centerPoint;
	var currentLocation;
	var destination;
	var angle;
	var slopeSigns;
	var quadrant;
	
	var debug = true;
	var test1;
	
	function initialize() {
		currentLocation = null;
		destination = null;
		angle = null;
		slopeSigns = null;
		quadrant = null;
		
		if (debug) {
			currentLocation = cLocation;
			destination = nwLocation;
		}
	}
	
	function start() {
		if (!debug) {
			GPS.enableLocationEvents(GPS.LOCATION_CONTINUOUS, method(:onPosition));
		}
	}
	
	function stop() {
		
	}
	
	function update() {
		updateSlopeSigns();
		updateQuadrant();
		updateAngle();
		
		if (debug) {
			
		}
	}
	
	function onPosition(info) {
		currentLocation = info.position;
	}
	
	// Given two points on the globe, returns the angle of travel relative to north in radians.
	function updateAngle() {
		var opposite = null;
		var adjacent = null;
		
		// What is considered the opposite and adjacent ends is dependent on the quadrant
		switch (quadrant) {
			// Y value is the opposite side, X values is the adjacent side
			case GeocacheFinderTracker.QUADRANT_ONE:
			case GeocacheFinderTracker.QUADRANT_THREE:
				opposite = destination.toRadians()[0] - currentLocation.toRadians()[0];
				adjacent = destination.toRadians()[1] - currentLocation.toRadians()[1];
				break;
			// X value is the opposite side, Y values is the adjacent side
			case GeocacheFinderTracker.QUADRANT_TWO:
			case GeocacheFinderTracker.QUADRANT_FOUR:
				opposite = destination.toRadians()[1] - currentLocation.toRadians()[1];
				adjacent = destination.toRadians()[0] - currentLocation.toRadians()[0];
				break;
		}
		
		// Use sohcahtoa to find the angle of the vector
		angle = Math.atan(opposite/adjacent);
		
		if (debug) {
			System.println("Angle: " + angle);
		}
	}
	
	function updateSlopeSigns() {
		var signs = new [2];
		var values = new [2];
		
		// index 0 is rise value, index 1 is run value
		values[0] = destination.toRadians()[0] - currentLocation.toRadians()[0];
		values[1] = destination.toRadians()[1] - currentLocation.toRadians()[1];
		
		for (var i = 0; i < 2; i++) {
			if (values[i] > 0) {
				signs[i] = :pos;
			} else if (values[i] < 0) {
				signs[i] = :neg;
			} else {
				signs[i] = :zero;
			}
		}
		
		if (debug) {
			System.println("Rise sign: " + signs[0].toString() + ", Run sign: " + signs[1].toString());
			System.println("slopeSigns: " + values.toString());
		}
		
		slopeSigns = signs;
	}
	
	// Returns the quadrant the direction of travel is in
	function updateQuadrant() {
		if (slopeSigns[0] == :pos && slopeSigns[1] == :pos) {
			quadrant = GeocacheFinderTracker.QUADRANT_ONE;
		} else if (slopeSigns[0] == :pos && slopeSigns[1] == :neg) {
			quadrant = GeocacheFinderTracker.QUADRANT_TWO;
		} else if (slopeSigns[0] == :neg && slopeSigns[1] == :neg) {
			quadrant = GeocacheFinderTracker.QUADRANT_THREE;
		} else if (slopeSigns[0] == :neg && slopeSigns[1] == :pos) {
			quadrant = GeocacheFinderTracker.QUADRANT_FOUR;
		}
		
		if (debug) {
			System.println("Quadrant: " + quadrant);
		}
	}
	
	function getQuadrantOffset() {
		switch (quadrant) {
			case GeocacheFinderTracker.QUADRANT_ONE:
				return 0;
			case GeocacheFinderTracker.QUADRANT_TWO:
				return Math.PI /2;
			case GeocacheFinderTracker.QUADRANT_THREE:
				return Math.PI;
			case GeocacheFinderTracker.QUADRANT_FOUR:
				return -1 * Math.PI / 2;
			default:
				break;
		}
	}
	
	function rotatePoint() {
		var newCoords = new [2];
		var rotationAngle = getQuadrantOffset();
		
		var sin = Math.sin(rotationAngle);
		var cos = Math.cos(rotationAngle);
		var drawCoords = drawPoint(109, angle);
		
		System.println("Before rotation: " + drawCoords.toString());
		
		newCoords[0] = (drawCoords[0] * cos) - (drawCoords[1] * sin);
		newCoords[1] = (drawCoords[0] * sin) + (drawCoords[1] * cos);
		
		System.println("After rotation: " + newCoords.toString());
		
		return newCoords;
	}
	
	function drawPoint(radius, angle) {	
		return [radius * Math.cos(angle), radius * Math.sin(angle)];

	}
	
	function shiftCoords(coords) {
		var newValues = new [2];
		
		newValues[0] = coords[0] + 109;
		newValues[1] = 109 - coords[1];
		
		return newValues;
	}
	
	function sohcahtoa(angle, h) {
		return [h * Math.cos(angle), h * Math.sin(angle)];
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
}