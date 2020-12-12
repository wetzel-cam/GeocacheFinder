using Toybox.Application;
using Toybox.WatchUi;

class GeocacheFinderApp extends Application.AppBase {

	var tracker;
	
    function initialize() {
        AppBase.initialize();
        
        tracker = new GeocacheFinderTracker();
        
    }

    // onStart() is called on application start up
    function onStart(state) {
    	tracker.start();
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	tracker.stop();
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new GeocacheFinderView(), new GeocacheFinderDelegate() ];
    }
}