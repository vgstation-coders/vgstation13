/rayCastHit
	var/ray/used_ray
	var/atom/movable/hit_atom
	var/vector/point
	var/vector/point_raw
	var/distance
	var/hit_type // see defines in ray.dm

/rayCastHit/New(var/ray/used_ray, var/atom/movable/hit_atom, var/vector/point, var/vector/point_raw, var/distance, var/hit_type)
	src.used_ray = used_ray
	src.hit_atom = hit_atom
	src.point = point
	src.point_raw = point_raw
	src.distance = distance
	src.hit_type = hit_type
