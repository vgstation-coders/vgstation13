/proc/cast_ray_test()
	var/vector3/origin = new /vector3(235 , 241, 1)
	var/vector3/direction = new /vector3(1, 1, 0)
	var/ray/our_ray = new /ray(origin, direction)
	var/list/res = our_ray.getTurfs()
	for(var/a in res)
		message_admins(atom_loc_line(a))
	return res

/proc/locate_test()
	message_admins(atom_loc_line(locate(235, 241, 1)))

