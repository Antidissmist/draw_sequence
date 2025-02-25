# draw_sequence 1.0.1
Manually draw a sequence in GameMaker

![screenshot](https://github.com/user-attachments/assets/e01390da-f612-436e-ac23-c2a36664c06c)



This is a simple script that is used for manually drawing sequences that are made of sprites. You can simply call `draw_sequence(sequence_asset,frame,x,y,xscale,yscale,angle,color,alpha)`, as if it were a sprite itself.

It's mainly for my own use, but it might be useful to you.

My code basically goes through the struct from `sequence_get()`, and caches a list of what sprites to draw and where, so it is quicker to do every frame.


Features:

- draw a whole sequence at once with multiple translated, rotated, and scaled sprites.
- rotate, scale, and color a whole sequence
- image_index keyframes

Missing features:
- not tested with sequence tracks other than sprites.
- parameter tracks for "origin" and some others are not implemented. Only position, rotation, scale, image_index.
- image_speed keyframes are not implemented. 
- there is no interpolation. My code is for using a sequence just like a frame based animation.

Otherwise, it should mimic the built in sequence drawing as close as possible. 


`draw_sequence_edited()`:

You can pass in a struct to change how specific sprites are drawn.
```gml
{
	"sp_player_hat": {
		drawfunc: function(sprite,index,x,y,xscale,yscale,angle,color,alpha),
		(optional) visiblefunc: function() -> bool
	}
}
```
This is useful if for example you want to change the sprite of an item being held, or change the hat on someone's head. 

