/*
*	draw_sequence | v1.0.1
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
(the trackname argument is to differentiate multiple tracks of the same sprite)
{
	"sp_player_hat": {
		drawfunc: function(sprite,index,x,y,xscale,yscale,angle,color,alpha, trackname),
		(optional) visiblefunc: function(trackname) -> bool
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
	
	if _frame == -1 {
		//default speed
		_frame = current_time/1000 * seq_cache.playback_speed;
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
		
		drawfunc = undefined;
		
		if is_edited {
			sprite_key = part.key;
			if variable_struct_exists(_edit_struct,sprite_key) {
				edits = _edit_struct[$ sprite_key];
				//check visible
				if variable_struct_exists(edits,"visiblefunc") && !edits.visiblefunc(part.trackname) {
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
		
		
		if drawfunc != undefined {
			drawfunc(
				part_sprite,
				part.index,
				_x + part.x * _xsc,
				_y + part.y * _ysc,
				part.xscale * _xsc,
				part.yscale * _ysc,
				part_ang,
				_col,
				_alph,
				part.trackname
			);
		}
		else {
			draw_sprite_ext(
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
		
		var _fps = 60; //of the game
		var frame_count = struct.length;
		var playback_speed = struct.playbackSpeed;
		if struct.playbackSpeedType==spritespeed_framespergameframe {
			playback_speed *= _fps;
		}
		
		var seq_cache = {
			frame_count,
			playback_speed,
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
			
			var trackname = track.name; //by default the sprite name
			
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
			if sprite_get_speed_type(sprite)==spritespeed_framespergameframe {
				sprite_speed *= _fps; //speed will match that in the editor, but it seems that the actual in-room sequence speed is incorrect :P
			}
			
			var transforms = track.tracks; //position, rotation, scale, origin, image_index
			var transforms_count = array_length(transforms);
			
			//image speed is disabled when there exists an image_index track
			var has_index_track = array_any(transforms,function(elem,ind){
				return elem.name=="image_index";
			});
			
			//default properties
			var sprite_x = 0;
			var sprite_y = 0;
			var sprite_xscale = 1;
			var sprite_yscale = 1;
			var sprite_angle = 0;
			
			//for each frame in the sequence, add a cached part
			for(var frame_index=sprite_startframe; frame_index<=sprite_endframe; frame_index++) {
				
				var frame_str = {
					key: sprite_get_name(sprite),
					trackname,
					sprite,
					index: has_index_track ? 0 : (frame_index * sprite_speed/playback_speed),
					x: sprite_x,
					y: sprite_y,
					xscale: sprite_xscale,
					yscale: sprite_yscale,
					angle: sprite_angle,
				};
				var sprite_frame_count = sprite_get_number(sprite);
				if !is_array(seq_cache.frames[frame_index]) {
					seq_cache.frames[frame_index] = [];
				}
				array_push(seq_cache.frames[frame_index],frame_str);
				
				
				//for each transform (position, rotation, scale, origin, image_index)
				//iterate backwards to avoid the duplicate scale track :P
				for(var r=transforms_count-1; r>=0; r--) {
					var transform = transforms[r];
					
					var transform_frames = transform.keyframes;
					var transform_frame_count = array_length(transform_frames);
					if transform_frame_count==0 continue; //no keyframes, skip
					
					//find last frame of this transform
					var transform_index = 0;
					var last_frame = 0;
					for(var tf=0; tf<transform_frame_count; tf++) {
						last_frame = transform_frames[tf].frame;
						if last_frame <= frame_index {
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
						
						case "image_index":
							var last_ind = transform_frame.channels[0].value;
							frame_str.index = clamp(last_ind,0,sprite_frame_count-1); //sequences clamp the frame
						break;
						
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







