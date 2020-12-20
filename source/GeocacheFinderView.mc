using Toybox.WatchUi;
using Toybox.System;

using Toybox.WatchUi as Ui;
using Toybox.Sensor;
using Toybox.Timer;

class GeocacheFinderView extends WatchUi.View {
	
	var tracker;
	var value;
	
	var mLabel;
	var mLabel2;
	var mPrompt;
	
	var timer;

    function initialize() {
        View.initialize();
        tracker = Application.getApp().tracker;
        mPrompt = Ui.loadResource(Rez.Strings.prompt);
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        mLabel = View.findDrawableById("distance_text");
        mLabel2 = View.findDrawableById("direction");
        timer = new Timer.Timer();
        timer.start(method(:timerCallback), 1000, true);	
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        System.println(tracker.getAngle());
        System.println(tracker.getQuadrant());
        var value = tracker.orientPoint();
		
		System.println("In update: " + value.toString());
        if (value != null) {
        	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        	dc.fillCircle(value[0], value[1], 5);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
	
	function timerCallback() {
		WatchUi.requestUpdate();
	}
}
