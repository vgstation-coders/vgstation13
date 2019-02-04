proc/generate_room(var/turf/source, var/range, var/wall, var/floor, var/cardinal_atom, var/shape = "circle")
	var/list/affected_turfs
	var/list/internal_turfs
	switch(shape)
		if("circle")
			affected_turfs = circleviewturfs(source, range)
			internal_turfs = circleviewturfs(source, range-1)
		else
			affected_turfs = range(source, range)
			internal_turfs = range(source, range-1)
	for(var/turf/T in affected_turfs)
		if(!(internal_turfs.Find(T)))
			if(cardinal_atom && cardinal.Find(get_dir(T, source)))
				new cardinal_atom(T)
			else
				new wall(T)
		if(istype(T, get_base_turf(T.z)))
			T.ChangeTurf(floor)


	return internal_turfs