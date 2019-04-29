/client/proc/cmd_mass_modify_object_variables(target_type as text, variable_name as null|text)
	set category = "Debug"
	set name = "Mass Edit Variables"
	set desc="(typepath,variable) Change a variable of all objects of the specified type"

	if(!check_rights(R_VAREDIT))
		return

	if(istext(target_type))
		target_type = input("Select an object type to mass-modify", "Mass-editing") as null|anything in get_matching_types(target_type, /atom)

		//get_vars_from_type() fails on turf and area objects. If you want to mass-edit a turf, you have to do it through the varedit window
		if(ispath(target_type, /atom) && !ispath(target_type, /atom/movable))
			to_chat(src, "<span class='warning'>It's impossible to perform this task on objects of type [target_type] through the verb. Use the mass edit function from View Variables instead.")
			return
	if(!target_type)
		return

	var/include_subtypes = FALSE
	if(length(typesof(target_type)))
		switch(alert("Strict object type detection?", "Mass-editing", "Strictly this type","This type and subtypes", "Cancel"))
			if("Strictly this type")
				include_subtypes = FALSE
			if("This type and subtypes")
				include_subtypes = TRUE
			else
				return

	if(!variable_name)
		variable_name = input("Select a variable to edit.", "Mass-editing [target_type]") as null|anything in get_vars_from_type(target_type)
	if(!variable_name)
		return

	var/reset_to_initial = FALSE
	var/new_value = null
	switch(alert("What to do with the object's variable [variable_name]?", "Mass-editing [target_type]", "Reset to initial", "Set new value", "Cancel"))
		if("Cancel")
			return
		if("Reset to initial")
			reset_to_initial = TRUE
		if("Set new value")
			new_value = variable_set(usr)

	//Log the action before actually performing it, in case it crashes the server
	feedback_add_details("admin_verb","MEV")
	log_admin("[key_name(src)] mass modified [target_type]'s [variable_name] to [reset_to_initial ? "its initial value" : " [new_value] "]")
	message_admins("[key_name_admin(src)] mass modified [target_type]'s [variable_name] to [reset_to_initial ? "its initial value" : " [html_encode(new_value)] "]", 1)

	mass_modify_variable(target_type, variable_name, new_value, reset_to_initial, include_subtypes)

//Mass-modifies all atoms of type [type], changing their variable [var_name] to [new_value]
//If reset_to_initial is TRUE, the variables will be reset to their initial values, instead of getting a new value
/proc/mass_modify_variable(type, var_name, new_value, reset_to_initial = FALSE, include_subtypes = TRUE)

	var/base_path
	if(isdatum(type))
		var/datum/D = type
		base_path = D.type
	else if(ispath(type))
		base_path = type
	else if(istext(type))
		base_path = text2path(type)

	if(!ispath(base_path, /atom))
		to_chat(usr, "Mass-editing is not supported for objects of type [base_path]")
		return

	//Safety measures copied from modifyvariables.dm
	if(!usr.client.can_edit_var(var_name))
		return
	switch(var_name)
		if("bound_width", "bound_height", "bound_x", "bound_y")
			if(new_value % world.icon_size) //bound_width/height must be a multiple of 32, otherwise movement breaks - BYOND issue
				to_chat(usr, "[var_name] can only be a multiple of [world.icon_size]!")
				return

	//BYOND's internal optimisation makes this work better than cycling through every atom
	#define is_valid_atom(atom) (atom.type == base_path || (include_subtypes && istype(atom, base_path)))
	if(ispath(base_path, /turf))
		for(var/turf/A in world)
			if(is_valid_atom(A))
				if(reset_to_initial)
					A.vars[var_name] = initial(A.vars[var_name])
				else
					A.vars[var_name] = new_value
			CHECK_TICK
	else if(ispath(base_path, /mob))
		for(var/mob/A in mob_list)
			if(is_valid_atom(A))
				if(reset_to_initial)
					A.vars[var_name] = initial(A.vars[var_name])
				else
					A.vars[var_name] = new_value
			CHECK_TICK
	else if(ispath(base_path, /area))
		for(var/area/A in world)
			if(is_valid_atom(A))
				if(reset_to_initial)
					A.vars[var_name] = initial(A.vars[var_name])
				else
					A.vars[var_name] = new_value
			CHECK_TICK
	else if(ispath(base_path, /obj))
		for(var/obj/A in world)
			if(is_valid_atom(A))
				if(reset_to_initial)
					A.vars[var_name] = initial(A.vars[var_name])
				else
					A.vars[var_name] = new_value
			CHECK_TICK
	else if(ispath(base_path, /atom))
		for(var/atom/A in world)
			if(is_valid_atom(A))
				if(reset_to_initial)
					A.vars[var_name] = initial(A.vars[var_name])
				else
					A.vars[var_name] = new_value
			CHECK_TICK

	#undef is_valid_atom
