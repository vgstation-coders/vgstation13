#define VALUE_OPERATION "Operation"
#define VALUE_CHECK_1 "Checked Value 1"
#define VALUE_CHECK_2 "Checked Value 2"
#define VALUE_DEVICE_1 "Device 1"
#define VALUE_DEVICE_2 "Device 2"
#define VALUE_PULSE_IF_TRUE "Pulse if true"
#define VALUE_PULSE_IF_FALSE "Pulse if false"

//////////////////////////Comparison circuit////////////////////////
// * When pulsed, check FIRST connected assembly. If the condition is TRUE, emit a pulse to the SECOND connected assembly. If the condition is false, emit a pulse to the THIRD connected assembly.
//
// * get pulse: check condition. If true, send pulse to all outputs

var/global/list/comparison_circuit_operations = list("EQUAL TO", "LESS THAN", "MORE THAN", "LESS THAN OR EQUAL TO", "MORE THAN OR EQUAL TO", "NOT EQUAL TO")

/obj/item/device/assembly/comparison
	name = "comparison circuit"

	desc = "A tiny circuit intended for use in assembly frames. When it receives a signal, it checks whether the condition is true or false, and sends a pulse to the the corresponding assembly."
	icon_state = "circuit_="
	starting_materials = list(MAT_IRON = 100, MAT_GLASS = 25)
	w_type = RECYK_ELECTRONIC

	origin_tech = Tc_PROGRAMMING + "=1"

	wires = WIRE_PULSE | WIRE_RECEIVE

	connection_text = "connected to"

	var/obj/item/device/assembly/check_this = 1 //Either an assembly, or a constant
	var/checked_value_1 //If check_this is an assembly, this var contains the value that is used

	var/check_type = "EQUAL TO"

	var/obj/item/device/assembly/check_against = 1 //Either an assembly, or a constant
	var/checked_value_2 //If check_against is an assembly, this var contains the value that is used

	var/obj/item/device/assembly/pulse_if_true = null

	var/obj/item/device/assembly/pulse_if_false = null

	var/list/device_pool = list() //List of all connected devices

	accessible_values = list(VALUE_OPERATION = "check_type;"+VT_TEXT,\
		VALUE_CHECK_1 = "checked_value_1;"+VT_TEXT,\
		VALUE_CHECK_2 = "checked_value_2;"+VT_TEXT,\
		VALUE_DEVICE_1 = "check_this;"+VT_POINTER,\
		VALUE_DEVICE_2 = "check_against;"+VT_POINTER,\
		VALUE_PULSE_IF_TRUE = "pulse_if_true;"+VT_POINTER,\
		VALUE_PULSE_IF_FALSE = "pulse_if_false;"+VT_POINTER)

/obj/item/device/assembly/comparison/activate()
	if(!..())
		return 0

	var/value_1 = 0
	if(isnum(check_this) || istext(check_this))
		value_1 = check_this
	else if(check_this)
		value_1 = check_this.get_value(checked_value_1)

	var/value_2 = 0
	if(isnum(check_against) || istext(check_against))
		value_2 = check_against
	else if(check_against)
		value_2 = check_against.get_value(checked_value_2)

	var/result = 0

	switch(check_type)
		if("EQUAL TO")
			result = (value_1 == value_2)
		if("LESS THAN")
			result = (value_1 < value_2)
		if("MORE THAN")
			result = (value_1 > value_2)
		if("LESS THAN OR EQUAL TO")
			result = (value_1 <= value_2)
		if("MORE THAN OR EQUAL TO")
			result = (value_1 >= value_2)
		if("NOT EQUAL TO")
			result = (value_1 != value_2)

	switch(result)
		if(0)
			if(pulse_if_false)
				pulse_if_false.pulsed()
		else
			if(pulse_if_true)
				pulse_if_true.pulsed()



/obj/item/device/assembly/comparison/interact(mob/user as mob)
	var/dat = ""

	dat += "CONDITON:<br>"

	dat += "<a href='?src=\ref[src];change_check_this=1'>[check_this]</a>"

	if(istype(check_this))
		dat += " ([checked_value_1])"

	dat += " is <a href='?src=\ref[src];change_check_type=1'>[check_type]</a> "

	dat += "<a href='?src=\ref[src];change_check_against=1'>[check_against]</a>"

	if(istype(check_against))
		dat += " ([checked_value_2])"

	dat += "<BR>"

	dat += "IF <b>TRUE</b>: <a href='?src=\ref[src];change_pulse_if_true=1'>[pulse_if_true ? "pulse [pulse_if_true]" : "do nothing"]</a><BR>"
	dat += "IF <b>FALSE</b>: <a href='?src=\ref[src];change_pulse_if_false=1'>[pulse_if_false ? "pulse [pulse_if_false]" : "do nothing"]</a><BR><hr>"

	dat += "Connected devices: "

	if(device_pool.len)

		for(var/i = 1 to device_pool.len)
			dat += "[device_pool[i]]"
			if(i != device_pool.len)
				dat += ", " //If not last item in the list, add a comma

	var/datum/browser/popup = new(user, "circuit2", "[src]", 500, 300, src)
	popup.set_content(dat)
	popup.open()

	onclose(user, "circuit2")

	return



/obj/item/device/assembly/comparison/Topic(href, href_list)
	if(..())
		return

	if(href_list["change_check_type"])
		var/choice = input(usr, "Select a new check type for \the [src].", "\The [src]") as null|anything in comparison_circuit_operations

		if(isnull(choice))
			return
		if(..())
			return

		to_chat(usr, "<span class='info'>You change the check from [check_type] to [choice].</span>")

		check_type = choice

	//Trigger warning: horrible code below

	if(href_list["change_check_this"])
		var/choice = input(usr, "Select a new checked value #1 for \the [src].", "\The [src]") as null|anything in (device_pool + "Constant number" + "Constant string") //Select an assembly, or "Constant number"

		if(isnull(choice))
			return
		if(..())
			return

		if(choice == "Constant number") //Selected "Constant number" - ask the user to specify a number
			var/new_num = input(usr, "Please type in a number that will be used as value #1.", "\The [src]") as null|num

			if(isnull(new_num))
				return
			if(..())
				return

			check_this = new_num
			checked_value_1 = null

			to_chat(usr, "<span class='info'>Value #1 set to be [check_this]</span>")
		else if(choice == "Constant string")
			var/new_txt = stripped_input(usr, "Please type in a string that will be used as value #1.", "\The [src]", max_length = MAX_TEXT_VALUE_LEN) as null|text

			if(isnull(new_txt)) return
			if(..()) return

			check_this = new_txt
			checked_value_1 = null

			to_chat(usr, "<span class='info'>Value #1 set to be \"[check_this]\"</span>")
		else //Selected an assembly - ask the user to select a value
			var/obj/item/device/assembly/A = choice
			if(!istype(A))
				return

			if(!A.accessible_values || !A.accessible_values.len) //No accessible values
				to_chat(usr, "<span class='info'>\The [A] has no accessible values.")
				return

			var/new_value = input(usr, "Select which of \the [A]'s values is used as \the [src]'s value #1.", "\The [src]") as null|anything in A.accessible_values

			if(isnull(new_value))
				return
			if(..())
				return

			/*//Check if the selected value is a number

			var/new_values_params = A.accessible_values[new_value]
			var/list/L = params2list(new_values_params)
			if(L[VALUE_VARIABLE_TYPE] != "number")
				to_chat(usr, "<span class='info'>Only numbers may be used in \the [src].</span>")
				return
			*/ //Let's try permitting strings to be used

			//Just some more sanity
			if(!device_pool.Find(choice))
				return

			//Finally we're here

			check_this = choice
			checked_value_1 = new_value

			to_chat(usr, "<span class='info'>Value #1 set to be [check_this] - [checked_value_1]</span>")

	if(href_list["change_check_against"]) //Copy of the above, with some slight tweaks
		var/choice = input(usr, "Select a new checked value #2 for \the [src].", "\The [src]") as null|anything in (device_pool + "Constant number" + "Constant string") //Select an assembly, or "Constant number"

		if(isnull(choice))
			return
		if(..())
			return

		if(choice == "Constant number") //Selected "Constant number" - ask the user to specify a number
			var/new_num = input(usr, "Please type in a number that will be used as value #2.", "\The [src]") as null|num

			if(isnull(new_num))
				return
			if(..())
				return

			check_against = new_num
			checked_value_2 = null

			to_chat(usr, "<span class='info'>Value #2 set to be [check_against]</span>")
		else if(choice == "Constant string")
			var/new_txt = stripped_input(usr, "Please type in a string that will be used as value #2.", "\The [src]", max_length = MAX_TEXT_VALUE_LEN) as null|text

			if(isnull(new_txt)) return
			if(..()) return

			check_against = new_txt
			checked_value_2 = null

			to_chat(usr, "<span class='info'>Value #2 set to be \"[check_against]\"</span>")
		else //Selected an assembly - ask the user to select a value
			var/obj/item/device/assembly/A = choice
			if(!istype(A))
				return

			if(!A.accessible_values || !A.accessible_values.len) //No accessible values
				to_chat(usr, "<span class='info'>\The [A] has no accessible values.")
				return

			var/new_value = input(usr, "Select which of \the [A]'s values is used as \the [src]'s value #2.", "\The [src]") as null|anything in A.accessible_values

			if(isnull(new_value))
				return
			if(..())
				return

			//Check if the selected value is a number

			var/new_values_params = A.accessible_values[new_value]
			var/list/L = params2list(new_values_params)
			if(L[VALUE_VARIABLE_TYPE] != "number")
				to_chat(usr, "<span class='info'>Only numbers may be used in \the [src].</span>")
				return

			//Just some more sanity
			if(!device_pool.Find(choice))
				return

			//Finally we're here

			check_against = choice
			checked_value_2 = new_value

			to_chat(usr, "<span class='info'>Value #2 set to be [check_against] - [checked_value_2]</span>")

	if(href_list["change_pulse_if_true"])
		var/choice = input(usr, "Select an assembly that will be pulsed if the condition is true.", "\The [src]") as null|anything in (device_pool + "Nothing")

		if(!choice)
			return
		if(..())
			return

		if(choice == "Nothing")
			pulse_if_true = null
		else
			if(!device_pool.Find(choice))
				return

			pulse_if_true = choice

		to_chat(usr, "<span class='info'>If the condition is true, [pulse_if_true ? pulse_if_true : "nothing"] will be pulsed.</span>")

	if(href_list["change_pulse_if_false"])
		var/choice = input(usr, "Select an assembly that will be pulsed if the condition is false.", "\The [src]") as null|anything in (device_pool + "Nothing")

		if(!choice)
			return
		if(..())
			return

		if(choice == "Nothing")
			pulse_if_false = null
		else
			if(!device_pool.Find(choice))
				return

			pulse_if_false = choice

		to_chat(usr, "<span class='info'>If the condition is false, [pulse_if_false ? pulse_if_false : "nothing"] will be pulsed.</span>")


	if(usr)
		attack_self(usr)

/obj/item/device/assembly/comparison/write_to_value(value, new_value)
	switch(value)
		//Shitcode warning
		//Special cases for Device 1 and Device 2 variables - they can work both as numbers and as pointers. Turn them into numbers if there's no accessed value data for them
		if(VALUE_DEVICE_1)
			if(!checked_value_1 && isnum(new_value))
				set_value("check_this", new_value)
				return

		if(VALUE_DEVICE_2)
			if(!checked_value_2 && isnum(new_value))
				set_value("check_against", new_value)
				return

	return ..()

/obj/item/device/assembly/comparison/set_value(var_name, new_value)
	if(var_name == "check_type")
		if(!comparison_circuit_operations.Find(new_value)) //Not a valid operation
			return

	return ..(var_name, new_value)

/obj/item/device/assembly/comparison/connected(var/obj/item/device/assembly/A, in_frame)
	..()

	device_pool |= A //Make the connected assembly available

/obj/item/device/assembly/comparison/disconnected(var/obj/item/device/assembly/A, in_frame)
	..()

	//Remove all references and make the disconnected assembly unavailable
	device_pool.Remove(A)
	if(check_this == A)
		check_this = 1
	if(check_against == A)
		check_against = 1
	if(pulse_if_true == A)
		pulse_if_true = null
	if(pulse_if_false == A)
		pulse_if_false = null

#undef VALUE_OPERATION
#undef VALUE_CHECK_1
#undef VALUE_CHECK_2
#undef VALUE_DEVICE_1
#undef VALUE_DEVICE_2
#undef VALUE_PULSE_IF_TRUE
#undef VALUE_PULSE_IF_FALSE
