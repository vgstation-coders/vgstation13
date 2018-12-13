var/list/forbidden_varedit_object_types = list(
										/datum/admins,						//Admins editing their own admin-power object? Yup, sounds like a good idea.
										/datum/blackbox,	//Prevents people messing with feedback gathering
										/datum/feedback_variable,			//Prevents people messing with feedback gathering
									)

//Interface for editing a variable. It returns its new value. If edited_datum, it automatically changes the edited datum's value
//If called with just [user] argument, it allows you to create a value such as a string, a number, an empty list, a nearby object, etc...
//If called with [edited_datum] and [edited_variable], you gain the ability to get the variable's initial value.

// acceptsLists : if we're setting a variable in a list
/proc/variable_set(mob/user, datum/edited_datum = null, edited_variable = null, autoselect_var_type = FALSE, value_override = null, logging = TRUE, var/acceptsLists = TRUE)
	var/client/C

	if(ismob(user))
		C = user.client
	else if(isclient(user))
		C = user

	if(!C || !C.holder)
		return

	if(!C.can_edit_var(edited_variable, edited_datum?.type))
		return

	//Special case for "appearance", because appearance values can't be stored anywhere.
	//It's impossible for this proc to return an appearance value, so just set it directly here
	if((isimage(edited_datum) || isatom(edited_datum)) && edited_variable == "appearance")
		if(!C.holder.marked_appearance)
			to_chat(usr, "You don't have a saved appearance!")
			return
		else
			var/atom/A = edited_datum
			if(value_override == "initial")
				if(logging)
					log_admin("[key_name(usr)] reset [edited_datum]'s appearance")

				A.appearance = initial(A.appearance)
				to_chat(usr, "Reset [edited_datum]'s appearance")

			else
				if(logging)
					log_admin("[key_name(usr)] modified [edited_datum]'s appearance to [C.holder.marked_appearance]")

				A.appearance = C.holder.marked_appearance.appearance
				to_chat(usr, "Changed [edited_datum]'s appearance to [C.holder.marked_appearance]")
			return

	#define V_MARKED_DATUM "marked_datum"
	#define V_RESET "reset"
	#define V_TEXT "text"
	#define V_NUM "num"
	#define V_TYPE "type"
	#define V_LIST_EMPTY "empty_list"
	#define V_LIST "list"
	#define V_OBJECT "object"
	#define V_ICON "icon"
	#define V_FILE "file"
	#define V_CLIENT "client"
	#define V_NULL "null"
	#define V_CANCEL "cancel"
	#define V_MATRIX "matrix"

	var/new_variable_type
	var/old_value = null //Old value of the variable
	var/new_value = value_override //New value of the variable

	if(edited_datum && edited_variable)
		//Check if the variable actually exists
		if(!edited_datum.vars.Find(edited_variable))
			return

		old_value = edited_datum.vars[edited_variable]

	if(isnull(new_value))
		if(autoselect_var_type)
			if(isnull(old_value))
				to_chat(usr, "Unable to determine variable type.")
			else if(isnum(old_value))
				to_chat(usr, "Variable appears to be <b>NUM</b>.")
				new_variable_type = V_NUM
			else if(istext(old_value))
				to_chat(usr, "Variable appears to be <b>TEXT</b>.")
				new_variable_type = V_TEXT
			else if(isloc(old_value))
				to_chat(usr, "Variable appears to be <b>REFERENCE</b>. Selecting from nearby objects...")
				new_variable_type = V_OBJECT
			else if(isicon(old_value))
				to_chat(usr, "Variable appears to be <b>ICON</b>.")
				new_variable_type = V_ICON
			else if(ispath(old_value))
				to_chat(usr, "Variable appears to be <b>TYPE</b>.")
				new_variable_type = V_TYPE
			else if(istype(old_value,/client))
				to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
				new_variable_type = V_CLIENT
			else if(isfile(old_value))
				to_chat(usr, "Variable appears to be <b>FILE</b>.")
				new_variable_type = V_FILE
			else if(islist(old_value))
				to_chat(usr, "Variable appears to be <b>LIST</b>.")
				new_value = C.mod_list(old_value) //Use a custom interface for list editing
			else if(ismatrix(old_value))
				to_chat(usr, "Variable appears to be <b>MATRIX</b>.")
				new_value = C.modify_matrix_menu(old_value) //Use a custom interface for matrix editing


	if(isnull(new_value)) //If a custom interface hasn't already set the value
		//Build the choices list
		var/list/choices = list(\
		"text" = V_TEXT,
		"num"  = V_NUM,
		"type" = V_TYPE,
		"empty list"      = V_LIST_EMPTY,
		"list"  = V_LIST,
		"object (nearby)" = V_OBJECT,
		"icon"   = V_ICON,
		"file"   = V_FILE,
		"client" = V_CLIENT,
		"matrix" = V_MATRIX,
		"null"   = V_NULL,
		)

		if (!acceptsLists)
			choices -= V_LIST
			choices -= V_LIST_EMPTY

		if(C.holder.marked_datum) //Add the marked datum option
			var/list_item_name
			if(isdatum(C.holder.marked_datum))
				list_item_name = "marked datum ([C.holder.marked_datum.type])"
			else if(isfile(C.holder.marked_datum))
				list_item_name = "marked datum (file)"
			else if(isicon(C.holder.marked_datum))
				list_item_name = "marked datum (icon)"
			else
				list_item_name = "marked datum ([C.holder.marked_datum])"
			choices[list_item_name] = V_MARKED_DATUM

		if(edited_datum && edited_variable) //Add the restore to default option
			choices["restore to default"] = V_RESET

		//Add the cancel option
		choices["CANCEL"] = V_CANCEL

		if(!new_variable_type)
			new_variable_type = input("What kind of variable?","Variable Type") as null|anything in choices
		var/selected_type = choices[new_variable_type]
		var/window_title = "Varedit [edited_datum]"

		switch(selected_type)
			if(V_CANCEL)
				return

			if(V_TEXT)
				new_value = input("Enter new text:", window_title, old_value) as text

			if(V_NUM)
				new_value = input("Enter new number:", window_title, old_value) as num

			if(V_TYPE)
				var/partial_type = input("Enter type, or leave blank to see all types", window_title, "[old_value]") as text|null

				var/list/matches = get_matching_types(partial_type, /datum)
				new_value = input("Select type", window_title) as null|anything in matches

			if(V_LIST_EMPTY)
				if (acceptsLists)
					new_value = list()

			if(V_LIST)
				if (acceptsLists)
					new_value = C.populate_list()

			if(V_OBJECT)
				new_value = input("Select reference:", window_title, old_value) as mob|obj|turf|area in range(8, get_turf(user))

			if(V_FILE)
				new_value = input("Pick file:", window_title) as file

			if(V_ICON)
				new_value = input("Pick icon:", window_title) as icon

			if(V_CLIENT)
				var/list/keys = list()
				for(var/mob/M in mob_list)
					if(M.client)
						keys += M.client

				new_value = input("Please, select a player!", window_title, null, null) as null|anything in keys

			if(V_MARKED_DATUM)
				new_value = C.holder.marked_datum

			if(V_RESET)
				if(edited_datum && edited_variable)
					new_value = initial(edited_datum.vars[edited_variable])

					edited_datum.vars[edited_variable] = new_value
					to_chat(user, "Restored '[edited_variable]' to original value - [new_value]")

			if(V_NULL)
				new_value = null

			if(V_MATRIX)
				new_value = matrix()

			else
				to_chat(user, "Unknown type: [selected_type]")

	switch(edited_variable)
		if("bound_width", "bound_height", "bound_x", "bound_y")
			if(new_value % world.icon_size) //bound_width/height must be a multiple of 32, otherwise movement breaks - BYOND issue
				to_chat(usr, "[edited_variable] can only be a multiple of [world.icon_size]!")
				return

	if(edited_datum && edited_variable)
		if(isdatum(edited_datum) && edited_datum.variable_edited(edited_variable, old_value, new_value))
		//variable_edited() can block the edit in case there's special behavior for a variable (for example, updating lights after they're changed)
			new_value = edited_datum.vars[edited_variable]
		else
			edited_datum.vars[edited_variable] = new_value

		if(logging)
			log_admin("[key_name(usr)] modified [edited_datum]'s [edited_variable] to [html_encode(new_value)]")

	return new_value

	#undef V_MARKED_DATUM
	#undef V_RESET
	#undef V_TEXT
	#undef V_NUM
	#undef V_TYPE
	#undef V_LIST_EMPTY
	#undef V_LIST
	#undef V_OBJECT
	#undef V_ICON
	#undef V_FILE
	#undef V_CLIENT
	#undef V_NULL

/client/proc/populate_list()
	var/to_continue = TRUE
	var/list/things_to_return = list()
	while (to_continue)
		things_to_return += variable_set(src, acceptsLists = FALSE)
		to_continue = (alert("Do you want to add another item to the list? It has currently [things_to_return.len] items.", "Filling a list", "Yes", "No") == "Yes")

	return things_to_return

/client/proc/cmd_modify_ticker_variables()
	set category = "Debug"
	set name = "Edit Ticker Variables"

	if (ticker == null)
		to_chat(src, "Game hasn't started yet.")
	else
		debug_variables(ticker)
		feedback_add_details("admin_verb","ETV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//Select and add a value to list L
/client/proc/mod_list_add(var/list/L)
	if(!check_rights(R_VAREDIT))
		return

	var/added_value = variable_set(src, L)

	switch(alert("Would you like to associate a var with the list entry?",,"Yes","No"))
		if("Yes")
			L[added_value] = variable_set(src, L) //haha
		else
			L.Add(added_value)

//Modify a list - either add or remove a balue
/client/proc/mod_list(var/list/L)
	if(!check_rights(R_VAREDIT))
		return

	//var/list/names = sortList(L)
	//Don't sort the list - item order is important in some lists

	var/variable = input("Select a variable to remove from the list, or select (ADD VAR) to add a new one","Var") as null|anything in L + "(ADD VAR)"

	if(!variable)
		return L
	else if(variable == "(ADD VAR)")
		mod_list_add(L)
		return L
	else
		L[variable] = variable_set(src, L)

	return L

/client/proc/modify_matrix_menu(var/matrix/M = matrix(), var/verbose = TRUE)
	if (verbose)
		to_chat(src, "Current matrix: a: [M.a], b: [M.b], c: [M.c], d: [M.d], e: [M.e], f: [M.f].")

	var/input = input("Which action do you want to apply to this matrix?") as null|anything in list("Scale", "Translate", "Turn", "Manual","Reset")
	if (!input)
		return

	switch (input)
		if ("Scale")
			var/x = input("X scale") as num
			var/y = input("Y scale") as num

			M.Scale(x, y)

		if ("Translate")
			var/x = input("X amount") as num
			var/y = input("Y amount") as num

			M.Translate(x, y)

		if ("Turn")
			var/angle = input("Angle (clockwise)") as num

			M.Turn(angle)

		if ("Reset")
			M = matrix()

		if ("Manual")
			var/list/numbers = splittext(input("Enter the matrix components as a comma separated list.") as text|null, ",")
			if (!numbers || numbers.len != 6)
				to_chat(src, "Cancelled or not enough arguments provided.")

			else
				var/list/newnumbers = list()
				for (var/number in numbers)
					number = text2num(number) || 0
					newnumbers += number

				M = matrix(newnumbers[1], newnumbers[2], newnumbers[3], newnumbers[4], newnumbers[5], newnumbers[6])

	if (verbose)
		to_chat(src, "New matrix: a: [M.a], b: [M.b], c: [M.c], d: [M.d], e: [M.e], f: [M.f].")

	return M

/client/proc/can_edit_var(var/tocheck, var/type_to_check)
	if(tocheck in nevervars)
		to_chat(usr, "Editing this variable is forbidden.")
		return FALSE

	if (is_type_in_list(type_to_check, forbidden_varedit_object_types))
		to_chat(usr, "Editing this variable is forbidden.")
		return FALSE

	if(tocheck == "bounds")
		to_chat(usr, "Editing this variable is forbidden. Edit bound_width or bound_height instead.")
		return FALSE

	if(tocheck in lockedvars)
		if(!check_rights(R_DEBUG))
			return FALSE

	return TRUE
