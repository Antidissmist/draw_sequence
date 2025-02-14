


draw_sequence(seq_asset,frame,hspacing*2,vspacing);

draw_sequence_edited(seq_asset,frame,hspacing*2,vspacing*2.5,,,,,,edit_struct);

var xsc = 1 + 0.3*sin(current_time/300)
var ysc = 1 + 0.3*sin(current_time/400)
var ang = current_time/20;
draw_sequence(seq_asset,frame,hspacing*3,vspacing, xsc,ysc,ang);


draw_text(200,vspacing+100,"regular sequence");
draw_text(200+hspacing,vspacing+100,"draw_sequence");
draw_text(200+hspacing*2,vspacing+100,"draw_sequence\nwith angle & scale");

draw_text(200+hspacing,vspacing*2.5+100,"draw_sequence_edited");


frame += 1/60 * 10;

//loop
if layer_sequence_get_headpos(layseq) >= layer_sequence_get_length(layseq)-1 {
	layer_sequence_play(layseq);
}

