
/proc/raycast_test(var/x = 1, var/y = 1, var/dist)
	var/vector/origin = new /vector(usr.x, usr.y)
	var/vector/direction = new /vector(x, y)

	var/ray/our_ray = new /ray(origin, direction, usr.z)
	var/list/res = our_ray.cast(dist)
	for(var/rayCastHit/rCH in res)
		var/image/I = image('icons/Testing/Zone.dmi',"fullblock",10)
		rCH.hit_atom.overlays += I
		var/ref = "\ref[rCH.hit_atom]"
		spawn(30)
			var/atom/movable/R = locate(ref)
			R.overlays -= I
	return res
