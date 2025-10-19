import funkin.backend.utils.DiscordUtil;
import flixel.text.FlxTextBorderStyle;
import flixel.addons.display.FlxBackdrop;
import funkin.options.OptionsMenu;
import funkin.backend.scripting.events.menu.MenuChangeEvent;
import funkin.backend.scripting.events.NameEvent;
import funkin.menus.ModSwitchMenu;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.FlxSprite;

final menuOptions:Array<Dynamic> = [
    { n: "story mode", action: "story", x:0, y:0, scaleX:-0.20, scaleY:-0.20, selX:0, selY:15, selScaleX:-0.40, selScaleY:-0.40 },
    { n: "freeplay", action: "freeplay", x:0, y:0, scaleX:-0.20, scaleY:-0.20, selX:0, selY:15, selScaleX:-0.40, selScaleY:-0.40 },
    { n: "options", action: "options", x:0, y:0, scaleX:-0.20, scaleY:-0.20, selX:0, selY:15, selScaleX:-0.40, selScaleY:-0.40 },
    { n: "awards", action: "awards", x:0, y:0, scaleX:-0.20, scaleY:-0.20, selX:0, selY:4, selScaleX:-0.40, selScaleY:-0.40 },
    { n: "gallery", action: "gallery", x:0, y:0, scaleX:-0.20, scaleY:-0.20, selX:0, selY:0, selScaleX:-0.45, selScaleY:-0.45 },
    { n: "credits", action: "credits", x:0, y:0, scaleX:-0.20, scaleY:-0.20, selX:0, selY:12, selScaleX:-0.42, selScaleY:-0.42 },
    { n: "mods", action: "mods", x:0, y:0, scaleX:-0.20, scaleY:-0.20, selX:0, selY:0, selScaleX:-0.50, selScaleY:-0.50 }
];

var campaigns:Array<String> = ["Funkin"];
var selectedCampaign:String = campaigns[FlxG.random.int(0, campaigns.length - 1)];
var curSelected:Int = 0;

var pagesBG:FlxSpriteGroup = new FlxSpriteGroup();
var pagesBars:FlxSpriteGroup = new FlxSpriteGroup();
var pagesOptions:FlxSpriteGroup = new FlxSpriteGroup();
var menuArrows:FlxSpriteGroup = new FlxSpriteGroup();
var arrowColorTimer:Float = 0;
var arrowColors:Array<Int> = [
    0x00FFFF, // cyan
    0x006994, // deep sea blue
    0xFF0000, // bright red
    0x800000, // maroon
    0x00FF00, // bright green
    0x228B22, // forest green
    0x00FFFF  // back to cyan
];

var canMoveOption:Bool = true;
var canSelectOption:Bool = true;

final baseX:Float = 0;
final baseY:Float = 0;

function create() {
		DiscordUtil.changePresence("Symphony of the Daniels: Main Menu", null);
		FlxG.mouse.visible = true;

		var winWidth:Float = FlxG.width;
		var winHeight:Float = FlxG.height;

		for (i in 0...menuOptions.length) {
		var opt = menuOptions[i];

		var bg:FlxSprite;
		var winWidth:Float = FlxG.width;
		var winHeight:Float = FlxG.height;

		// Paths to check in order
		var pathsToCheck:Array<String> = [
			"menus/mainmenu" + selectedCampaign + "/" + opt.n + "-BG",
			"menus/mainmenu/Funkin/" + opt.n + "-BG"
		];

		var found:Bool = false;
		for (path in pathsToCheck) {
			if (Assets.exists(Paths.file("images/" + path + ".xml"))) {
				bg = new FlxSprite();
				bg.frames = Paths.getFrames(path);
				bg.animation.addByPrefix("idle", "anim", 24, true);
				bg.animation.play("idle", true);
				found = true;
				break;
			} else if (Assets.exists(Paths.image(path))) {
				bg = new FlxSprite(0, 0, Paths.image(path));
				found = true;
				break;
			}
		}

		if (!found) {
			bg = new FlxSprite(0, 0, Paths.image("menus/menuBG"));
		}

		bg.antialiasing = true;
		bg.ID = i;
		bg.setGraphicSize(winWidth, winHeight);
		bg.updateHitbox();
		bg.x = i * winWidth;
		pagesBG.add(bg);

        // Bottom bar & line only
        var bottomBar = new FlxSprite().makeSolid(winWidth, 100, 0x80000000);
        bottomBar.y = winHeight - bottomBar.height;

        var line = new FlxSprite();
        line.makeSolid(winWidth, 6, 0x66FFFFFF);
        line.y = bottomBar.y + (bottomBar.height / 2) - (line.height / 2);

        bottomBar.x = line.x = i * winWidth;
        pagesBars.add(bottomBar);
        pagesBars.add(line);

        // Button
        var buttonPngExists:Bool = Assets.exists(Paths.image("menus/mainmenu/" + opt.n));
        var buttonXmlExists:Bool = Assets.exists(Paths.file('images/menus/mainmenu/' + opt.n + '.xml'));
        var button = new FlxSprite();
        button.antialiasing = true;
        button.alpha = 1;
        button.ID = i;

        if (buttonPngExists && buttonXmlExists) {
            button.frames = Paths.getFrames("menus/mainmenu/" + opt.n);
            button.animation.addByPrefix('idle', opt.n + ' basic0', 24, true);
            button.animation.addByPrefix('selected', opt.n + ' white0', 24, true);
            button.animation.play('idle', true);
        } else if (buttonPngExists && !buttonXmlExists) {
            button.loadGraphic(Paths.image("menus/mainmenu/" + opt.n));
        } else trace('Button asset not found for: ' + opt.n);

        var defaultScaleX = 1 + opt.scaleX;
        var defaultScaleY = 1 + opt.scaleY;
        button.scale.set(defaultScaleX, defaultScaleY);
        button.updateHitbox();
        button.x = i * winWidth + (winWidth - button.width) / 2 + opt.x;
        button.y = bottomBar.y + (bottomBar.height / 2) - (button.height / 2) + opt.y;
        pagesOptions.add(button);
    }

    // Add animated arrows on top layer
    if (Assets.exists(Paths.image("menus/arrow")) && Assets.exists(Paths.file("images/menus/arrow.xml"))) {
        var leftArrow = new FlxSprite();
        leftArrow.frames = Paths.getFrames("menus/arrow");
        leftArrow.animation.addByPrefix("loop", "arrow pointer loop", 24, true);
        leftArrow.animation.play("loop", true);
        leftArrow.antialiasing = true;
        leftArrow.x = 25;
        leftArrow.y = winHeight - 100 + 50 - leftArrow.height / 2;
        menuArrows.add(leftArrow);

        var rightArrow = new FlxSprite();
        rightArrow.frames = Paths.getFrames("menus/arrow");
        rightArrow.animation.addByPrefix("loop", "arrow pointer loop", 24, true);
        rightArrow.animation.play("loop", true);
        rightArrow.antialiasing = true;
        rightArrow.scale.set(-1, 1); // flip horizontally
        rightArrow.x = winWidth - 75;
        rightArrow.y = winHeight - 100 + 50 - rightArrow.height / 2;
        menuArrows.add(rightArrow);
    } else trace("Arrow spritesheet or XML missing!");

    add(pagesBG);
    add(pagesBars);
    add(pagesOptions);
    add(menuArrows); // always on top
    CoolUtil.playMusic(Paths.music("freakyMenu"), true, 1);
    updatePageSelection();
}

function update(elapsed:Float) {
    if (!canSelectOption) return;

    if (canMoveOption && controls.LEFT_P) changeOption(-1);
    else if (canMoveOption && controls.RIGHT_P) changeOption(1);

    if (controls.ACCEPT) flashSelection();
    if (controls.BACK) FlxG.switchState(new TitleState());
    if (controls.SWITCHMOD) {
        var subMods = new ModSwitchMenu();
        subMods.closeCallback = () -> {
            pagesOptions.forEach((o) -> { o.visible = true; o.alpha = 1; });
            canMoveOption = true;
            canSelectOption = true;
            CoolUtil.playMusic(Paths.music("freakyMenu"), true, 1);
        };
        openSubState(subMods);
        persistentUpdate = false;
        persistentDraw = true;
    }

    for (i in 0...pagesOptions.members.length) {
        var button = cast(pagesOptions.members[i], FlxSprite);
        var pageIndex = button.ID;
        var opt = menuOptions[pageIndex];
        button.x = pagesOptions.x + pageIndex * FlxG.width + (FlxG.width - button.width) / 2 + opt.x;
    }

    arrowColorTimer += elapsed * 0.5; // speed of color shift

    // Loop through the arrowColors array
    var colorCount:Int = arrowColors.length - 1; // last index for interpolation
    var t:Float = arrowColorTimer % colorCount; // current position in color sequence
    var i:Int = Std.int(t); // current color index
    var lerpT:Float = t - i; // interpolation factor between i and i+1

    var c0:Int = arrowColors[i];
    var c1:Int = arrowColors[i + 1];

    // Interpolate each channel separately
    var r:Int = Std.int(((c0 >> 16) & 0xFF) * (1 - lerpT) + ((c1 >> 16) & 0xFF) * lerpT);
    var g:Int = Std.int(((c0 >> 8) & 0xFF) * (1 - lerpT) + ((c1 >> 8) & 0xFF) * lerpT);
    var b:Int = Std.int((c0 & 0xFF) * (1 - lerpT) + (c1 & 0xFF) * lerpT);

    var finalColor:Int = (r << 16) | (g << 8) | b;

    for (arrowObj in menuArrows.members) {
        var arrow = cast(arrowObj, FlxSprite);
        arrow.color = finalColor;
    }

}

function changeOption(direction:Int):Void {
    if (!canMoveOption) return;

    canMoveOption = false;
    canSelectOption = false;
    curSelected += direction;

    if (curSelected < 0) curSelected = menuOptions.length - 1;
    else if (curSelected >= menuOptions.length) curSelected = 0;

    for (buttonObj in pagesOptions.members) {
        var button = cast(buttonObj, FlxSprite);
        var opt = menuOptions[button.ID];
        button.animation.play('idle', true);
        button.scale.set(1 + opt.scaleX, 1 + opt.scaleY);
        button.updateHitbox();

        var bottomBar = cast(pagesBars.members[button.ID * 2], FlxSprite);
        button.y = bottomBar.y + (bottomBar.height / 2) - (button.height / 2) + opt.y;
    }

    var targetX = -curSelected * FlxG.width;
    for (grp in [pagesBG, pagesBars, pagesOptions]) {
        FlxTween.tween(grp, { x: targetX }, 0.5, {
            ease: FlxEase.quadInOut,
            onComplete: function(_) {
                canMoveOption = true;
                canSelectOption = true;
                updatePageSelection();
            }
        });
    }
}

function updatePageSelection():Void {
    var button = cast(pagesOptions.members[curSelected], FlxSprite);
    var opt = menuOptions[button.ID];
	updateArrowsVisibility();
    button.animation.play('selected', true);
    button.scale.set(1 + opt.selScaleX, 1 + opt.selScaleY);
    button.updateHitbox();
    button.x = pagesOptions.x + button.ID * FlxG.width + (FlxG.width - button.width) / 2 + opt.selX;

    var bottomBar = cast(pagesBars.members[button.ID * 2], FlxSprite);
    button.y = bottomBar.y + (bottomBar.height / 2) - (button.height / 2) + opt.selY;
}

function updateArrowsVisibility():Void {
    if (menuArrows.members.length >= 2) {
        var leftArrow:FlxSprite = cast(menuArrows.members[0], FlxSprite);
        var rightArrow:FlxSprite = cast(menuArrows.members[1], FlxSprite);

        leftArrow.visible = curSelected > 0;
        rightArrow.visible = curSelected < menuOptions.length - 1;
    }
}



function flashSelection():Void {
    var selected = menuOptions[curSelected];
    var button = cast(pagesOptions.members[curSelected], FlxSprite);

    canMoveOption = false;
    canSelectOption = false;
    FlxG.sound.play(Paths.sound('menu/confirm'));

    var flickerTween = FlxTween.tween(button, { alpha: 0 }, 0.1, {
        ease: FlxEase.quadInOut,
        type: FlxTween.PINGPONG,
        loops: 5
    });

    new FlxTimer().start(1, function(_) {
        flickerTween.cancel();
        button.alpha = 1;

        switch (selected.action) {
            case "story":
                FlxG.switchState(new StoryMenuState());

            case "freeplay":
                var freeplaySub = new ModSubState("FreeplaySubState");
                freeplaySub.closeCallback = () -> {
                    pagesOptions.forEach((o) -> { o.visible = true; o.alpha = 1; });
                    canMoveOption = true;
                    canSelectOption = true;
                    persistentUpdate = true;
                    persistentDraw = true;
                    CoolUtil.playMusic(Paths.music("freakyMenu"), true, 1);
                };
                openSubState(freeplaySub);

            case "options":
                FlxG.switchState(new OptionsMenu());

            case "awards":
                FlxG.switchState(new ModState("AwardsState"));

            case "gallery":
                FlxG.switchState(new ModState("GalleryState"));

            case "credits":
                FlxG.switchState(new CreditsMenu());

            case "mods":
                var modsSub = new ModSwitchMenu();
                modsSub.closeCallback = () -> {
                    pagesOptions.forEach((o) -> { o.visible = true; o.alpha = 1; });
                    canMoveOption = true;
                    canSelectOption = true;
                    CoolUtil.playMusic(Paths.music("freakyMenu"), true, 1);
                };
                openSubState(modsSub);
                persistentUpdate = false;
                persistentDraw = true;

            default:
                trace("No action defined for: " + selected.n);
        }
    });
}
