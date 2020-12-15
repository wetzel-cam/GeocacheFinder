using Toybox.Position as GPS;
using Toybox.Sensor;
using Toybox.Timer;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Math;

class GeocacheFinderTracker {
	enum {
		LOCATION_DEGREES,
		LOCATION_RADIANS,
		LOCATION_GEO_STRING
	}
	
	enum {
		QUAD_1,
		QUAD_2,
		QUAD_3,
		QUAD_4
	}
	
	// An approximate value for r in haversine formula
	// Value in kilometers
	static const RADIUS_EARTH = 6367.5165;

	// Toybox.Position.Location objects
	hidden var destinationData;
	hidden var locationData;
	
	hidden var radiusOfScreen;
	
	hidden var distanceFromDestination;
	hidden var angleFromDest;
	
	// debug/testing
	var debug = true;
	var mArrow;
	var mag;
	var timer;
	var coords;
	var azimuth;
	
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
		timer = new Timer.Timer();
		coords = null;
		angleFromDest = 0;
	}
	
	function start() {
		if (debug) {
			var xCurrent = myLocation.toRadians()[0];
			var yCurrent = myLocation.toRadians()[1];
			var xCache = cacheLocation.toRadians()[0];
			var yCache = cacheLocation.toRadians()[1];
			
			var xSlope = xCache - xCurrent;
			var ySlope = yCache - yCurrent;
			azimuth = Math.sqrt((xSlope * xSlope) + (ySlope * ySlope));
			
			var quadsArray = [
				getSlopeSign(xSlope), 
				getSlopeSign(ySlope)
			];
			
			System.println("X: " + quadsArray[0].toString() + ", Y: " + quadsArray[1].toString());
			
			var quad = getQuadrant(quadsArray);
			
			System.println(quad);
			
			var quadVal = getQuadrantValue(quad);
			
			System.println(quadVal);
			
			var angle = Math.atan2(ySlope.abs(), xSlope.abs());
			
			System.println(angle);
			
			var newAngle = quadVal + angle;
			
			System.println(newAngle);
			
			angleFromDest = newAngle;
		}
		
		GPS.enableLocationEvents(GPS.LOCATION_CONTINUOUS, method(:onPosition));
		timer.start(method(:timerCallback), 500, true);
	}
	
	function stop() {
		GPS.enableLocationEvents(GPS.LOCATION_DISABLE, method(:onPosition));
		timer.stop();
	}
	
	// used so that the distance isn't calculated multiple times if getDistance
	// is called more than once and for other update shit
	function update(dc) {
		if (hasPosition() & hasDestination()) {
			distanceFromDestination = haversineFormula(locationData, destinationData);
		}
		
//		var coords = positionArrow(getHeading());
		
		getCardinalDirection();
		
		// TODO: allow the outside arrow to orient towards objective or to north.
		if (coords != null) {			
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
			dc.fillCircle(coords[0] + 109, coords[1] + 109, 10);
		}
		
//		var xyc = sohcahtoa(angleFromDest, azimuth);
		var xyc = positionArrow(angleFromDest);
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
		dc.fillCircle(xyc[0] + 109, xyc[1] + 109, 5);
//		dc.fillCircle(xyc[0] + 109 - Math.PI/2, xyc[1] + 109 - Math.PI/2, 5);
		
		
		
		// LEFT OFF: While facing north, have the point of geocache (blue dot) pointin towards its location
		// as it stands, I think the dot points to the correct angle, but it's reflected over the y axis right now
		
		
		
		
//		WatchUi.requestUpdate();
	}
	
	// Testing location data from geocache
	// 39.205205, -76.694262
	function onPosition(info) {
		locationData = info.position;
		
//		coords = positionArrow(info.heading);
		
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
			System.println("Heading: " + heading.toString());
			return heading;
		} else {
			return 0;
		}
	}
	
	function calculateAngleFromHeading() {
		
	}
	
	function getAngleAwayFromDest() {
		angleFromDest = Math.atan2(coords[1], coords[0]);
	}
	
	function getCardinalDirection() {		
		if (mag != null) {
			System.println("X: " + mag[0] + ", Y: " + mag[1] + ", Z: " + mag[2]);
			return "X: " + mag[0] + ", Y: " + mag[1] + ",\nZ: " + mag[2];
		} else {
			return "Waiting on data";
		}
	}
	
	function timerCallback() {
		var info = Sensor.getInfo();
		
//		if (info has :mag && info.mag != null) {
//			mag = info.mag;
//		}

		coords = positionArrow(info.heading);
		
		WatchUi.requestUpdate();
	}
	
	function getQuadrantValue(value) {
		switch (value) {
			case QUAD_1:
				return 0;
			case QUAD_2:
				return Math.PI / 2;
			case QUAD_3:
				return Math.PI;
			case QUAD_4:
				return Math.PI * 3 / 2;
			default:
				return 0;
		}
	}
	
	function getQuadrant(value) {
		if (value[0] == :pos && value[1] == :pos) {
			return QUAD_1;
		} else if (value[0] == :neg && value[1] == :pos) {
			return QUAD_2;
		} else if (value[0] == :neg && value[1] == :neg) {
			return QUAD_3;
		} else if (value[0] == :pos && value[1] == :neg) {
			return QUAD_4;
		}
	}
	
	// Gets the quadrant of the cache location relative to current location
	// sets the currentlocation as the center of a circle. using part of
	// the std circle formula, you can find the direction of travel
	// value = (x - h); x = x coord of a point on circumference of a circle,
	// h = center of the same circle. The sign value tells whether the abscissa is pos or neg
	function getSlopeSign(value) {
		if (value > 0) {
			return :pos;
		} else if (value < 0) {
			return :neg;
		} else {
			return :zero;
		}
	}
	
	// takes heading in rads
	// returns an array
	function positionArrow(heading) {	
		// Cardinal Y direction is opposite the screen coordinates
		// Shifted the heading by Pi, sensor reports north at 0 rads
		return [radiusOfScreen * Math.cos(heading + (Math.PI / 2)), (radiusOfScreen * Math.sin(heading + (Math.PI / 2))) * -1];
//		return [radiusOfScreen * Math.cos(heading), (radiusOfScreen * Math.sin(heading)) * -1];

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