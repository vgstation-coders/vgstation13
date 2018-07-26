/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	recieving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/MouseDrop(atom/over_object,src_location,over_location,src_control,over_control,params)
	if(!can_MouseDrop(over_object))
		return FALSE

	spawn(0)
		over_object.MouseDrop_T(src,usr,src_location,over_location,src_control,over_control,params)
	return TRUE

// recieve a mousedrop
/atom/proc/MouseDrop_T(over_object,mob/user,src_location,over_location,src_control,over_control,params)
	var/turf/T = get_turf(src)
	if(!T)
		return
	//What's this doing here?
	//With large items that have their own pixel_x, such a fireaxe hanging off the side of a table, you can end up visually
	//"clicking" one turf, but the game still thinks you clicked the turf that that object is in.
	//This effectively finds the real turf you clicked as if you had clicked the floor instead.
	var/list/params_list = params2list(params)
	var/deltax = pixel_x + text2num(params_list["icon-x"]) - WORLD_ICON_SIZE/2
	var/deltay = pixel_y + text2num(params_list["icon-y"]) - WORLD_ICON_SIZE/2
	while(deltax > WORLD_ICON_SIZE/2)
		T = get_step(T, EAST)
		deltax -= WORLD_ICON_SIZE
	while(deltax < -WORLD_ICON_SIZE/2)
		T = get_step(T, WEST)
		deltax += WORLD_ICON_SIZE
	while(deltay > WORLD_ICON_SIZE/2)
		T = get_step(T, NORTH)
		deltay -= WORLD_ICON_SIZE
	while(deltay < -WORLD_ICON_SIZE/2)
		T = get_step(T, SOUTH)
		deltay += WORLD_ICON_SIZE
	if(!T)
		return
	params_list["icon-x"] = deltax + WORLD_ICON_SIZE/2
	params_list["icon-y"] = deltay + WORLD_ICON_SIZE/2
	params = list2params(params_list)
	T.MouseDrop_T(over_object,user,src_location,over_location,src_control,over_control,params)

/obj/MouseDrop_T(atom/over_object, mob/user)
	if(material_type)
		material_type.on_use(src, over_object, user)
	..()

/atom/proc/can_MouseDrop(atom/otheratom, mob/user = usr)
	if(!user || !otheratom)
		return FALSE
	if(!Adjacent(user) || !otheratom.Adjacent(user))
		return FALSE
	return TRUE
