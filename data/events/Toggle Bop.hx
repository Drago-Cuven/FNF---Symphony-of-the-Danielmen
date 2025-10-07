var bopEnabled = false;
var intensity = 0.1;
var rate = 4;
var offset = 0;

function onEvent(e) {
    var event = e.event;
    switch (event.name) {
        case "Toggle Bop":
            bopEnabled = event.params[0] == "True";
            if (event.params[0] == "True") {
                intensity = event.params[1];
                rate = event.params[2];
                offset = event.params[3];
            }
    }
}

function stepHit() {
    if (bopEnabled) {
        if (curStep % rate == offset) {
            camGame.zoom += intensity/2;
            camHUD.zoom += intensity/4;
            // camHUDZoom += intensity;
            // camGameZoom += intensity;
        }
    }
}