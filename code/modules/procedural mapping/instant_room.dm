proc/generate_room(var/turf/source, var/range, var/wall, var/floor, var/cardinal_atom, var/shape = "circle")
	var/list/outer_turfs
	var/list/internal_turfs
	switch(shape)
		if("circle")
			outer_turfs = circleviewturfs(source, range)
			internal_turfs = circleviewturfs(source, range-1)
		else
			outer_turfs = range(source, range)
			internal_turfs = range(source, range-1)
	outer_turfs -= internal_turfs
	for(var/turf/T in outer_turfs)
		if(cardinal_atom && cardinal.Find(get_dir(T, source)))
			new cardinal_atom(T)
		else
			new wall(T)
	for(var/turf/T in internal_turfs)
		if(istype(T, get_base_turf(T.z)))
			T.ChangeTurf(floor)


	return internal_turfs