/proc/generate_room(var/turf/source, var/range, var/wall, var/floor, var/cardinal_atom, var/insidedoor, var/shape = "circle")
	var/list/outer_turfs
	var/list/internal_turfs
	switch(shape)
		if("circle")
			outer_turfs = circlerangeturfs(source, range)
			internal_turfs = circlerangeturfs(source, range-1)
		else
			outer_turfs = range(source, range)
			internal_turfs = range(source, range-1)
	outer_turfs -= internal_turfs
	for(var/turf/T in outer_turfs)
		if(!istype(T, get_base_turf(T.z)))
			continue
		if(cardinal_atom && cardinal.Find(get_dir(T, source)))
			T.ChangeTurf(floor) //give it a floor
			new cardinal_atom(T) //place a door
			if(insidedoor) //add a doormat
				var/instep = get_step(T,get_dir(T,source))
				new insidedoor(instep)
		else
			new wall(T)
	for(var/turf/T in internal_turfs)
		if(istype(T, get_base_turf(T.z)))
			T.ChangeTurf(floor)
		else
			internal_turfs -= T //only send the ones we made

	return internal_turfs
