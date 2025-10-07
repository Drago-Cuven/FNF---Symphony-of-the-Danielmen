notesCount = -1;
function postUpdate(){
if (notesCount != notesGroup.members.length){
for (i in notesGroup) updateNot(i,noteTypes[i.type-1]);
notesCount = notesGroup.members.length;
}
}
anims = ['purple0','blue0','green0','red0'];
function updateNot(no,type){
texture = '';
if (type == 'Glit') texture = 'game/notes/bull';
if (texture != ''){
no.frames = Paths.getSparrowAtlas(texture);
no.animation.addByPrefix('idle',anims[no.id]);
no.animation.play('idle');
no.angle = 0;
}
}