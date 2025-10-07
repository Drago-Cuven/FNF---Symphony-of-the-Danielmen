import funkin.backend.scripting.GlobalScript;
import funkin.backend.assets.ModsFolder;
import funkin.backend.utils.NativeAPI.ConsoleColor;
import funkin.backend.system.Logs;

function postUpdate() 
	if (FlxG.keys.justPressed.F6) {
		Logs.trace('Reloading global script(s)...', 1, ConsoleColor.YELLOW);
		try {
			GlobalScript.onModSwitch(ModsFolder.currentModFolder);
			Logs.trace('Successfully reloaded global script(s)!', 1, ConsoleColor.GREEN);
		} catch (e:Dynamic) {
			Logs.trace('Uh Oh! Failed to reload global script(s).', 1, ConsoleColor.RED);
		}
	}