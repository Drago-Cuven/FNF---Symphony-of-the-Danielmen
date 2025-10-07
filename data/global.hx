import funkin.backend.scripting.MultiThreadedScript;
import funkin.backend.scripting.GlobalScript;

function readSubFolder(folder) {
	var globalScripts = Paths.getFolderContent(folder).filter((i:String) -> return StringTools.endsWith(i, '.hx'));
	for (script in globalScripts) {
		var daScript = new MultiThreadedScript(Paths.script(folder + '/' + script));
		daScript.call('create');
		GlobalScript.scripts.add(daScript.script);
		daScript.call('postCreate');
	}
	for (daFolder in Paths.getFolderDirectories(folder+"/", true)) {
		readSubFolder(daFolder);
	}
}

function new() {
	var globalScripts = Paths.getFolderContent('data/scripts/global').filter((i:String) -> return StringTools.endsWith(i, '.hx'));
	for (script in globalScripts) {
		var daScript = new MultiThreadedScript(Paths.script('data/scripts/global/' + script));
		daScript.call('create');
		GlobalScript.scripts.add(daScript.script);
		daScript.call('postCreate');
	}
	for (folder in Paths.getFolderDirectories('data/scripts/global/', true)) {
		readSubFolder(folder);
	}
}
