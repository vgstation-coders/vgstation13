/rayCastHit
	var/ray/used_ray
	var/atom/movable/hit_atom
	var/vector/point
	var/distance

/rayCastHit/New(var/ray/used_ray, var/atom/movable/hit_atom, var/vector/point, var/distance)
	src.used_ray = used_ray
	src.hit_atom = hit_atom
	src.point = point
	src.distance = distance
