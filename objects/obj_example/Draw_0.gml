


draw_sequence(seq_asset,frame,hspacing*2,vspacing);

var xsc = 1 + 0.3*sin(current_time/300)
var ysc = 1 + 0.3*sin(current_time/400)
var ang = current_time/20;
draw_sequence(seq_asset,frame,hspacing*3,vspacing, xsc,ysc,ang);



frame += 1/60 * 10;

//loop
if layer_sequence_get_headpos(layseq) >= layer_sequence_get_length(layseq)-1 {
	layer_sequence_play(layseq);
}

