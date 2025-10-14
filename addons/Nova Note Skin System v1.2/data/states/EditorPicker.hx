import funkin.editors.EditorPickerOption;
import funkin.backend.MusicBeatState;

var localOptions = [
    {
        name: "Note Style Editor", // Adapted from V-Slice naming conventions.
        id: "noteskin",
        state: null,
        modState: "noteSkinEditor/selector/SkinSelector"
    }
];

var optionsToAdd = [];

var option;

function create() {
    for (i in localOptions) {
        if (i.modState != null) {
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
                            FlxG.switchState(new ModState(i.modState));
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