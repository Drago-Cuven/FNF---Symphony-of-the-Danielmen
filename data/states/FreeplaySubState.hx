import funkin.menus.FreeplaySonglist;
import objects.Capsule;
import objects.CapsuleNumber;
import objects.CapsuleText;
import Reflect;
import sys.FileSystem;

static var currentCharacter:String = "boyfriend";//"boyfriend";
var menuData;

var variations = [
	{
		id: "normal",
		difficulties: ["easy", "normal", "hard"],
		inst: ""
	},
	{
		id: "erect",
		difficulties: ["erect", "nightmare"],
		inst: "-erect"
	}
];

var difficulties:Array = ["easy", "normal", "hard", "erect", "nightmare"];
var curDifficulty:Int = 1;

var backingCard:FunkinSprite;
var backgroundImage:FunkinSprite;

var notch:FunkinSprite;

var menuTitle:FlxText;
var ostTitle:FlxText;

// important
var curSelected:Int = 0;

// camera shit
var bgCamera:FlxCamera;
var fgCamera:FlxCamera;

// objects
var songs:FlxGroup;
var diffGroup:FlxSpriteGroup;
var diffMap:Map<String, FlxSprite> = [];

var leftArrow:FunkinSprite;
var rightArrow:FunkinSprite;

var disableInput:Bool = false;

var dj:FunkinSprite;

var songMetasOG = FreeplaySonglist.get().songs;
var songMetas = FreeplaySonglist.get().songs;
trace(songMetas);

var ogList;

var songTimerDuration = 50;
var songTimer = -1;

var albumArt;

static var yoSelected = 0;
static var yoDifficulty = 0;

function create():Void {
	//CoolUtil.playMenuSong();

	curSelected = yoSelected;
	curDifficulty = yoDifficulty;

	menuData = CoolUtil.parseJson("data/config/freeplayCharacters/" + currentCharacter + ".json");
	var finalList = [];
	for (i in songMetas) {
		for (song in menuData.songList) {
			if (i.name == song) {
				finalList.push(i);
			}
		}
	}

	    var randomSongMeta = {
        opponentModeAllowed: true,
        icon: "face",
        difficulties: ["easy", "normal", "hard", "erect", "nightmare"],
        color: "#FFFFFF",
        name: "random",
        coopAllowed: true,
        stepsPerBeat: 4,
        displayName: "Random",
        beatsPerMeasure: 4,
        bpm: 145,
        customValues: {
            album: "none"
        }
    };

    // Add Random to the TOP of the list
    finalList.insert(0, randomSongMeta);

	songMetas = finalList;
	songMetasOG = finalList;

	backgroundImage = new FunkinSprite(0, 0, Paths.image("menus/freeplay/background/" + menuData.bgSprite));
	backgroundImage.antialiasing = true;
	backgroundImage.x = -backgroundImage.width;
	backgroundImage.setGraphicSize(FlxG.width, FlxG.height);
	backgroundImage.scale.x = backgroundImage.scale.y;
	backgroundImage.updateHitbox();
	add(backgroundImage);
	FlxTween.tween(backgroundImage, { x: FlxG.width - backgroundImage.width }, 0.2, { ease: FlxEase.sineOut, startDelay: 0.1 });

	backingCard = new FunkinSprite(0, 0, Paths.image("menus/freeplay/background/pinkBack"));
	backingCard.color = FlxColor.fromString(menuData.bgCardColor);
	backingCard.antialiasing = true;
	backingCard.x = -backingCard.width;
	add(backingCard);
	FlxTween.tween(backingCard, { x: 0 }, 0.2, { ease: FlxEase.sineOut });
	
	dj = new FunkinSprite(menuData.dj.position[0], menuData.dj.position[1]);
	dj.loadSprite(Paths.image("menus/freeplay/djs/" + menuData.dj.assetPath));
	dj.animation.addByPrefix('intro', menuData.dj.animations.intro.prefix, menuData.dj.animations.intro.frameRate ?? 24, menuData.dj.animations.intro.looping ?? false);
	dj.animation.addByPrefix('idle', menuData.dj.animations.idle.prefix, menuData.dj.animations.idle.frameRate ?? 24, menuData.dj.animations.idle.looping ?? falsee);
	dj.animation.addByPrefix('exit', menuData.dj.animations.exit.prefix, menuData.dj.animations.exit.frameRate ?? 24, menuData.dj.animations.exit.looping ?? false);
	dj.animation.addByPrefix('confirm', menuData.dj.animations.confirm.prefix, menuData.dj.animations.confirm.frameRate ?? 24, menuData.dj.animations.confirm.looping ?? false);
	dj.addOffset('idle', -menuData.dj.animations.idle.offsets[0], -menuData.dj.animations.idle.offsets[1]);
	dj.addOffset('exit', -menuData.dj.animations.exit.offsets[0], -menuData.dj.animations.exit.offsets[1]);
	dj.addOffset('intro', -menuData.dj.animations.intro.offsets[0], -menuData.dj.animations.intro.offsets[1]);
	dj.addOffset('confirm', -menuData.dj.animations.confirm.offsets[0], -menuData.dj.animations.confirm.offsets[1]);
	dj.antialiasing = true;
	dj.updateHitbox();
	add(dj);

	camera = bgCamera = new FlxCamera();
	bgCamera.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(bgCamera, false);

	fgCamera = new FlxCamera();
	fgCamera.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(fgCamera, false);

	songs = new FlxGroup();
	for (i=>chartMeta in songMetas) {
		trace(chartMeta);
		var capsule:Capsule = new Capsule(0, 120 * i, chartMeta, menuData.capsule);
		capsule.extra.set("defaultLabel", i.name);

		var bpmArr = [];
		for (i in (chartMeta.bpm + "").split("")) {
			bpmArr.push(Std.parseInt(i));
		}
		if (bpmArr.length-1 != 2) {
			bpmArr.insert(0, 0);
		}

		var capsuleNumbers = [];
		var offset = 0;
		for (i in 0...3) {
			var number = new CapsuleNumber(175 + offset, 87.5).init(false, bpmArr[i]);
			number.updateHitbox();
			offset += 11;
			if (bpmArr[i] == 1)
				offset -= 4;
			capsuleNumbers.push(number);
		}

		capsule.initNumbers(
			[
				for (i in 0...2)
					new CapsuleNumber(474 + (i * 30), 27).init(true)
			],
			capsuleNumbers,
			[
				new CapsuleNumber(355, 88.5).init()
			]
		);
		var capsuleText = new CapsuleText(150, 42);
		capsuleText.glowColor = FlxColor.fromString(menuData.glowColor);
		capsuleText.init(chartMeta.displayName ?? "Unknown", Std.int(40 * capsule.realScaled));
		capsule.initSongText(capsuleText);
		
		songs.add(capsule);
	}
	add(songs);

	diffGroup = new FlxSpriteGroup(200, 80);
	for (i=>diff in difficulties) {
		if (diffMap.exists(diff)) continue;

		var sprite:FlxSprite = new FlxSprite();
		sprite.antialiasing = true;
		sprite.alpha = 0;

		var pngExists:Bool = Assets.exists(Paths.image('menus/freeplay/diffs/' + diff));
		var xmlExists:Bool = Assets.exists(Paths.file('images/menus/freeplay/diffs/' + diff + '.xml'));

		if (pngExists && xmlExists) {
			sprite.frames = Paths.getFrames('menus/freeplay/diffs/' + diff);
			sprite.animation.addByPrefix('idle', 'idle0', 24, true);
			sprite.animation.play('idle', true);
			trace('Difficulty "' + diff + '" has an animated sprite.');
		} else if (pngExists && !xmlExists) {
			sprite.loadGraphic(Paths.image('menus/freeplay/diffs/' + diff));
			trace('Difficulty "' + diff + '" is a static sprite.');
		} else {
			trace('Difficulty "' + diff + '" doesn\'t exist!');
		}

		sprite.ID = i;
		sprite.updateHitbox();
		sprite.x -= sprite.width/2;
		
		diffGroup.add(sprite);
		diffMap.set(diff, sprite);
	}
	diffGroup.cameras = [bgCamera];
	add(diffGroup);

	
	notch = new FunkinSprite().makeGraphic(FlxG.width, 48+16, FlxColor.BLACK);
	notch.y = -70;
	add(notch);
	FlxTween.tween(notch, { y: 0 }, 0.2, { ease: FlxEase.sineOut, startDelay: 0.3 });
	
	menuTitle = new FlxText(8, 8, 0, 'FREEPLAY', 48);
    menuTitle.font = 'VCR OSD Mono';
	add(menuTitle);

	ostTitle = new FlxText(8, 8, 0, 'OFFICIAL OST', 48);
    ostTitle.font = 'VCR OSD Mono';
	add(ostTitle);

	leftArrow = new FunkinSprite(20, 70, Paths.image("menus/freeplay/ui/" + menuData.arrowSprite));
	leftArrow.animation.addByPrefix('idle', 'arrow pointer loop', 24, true);
	leftArrow.playAnim('idle');
	leftArrow.antialiasing = true;
	leftArrow.y = -leftArrow.height;
	add(leftArrow);

	rightArrow = new FunkinSprite(330, 70, Paths.image("menus/freeplay/ui/" + menuData.arrowSprite));
	rightArrow.animation.addByPrefix('idle', 'arrow pointer loop', 24, true);
	rightArrow.playAnim('idle');
	rightArrow.antialiasing = true;
	rightArrow.flipX = true;
	rightArrow.y = -rightArrow.height;
	add(rightArrow);

	diffGroup.y = -100;

	FlxTween.tween(rightArrow, { y: 70 }, 0.3, { ease: FlxEase.backOut, startDelay: 0.3 });
	FlxTween.tween(leftArrow, { y: 70 }, 0.3, { ease: FlxEase.backOut, startDelay: 0.3 });
	FlxTween.tween(diffGroup, { y: 80 }, 0.3, { ease: FlxEase.backOut, startDelay: 0.2 });

	ogList = Reflect.copy(songs);
	

	dj.playAnim('intro', true);

	playSelectedSong();
	
	albumArt = new FunkinSprite(990, 280);
	albumText = new FunkinSprite(990, 500);
	albumArt.antialiasing = true;
	albumText.antialiasing = true;
	albumArt.updateHitbox();
	albumText.updateHitbox();
	albumArt.x += 400;
	albumText.x += 380;
	albumArt.angle = 40;
	albumText.angle = 40;
	FlxTween.tween(albumArt, { x: albumArt.x - 435, angle: 10 }, 0.4, { ease: FlxEase.backOut, startDelay: 0.2 });
	FlxTween.tween(albumText, { x: albumText.x - 435, angle: 0 }, 0.4, { ease: FlxEase.backOut, startDelay: 0.2 });
	//loadAlbum("volume1");
	add(albumArt);
	add(albumText);

	curDifficulty--;
	changeDifficulty(1);
	/* curDifficulty = 0;
	changeDifficulty(1); */
}

var previousDiff = 0;

function update() {
	//dj.playAnim("dj dj intro", true, false, 0);
	if (!disableInput) {
		changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0));
		changeDifficulty((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
		selectSong(FlxG.keys.justPressed.ENTER);
	}

	var capsuleX = 335;
	for (i=>song in songs.members) {
		song.y = lerp(song.y, (FlxG.height/2)+(120 * (i-curSelected))-100, 0.3);
        if (i > curSelected) {
            song.x = lerp(song.x, capsuleX - ((i-curSelected)*30) + 30, 0.3);
        } else if (i == curSelected) {
            song.x = lerp(song.x, capsuleX, 0.3);
		} else {
            song.x = lerp(song.x, capsuleX + ((i-curSelected)*30), 0.3);
        }
		for (text in song.songText) {
			text.alpha = i == curSelected ? 1 : 0.5;
		}
		if (song.self.animation.curAnim.name != (i == curSelected ? "selected" : "unselected")) {
			song.self.playAnim(i == curSelected ? "selected" : "unselected", true);
		}
	}

	if (controls.BACK && !disableInput) {
		disableInput = true;
        FlxG.sound.play(Paths.sound('menu/cancel'));
		for (i=>song in songs.members) {
			FlxTween.tween(song.self.scale, { x: 0.85 * 2, y: 0.85 * 0.5 }, 0.2, { ease: FlxEase.backIn, startDelay: 0.1, onUpdate: song.self.updateHitbox, onComplete: ()->{song.visible = false;} });
		}
		FlxTween.tween(backingCard, { x: -backingCard.width }, 0.2, { ease: FlxEase.quadIn, startDelay: 0.1 });
		FlxTween.tween(backgroundImage, { x: -backgroundImage.width }, 0.2, { ease: FlxEase.quadIn });
		FlxTween.tween(notch, { y: -70 }, 0.2, { ease: FlxEase.sineOut });
		FlxTween.tween(rightArrow, { y: -rightArrow.height }, 0.3, { ease: FlxEase.backIn, startDelay: 0.1 });
		FlxTween.tween(leftArrow, { y: -leftArrow.height }, 0.3, { ease: FlxEase.backIn, startDelay: 0.1 });
		FlxTween.tween(diffGroup, { y: -diffGroup.members[0].height }, 0.3, { ease: FlxEase.backIn, startDelay: 0.2 });
		FlxTween.tween(dj, { y: 600 }, 0.5, { ease: FlxEase.backIn, onComplete: close, startDelay: currentCharacter == "pico" ? 1 : 0.5 });
		FlxTween.tween(albumArt, { x: albumArt.x + 435, angle: 40 }, 0.4, { ease: FlxEase.backIn });
		FlxTween.tween(albumText, { x: albumText.x + 380, angle: 0 }, 0.4, { ease: FlxEase.backIn });

		dj.playAnim("exit", true);
		//dj.playAnim("dj freeplay", true, 'none', false, 708);
	}

	menuTitle.y = notch.y + 8;
	ostTitle.updateHitbox();
	ostTitle.x = FlxG.width - ostTitle.width - 8;
	ostTitle.y = notch.y + 8;

	for (i in diffGroup) {
		i.alpha = i.ID == curDifficulty ? 1 : 0;
	}

	if (dj.animation.name == "intro" && dj.animation.curAnim.curFrame == 16) {
		dj.playAnim('idle', true);
	}

	if (songTimer > -1) {
		songTimer--;
	}
	if (songTimer == 0) {
		playSelectedSong();
	}

	for (i=>song in songs.members) {
		if (songTimer != -1) {
			song.alpha = 1;
		} else {
			song.alpha = i == curSelected ? 1 : 0.9;
		}
	}

	if (FlxG.keys.justPressed.TAB && !disableInput) {
		FlxG.sound.play(Paths.sound('menu/confirm'));
		dj.playAnim("exit", true);
			
		new FlxTimer().start(1, ()->{
			fgCamera.fade(FlxColor.BLACK, 0.25, false, ()->{
				currentCharacter = currentCharacter == "boyfriend" ? "pico" : "boyfriend";
				FlxG.switchState(new FreeplayState());
			});
		});
		
	}

	yoSelected = curSelected;
	yoDifficulty = curDifficulty;

	albumArt.y = lerp(albumArt.y, 280, 0.1);
	albumText.y = lerp(albumText.y, 508, 0.1);
}

var playingSong = "";

function playSelectedSong(?index, ?diff, ?vol) {
	index ??= curSelected;
	diff ??= curDifficulty;
	vol ??= 1;
	var variationToPlay = "";
	if (curSelected != 0) {
		for (i in variations) {
			if (i.difficulties.contains(difficulties[diff])) {
				variationToPlay = i.inst;
			}
		}
	}

	var aliases = [
		"easy" => [
			"VoicesInst (Normal)",
			"Inst"
		],
		"normal" => [
			"VoicesInst (Normal)",
			"Inst"
		],
		"hard" => [
			"VoicesInst (Normal)",
			"Inst"
		],
		"erect" => [
			"VoicesInst (Erect)",
			"Inst-erect"
		],
		"nightmare" => [
			"VoicesInst (Erect)",
			"Inst-nightmare"
		]
	];
	trace(curSelected);
if (curSelected == 0 && playingSong != "freeplayRandom") {
	CoolUtil.playMusic(Paths.music("freeplayRandom"), false, vol);
	playingSong = "freeplayRandom";
    Conductor.changeBPM(145, [4, 4], 4);
    bop();
} else {
    for (i in aliases.get(difficulties[curDifficulty])) {
        var songPath = StringTools.replace(Paths.inst(songMetas[index].name, "normal", ""), "Inst", i);
        trace(songPath);
        
        if (playingSong != songPath) {
            if (Assets.exists(songPath)) {
                CoolUtil.playMusic(songPath, false, vol);
                playingSong = songPath;
                Conductor.changeBPM(songMetas[index].bpm, [4, 4], songMetas[index].stepsPerBeat);
                bop();
                break;
            }
        } else {
            break;
        }
    }
}
}

function changeSelection(?amount:Int, ?skip:Bool):Void {
	amount ??= 0;
	skip ??= true;
	if (curSelected + amount == -1 && !skip) {
		amount = 0;
		curSelected = 0;
	}
	curSelected = FlxMath.wrap(curSelected + amount, 0, songs.length - 1);
    if (amount != 0) {
		//playSelectedSong();
		songTimer = songTimerDuration;
        FlxG.sound.play(Paths.sound('menu/scroll'));
    }

	reloadAlbum();
}

function checkSongHasDifficulty(songMeta, difficulty:String) {
	difficulty = difficulty.toLowerCase();
	var has = false;
	for (i in songMeta.difficulties) {
		if (i.toLowerCase() == difficulty) {
			has = true;
		}
	}
	return has;
}

function changeDifficulty(?amount:Int) {
	amount ??= 0;
	previousDiff = curDifficulty;
	curDifficulty = FlxMath.wrap(curDifficulty + amount, 0, difficulties.length - 1);
	if (amount == 0) return;
	remove(songs);
	for (i=>song in ogList.members) {
		if (!songs.members.contains(song)) {
			curSelected++;
		}
	}
	songs = new FlxGroup();
	songMetas = [];
	for (i=>song in ogList.members) {
		if (checkSongHasDifficulty(songMetasOG[i], difficulties[curDifficulty])) {
			songMetas.push(songMetasOG[i]);
			songs.add(song, true);
		} else {
			curSelected--;
		}
	}
	add(songs);
	changeSelection(0, false);
	songTimer = songTimerDuration;

	for (i in 0...songs.length) {
		var capsuleText = songs.members[i].songText;
		if (curSelected != 0) {
			capsuleText.text = songMetas[i].displayName + (difficulties[curDifficulty] == "erect" || difficulties[curDifficulty] == "nightmare" ? " Erect" : "");
		}
		songs.members[i].initSongText(capsuleText);
	}

	reloadAlbum();
	//playSelectedSong();
}

function selectSong(pressedEnter:Bool) {
	if (!pressedEnter) return;
	songTimer = 10000;
	if (curSelected == 0) {
		changeSelection(FlxG.random.int(1, songMetas.length-1));
		selectSong(true);
		return;
	}
	if (!checkSongHasDifficulty(songMetas[curSelected], difficulties[curDifficulty])) {
		bgCamera.shake(0.002, 0.2);
		FlxG.sound.play(Paths.sound('menu/cancel'));
		return;
	}
	disableInput = true;
	for (i=>capsule in songs.members) {
		if (i == curSelected) {
			capsule.icon.playAnim("select", true, 'none', false, 2);
        	FlxG.sound.play(Paths.sound('menu/confirm'));
				
			dj.playAnim("confirm", true);
			//dj.playAnim("dj freeplay", true, 'none', true, 56);
			new FlxTimer().start(1, ()->{
				PlayState.loadSong(songMetas[curSelected].name, difficulties[curDifficulty], false, false);
				FlxG.switchState(new PlayState());
			});
		}
	}
}

function bop() {
	//dj.playAnim("dj freeplay", true, 'none', false, 17); // bop anim
	if (dj.animation.name == "idle") {
		dj.playAnim("idle", true);
	}
}

function beatHit() {
	if (curBeat % 2 == 0) {
		if (!disableInput) {
			bop();
		}
	}
}

var previousAlbum = "";
function loadAlbum(id:String) {
	albumArt.alpha = curSelected != 0 && id != "none" ? 1 : 0;
	if (previousAlbum == id) return;
	previousAlbum = id;
	albumArt.loadGraphic(Paths.image("menus/freeplay/album/" + id));
	albumArt.y += 10;
	albumText.y += 10;
	var pngExists:Bool = Assets.exists(Paths.image("menus/freeplay/album/" + id + "-text"));
	var xmlExists:Bool = Assets.exists(Paths.file("images/menus/freeplay/album/" + id + "-text.xml"));
	trace(Paths.image("menus/freeplay/album/" + id + "-text"));
	trace(pngExists);
	trace(Paths.file("menus/freeplay/album/" + id + "-text.xml"));
	trace(xmlExists);
	albumText.visible = true;
	if (pngExists && xmlExists) {
		albumText.frames = Paths.getFrames("menus/freeplay/album/" + id + "-text");
		albumText.animation.addByPrefix('idle', 'idle0', 24, true);
		albumText.animation.play('idle', true);
		trace('Text of "' + id + '" has an animated sprite.');
	} else if (pngExists && !xmlExists) {
		albumText.loadGraphic(Paths.image("menus/freeplay/album/" + id + "-text"));
		trace('Text of "' + id + '" is static.');
	} else {
		albumText.visible = false;
	}


}


function reloadAlbum() {
	loadAlbum(songMetas[curSelected]?.customValues?.album ?? "placeholder");
}