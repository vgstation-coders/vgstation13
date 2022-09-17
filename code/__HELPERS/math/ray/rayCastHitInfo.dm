/rayCastHitInfo
	var/ray/used_ray
	var/datum/weakref/hit_atom
	var/vector/point
	var/vector/point_raw
	var/distance

/rayCastHitInfo/New(var/ray/used_ray, var/datum/weakref/hit_atom, var/vector/point, var/vector/point_raw, var/distance)
	src.used_ray = used_ray
	src.hit_atom = hit_atom
	src.point = point
	src.point_raw = point_raw
	src.distance = distance

/rayCastHitInfo/Destroy()
	used_ray = null
	hit_atom = null
	point = null
	point_raw = null
	..()
