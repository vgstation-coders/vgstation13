/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	recieving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/MouseDrop(atom/over_object,src_location,over_location,src_control,over_control,params)
	if(!over_object) //Dragged to the stat panel
		return
	var/list/params_list = params2list(params)
	if(params_list["ctrl"]) //More modifiers can be added - check click.dm
		spawn(0)
			over_object.CtrlMouseDropTo(src,usr,src_location,over_location,src_control,over_control,params)
		return CtrlMouseDropFrom(over_object,src_location,over_location,src_control,over_control,params)

	spawn(0)
		over_object.MouseDropTo(src,usr,src_location,over_location,src_control,over_control,params)
	return MouseDropFrom(over_object,src_location,over_location,src_control,over_control,params)

// mousedrop issued from us
/atom/proc/MouseDropFrom(atom/over_object,src_location,over_location,src_control,over_control,params)
	return

// recieve a mousedrop
/atom/proc/MouseDropTo(atom/over_object,mob/user,src_location,over_location,src_control,over_control,params)
	return

/obj/MouseDropTo(atom/over_object, mob/user)
	if(material_type)
		material_type.on_use(src, over_object, user)
	..()

/atom/proc/CtrlMouseDropFrom(atom/over_object,src_location,over_location,src_control,over_control,params)
	return

/atom/movable/CtrlMouseDropFrom(atom/over_object,src_location,over_location,src_control,over_control,params)
	var/turf/T = get_turf(over_object)
	if(!T)
		return
	//What's this doing here?
	//With large items that have their own pixel_x, such a fireaxe hanging off the side of a table, you can end up visually
	//"clicking" one turf, but the game still thinks you clicked the turf that that object is in.
	//This effectively finds the real turf you clicked as if you had clicked the floor instead.
	var/list/params_list = params2list(params)
	var/deltax = over_object.pixel_x + text2num(params_list["icon-x"]) - WORLD_ICON_SIZE/2
	var/deltay = over_object.pixel_y + text2num(params_list["icon-y"]) - WORLD_ICON_SIZE/2
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

	if(usr.incapacitated() || !usr.Adjacent(T))
		return
	usr.Move_Pulled(T, src)
	usr.face_atom(T)

/atom/proc/CtrlMouseDropTo(atom/over_object,mob/user,src_location,over_location,src_control,over_control,params)
	return
