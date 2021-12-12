/turf/var/blocks_light = -1              // Whether or not this turf occludes light based on turf opacity and contents. See check_blocks_light().
/turf/var/lumcount = -1
// Flags the turf to recalc blocks_light next call since opacity has changed.
/turf/set_opacity()
	var/old_opacity = opacity
	. = ..()
	if(opacity != old_opacity)
		blocks_light = -1

/turf/proc/get_lumcount()
	if(lumcount == -1)
		lumcount = 0
		for(var/atom/movable/light/thing in view(src))
			lumcount += max(thing.light_range + 2 - get_dist(thing, src),0)
		lumcount = clamp(lumcount,0,10)
	return lumcount

// Checks if the turf contains an occluding object or is itself an occluding object.
/turf/proc/check_blocks_light()
	if(blocks_light == -1)
		blocks_light = 0
		if(opacity)
			blocks_light = 1
		else
			for(var/atom/movable/AM in contents)
				if(AM.opacity)
					blocks_light = 1
					break
	return blocks_light

// Returns a list of occluding corners based on the angle of the light to the turf
// as well as the available edges of clear space around the turf. Calculated and
// called in light_effect_cast.dm.

// Should theoretically be possible to override this down the track to generate
// directional shadow casting points for non-full-turf objects or structures.

/turf/proc/get_corner_offsets(var/check_angle, var/check_dirs)
	var/list/offsets = list(0,0,0,0)
	if(abs(check_angle) == 180) // Source is west.
		if(check_dirs & NORTH)
			offsets[1] = -1
			offsets[2] =  1
		if(check_dirs & SOUTH)
			offsets[3] = -1
			offsets[4] = -1
	else if(check_angle == 90)  // Source is south.
		if(check_dirs & WEST)
			offsets[1] = -1
			offsets[2] = -1
		if(check_dirs & EAST)
			offsets[3] =  1
			offsets[4] = -1
	else if(check_angle == 0)   // Source is east.
		if(check_dirs & SOUTH)
			offsets[1] =  1
			offsets[2] = -1
		if(check_dirs & NORTH)
			offsets[3] =  1
			offsets[4] =  1
	else if(check_angle == -90) // Source is north.
		if(check_dirs & EAST)
			offsets[1] =  1
			offsets[2] =  1
		if(check_dirs & WEST)
			offsets[3] = -1
			offsets[4] =  1
	else
		switch(check_angle)
			if(-179 to -89)      // Source is northwest.
				if(check_dirs & EAST)
					offsets[1] =   1
					offsets[2] =   1
				if(check_dirs & SOUTH)
					offsets[3] =  -1
					offsets[4] =  -1
			if(-90 to -1)         // Source is northeast.
				if(check_dirs & SOUTH)
					offsets[1] =   1
					offsets[2] =  -1
				if(check_dirs & WEST)
					offsets[3] =  -1
					offsets[4] =   1
			if(0 to 89)          // Source is southeast.
				if(check_dirs & WEST)
					offsets[1] =  -1
					offsets[2] =  -1
				if(check_dirs & NORTH)
					offsets[3] =   1
					offsets[4] =   1
			if(90 to 179)        // Source is southwest.
				if(check_dirs & NORTH)
					offsets[1] =  -1
					offsets[2] =   1
				if(check_dirs & EAST)
					offsets[3] =   1
					offsets[4] =  -1
	return offsets
