// If you add a more comprehensive system, just untick this file.

/proc/HasAbove(var/z)
	if(z > world.maxz || z < 1)
		return FALSE
	return map.zLevels[z].z_above ? TRUE : FALSE

/proc/HasBelow(var/z)
	if(z > world.maxz || z < 1)
		return FALSE
	return map.zLevels[z].z_below ? TRUE : FALSE

/proc/GetAbove(var/atom/atom)
	var/turf/turf = get_turf(atom)
	if(!turf)
		return null
	return HasAbove(turf.z) ? locate(turf.x,turf.y,map.zLevels[turf.z].z_above) : null

/proc/GetBelow(var/atom/atom)
	var/turf/turf = get_turf(atom)
	if(!turf)
		return null
	return HasBelow(turf.z) ? locate(turf.x,turf.y,map.zLevels[turf.z].z_below) : null

/proc/GetConnectedZlevels(z)
	. = list(z)
	for(var/level = z, HasBelow(level), level = map.zLevels[level].z_below)
		if((level != z) && (level in .)) // No infinite loops
			break
		. |= level
	for(var/level = z, HasAbove(level), level = map.zLevels[level].z_above)
		if((level != z) && (level in .)) // No infinite loops
			break
		. |= level

/proc/AreConnectedZLevels(var/zA, var/zB)
	return zA == zB || (zB in GetConnectedZlevels(zA))

/proc/GetOpenConnectedZlevels(var/atom/atom)
	var/turf/turf = get_turf(atom)
	if (!turf)
		return list()
	. = list(turf.z)
	for(var/level = turf.z, HasBelow(level) && isvisiblespace(GetBelow(locate(turf.x,turf.y,level))), level = map.zLevels[level].z_below)
		if((level != turf.z) && (level in .)) // No infinite loops
			break
		. |= level
	for(var/level = turf.z, HasAbove(level) && isvisiblespace(GetAbove(locate(turf.x,turf.y,level))), level = map.zLevels[level].z_above)
		if((level != turf.z) && (level in .)) // No infinite loops
			break
		. |= level

/proc/AreOpenConnectedZLevels(var/zA, var/zB)
	return zA == zB || (zB in GetOpenConnectedZlevels(zA))

/proc/get_zstep(ref, dir)
	if(dir == UP)
		. = GetAbove(ref)
	else if (dir == DOWN)
		. = GetBelow(ref)
	else
		. = get_step(ref, dir)
