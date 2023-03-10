var/global/list/visible_spaces = list(/turf/simulated/open, /turf/simulated/floor/glass)

#define isvisiblespace(A) is_type_in_list(A, visible_spaces)
#define OPENSPACE_PLANE_START -23
#define OPENSPACE_PLANE_END -8
#define OPENSPACE_PLANE -25
#define OVER_OPENSPACE_PLANE -7

/turf/proc/is_space()
	return 0

/turf/space/is_space()
	return 1

// Called after turf replaces old one
/turf/proc/post_change()
	levelupdate()
	var/turf/simulated/open/T = GetAbove(src)
	if(istype(T))
		T.update_icon()


/proc/is_on_same_plane_or_station(var/z1, var/z2)
	if(z1 == z2)
		return 1
	if((z1 in map.zLevels) && (z2 in map.zLevels))
		return 1
	return 0

// BEGIN /VG/ CODE

// Helper for the below
/proc/get_zs_away(atom/Loc1,atom/Loc2)
	if(Loc1.z == Loc2.z)
		return 0 // Nip this in the bud to save performance maybe
	if(!(HasAbove(Loc1.z) && HasBelow(Loc1.z)) || !(HasAbove(Loc2.z) && HasBelow(Loc2.z)) || !AreConnectedZLevels(Loc1.z, Loc2.z))
		return INFINITY // Redundant to below but sanity checking and performance

	var/dist_above = 0
	var/dist_below = 0
	var/above_found = FALSE // Using booleans to see how we handle this later, don't want us hitting the ceiling and pulling a short distance when it wasn't found
	var/below_found = FALSE

	for(var/level = Loc1.z, HasBelow(level), level = map.zLevels[level].z_below)
		if(level == Loc2.z)
			below_found = TRUE
			break
		dist_below++
		if(map.zLevels[level].z_below == Loc1.z) // If we end up where we started, get out of the infinite loop (called after value is upped)
			break

	for(var/level = Loc1.z, HasAbove(level), level = map.zLevels[level].z_above)
		if(level == Loc2.z)
			above_found = TRUE
			break
		dist_above++
		if(map.zLevels[level].z_above == Loc1.z)
			break

	if(above_found && below_found)
		return min(dist_above,dist_below) // Get minimum of each if found above AND below
	else if(above_found)
		return dist_above // Otherwise as normal
	else if(below_found)
		return dist_below
	return INFINITY // Yeah, redundant

/**
 * Z-Distance functions
 *
 * Because vanilla get_dist() only gets the max value of either x or y and not z for some reason, thanks BYOND!
 *
 * Euclidean follows suit for the proper formula
 */
/proc/get_z_dist(atom/Loc1, atom/Loc2)
	var/dx = abs(Loc1.x - Loc2.x)
	var/dy = abs(Loc1.y - Loc2.y)
	var/dz = get_zs_away(Loc1,Loc2)

	return max(dx,dy,dz)

/proc/get_z_dist_euclidian(atom/Loc1, atom/Loc2)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y
	var/dz = get_zs_away(Loc1,Loc2)

	return sqrt(dx**2 + dy**2 + dz**2)

/**
 * Get Distance, Squared
 *
 * Because sqrt is slow, this returns the z distance squared, which skips the sqrt step.
 *
 * Use to compare distances. Used in component mobs.
 */
/proc/get_z_dist_squared(var/atom/a, var/atom/b)

	return ((b.x-a.x)**2) + ((b.y-a.y)**2) + ((get_zs_away(a,b))**2)

/proc/multi_z_spiral_block(var/turf/epicenter,var/max_range,var/draw_red=0,var/difference=0,var/multiple=1)
	var/turf/upturf = epicenter
	var/turf/downturf = epicenter
	. = spiral_block(epicenter,max_range,draw_red)
	var/current_size = max_range
	for(var/i = 1, i < max_range, i++)
		current_size += difference
		current_size *= multiple
		if(HasAbove(upturf.z))
			upturf = GetAbove(upturf)
			log_debug("Spiralling block of size [current_size] in [upturf.loc.name] ([upturf.x],[upturf.y],[upturf.z])")
			. += spiral_block(upturf, current_size, draw_red)
		if(HasBelow(downturf.z))
			downturf = GetBelow(downturf)
			log_debug("Spiralling block of size [current_size] in [downturf.loc.name] ([downturf.x],[downturf.y],[downturf.z])")
			. += spiral_block(downturf, current_size, draw_red)

/client/proc/check_multi_z_spiral()
	set name = "Check Multi-Z Spiral Block"
	set category = "Debug"

	var/turf/epicenter = get_turf(usr)
	var/max_range = input("Set the max range") as num
	var/shape_txt = alert("What shape?","Spiral Block", "Cube","Octahedron")
	var/shape = shape_txt == "Cube" ? 1 : 0
	multi_z_spiral_block(epicenter,max_range,shape)
