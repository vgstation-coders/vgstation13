/**
 * Atmospherics-related utilities
 */

// For straight pipes
/proc/rotate_pipe_straight(var/newdir)
	switch(newdir)
		if(SOUTH) // 2->1
			return NORTH
		if(WEST) // 8->4
			return EAST
		// New - N3X
		if(NORTHWEST)
			return NORTH
		if(NORTHEAST)
			return EAST
		if(SOUTHWEST)
			return NORTH
		if(SOUTHEAST)
			return EAST
	return newdir
