/atom/movable/proc/vector_translate(var/vector/V, var/delay)
	var/turf/T = get_turf(src)
	var/turf/destination = locate(T.x + V.x, T.y + V.y, z)
	var/vector/V_norm = V.chebyshev_normalized()
	if (!V_norm.is_integer())
		return
	var/turf/destination_temp
	while (destination_temp != destination)
		destination_temp = locate(T.x + V_norm.x, T.y + V_norm.y, z)
		forceMove(destination_temp, glide_size_override = DELAY2GLIDESIZE(delay))
		T = get_turf(src)
		sleep(delay + world.tick_lag) // Shortest possible time to sleep

/atom/proc/get_translated_turf(var/vector/V)
	var/turf/T = get_turf(src)
	return locate(T.x + V.x, T.y + V.y, z)

//Vector representing world-pos of A
/proc/atom2vector(var/atom/A)
	return new /vector(A.x, A.y)

//Vector from A -> B
/proc/atoms2vector(var/atom/A, var/atom/B)
	return new /vector((B.x - A.x), (B.y - A.y))
