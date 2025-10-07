import Type;

function preStateSwitch():Void {
	if (getStateName() == 'FreeplayState') {
		FlxG.game._requestedState = new MainMenuState();
		FlxG.game._requestedState.curSelected = 1;
		new FlxTimer().start(0.01, ()->{
			FlxG.state.persistentUpdate = false;
			FlxG.state.openSubState(new ModSubState('FreeplaySubState'));
		});
	}
}

function getStateName():Void {
	var split:Array<String> = Type.getClassName(Type.getClass(FlxG.game._requestedState)).split('.');
	return split[split.length - 1];
}

function blendMode(name:String) {
	return [
		"add",
		"alpha",
		"darken",
		"difference",
		"erase",
		"hardlight",
		"invert",
		"layer",
		"lighten",
		"muiltiply",
		"normal",
		"overlay",
		"screen",
		"shader",
		"subtract"
	].indexOf(name.toLowerCase());
}

static var BlendMode = {
	fromString: blendMode,
	ADD: 0,
	ALPHA: 1,
	DARKEN: 2,
	DIFFERENCE: 3,
	ERASE: 4,
	HARDLIGHT: 5,
	INVERT: 6,
	LAYER: 7,
	LIGHTEN: 8,
	MULTIPLY: 9,
	NORMAL: 10,
	OVERLAY: 11,
	SCREEN: 12,
	SHADER: 13,
	SUBTRACT: 14
}