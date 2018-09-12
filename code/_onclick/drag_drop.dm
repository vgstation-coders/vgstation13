/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	recieving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/MouseDrop(atom/over)
	if(!can_MouseDrop(over))
		return FALSE

	spawn(0)
		over.MouseDrop_T(src,usr)
	return TRUE

// recieve a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user)
	return

/obj/MouseDrop_T(atom/dropping, mob/user)
	if(material_type)
		material_type.on_use(src, dropping, user)

/atom/proc/can_MouseDrop(atom/otheratom, mob/user = usr)
	if(!user || !otheratom)
		return FALSE
	if(!Adjacent(user) || !otheratom.Adjacent(user))
		return FALSE
	return TRUE