using Toybox.WatchUi;
using Toybox.System;

using Toybox.WatchUi as Ui;

class GeocacheFinderView extends WatchUi.View {
	
	var tracker;
	var value;
	
	var mLabel;
	var mPrompt;
	
    function initialize() {
        View.initialize();
        tracker = Application.getApp().tracker;
        mPrompt = Ui.loadResource(Rez.Strings.prompt);
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        mLabel = View.findDrawableById("distance_text");		
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
        
		value = tracker.getDistance();
		if (value instanceof Lang.String) {
			mLabel.setText(mPrompt);
		} else {
			mLabel.setText(value.format("%.14f"));
		}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
