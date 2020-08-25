/rayCastHit
	var/ray/used_ray
	var/atom/movable/hit_atom
	var/vector/point
	var/vector/point_raw
	var/distance
	var/hit_type // see defines in ray.dm

/rayCastHit/New(var/rayCastHitInfo/info, var/hit_type)
	src.used_ray = info.used_ray
	src.hit_atom = info.hit_atom
	src.point = info.point
	src.point_raw = info.point_raw
	src.distance = info.distance
	src.hit_type = hit_type

/rayCastHit/Destroy()
	qdel(used_ray)
	used_ray = null
	qdel(hit_atom)
	hit_atom = null
	qdel(point)
	point = null
	qdel(point_raw)
	point_raw = null
	..()

//see ray.dm for defines
/rayCastHit/proc/hit_code()
	if(hit_type < RAY_CAST_NO_HIT_CONTINUE)
		return RAY_CAST_NO_HIT_EXIT
	else if(hit_type == RAY_CAST_NO_HIT_CONTINUE)
		return RAY_CAST_NO_HIT_CONTINUE
	else if(hit_type <= RAY_CAST_HIT_CONTINUE)
		return RAY_CAST_HIT_CONTINUE
	else if(hit_type > RAY_CAST_HIT_CONTINUE)
		return RAY_CAST_HIT_EXIT
