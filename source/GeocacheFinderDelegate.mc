using Toybox.WatchUi;

class GeocacheFinderDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new GeocacheFinderMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}