
/proc/raycast_test(var/x = 1, var/y = 1, var/dist)
	var/_vector/origin = new /_vector(usr.x, usr.y)
	var/_vector/direction = new /_vector(x, y)

	var/ray/our_ray = new /ray(origin, direction, usr.z)
	var/list/res = our_ray.cast(dist)
	for(var/rayCastHit/rCH in res)
		var/image/I = image('icons/Testing/Zone.dmi',"fullblock",10)
		var/datum/weakref/ref = rCH.hit_atom
		var/atom/movable/R = ref.get()
		R.overlays += I
		R = null
		spawn(30)
			R = ref.get()
			R.overlays -= I
	return res
