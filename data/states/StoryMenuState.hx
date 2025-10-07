var erectSprite;

function create() {
    for (i=>week in weeks) {
        week.difficulties = [ "easy", "normal", "hard", "erect", "nightmare" ];
    }
    erectSprite = new FunkinSprite(0, 0, Paths.image("menus/storymenu/difficulties/erect"));
    difficultySprites.set("erect", erectSprite);
}

function update() {
    for (i=>week in weeks) {
        week.difficulties = [ "easy", "normal", "hard", "erect", "nightmare" ];
    }
}