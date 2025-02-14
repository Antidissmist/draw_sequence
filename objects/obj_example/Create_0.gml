

hspacing = 300;
vspacing = 200;

seq_asset = seq_example;

lay = layer_create(depth);
layseq = layer_sequence_create(lay,hspacing,vspacing,seq_asset);


frame = 0;



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
};

