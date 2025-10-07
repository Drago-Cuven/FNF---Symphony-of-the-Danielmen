import openfl.display.BlendMode;
import funkin.backend.utils.CoolUtil;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.tweens.FlxTweenType;
import flixel.FlxText;

var capsuleScale:Float = 0.8;
var color:FlxColor = FlxColor.RED;
var bpm = 666;
var diff = 69;
var wew = ["ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"];
var songName = "Random";
var moving = true;
var wid = 291;
var rank:FlxSprite = null;
var blur:FlxSprite = null;
var iconName = "";
var capsuleArray = [];

public var targetPos:FlxPoint = FlxPoint.get();
public var selected = false;
public var icon:FlxSprite = null;

public function createCapsule(x, y, data, isRandom, hasRank = false, rank = "PERFECT") {
    capsuleGroup = new FlxSpriteGroup();
    
    if (!isRandom) {
        bpm = data.bpm;
        songName = data.displayName;
        iconName = data.icon;   
    }
    
    if (!isRandom) {
        bpmText = new FlxSprite(38, 63).loadGraphic(Paths.image("freeplay/freeplayCapsule/bpmtext"));
        bpmText.setGraphicSize(bpmText.width * 0.9);
        bpmText.updateHitbox();
        capsuleGroup.add(bpmText);

        var bpmString = CoolUtil.addZeros(bpm, 3);
        var bpmArray = bpmString.split("");

        for (i in 0...3) {
            bpmNum = new FlxSprite(82 + 12 * i, 63);
            bpmNum.frames = Paths.getSparrowAtlas('freeplay/freeplayCapsule/smallnumbers');
            bpmNum.animation.addByPrefix('num', wew[Std.parseInt(bpmArray[i])], 24, true);
            bpmNum.animation.play('num');
            bpmNum.setGraphicSize(bpmNum.width * 0.9);
            bpmNum.updateHitbox();
            capsuleGroup.add(bpmNum);
        }

        diffText = new FlxSprite(318, 63).loadGraphic(Paths.image("freeplay/freeplayCapsule/difficultytext"));
        diffText.setGraphicSize(diffText.width * 0.9);
        diffText.updateHitbox();
        capsuleGroup.add(diffText);

        var diffString = CoolUtil.addZeros(diff, 2);
        var diffArray = diffString.split("");

        for (i in 0...2) {
            diffNum = new FlxSprite(363 + 29 * i, 8);
            diffNum.frames = Paths.getSparrowAtlas('freeplay/freeplayCapsule/bignumbers');
            diffNum.animation.addByPrefix('num', wew[Std.parseInt(diffArray[i])], 24, true);
            diffNum.animation.play('num');
            diffNum.setGraphicSize(diffNum.width * 0.9);
            diffNum.updateHitbox();
            capsuleGroup.add(diffNum);
        }
    }

    glow = capsuleSpr(-39, -10, "capsule glow");
    glow.blend = BlendMode.ADD;

    blurText = new FlxText(57, 22, 0, songName, 32);
	blurText.font = Paths.font("5by7.ttf");
    blurText.shader = new CustomShader("gaussianBlur");
    blurText.shader._amount = 1;
	capsuleGroup.add(blurText);

    songText = new FlxText(57, 22, 0, songName, 32);
	songText.font = Paths.font("5by7.ttf");

	capsuleGroup.add(songText);
    
    if (!isRandom) {
        icon = new FlxSprite(-40, -15);
        icon.frames = Paths.getSparrowAtlas('freeplay/icons/' + iconName + 'pixel');
        icon.setGraphicSize(icon.width * 2);
        icon.animation.addByPrefix('idle', "idle", 24, true);
        icon.animation.addByPrefix('confirm', "confirm0", 10, false);
        icon.animation.play('idle');
        icon.updateHitbox();
        capsuleGroup.add(icon);
    }

    if (hasRank) {
        wid = 245;
        var rankAsset;
        var blur;
        for (idx => w in [blur, rankAsset]) {
            w[idx] = new FlxSprite(315, 17);
            w[idx].frames = Paths.getSparrowAtlas('freeplay/rankbadges');
            w[idx].setGraphicSize(rank.width * 0.9);
            w[idx].animation.addByPrefix('idle',  rank + " rank0", 24, false);
            w[idx].animation.play('idle');
            w[idx].updateHitbox();
            capsuleGroup.add(w[idx]);
        }
        blur.shader = new CustomShader("gaussianBlur");
        blur.shader._amount = 1;
    }

    // 291
    // 245
    songText.clipRect = blurText.clipRect = new FlxRect(songText.offset.x, 0, wid, songText.height);

    capsuleGroup.setPosition(x, y);
    targetPos.x = x;
    targetPos.y = y;

    add(capsuleGroup);

    updateSelected(selected);
}

function capsuleSpr(x, y, anim) {
    capsule = new FlxSprite(x, y);
    capsule.frames = Paths.getSparrowAtlas('freeplay/capsule');
    capsule.animation.addByPrefix('cap', anim, 24, true);
    capsule.animation.play('cap');
    capsule.scale.set(capsuleScale, capsuleScale);
    capsule.updateHitbox();
    capsuleGroup.add(capsule);
    return capsule;
}

public function updateSelected(select) {
    selected = select;
    if (selected) {
        if (songText.width > wid) {
            FlxTween.tween(songText.offset, {x: songText.width - wid}, 2, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG, startDelay: 0.3, loopDelay: 0.3, onUpdate: () -> {
                songText.clipRect = blurText.clipRect = new FlxRect(songText.offset.x, 0, wid, songText.height);
                songText.offset = blurText.offset;
            }}, 0);
        }
        for (idx => w in [blur, rankAsset]) w[idx].animation.play("idle", true);
    } else {
        FlxTween.cancelTweensOf(songText.offset);
        songText.offset.x = blurText.offset.x = 0;
        songText.clipRect = blurText.clipRect = new FlxRect(songText.offset.x, 0, wid, songText.height);
    }
}


function update(MS) {
    color = FlxColor.fromHSB(0, 1, selected ? 1 : 0.6);
    backing.color = glow.color = blurText.color = color;
    capsuleGroup.x = CoolUtil.fpsLerp(capsuleGroup.x, targetPos.x, 0.4);
    capsuleGroup.y = CoolUtil.fpsLerp(capsuleGroup.y, targetPos.y, 0.3);
}