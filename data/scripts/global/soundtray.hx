// based on syrup's sound tray script https://discord.com/channels/860561967383445535/1245224473628512326
import funkin.backend.system.Main;
import funkin.backend.utils.CoolUtil;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

var bars:Array<Bitmap> = [];
var graphicScale:Float = 0.60;
var lerpYPos = -115;
var alphaTarget = 0;
var shitTimer:FlxTimer;
var volUp = FlxG.sound.load(Paths.sound('soundtray/Volup'));
var volDown = FlxG.sound.load(Paths.sound('soundtray/Voldown'));
var volMax = FlxG.sound.load(Paths.sound('soundtray/VolMAX'));
for (i in [volUp, volDown, volMax]) i.persist = true; 
var shitTimer = 0;
var bg = null;
var backing = null;

function generateSprites(folder = null) {
    if (folder == null) folder = "";
    for (i in 0...bars.length) bars[i].destroy();
    if (bg != null) bg.destroy();
    if (backing != null) backing.destroy();
    bars = [];

    bg = new Bitmap(BitmapData.fromFile(StringTools.replace(Paths.image('soundtray/' + folder + 'volumebox'), 'assets/', Paths.getAssetsRoot() + '/')));
    bg.scaleX = graphicScale;
    bg.scaleY = graphicScale;
    bg.smoothing = true;
    soundTraySpr.addChild(bg);

    backing = new Bitmap(BitmapData.fromFile(StringTools.replace(Paths.image('soundtray/' + folder + 'bars_10'), 'assets/', Paths.getAssetsRoot() + '/')));
    backing.scaleX = graphicScale;
    backing.scaleY = graphicScale;
    backing.smoothing = true;
    backing.alpha = 0.4;
    soundTraySpr.addChild(backing);

    for (i in 1...11) {
        bar = new Bitmap(BitmapData.fromFile(StringTools.replace(Paths.image('soundtray/' + folder + 'bars_' + i), 'assets/', Paths.getAssetsRoot() + '/')));
        bar.scaleX = graphicScale;
        bar.scaleY = graphicScale;
        bar.smoothing = true;
        soundTraySpr.addChild(bar);
        bars.push(bar);
    }

    for (i in 0...bars.length){
        bars[i].x = backing.x = 17;
        bars[i].y = backing.y = 10;
    }
}

function create() {
    soundTraySpr = new Sprite();
    soundTraySpr.y = -115;
    Main.instance.addChild(soundTraySpr);
    generateSprites();
}

function postUpdate(MS) {
    soundTraySpr.x = (0.5 * (Lib.current.stage.stageWidth - soundTraySpr.width));

    var volDown = FlxG.sound.volumeDownKeys;
	var volUp = FlxG.sound.volumeUpKeys;
	var mutekey = FlxG.sound.muteKeys;

    if (shitTimer > 0) {
        lerpYPos = 10;
        alphaTarget = 1;
    } else {
        lerpYPos = -115;
        alphaTarget = 0;
    }

    if (shitTimer > 0) shitTimer -= MS;

    soundTraySpr.y = CoolUtil.fpsLerp(soundTraySpr.y, lerpYPos, 0.1);
    soundTraySpr.alpha = CoolUtil.fpsLerp(soundTraySpr.alpha, alphaTarget, 0.25);

    var globalVolume:Int = Math.round(FlxG.sound.volume * 10);
	
	if (FlxG.sound.muted)
		globalVolume = 0;

	for (i in 0...bars.length){
		if (i < globalVolume)
			bars[i].visible = true;
		else
			bars[i].visible = false;
	}

    if (FlxG.keys.anyJustReleased(volDown))
		soundTray("down");
	if (FlxG.keys.anyJustReleased(volUp))
		soundTray("up");
	if (FlxG.keys.anyJustReleased(mutekey))
		soundTray("mute");
}

function soundTray(key) {
	switch(key){
		case "down":
			volDown.play(true);
		case "up":
			if (FlxG.sound.volume != 1){
				volUp.play(true);
			}else{
				volMax.play(true);
			}
		case "mute":
			volUp.play(true);
            // yes we do need this check the og
	}
    shitTimer = 1;
}

function preStateSwitch()
	FlxG.sound.soundTrayEnabled = false;

function destroy() {
    FlxG.sound.soundTrayEnabled = true;
    Main.instance.removeChild(soundTraySpr);
}
