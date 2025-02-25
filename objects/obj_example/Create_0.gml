

hspacing = 300;
vspacing = 200;

seq_asset = seq_example;

lay = layer_create(depth);
layseq = layer_sequence_create(lay,hspacing,vspacing,seq_asset);


frame = 0;
var struct = sequence_get(seq_asset);
sequence_speed = struct.playbackSpeed;


edit_struct = {
	"sp_smiley": {
		drawfunc: function(spr,ind,xx,yy,xsc,ysc,ang,col,alph) {
			draw_sprite_ext(sp_smiley_2,ind,xx,yy,xsc,ysc,ang,col,alph);
			draw_text(xx,yy-40,"hello");
		}
	},
	"sp_box": {
		drawfunc: function(spr,ind,xx,yy,xsc,ysc,ang,col,alph) {
			draw_sprite_ext(sp_smiley,ind,xx,yy,xsc,ysc,ang,col,0.5 + sin(current_time/50)/2);
		}
	},
	//different behavior for instances of the same sprite
	"sp_animated": {
		drawfunc: function(spr,ind,xx,yy,xsc,ysc,ang,col,alph, trackname) {
			if trackname == "test 1" {
				col = c_blue;
			}
			else if trackname == "thing 2" {
				col = c_lime;
			}
			draw_sprite_ext(spr,ind,xx,yy,xsc,ysc,ang,col,alph);
		}
	},
};

