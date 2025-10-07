import funkin.backend.MusicBeatGroup;
import openfl.filters.GlowFilter;
import flixel.math.FlxRect;

class CapsuleText extends MusicBeatGroup {
	public var blurredText:FlxText;
	private var whiteText:FlxText;

	public var text:String;

	public var clipWidth:Int = 255;

	public var tooLong:Bool = false;

	public var glowColor:FlxColor = 0xFF00CCFF;

	// 255, 27 normal
	// 220, 27 favorited

	public function init(songTitle:String, size:Float):CapsuleText {
		blurredText = initText(songTitle, size);
		blurredText.shader = new CustomShader('gaussianBlur');
		blurredText.shader._amount = 1;
		whiteText = initText(songTitle, size);
		text = songTitle;

		blurredText.color = glowColor;
		whiteText.color = FlxColor.WHITE;

		add(blurredText);
		add(whiteText);

		return this;
	}

	private function initText(songTitle:String, size:Float):FlxText {
		var text:FlxText = new FlxText(0, 0, 0, songTitle, Std.int(size));
		text.font = Paths.font('5by7.ttf');
		return text;
	}

	public function applyStyle(color:FlxColor):Void {
		glowColor = color;
		blurredText.color = glowColor;
		whiteText.textField.filters = [new GlowFilter(glowColor, 1, 5, 5, 210, 2)];
	}

	// ???? none
	// 255, 27 normal
	// 220, 27 favorited

	private function set_clipWidth(value:Int):Int {
		// resetText();
		checkClipWidth(value);
		return clipWidth = value;
	}

	private function checkClipWidth(?wid:Int):Void {
		wid ??= clipWidth;

		if (whiteText.width > wid) {
			tooLong = true;
			blurredText.clipRect = new FlxRect(0, 0, wid, blurredText.height);
			whiteText.clipRect = new FlxRect(0, 0, wid, whiteText.height);
		} else {
			tooLong = false;
			blurredText.clipRect = null;
			whiteText.clipRect = null;
		}
	}

	public function set_text(value:String):String {
		if (value == null)
			return text;

		if (blurredText == null || whiteText == null) {
			trace('WARN: Capsule not initialized properly');
			return text = value;
		}

		blurredText.text = value;
		whiteText.text = value;
		checkClipWidth();
		whiteText.textField.filters = [new GlowFilter(glowColor, 1, 5, 5, 210, 2)];

		return text = value;
	}
}