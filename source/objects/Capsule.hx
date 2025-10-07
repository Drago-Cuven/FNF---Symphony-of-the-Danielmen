import funkin.backend.MusicBeatGroup;

class Capsule extends MusicBeatGroup {
	public var realScaled:Float = 0.8;

	public var extra = [
		"init" => null
	];
	public var songText:MusicBeatGroup;

	public var self:FunkinSprite;
	public var icon:HealthIcon;

	public var data:Dynamic;

	public var selected:Bool;
	private function set_selected(value:Bool):Bool {
		return selected = value;
	}

	public var bigNumbers:MusicBeatGroup;
	public var smallNumbers:MusicBeatGroup;
	public var weekNumbers:MusicBeatGroup;

	public function new(x:Float, y:Float, chartMeta, capsuleData) {
		super(x, y);
		self = new FunkinSprite(50, 5, Paths.image('menus/freeplay/capsule/capsule/' + capsuleData.assetPath));
		self.animation.addByPrefix('selected', capsuleData.animations.selected.prefix, capsuleData.animations.selected.frameRate);
		self.animation.addByPrefix('unselected', capsuleData.animations.deselected.prefix, capsuleData.animations.deselected.frameRate);
		self.addOffset('unselected', -capsuleData.animations.deselected.offsets[0], -capsuleData.animations.deselected.offsets[1]);
		self.addOffset('selected', -capsuleData.animations.selected.offsets[0], -capsuleData.animations.selected.offsets[1]);
		self.playAnim('unselected', true);
		add(self);

		var bpmText:FlxSprite = new FlxSprite(128, 87, Paths.image('menus/freeplay/capsule/bpmtext'));
		bpmText.setGraphicSize(Std.int(bpmText.width * 0.9));
		bpmText.updateHitbox();
		add(bpmText);

		var difficultyText:FlxSprite = new FlxSprite(420, 87, Paths.image('menus/freeplay/capsule/difficultytext'));
		difficultyText.setGraphicSize(Std.int(difficultyText.width * 0.9));
		add(difficultyText);

		/* var difficultyText:FlxSprite = new FlxSprite(414, 87, Paths.image('menus/freeplay/capsule/difficultytext'));
		difficultyText.setGraphicSize(Std.int(difficultyText.width * 0.9));
		add(difficultyText); */

		/* var weekType:FunkinSprite = new FunkinSprite(291, 87, Paths.image('menus/freeplay/capsule/weektypes'));
		weekType.animation.addByPrefix('WEEK', 'WEEK text instance 1', 24, false);
		weekType.animation.addByPrefix('WEEKEND', 'WEEKEND text instance 1', 24, false);
		weekType.setGraphicSize(Std.int(weekType.width * 0.9));
		add(weekType); */

		var newText:FunkinSprite = new FunkinSprite(454, 9, Paths.image('menus/freeplay/capsule/new'));
		newText.animation.addByPrefix('newAnim', 'NEW notif', 24);
		newText.playAnim('newAnim', true);
		newText.setGraphicSize(Std.int(newText.width * 0.9));
		//add(newText);

		add(bigNumbers = new MusicBeatGroup());
		add(smallNumbers = new MusicBeatGroup());

		// fake rank
		// ranking

		// sparkle

		// song text

		icon = new HealthIcon('freeplay/' + chartMeta.icon);
		icon.setPosition(145, 35);
		icon.scale.set(1, 1);
		icon.updateHitbox();
		icon.scale.set(2, 2);
		icon.origin.x = 100;
		if (icon.curCharacter == "face") {
			icon.visible = false;
		}
		add(icon);

		add(weekNumbers = new MusicBeatGroup());

		// don't know if I want this yet
		weekNumbers.visible = false;

		self.scale.set(0.85, 0.85);
		self.scale.x *= 2;
		self.scale.y *= 0.5;
		self.updateHitbox();
		self.centerOrigin();


		FlxTween.tween(self.scale, { x: 0.85, y: 0.85 }, 0.2, { ease: FlxEase.backOut, startDelay: 0.1, onUpdate: self.updateHitbox });
	}

	public function init(chartMeta):Capsule {
		return this;
	}

	public function initNumbers(big:Array<FunkinSprite>, small:Array<FunkinSprite>, week:Array<FunkinSprite>):Capsule {
		var bigArray:Array<FunkinSprite> = big ?? [];
		var smallArray:Array<FunkinSprite> = small ?? [];
		var weekArray:Array<FunkinSprite> = week ?? [];

		for (number in bigArray)
			bigNumbers.add(number);
		for (number in smallArray)
			smallNumbers.add(number);
		for (number in weekArray)
			weekNumbers.add(number);

		return this;
	}
	public function initSongText(text:MusicBeatGroup):Capsule {
		if (members.contains(songText))
			remove(songText);
		songText = text;
		insert(members.indexOf(icon), text);
		return this;
	}

	public function updateHealth(what:Int) {
		icon.updateHealthIcon(what);
	}
}