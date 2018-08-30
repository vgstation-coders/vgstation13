/obj/item/device/assembly_frame
	name = "assembly frame"
	desc = "A large metal box with a frame inside, designed to store and link tiny assemblies like timers and signalers. There is a display with an interface for connecting assemblies together."

	icon_state = "assembly_box"
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=3;" + Tc_MAGNETS + "=3"

	var/list/obj/item/device/assembly/assemblies = list()

	var/list/connections = list() //Assembly associated with the list of assemblies it's connected to

	var/lock_ejection = 0 //If 1, prevent ejecting assemblies
	var/require_parts_for_import = 1 //If 0, importing doesn't take nearby parts. Instead, required parts are generated out of thin air

/obj/item/device/assembly_frame/admin
	name = "turbo assembly frame"
	require_parts_for_import = 0

/obj/item/device/assembly_frame/Destroy()
	for(var/obj/item/device/assembly/AS in connections)
		var/list/L = connections[AS]

		for(var/DC in L)
			AS.disconnected(DC, in_frame = 1)

	connections = null

	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))

	assemblies = null

	..()

/obj/item/device/assembly_frame/proc/get_assembly_href(var/obj/item/device/assembly/A)
	var/txt_buttons = "<a href='?src=\ref[src];eject=1;assembly=\ref[A]'>\[X\]</a><a href='?src=\ref[src];pulse=1;assembly=\ref[A]'>\[P\]</a><a href='?src=\ref[src];reorder=1;assembly=\ref[A]'>\[M\]</a>"

	var/txt_assembly_number = "([assemblies.Find(A)])"

	var/txt_assembly = "<a href='?src=\ref[src];interact=1;assembly=\ref[A]'><b>[A]</b></a>"

	var/txt_connections
	if(!connections.Find(A))
		txt_connections = "<small>(<a href='?src=\ref[src];connect=1;assembly=\ref[A]'>connect</a>)</small>"
	else
		txt_connections = "<small> [A.connection_text]: "

		var/list/list_of_connections = connections[A]

		if(list_of_connections.len)
			for(var/obj/item/device/assembly/C in list_of_connections)
				txt_connections += "[assemblies.Find(C)]-<a href='?src=\ref[src];disconnect=1;assembly=\ref[A];disconnect_which=\ref[C]'><b>[C.short_name][C.labeled]</b></a>, "

			txt_connections += "<a href='?src=\ref[src];connect=1;assembly=\ref[A]'><b>add more</b></a></small>"

	return "[txt_buttons] [txt_assembly_number] [txt_assembly] [txt_connections]"

///////

/obj/item/device/assembly_frame/attack_self(mob/user)
	var/dat = "<h4>AdCo. Assembly Frame MK II <small>\[<a href='?src=\ref[src];help=1'>?</a>\] \[<a href='?src=\ref[src];lock=1'>[lock_ejection ? "UNLOCK" : "LOCK"]</a>\] \[<a href='?src=\ref[src];export=1'>EXPORT</a>\]</small></h4><br>"

	if(!assemblies.len)
		dat += "<p>No assemblies found!</p>"
	else
		for(var/obj/item/device/assembly/A in assemblies)

			dat += "<p>[get_assembly_href(A)]</p>"

			//Example result:

			//[X][P][M] (1) remote signalling device sending signals to: 2-speaker (alert), 3-timer (countdown), add more
			//[X][P][M] (2) speaker (alert) (connect)
			//[X][P][M] (3) timer (countdown) sending signals to: 4-signaler (radio alert), add more
			//[X][P][M] (4) signaler (radio alert) (connect)

			//Clicking on [X] ejects the assembly
			//Clicking on [P] pulses the assembly
			//Clicking on [M] moves the assembly to a different index (for example clicking 2-[M] and entering 3 will move the speaker to index 3)
			//Clicking on the assembly's name allows you to change its settings (or otherwise interact with it
			//Clicking on (connect) or "add more" allows you to select an assembly to connect to
			//Clicking on any assembly after "sending signals to" will remove the connection

	var/datum/browser/popup = new(user, "\ref[src]", "[src]", 500, 300, src)
	popup.set_content(dat)
	popup.open()

	onclose(user, "\ref[src]")

	return

/obj/item/device/assembly_frame/Topic(href, href_list)
	if(..())
		return

	var/obj/item/device/assembly/AS = locate(href_list["assembly"])
	var/assembly_found = 1
	if(!istype(AS) || !assemblies.Find(AS))
		assembly_found = 0

	if(href_list["lock"])
		lock_ejection = !lock_ejection

		if(lock_ejection)
			to_chat(usr, "<span class='info'>You have locked \the [src]. Assemblies can no longer be ejected.</span>")
		else
			to_chat(usr, "<span class='info'>You have unlocked \the [src]. Assemblies can now be ejected freely.</span>")
	if(href_list["connect"]) //Connect AS to another assembly
		if(!assembly_found)
			return

		var/list/active_connections = connections[AS]

		if(assemblies.len == 1) //Only one assembly in the board (this one) - return
			return

		var/list/list_to_take_from = (assemblies - AS)

		if(active_connections)
			list_to_take_from -= active_connections

		var/list/list_for_input = list()
		for(var/A in list_to_take_from)
			list_for_input["[assemblies.Find(A)]-[A]"] = A //The list is full of strings that are associated with assemblies

		var/choice_input = input(usr, "Send output from [AS] to which device?", "[src]") as null|anything in list_for_input //This input only returns a string with the assembly's number and name
		var/obj/item/device/assembly/choice = list_for_input[choice_input] //Get the ACTUAL assembly object

		if(!choice)
			return
		if(..())
			return

		///////////////Don't do infinite loops kids/////
		if(istype(choice, /obj/item/device/assembly/math) && istype(AS, /obj/item/device/assembly/math)) //Both assemblies are math circuits
			var/list/choices_connections = connections[choice]
			if(choices_connections && (AS in choices_connections)) //If the other assembly is connected to us (and right now we're trying to connect ourselves to it, creating an infinite loop of math)
				to_chat(usr, "<span class='info'>SYSTEM ERROR: Infinite loop detected, operation aborted.</span>")
				return

		////////////////////////////////////////////////

		start_new_connection(AS, choice)

		to_chat(usr, "<span class='info'>You connect \the [AS] to \the [choice].</span>")

	if(href_list["eject"]) //Eject AS from the frame
		if(!assembly_found)
			return

		if(lock_ejection)
			to_chat(usr, "<span class='info'>\The [src] is locked! You must unlock it before ejecting any assemblies.</span>")
			return

		eject_assembly(AS)

		to_chat(usr, "<span class='info'>You remove \the [AS] from \the [src].</span>")

	if(href_list["pulse"])
		if(!assembly_found)
			return

		if(AS.loc != src)
			to_chat(usr, "<span class='warning'>A green light flashes on \the [src], indicating an error.</span>")
			return

		AS.pulsed()

	if(href_list["reorder"])
		if(!assembly_found)
			return

		if(AS.loc != src)
			to_chat(usr, "<span class='warning'>A purple light flashes on \the [src], indicating an error.</span>")
			return

		var/new_index = input("Enter a new index for \the [assemblies.Find(AS)]-[AS].") as null|num
		if(isnull(new_index))
			return
		if(..())
			return

		new_index = Clamp(new_index, 1, assemblies.len)

		assemblies.Remove(AS)
		assemblies.Insert(new_index, AS)

	if(href_list["interact"])
		if(!assembly_found)
			return

		AS.attack_self(usr)
		return

	if(href_list["export"])
		//Find a blank sheet of paper on the same turf, export to it
		var/obj/item/weapon/paper/P

		for(var/obj/item/weapon/paper/check in get_turf(src))
			if(check.info)
				continue

			P = check
			break

		if(!P)
			to_chat(usr, "<span class='notice'>Unable to export configuration: unable to find an empty paper sheet.</span>")
			return

		P.info = to_text()
		P.update_icon()

		to_chat(usr, "<span class='info'>Configuration exported successfully.</span>")

	if(href_list["disconnect"]) //Remove link from AS to specified assembly
		var/obj/item/device/assembly/disconnected = locate(href_list["disconnect_which"]) //Find assembly to disconnect from AS

		disconnect_assembly_from(AS, disconnected)

	if(href_list["help"])
		//Here comes the fluff
		spawn(2)
			to_chat(usr, "<span class='notice'>You press \the [src]'s help button.</span>")
			sleep(5)
			to_chat(usr, "----------------------------------")
			to_chat(usr, "<span class='info'><h5>AdCo. Assembly Frame MK II</h5></span>")
			to_chat(usr, "----------------------------------")
			sleep(5)
			to_chat(usr, "<span class='info'>To connect a device to the assembly frame, insert it into any of the numbered sockets inside.</span>")
			to_chat(usr, "<span class='info'>The device list on the monitor displays all connected devices along with their number. To the right of each device is a list of other devices that are connected to it.</span>")
			to_chat(usr, "<span class='info'>To make device A send signals to device B, first ensure that both devices are connected to the assembly frame. Then press the \"connect\" button next to device A on the monitor, and select device B. Any signals emitted by device A will now be received by device B (but not vice versa).</span>")
			to_chat(usr, "<span class='info'>To stop device A from receiving device B's signals, find device B in the device list. To the right of device B is a list of other devices that are connected to it. Find device A in that list and select it. Device A will no longer receive signals from device B.</span>")
			to_chat(usr, "<span class='info'>To pulse a device, press the \[P\] button next to it.</span>")
			to_chat(usr, "<span class='info'>To eject a device, press the \[X\] button next to it. To prevent yourself from accidentally ejecting important devices, lock the assembly frame by pressing on the LOCK button.</span>")
			to_chat(usr, "<span class='info'>To change a device's index, press the \[M\] button next to it.</span>")
			to_chat(usr, "----------------------------------")
			to_chat(usr, "<span class='info'>To export the device data to a sheet of paper, place a blank paper sheet under the assembly frame and press the \[<b>EXPORT</b>\] button. The sheet of paper will then contain complete information about the inserted devices and the connections between them.</span>")
			to_chat(usr, "<span class='info'>To import the device data from a sheet of paper, place all the necessary devices under an empty assembly frame and insert the paper with the exported device data into the assembly frame. As long as all necessary devices are present and the data isn't corrupted, the frame will automatically assemble, link and set up everything.</span>")

		return

	if(usr)
		attack_self(usr)

/obj/item/device/assembly_frame/proc/receive_pulse(var/obj/item/device/assembly/from)
	if(!assemblies.Find(from))
		return
	if(!connections.Find(from))
		return

	var/list/connected_to_source = connections[from]

	from.send_pulses_to_list(connected_to_source)



/obj/item/device/assembly_frame/attackby(obj/item/W, mob/user)
	..()

	if(istype(W, /obj/item/device/assembly))
		insert_assembly(W, user)

	else if(istype(W, /obj/item/device/assembly_holder))
		to_chat(user, "<span class='notice'>\The [W] is too big for any of the sockets here. Try taking it apart.")
		return

	if(istype(W, /obj/item/weapon/paper))

		to_chat(user, "<span class='info'>You start inserting \the [W] into \the [src].</span>")

		spawn()
			if(do_after(user, src, 30))
				if(assemblies.len || connections.len)
					to_chat(user, "<span class='notice'>Unable to import configuration: the assembly frame must be empty.</span>")
					return

				var/obj/item/weapon/paper/P = W
				var/turf/T = get_turf(src)
				var/list/used_parts = T.contents.Copy()

				var/assembly_data = P.info
				//Clean all the <span> tags
				assembly_data = replacetext(assembly_data, "</span>", "")

				if(copytext(assembly_data, 1,2) == "<") //Text starts with an opening <span> tag
					var/last_span = findtext(assembly_data, ">")
					if(last_span)
						assembly_data = copytext(assembly_data, last_span + 1) //Cut it off

				var/from_text_result = from_text(assembly_data, require_parts_for_import, used_parts)
				if(from_text_result == 1)
					to_chat(user, "<span class='info'>Configuration imported successfully.</span>")
					message_admins("[key_name_admin(user)] has imported a configuration with [assemblies.len] elements into an assembly frame! [formatJumpTo(get_turf(src))]")
				else if(from_text_result == null)
					to_chat(user, "<span class='notice'>Unable to import configuration: corrupt input data.</span>")
				else if(from_text_result == 0)
					to_chat(user, "<span class='notice'>Unable to import configuration: encountered an error while enstablishing device connections.</span>")
				else if(islist(from_text_result))
					to_chat(user, "<span class='notice'>Unable to import configuration: missing parts: [english_list(from_text_result)].")
		return 1

/obj/item/device/assembly_frame/proc/insert_assembly(obj/item/device/assembly/AS, mob/user = null)
	if(!istype(AS))
		return

	if(istype(user) || ismob(AS.loc))
		if(!user)
			user = AS.loc
		if(user.drop_item(AS, src))
			AS.holder = src
			assemblies.Add(AS)

	else if(istype(AS.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = AS.loc
		if(S.remove_from_storage(AS, src))
			AS.holder = src
			assemblies.Add(AS)

	else //Make sure to remove the thing properly BEFORE calling insert_assembly, in this case
		if(AS.forceMove(src))
			AS.holder = src
			assemblies.Add(AS)

	if(!AS.secured)
		AS.toggle_secure() //Make it secured

/obj/item/device/assembly_frame/proc/start_new_connection(obj/item/device/assembly/new_parent, obj/item/device/assembly/orphan)
	var/list/active_connections = connections[new_parent
	]
	if(!active_connections) //If there ISN'T a list with connections
		connections[new_parent] = list(orphan) //Make a new one
	else
		active_connections |= orphan

	new_parent.connected(orphan, in_frame = 1)

/obj/item/device/assembly_frame/proc/disconnect_assembly_from(obj/item/device/assembly/parent, obj/item/device/assembly/child_to_disown)
	if(!istype(parent) || !istype(child_to_disown))
		return

	var/list/L = connections[parent] //Find list of assemblies connected to the parent

	if(!L)
		return

	L.Remove(child_to_disown) //Remove the disconnected assembly from that list
	parent.disconnected(child_to_disown, in_frame = 1)

	if(!L.len) //If parent isn't connected to anything, remove parent from the list of assemblies with connections
		connections.Remove(parent)

/obj/item/device/assembly_frame/proc/eject_assembly(obj/item/device/assembly/AS) //Disconnect an assembly from everything, then remove it
	for(var/A in connections) //Remove all references to this assembly in this board
		var/list/L = connections[A]
		L.Remove(AS)

		var/obj/item/device/assembly/disconnected_from = A
		disconnected_from.disconnected(AS, in_frame = 1)
		AS.disconnected(disconnected_from, in_frame = 1)

		if(!L.len) //If list of A's connections is empty
			connections.Remove(A) //Remove A from the list of assemblies with connections

	assemblies.Remove(AS)
	connections.Remove(AS)

	AS.holder = null
	AS.forceMove(get_turf(src))

/obj/item/device/assembly_frame/proc/to_text() //Return a string that contains all information necessary to copy this assembly. Hoo boy. Probably slow as fuck due to all the string operations. Also designed to be somewhat human-readable.
	var/list/mainholder = list() //For holdiing the top-level list with everything in it.
	for(var/obj/item/device/assembly/AS in assemblies)
		var/list/midholder = list()
		midholder.Add(AS.short_name)
		midholder.Add(AS.labeled && copytext(AS.labeled, 3, -1)) //A && B is a shortcut for A ? B : A, so this adds AS.labeled if it is falsy and just the part of AS.labeled within the parentheses otherwise.
		var/list/subholder = list()
		for(var/V in AS.accessible_values)
			subholder[V] = AS.get_value(V)
		midholder.Add(list2params(subholder))
		var/list/L = connections[AS]
		if(L)
			subholder = list()
			for(var/A in L)
				subholder.Add(assemblies.Find(A))
			midholder.Add(jointext(subholder, ";"))
		else
			midholder.Add("")
		mainholder.Add(jointext(midholder, "|"))
	return jointext(mainholder, "<BR>")

/obj/item/device/assembly_frame/proc/debug_to_text() //Spawns a paper with the to_text data
	var/obj/item/weapon/paper/P = new(get_turf(src))
	P.info = to_text()

//Fills and sets up the assembly frame from the string given by to_text(). Only works if the frame is empty.
//assembly_data is the string given by to_text. use_parts is whether or not to get assemblies from an atom's contents, otherwise simply creating them. parts_from is the list of available assemblies to grab if use_parts is true.
//Defaults to simply making the assemblies appear, in which case only assembly_data need be provided.
//If use_parts is set to 1, parts_from must be given.
//Returns:
// 1 if successful;
// a list of missing parts if it fails due to a lack of assemblies;
// 0 if the frame already has something in it;
// null if assembly_data is invalid or something weird happens.
//Still returns 1 if there is a non-fatal error, such as invalid value or data type for a value. This may be fixed later.
//MAKE SURE the assemblies in parts_from are located in a mob, a storage item, or something that won't have problems if items are just forceMove()d from its contents.
//If that isn't possible, make insert_assembly() work properly with the atom assemblies are being removed from or remove the required assemblies first.
/obj/item/device/assembly_frame/proc/from_text(assembly_data, use_parts = 0, list/obj/item/device/assembly/parts_from = null)
	if(assemblies.len || connections.len)
		return 0
	if(!assembly_data)
		return
	if(use_parts && !istype(parts_from))
		return

	var/list/data_list = decompose_text(assembly_data)
	if(isnull(data_list)) //If decompose_text() found any problems with the text, go ahead and stop.
		return

	var/list/obj/item/device/assembly/parts_to_add = list()

	if(!use_parts)
		var/list/req_parts = get_req_parts(data_list)
		if(isnull(req_parts)) //If any parts were invalid, stop.
			return
		for(var/req_part in req_parts)
			parts_to_add.Add(new req_part)

	else
		var/list/obj/item/device/assembly/parts_from_holder = parts_from.Copy() //I cannot fucking believe this is necessary, but here we are.
		var/list/missing_parts
		find_parts:
			for(var/list/req_part in data_list)
				var/req_part_short_name = req_part["short_name"]
				for(var/obj/item/device/assembly/check_part in parts_from_holder)
					if(req_part_short_name == check_part.short_name)
						parts_to_add.Add(check_part)
						parts_from_holder.Remove(check_part)
						continue find_parts
				if(!missing_parts)
					missing_parts = list()
				missing_parts.Add(req_part_short_name)
		if(missing_parts)
			return missing_parts

	for(var/obj/item/device/assembly/AS in parts_to_add)
		insert_assembly(AS)
		var/cur_pos = parts_to_add.Find(AS)
		var/list/a_data = data_list[cur_pos]
		AS.remove_label()
		AS.labeled = a_data["labeled"]
		AS.name += AS.labeled //Someday when I clean up my hand labeler shitcode I'll make an add_label proc that handles this too
		var/list/a_values = a_data["values"]
		for(var/a_value in a_values)
			AS.write_to_value(a_value, a_values[a_value])
		var/list/a_cons = a_data["connections"]

		if(a_cons.len)
			//var/list/obj/item/device/assembly/active_connections = list()
			for(var/a_con in a_cons)
				if(a_con == cur_pos)
					continue
				//active_connections |= parts_to_add[a_con]
				start_new_connection(AS, parts_to_add[a_con])
			//connections[AS] = active_connections
	return 1

//Converts the text from to_text into a list containing the information of the text.
//Returns this list if successful, of course.
//Returns null if assembly_data is invalid in any immediately-obvious way
//Each value in the main list is an associated list as follows:
//The key "short_name" has the value of this assembly's short_name.
//The key "labeled" has the value that this assembly's labeled var should be set to.
//The key "values" has another associated list as its value. The keys are entries in this assembly's accessible_values list and the values are what they should be set to. All values that are just numbers are converted to num, as write_to_value() will turn them back into strings if it should.
//The key "connections" has a list as its value. This list contains the indices in the assemblies list of the assemblies that this assembly should be connected to.
/obj/item/device/assembly_frame/proc/decompose_text(assembly_data)
	if(!istext(assembly_data))
		return null
	var/list/mainholder = splittext(assembly_data, "<BR>")
	. = list()
	for(var/a_data in mainholder)
		var/list/subholder = splittext(a_data, "|")
		if(subholder.len != 4) //A valid string for this purpose will always contain exactly four chunks of information per assembly, even if some are empty.
			return null
		if(!subholder[1]) //This is the only part that cannot be empty. Note that this does not check if it is a valid assembly short_name; normally, that is either done in get_req_parts() or irrelevant because invalid short_names shouldn't appear.
			return null
		var/list/rlistholder = list()
		rlistholder["short_name"] = subholder[1]
		rlistholder["labeled"] = subholder[2] && " ([subholder[2]])" //A && B is a shortcut for A ? B : A, so this adds subholder[2] if it is falsy and subholder[2] surrounded by parentheses and with a space before otherwise.
		if(subholder[3]) //This can be empty and still valid, but the check inside would disagree.
			var/list/valuesholder = params2list(subholder[3])
			for(var/value in valuesholder)
				var/numvalue = text2num(valuesholder[value])
				if(isnull(numvalue)) //If num2text doesn't work, leave the string be.
					continue
				if("[numvalue]" == valuesholder[value]) //Only change the string to a number if the whole string is the number. Necessary because text2num() always returns a number if the first character of the string is a number, even if the rest isn't.
					valuesholder[value] = numvalue
			rlistholder["values"] = valuesholder
		else
			rlistholder["values"] = list()
		if(subholder[4]) //No connections? No problem.
			var/list/connectionsholder_text = splittext(subholder[4], ";")
			var/list/connectionsholder_num = list()
			for(var/num in connectionsholder_text)
				var/numholder = text2num(num)
				if(!numholder) //It shouldn't be zero (not a valid position for an assembly) and it definitely shouldn't be null.
					return null
				if(numholder > mainholder.len) //There can't be an assembly at an index higher than the number of assemblies.
					return null
				connectionsholder_num.Add(numholder)
			rlistholder["connections"] = connectionsholder_num
		else
			rlistholder["connections"] = list()
		. += list(rlistholder) //So the actual rlistholder is added rather than its elements

//Accepts a list returned by decompose_text().
//Returns a list of the types of the assemblies the list calls for, unless the list calls for an invalid assembly, in which case it returns null.
//The returned list contains one entry per part in the given list, in the same order. Multiple of the same type of assembly means multiple copies of the type returned.
//NOTE: This does NOT check if the called-for assemblies are ones that should ever actually exist. It will not return null if asked for the base assembly type, infrared tripwires, etc.
//This is not a problem as long as from_text() is called with use_parts = 1, as those assemblies are unobtainable and thus the construction will fail elsewhere.
//However, this means that the ability to call, in any way, from_text() with use_parts = 0 should be restricted to admins and *maybe* trusted players unless extra checks are added.
/obj/item/device/assembly_frame/proc/get_req_parts(list/data_list)

	if(!assembly_short_name_to_type.len) //Populate the list the first time someone calls this proc
		for(var/assembly_path in typesof(/obj/item/device/assembly))
			var/obj/item/device/assembly/assembly_type = assembly_path//So I can use the undocumented behavior of initial() to retrieve the value without initializing the object.
			assembly_short_name_to_type[initial(assembly_type.short_name) || initial(assembly_type.name)] = assembly_path //I personally believe that this behavior of initial() was actually an accident on the part of the BYOND devs, but it's useful so whatever.

	. = list()
	for(var/list/part in data_list)
		var/assembly_path = assembly_short_name_to_type[part["short_name"]]
		if(!assembly_path)
			return null
		. += assembly_path

/obj/item/device/assembly_frame/proc/debug_from_text(use_parts = 0)
	var/obj/item/weapon/paper/P = locate() in loc
	var/list/parts_from = list()
	if(use_parts)
		var/obj/item/weapon/storage/box/B = locate() in loc
		parts_from = B.contents
	return from_text(P.info, use_parts, parts_from)
