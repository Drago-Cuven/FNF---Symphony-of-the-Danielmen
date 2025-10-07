
function onSelectItem(event) {
    if (event.name == "story mode") {
        event.cancelled = true;
        FlxG.switchState(new ModState("StorySelectState"));
    }
    if (event.name == "freeplay") {
        event.cancelled = true;
        persistentUpdate = false;
        var subState = new ModSubState("FreeplaySubState");
        subState.closeCallback = ()->{
            selectedSomethin = false;
            for (i in menuItems) {
                i.visible = true;
                i.alpha = 1;
            }
        }
        openSubState(subState);
    }
    if (event.name == "gallery") {
        FlxG.switchState(new ModState("GalleryState"));
    }
}