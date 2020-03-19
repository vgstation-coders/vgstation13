/rayCastHit
	var/ray/used_ray
	var/turf/hit_turf
	var/distance

/rayCastHit/New(var/ray/used_ray, var/turf/hit_turf, var/distance)
	src.used_ray = used_ray
	src.hit_turf = hit_turf
	src.distance = distance
