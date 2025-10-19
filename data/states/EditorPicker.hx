import funkin.editors.EditorPickerOption;
import funkin.editors.EditorTreeMenu;
import funkin.editors.EditorTreeMenuScreen;
import funkin.backend.MusicBeatState;

var localOptions = [
    {
        name: "Character Select Editor", // Adapted from V-Slice naming conventions.
        id: "charselect",
        state: null,
        onClick: ()->{
            var state = new EditorTreeMenu();
            state.scriptName = "CharSelect/selector/CharSelector";
            FlxG.switchState(state);
        }
    },
    {
        name: "Note Style Editor", 
        id: "noteskin",
        state: null,
        onClick: ()->{
            var state = new EditorTreeMenu();
            state.scriptName = "noteSkinEditor/selector/SkinSelector";
            FlxG.switchState(state);
        }
    }
];

var optionsToAdd = [];

var option;

function create() {
    for (i in localOptions) {
        if (i.onClick != null) {
            options.push({
                name: i.name,
                id: i.id,
                state: null,
                onClick: ()->{
                    selected = true;
                    CoolUtil.playMenuSFX(1);

                    MusicBeatState.skipTransIn = true;
                    MusicBeatState.skipTransOut = true;

                    if (FlxG.sound.music != null)
                        FlxG.sound.music.fadeOut(0.7, 0, function(n) {
                            FlxG.sound.music.stop();
                        });

                    sprites[curSelected].flicker(function() {
                        subCam.fade(0xFF000000, 0.25, false, function() {
                            i.onClick();
                        });
                    });
                }
            });
        } else {
            options.push(i);
        }
    }

    for (i in localOptions)
        optionsToAdd.push(new EditorPickerOption(i.name, i.id, FlxG.height / options.length));
}

function postCreate() {
    for (i in optionsToAdd)
        remove(sprites.pop());
    
    for (option in optionsToAdd) {
        option.y = sprites.length * (FlxG.height / options.length);
        sprites.push(option);
        add(option);
    }
}