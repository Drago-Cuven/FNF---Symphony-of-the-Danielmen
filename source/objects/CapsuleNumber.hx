class CapsuleNumber extends FunkinSprite {
	public var digit:Int = 0;
	private function set_digit(value:Int):Int {
		playAnim(numToString[value], true);
		centerOffsets();

		switch (value) {
			case 1: offset.x -= 4;
			case 3: offset.x -= 1;
			default: centerOffsets();
		}

		return digit = value;
	}

	public var baseY:Float = 0;
	public var baseX:Float = 0;
	private var numToString:Array<String> = ['ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE'];

	public function init(?big:Bool, ?initDigit:Int):CapsuleNumber {
		super(0, 0);
		big ??= false;
		initDigit ??= 0;

		frames = Paths.getFrames('menus/freeplay/capsule/' + (big ? 'bignumbers' : 'smallnumbers'));

		for (num in numToString)
			animation.addByPrefix(num, num, 24, false);

		set_digit(initDigit);

		setGraphicSize(Std.int(width * 0.9));
		updateHitbox();

		return this;
	}
}