
/proc/raycast_test(var/x = 1, var/y = 1, var/dist)
	var/vector3/origin = new /vector3(usr.x, usr.y, usr.z)
	var/vector3/direction = new /vector3(x, y, 0)
	var/ray/our_ray = new /ray(origin, direction)
	var/list/res = our_ray.getAllHits(dist)
	for(var/rayCastHit/rCH in res)
		var/image/I = image('icons/Testing/Zone.dmi',"fullblock",10)
		rCH.hit_turf.overlays += I
		var/ref = "\ref[rCH.hit_turf]"
		spawn(30)
			var/turf/R = locate(ref)
			R.overlays -= I
	return res

