/*
*	draw_sequence | v1.0.0
*	Github: https://github.com/Antidissmist/draw_sequence
*	Author: Antidissmist
*/



global._sequence_cache = {};

function draw_sequence(_seqid,_frame=undefined,_x=undefined,_y=undefined, _xsc=undefined,_ysc=undefined, _ang=undefined, _col=undefined,_alph=undefined) {	
	_draw_sequence_helper(_seqid,_frame,_x,_y,_xsc,_ysc,_ang,_col,_alph);
}
/*
edit struct example
(for changing how specific sprites behave)
{
	"sp_player_hat": {
		drawfunc: function(sprite,index,x,y,xscale,yscale,angle,color,alpha),
		(optional) visiblefunc: bool function
	}
}
*/
function draw_sequence_edited(_seqid,_frame=undefined,_x=undefined,_y=undefined, _xsc=undefined,_ysc=undefined, _ang=undefined, _col=undefined,_alph=undefined, _edit_struct=undefined) {
	_draw_sequence_helper(_seqid,_frame,_x,_y,_xsc,_ysc,_ang,_col,_alph,_edit_struct);
}

function _draw_sequence_helper(_seqid,_frame=0,_x=0,_y=0, _xsc=1,_ysc=1, _ang=0, _col=c_white,_alph=1, _edit_struct=undefined) {
	
	sequence_cache(_seqid);
	var seq_cache = global._sequence_cache[$ _seqid];
	
	
	//use a matrix if the transforms aren't simple
	var do_matrix = sign(_xsc)!=_xsc || sign(_ysc)!=_ysc || _ang!=0;
	if do_matrix {
		matrix_stack_push(matrix_build(_x,_y,0, 0,0,_ang, _xsc,_ysc, 1));
		matrix_set(matrix_world,matrix_stack_top());
		_x = 0;
		_y = 0;
		_xsc = 1;
		_ysc = 1;
		_ang = 0;
	}
	
	_frame = floor(_frame % seq_cache.frame_count);
	
	var is_edited = is_struct(_edit_struct);
	
	//draw cached sprites for this frame
	var parts = seq_cache.frames[_frame]
	var partlen = array_length(parts);
	var part,part_ang,part_sprite,drawfunc,sprite_key,edits;
	for(var p=0; p<partlen; p++) {
		part = parts[p];
		part_sprite = part.sprite;
		
		
		drawfunc = draw_sprite_ext;
		
		if is_edited {
			sprite_key = part.key;
			if variable_struct_exists(_edit_struct,sprite_key) {
				edits = _edit_struct[$ sprite_key];
				//check visible
				if variable_struct_exists(edits,"visiblefunc") && !edits.visiblefunc() {
					continue;
				}
				drawfunc = edits.drawfunc;
			}
		}
		
		
		part_ang = part.angle;
		
		//flip angle
		if _xsc < 0 {
			part_ang = 360 - part_ang;
		}
		if _ysc < 0 {
			part_ang = 180 - part_ang;
		}
		
		
		drawfunc(
			part_sprite,
			part.index,
			_x + part.x * _xsc,
			_y + part.y * _ysc,
			part.xscale * _xsc,
			part.yscale * _ysc,
			part_ang,
			_col,
			_alph
		);
		
	}
	
	if do_matrix {
		matrix_stack_pop();
		matrix_set(matrix_world,matrix_stack_top());
	}
	
}


function sequence_cache(_seqid) {
	
	var cache = global._sequence_cache;
	
	if !variable_struct_exists(cache,_seqid) {
		
		var struct = sequence_get(_seqid);
		if !is_struct(struct) {
			show_debug_message("draw_sequence unknown sequence!");
			return;
		}
		var frame_count = struct.length;
		
		var seq_cache = {
			frame_count,
			frames: array_create(frame_count,undefined),
		};
		cache[$ _seqid] = seq_cache;
		
		
		//for each sprite track in the sequence
		var tracks = struct.tracks;
		var track_count = array_length(tracks);
		for(var t=0; t<track_count; t++) {
			var track = tracks[t];
			
			//filter to only visible sprite tracks
			if track.type != seqtracktype_graphic continue;
			if !track.enabled || !track.visible continue;
			
			//get sprite
			var sprite = track.keyframes[0].channels[0].spriteIndex;
			if !sprite_exists(sprite) {
				show_debug_message("draw_sequence unknown sprite!");
				continue;
			}
			var sprite_startframe = track.keyframes[0].frame;
			var sprite_frame_length = track.keyframes[0].length;
			var sprite_endframe = min( sprite_startframe + sprite_frame_length, frame_count-1 );
			
			var sprite_speed = sprite_get_speed(sprite);
			
			var transforms = track.tracks; //position, rotation, scale, origin
			var transforms_count = array_length(transforms);
			
			//default transforms
			var sprite_x = 0;
			var sprite_y = 0;
			var sprite_xscale = 1;
			var sprite_yscale = 1;
			var sprite_angle = 0;
			
			//for each frame in the sequence, add a cached part
			for(var frame_index=sprite_startframe; frame_index<=sprite_endframe; frame_index++) {
				
				var frame_str = {
					key: sprite_get_name(sprite),
					sprite,
					index: (frame_index * sprite_speed/60),
					x: sprite_x,
					y: sprite_y,
					xscale: sprite_xscale,
					yscale: sprite_yscale,
					angle: sprite_angle,
				};
				if !is_array(seq_cache.frames[frame_index]) {
					seq_cache.frames[frame_index] = [];
				}
				array_push(seq_cache.frames[frame_index],frame_str);
				
				
				//for each transform (position, rotation, scale, origin)
				//iterate backwards to avoid the duplicate scale track :P
				for(var r=transforms_count-1; r>=0; r--) {
					var transform = transforms[r];
					
					var transform_frames = transform.keyframes;
					var transform_frame_count = array_length(transform_frames);
					
					//find last frame of this transform
					var transform_index = 0;
					for(var tf=0; tf<transform_frame_count; tf++) {
						if transform_frames[tf].frame <= frame_index {
							transform_index = tf;
						}
						else {
							break;
						}
					}
					var transform_frame = transform_frames[transform_index];
					
					//apply transform to this sprite
					switch (transform.name) {
						
						case "position":
							frame_str.x = transform_frame.channels[1].value; //why reversed? idk???
							frame_str.y = transform_frame.channels[0].value;
						break;
						
						case "rotation":
							frame_str.angle = transform_frame.channels[0].value;
						break;
						
						case "scale":
							frame_str.xscale = transform_frame.channels[1].value;
							frame_str.yscale = transform_frame.channels[0].value;
						break;
						
						//"origin"
						
					}
										
				}
				
				
			}		
			
		}
		
	}
	
	
}


///if you really want to
function sequence_cache_all() {
	array_foreach(asset_get_ids(asset_sequence),sequence_cache);
}







