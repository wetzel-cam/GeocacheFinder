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
	
	// test data
	static var cacheLocation = new GPS.Location(
		{
			:latitude => 39.205205d,
			:longitude => -76.694262d,
			:format => :degrees
		}
	);
//	39.206843, -76.690856
	static var currentLocation = new GPS.Location(
		{
			:latitude => 39.206843d,
			:longitude => -76.690856d,
			:format => :degrees
		}
	);
//	39.206823, -76.692099
	static var thirdLocation = new GPS.Location(
		{
			:latitude => 39.206823d,
			:longitude => -76.692099d,
			:format => :degrees
		}
	);
	
//	39.2094511,-76.6859241
	static var fourthLocation = new GPS.Location(
		{
			:latitude => 39.2094511d,
			:longitude => -76.6859241d,
			:format	=> :degrees
		}
	);
	
	var centerPoint;
	
	var debug = true;
	var test1;
	
	function initialize() {
	}
	
	function start() {
		if (debug) {
		}
	}
	
	function stop() {
		
	}
	
	// For all the draw functions and logic updates
	function update(dc) {
		// constant definitions
		centerPoint = [dc.getHeight() / 2, dc.getHeight() / 2];
		
		if (debug) {
			
		}
	}
	
	// Given two points on the globe, returns the angle of travel relative to north in radians.
	function getAngle() {
		// Find the slope between the points
		// NOTE: testing values, change to variables later
		var run = fourthLocation.toRadians()[0] - currentLocation.toRadians()[0];
		var rise = fourthLocation.toRadians()[1] - currentLocation.toRadians()[1];
		
		// Using sohcahtoa, find the angle of the right triangle drawn by the slope
		return Math.atan(rise/run);
	}
	
	// Returns the signs of the slopes
	function getSlopeSigns() {
		var signs = new [2];
		
		var run = fourthLocation.toRadians()[0] - currentLocation.toRadians()[0];
		var rise = fourthLocation.toRadians()[1] - currentLocation.toRadians()[1];
		var values = [rise, run];
		
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
		}
		
		return signs;
	}
	
	// Returns the quadrant the direction of travel is in
	function getQuadrant() {
		var signs = getSlopeSigns();
		
		if (signs[0] == :pos && signs[1] == :pos) {
			return 1;
		} else if (signs[0] == :pos && signs[1] == :neg) {
			return 2;
		} else if (signs[0] == :neg && signs[1] == :neg) {
			return 3;
		} else if (signs[0] == :neg && signs[1] == :pos) {
			return 4;
		}
	}
	
	function orientPoint() {
		var center = [109, 109];
		var newCoords = null;
		var angle = getAngle();
		// this value needs to change based on the quadrant(?) of the vector
		var rotationAngle = - Math.PI / 2;
		
		var sin = Math.sin(rotationAngle);
		var cos = Math.cos(rotationAngle);
		var coords = drawPoint(109, getAngle());
		
		System.println(coords.toString());
		
		var x = (coords[0] * cos) - (coords[1] * sin);
		var y = (coords[0] * sin) + (coords[1] * cos);
			
		newCoords = [center[0] + x, (center[1] + y)];
		
		System.println(newCoords.toString());
		
		return newCoords;
	}
	
	function drawPoint(radius, angle) {	
		return [radius * Math.cos(angle), (radius * Math.sin(angle))];

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