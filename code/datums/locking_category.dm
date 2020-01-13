/datum/locking_category
	var/atom/movable/owner
	var/list/atom/movable/locked

	var/name

	var/flags    = 0
	var/x_offset = 0
	var/y_offset = 0
	var/pixel_x_offset = 0
	var/pixel_y_offset = 0
	var/layer_override
	var/rotate_offsets = FALSE

// Modifies the new atom according to our flags.
/datum/locking_category/proc/lock(var/atom/movable/AM)
	if (!AM)
		return

	locked += AM

	if (ismob(AM))
		var/mob/M = AM
		M.update_canmove()

	AM.anchored = TRUE

	if (flags & DENSE_WHEN_LOCKING || AM.lockflags & DENSE_WHEN_LOCKED)
		owner.setDensity(TRUE)

	AM.pixel_x += pixel_x_offset * PIXEL_MULTIPLIER
	AM.pixel_y += pixel_y_offset * PIXEL_MULTIPLIER

	if(layer_override)
		AM.layer = layer_override

	update_lock(AM)
	AM.change_dir(owner.dir, owner)

/datum/locking_category/proc/update_locks()
	for(var/atom/A in locked)
		update_lock(A)

// Updates the position for AM.
/datum/locking_category/proc/update_lock(var/atom/movable/AM)
	var/new_loc = owner.loc

	var/new_x = x_offset
	var/new_y = y_offset

	if (rotate_offsets)
		//The shit below can be done through maths but I've decided to do it a simpler way
		//Basically, imagine a point with coordinates [x_offset; y_offset]
		//And that point is rotated around the point [0;0]
		//Default position is NORTH - 0 degrees
		//EAST means it's rotated 90 degrees clockwise
		//SOUTH means it's rotated 180 degrees, and so on

		switch (owner.dir)
			if (NORTH) //up
				new_x = x_offset
				new_y = y_offset
			if (EAST) // right
				new_x = y_offset
				new_y = -x_offset
			if (SOUTH) //down
				new_x = -x_offset
				new_y = -y_offset
			if (WEST) //left
				new_x = -y_offset
				new_y = x_offset


	if ((new_x || new_y) && isturf(new_loc))
		var/newer_loc = locate(owner.x + new_x, owner.y + new_y, owner.z)
		if (newer_loc) // Edge (no pun intended) case for map borders.
			new_loc = newer_loc

	AM.forceMove(new_loc, 0, 0, owner.glide_size)

// Modifies the atom to undo changes in lock().
/datum/locking_category/proc/unlock(var/atom/movable/AM)
	if (!AM)
		return

	locked -= AM

	AM.anchored = initial(AM.anchored)

	// Okay so now we have to loop through ALL of the owner's locked atoms and their categories to see if the owner still needs to be dense.
	var/found = FALSE
	if (flags & DENSE_WHEN_LOCKING || AM.lockflags & DENSE_WHEN_LOCKED)
		for (var/atom/movable/candidate in owner.locked_atoms)
			if (candidate.lockflags & DENSE_WHEN_LOCKED)
				found = TRUE
				break

			var/datum/locking_category/cat = owner.locked_atoms[candidate]
			if (cat.flags & DENSE_WHEN_LOCKING)
				found = TRUE
				break

	if (!found)
		owner.setDensity(initial(owner.density))

	if (ismob(AM))
		var/mob/M = AM
		M.update_canmove()

	AM.pixel_x -= pixel_x_offset * PIXEL_MULTIPLIER
	AM.pixel_y -= pixel_y_offset * PIXEL_MULTIPLIER

	if(layer_override)
		AM.layer = initial(AM.layer)

/datum/locking_category/New(var/atom/new_owner)
	locked = list()

	owner  = new_owner

	..()

/datum/locking_category/Destroy()
	owner  = null
	locked = null

/datum/locking_category/resetVariables()
	..()
	locked = list()
