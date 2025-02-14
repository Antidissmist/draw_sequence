# draw_sequence
Manually draw a sequence in GameMaker

![screenshot](https://github.com/user-attachments/assets/e01390da-f612-436e-ac23-c2a36664c06c)



This is a simple script that is used for manually drawing sequences that are made of sprites. You can simply call `draw_sequence(sequence_asset,frame,x,y,xscale,yscale,angle,color,alpha)`, as if it were a sprite itself.

It's mainly for my own use, but it might be useful to you.

My code basically goes through the struct from `sequence_get()`, and caches a list of what sprites to draw and where, so it is quicker to do every frame.


Features:

- draw a whole sequence at once with multiple translated, rotated, and scaled sprites.
- rotate, scale, and color a whole sequence

Missing features:
- not tested with sequence tracks other than sprites.
- parameter tracks for "origin" and others are not implemented. Only position, rotation, scale.
- sprite index, sprite speed not implemented. It will just play the sprite's animation. (for now)
- there is no interpolation. My code is for using a sequence just like a frame based animation.


`draw_sequence_edited()`:

you can pass in a struct to change how specific sprites are drawn.
```gml
{
	"sp_player_hat": {
		drawfunc: function(sprite,index,x,y,xscale,yscale,angle,color,alpha),
		(optional) visiblefunc: function() -> bool
	}
}
```