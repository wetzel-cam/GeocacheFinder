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
	static var myLocation = new GPS.Location(
		{
			:latitude => 39.206843d,
			:longitude => -76.690856d,
			:format => :degrees
		}
	);
//	39.206823, -76.692099
	static var thirdPoint = new GPS.Location(
		{
			:latitude => 39.206823d,
			:longitude => -76.692099d,
			:format => :degrees
		}
	);
	
	var centerPoint;
	
	var debug = true;
	
	function initialize() {
		
	}
	
	function start() {
		if (debug) {
		}
	}
	
	function stop() {
		
	}
	
	function update(dc) {
		centerPoint = [dc.getHeight(), dc.getHeight() / 2];
	}
	
	function drawPoint(r, heading) {	
		return [r * Math.cos(heading), (r * Math.sin(heading))];

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