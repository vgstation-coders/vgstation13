var/list/forbidden_varedit_object_types = list(
										/datum/admins,						//Admins editing their own admin-power object? Yup, sounds like a good idea.
										/obj/machinery/blackbox_recorder,	//Prevents people messing with feedback gathering
										/datum/feedback_variable,			//Prevents people messing with feedback gathering
										/datum/configuration,	//prevents people from fucking with logging.
									)

/*
/client/proc/cmd_modify_object_variables(obj/O as obj|mob|turf|area in world)
	set category = "Debug"
	set name = "Edit Variables"
	set desc="(target) Edit a target item's variables"
	src.modify_variables(O)
	feedback_add_details("admin_verb","EDITV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
*/

/proc/variable_set(mob/user, datum/edited_datum, edited_variable, autoselect_var_type = FALSE)
	var/client/C

	if(ismob(user))
		C = user.client
	else if(isclient(user))
		C = user

	if(!C || !C.holder)
		return

	#define V_MARKED_DATUM "marked_datum"
	#define V_RESET "reset"
	#define V_TEXT "text"
	#define V_NUM "num"
	#define V_TYPE "type"
	#define V_LIST "list"
	#define V_OBJECT "object"
	#define V_ICON "icon"
	#define V_FILE "file"
	#define V_CLIENT "client"
	#define V_NULL "null"
	#define V_CANCEL "cancel"
	#define V_MATRIX "matrix"

	var/list/choices = list(\
	"text" = V_TEXT,
	"num"  = V_NUM,
	"type" = V_TYPE,
	"empty list"      = V_LIST,
	"object (nearby)" = V_OBJECT,
	"icon"   = V_ICON,
	"file"   = V_FILE,
	"client" = V_CLIENT,
	"matrix" = V_MATRIX,
	"null"   = V_NULL,
	)

	if(C.holder.marked_datum)
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

	if(istype(edited_datum) && edited_variable)
		choices["restore to default"] = V_RESET

	//Cancel belongs at the end
	choices["CANCEL"] = V_CANCEL


	var/class
	var/var_value = null //Old value of the variable
	var/result //New value of the variable

	if(autoselect_var_type && istype(edited_datum) && edited_variable)
		var_value = edited_datum.vars[edited_variable]

		if(isnull(var_value))
			to_chat(usr, "Unable to determine variable type.")
		else if(isnum(var_value))
			to_chat(usr, "Variable appears to be <b>NUM</b>.")
			class = V_NUM
		else if(istext(var_value))
			to_chat(usr, "Variable appears to be <b>TEXT</b>.")
			class = V_TEXT
		else if(isloc(var_value))
			to_chat(usr, "Variable appears to be <b>REFERENCE</b>. Selecting from nearby objects...")
			class = V_OBJECT
		else if(isicon(var_value))
			to_chat(usr, "Variable appears to be <b>ICON</b>.")
			class = V_ICON
		else if(ispath(var_value))
			to_chat(usr, "Variable appears to be <b>TYPE</b>.")
			class = V_TYPE
		else if(istype(var_value,/client))
			to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
			class = V_CLIENT
		else if(isfile(var_value))
			to_chat(usr, "Variable appears to be <b>FILE</b>.")
			class = V_FILE
		else if(islist(var_value))
			to_chat(usr, "Variable appears to be <b>LIST</b>.")
			result = C.mod_list(var_value)
		else if(ismatrix(var_value))
			to_chat(usr, "Variable appears to be <b>MATRIX</b>.")
			result = C.modify_matrix_menu(var_value)


	if(!class && !result)
		class = input("What kind of variable?","Variable Type") in choices
	var/selected_type = choices[class]

	if(!result)
		switch(selected_type)
			if(V_CANCEL)
				return

			if(V_TEXT)
				result = input("Enter new text:","Text",null) as text

			if(V_NUM)
				result = input("Enter new number:","Num",0) as num

			if(V_TYPE)
				var/partial_type = input("Enter type, or leave blank to see all types", "Type") as text|null

				var/list/matches = matching_type_list(partial_type, /datum)
				result = input("Select type","Type") as null|anything in matches

			if(V_LIST)
				result = list()

			if(V_OBJECT)
				result = input("Select reference:","Reference",src) as mob|obj|turf|area in range(8, get_turf(user))

			if(V_FILE)
				result = input("Pick file:","File") as file

			if(V_ICON)
				result = input("Pick icon:","Icon") as icon

			if(V_CLIENT)
				var/list/keys = list()
				for(var/mob/M in mob_list)
					if(M.client)
						keys += M.client

				result = input("Please, select a player!", "Selection", null, null) as null|anything in keys

			if(V_MARKED_DATUM)
				result = C.holder.marked_datum

			if(V_RESET)
				if(istype(edited_datum) && edited_variable)
					result = initial(edited_datum.vars[edited_variable])

					edited_datum.vars[edited_variable] = result
					to_chat(user, "Restored '[edited_variable]' to original value - [result]")

			if(V_NULL)
				result = null

			if(V_MATRIX)
				result = matrix()

			else
				to_chat(user, "Unknown type: [selected_type]")

	if(istype(edited_datum))
		edited_datum.variable_edited(edited_variable, var_value, result)

	return result

	#undef V_MARKED_DATUM
	#undef V_RESET
	#undef V_TEXT
	#undef V_NUM
	#undef V_TYPE
	#undef V_LIST
	#undef V_OBJECT
	#undef V_ICON
	#undef V_FILE
	#undef V_CLIENT
	#undef V_NULL

/client/proc/cmd_modify_ticker_variables()
	set category = "Debug"
	set name = "Edit Ticker Variables"

	if (ticker == null)
		to_chat(src, "Game hasn't started yet.")
	else
		src.modify_variables(ticker)
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
		return
	else if(variable == "(ADD VAR)")
		mod_list_add(L)
		return
	else
		L.Remove(variable)

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

/client/proc/can_edit_var(var/tocheck)
	if(tocheck in nevervars)
		to_chat(usr, "Editing this variable is forbidden.")
		return FALSE

	if(tocheck in lockedvars)
		if(!check_rights(R_DEBUG))
			return FALSE

	return TRUE
