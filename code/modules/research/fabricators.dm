#define FAB_SCREEN_WIDTH		1040
#define FAB_SCREEN_HEIGHT		750

#define FAB_TIME_BASE			5
#define FAB_MAX_QUEUE			20

#define FAB_MAT_BASEMOD			100


/obj/machinery/r_n_d/fabricator
	desc = "A fabricator. What kind, you don't know."
	idle_power_usage = 20
	active_power_usage = 5000

	var/time_coeff = 1 //can be upgraded with research
	var/resource_coeff = 1 //can be upgraded with research
	max_material_storage = 562500 //All this could probably be done better with a list but meh.

	var/datum/research/files
	var/id
	var/sync = 0
	var/amount = 5
	var/build_number = 8

	var/obj/being_built
	build_time = FAB_TIME_BASE //time modifier for each machine. Protolathes have low time variable, mechfabs have high
	var/list/queue = list()
	var/processing_queue = 0
	var/screen = 0
	var/temp
	var/list/part_sets = list()
	var/datum/design/last_made
	var/start_end_anims = 0
	var/min_cap_C = 0.1 //The minimum cap used to how much cost coeff can be improved
	var/min_cap_T = 0.1 //The minimum cap used to how much time coeff can be improved
	var/fabricator_cooldown = 2 //In deciseconds, the delay between each item starting to be built

	machine_flags	= SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EMAGGABLE | MULTIOUTPUT
	research_flags = TAKESMATIN | HASOUTPUT | HASMAT_OVER | NANOTOUCH

/obj/machinery/r_n_d/fabricator/New()
	. = ..()
	//for(var/part_set in part_sets)
		//convert_part_set(part_set)

	files = new /datum/research(src) //Setup the research data holder.
	setup_part_sets()

/obj/machinery/r_n_d/fabricator/update_icon()
	..()
	if(being_built && (icon_state != "[base_state]_ani"))
		icon_state = "[base_state]_ani"

/obj/machinery/r_n_d/fabricator/examine(mob/user)
	..()
	if(being_built)
		to_chat(user, "<span class='info'>It's building \a [being_built].</span>")
	else
		to_chat(user, "<span class='info'>Nothing's being built.</span>")

/obj/machinery/r_n_d/fabricator/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating - 1
	max_material_storage = (initial(max_material_storage)+(T * 187500))

	T = 0
	var/datum/tech/Tech = files.known_tech["materials"]
	for(var/obj/item/weapon/stock_parts/manipulator/Ma in component_parts)
		T += Ma.rating - 1
	resource_coeff = max(round(initial(resource_coeff) - (initial(resource_coeff)*((Tech.level - 1)+(T * 2)))/25,0.01), min_cap_C)

	T = 0
	Tech = files.known_tech["programming"]
	for(var/obj/item/weapon/stock_parts/micro_laser/Ml in component_parts)
		T += Ml.rating - 1
	time_coeff = max(round(initial(time_coeff) - (initial(time_coeff)*((Tech.level - 1)+(T * 3)))/25,0.01), min_cap_T)

/obj/machinery/r_n_d/fabricator/emag_act()
	sleep()
	if(!(research_flags & ACCESS_EMAG))
		return
	switch(emagged)
		if(0)
			emagged = 0.5
			visible_message("[bicon(src)] <b>[src]</b> beeps: \"DB error \[Code 0x00F1\]\"")
			sleep(10)
			visible_message("[bicon(src)] <b>[src]</b> beeps: \"Attempting auto-repair\"")
			sleep(15)
			visible_message("[bicon(src)] <b>[src]</b> beeps: \"User DB corrupted \[Code 0x00FA\]. Truncating data structure...\"")
			sleep(30)
			visible_message("[bicon(src)] <b>[src]</b> beeps: \"User DB truncated. Please contact your Nanotrasen system operator for future assistance.\"")
			req_access = null
			emagged = 1
		if(0.5)
			visible_message("[bicon(src)] <b>[src]</b> beeps: \"DB not responding \[Code 0x0003\]...\"")
		if(1)
			visible_message("[bicon(src)] <b>[src]</b> beeps: \"No records in User DB\"")
	return

//takes all the items in a list, and gets the ones which aren't designs and turns them into designs
//basically, we call this whenever we add something that isn't a design to part_sets
/obj/machinery/r_n_d/fabricator/proc/convert_part_set(set_name as text)
	var/list/parts = part_sets[set_name]
	var/i = 0
	if(istype(parts, /list))
		for(var/thispart in parts)
			i++
			if(!thispart)
				parts.Remove(thispart)
				continue
			if(ispath(thispart) && !istype(thispart, /datum/design))
				var/datum/design/design = FindDesign(thispart)
				if(istype(design))
					parts[i] = design
				else
					parts.Remove(thispart)
			//debug below
			/*
			if(!istype(parts[i], /datum/design))
				parts.Cut(i, i++) //quick, sweep it under the rug
			*/
	return

//creates a set with the name and the list of things you give it
/obj/machinery/r_n_d/fabricator/proc/setup_part_sets()
	if(!part_sets || !part_sets.len)
		return

	var/counter = 0

	for(var/name_set in part_sets)
		var/list/part_set = part_sets[name_set]
		if(!istype(part_set) || !part_set.len)
			continue
		for(var/i = 1; i <= part_set.len; i++)
			var/datum/design/D = FindDesign(part_set[i])
			if(D)
				part_set[i] = D
				counter++

	for(var/name_set in part_sets)
		var/list/part_set = part_sets[name_set]
		for(var/element in part_set)
			if(!istype(element, /datum/design))
				warning("[element] was left over in setting up parts.")
				part_set.Remove(element)

	counter += convert_designs() //fill the rest of the way with the designs we get at base research - essentially a starting sync

	return counter

/obj/machinery/r_n_d/fabricator/process()
	..()
	if(busy || being_built || stat&(NOPOWER|BROKEN|FORCEDISABLE))
		return
	if(stopped)
		if(auto_make && last_made && !queue.len)
			add_to_queue(last_made)
			start_processing_queue()
		else
			return
	if(queue.len==0)
		stop_processing_queue()
		return

/obj/machinery/r_n_d/fabricator/proc/queue_pop()
	var/datum/design/D = queue[1]
	queue.Cut(1, 2)
	return D

//adds a design to a part list
/obj/machinery/r_n_d/fabricator/proc/add_part_to_set(set_name as text, var/datum/design/part)
	if(!part || !istype(part))
		return 0

	var/list/part_set_list = part_sets[set_name]
	if(!part_set_list)
		part_set_list = list()
	for(var/datum/design/D in part_set_list)
		if(D.build_path == part.build_path)
			// del part
			return 0
	part_set_list.Add(part)
	part_sets[set_name] = part_set_list.Copy()
	part_set_list.len = 0
	return 1

//deletes an entire part set from part_sets
/obj/machinery/r_n_d/fabricator/proc/remove_part_set(set_name as text)
	for(var/i=1,i<=part_sets.len,i++)
		if(part_sets[i]==set_name)
			part_sets.Remove(part_sets[i])
			return 1
	return

/obj/machinery/r_n_d/fabricator/proc/remove_part_from_set(set_name as text, var/datum/design/part)
	var/part_set = part_sets[set_name]
	part_set -= part
	return 1

//gets all the mats for a design, and returns a formatted string
/obj/machinery/r_n_d/fabricator/proc/output_part_cost(var/datum/design/part)
	var/output = ""
	for(var/M in part.materials)
		if(copytext(M,1,2) == "$")
			if(!(research_flags & IGNORE_MATS))
				var/datum/material/material=materials.getMaterial(M)
				output += "[output ? " | " : null][get_resource_cost_w_coeff(part,M)] [material.processed_name]"
		else
			if(!(research_flags & IGNORE_CHEMS))
				output += "[output ? " | " : null][get_resource_cost_w_coeff(part,M)] [chemical_reagents_list[M]]"
	return output

/obj/machinery/r_n_d/fabricator/proc/remove_materials(var/datum/design/part)
	for(var/M in part.materials)
		if(!check_mat(part, M))
			return 0

	for(var/M in part.materials)
		if(copytext(M,1,2) == "$" && !(research_flags & IGNORE_MATS))
			materials.removeAmount(M, get_resource_cost_w_coeff(part, M))

		else if(!(research_flags & IGNORE_CHEMS))
			var/left_to_remove = get_resource_cost_w_coeff(part, M)
			for(var/obj/item/weapon/reagent_containers/RC in component_parts)
				var/remove_amount = min(RC.reagents.get_reagent_amount(M), left_to_remove)
				RC.reagents.remove_reagent(M, remove_amount)
				left_to_remove -= remove_amount
				if(left_to_remove <= 0)
					break
			update_buffer_size()

	return 1

/obj/machinery/r_n_d/fabricator/proc/has_bluespace_bin()
	var/I = /obj/item/weapon/stock_parts/matter_bin/adv/super/bluespace
	//return (I in component_parts)
	return locate(I,component_parts)

//steals mats from other fabricators, then calls remove_materials again
/obj/machinery/r_n_d/fabricator/proc/bluespace_materials(var/datum/design/part)
	if(!has_bluespace_bin())
		return 0

	for (var/obj/machinery/r_n_d/fabricator/gibmats in machines)
		if(gibmats.has_bluespace_bin())
			for(var/gib in part.materials)
				if (gibmats.check_mat(part,gib) && !check_mat(part,gib))//they have what we need && we don't need more
					if(copytext(gib,1,2) == "$" && !(research_flags & IGNORE_MATS))
						var/bluespaceamount = get_resource_cost_w_coeff(part, gib)
						gibmats.materials.removeAmount(gib,bluespaceamount)
						materials.addAmount(gib,bluespaceamount)
	return remove_materials(part)

//Returns however much of that material we have
/obj/machinery/r_n_d/fabricator/proc/check_mats(var/material)
	if(copytext(material,1,2) == "$")//It's iron/gold/glass
		return materials.getAmount(material)
	else
		var/reagent_total = 0
		for(var/obj/item/weapon/reagent_containers/RC in component_parts)
			reagent_total += RC.reagents.get_reagent_amount(material)
		return reagent_total

//Returns however much of that material is in the bluespace network
/obj/machinery/r_n_d/fabricator/proc/check_mats_bluespace(var/material)
	if(!has_bluespace_bin()) //We can't access that
		return 0

	var/amount
	for(var/obj/machinery/r_n_d/fabricator/gibmats in machines)
		if(gibmats.has_bluespace_bin())
			amount += gibmats.materials.getAmount(material)
	return amount


/obj/machinery/r_n_d/fabricator/proc/check_mat(var/datum/design/being_built, var/M)
	if(copytext(M,1,2) == "$")
		if(research_flags & IGNORE_MATS)
			return 1
		return round(materials.storage[M] / get_resource_cost_w_coeff(being_built, M))
	else
		if(research_flags & IGNORE_CHEMS)
			return 1
		var/reagent_total = 0
		for(var/obj/item/weapon/reagent_containers/RC in component_parts)
			reagent_total += RC.reagents.get_reagent_amount(M)
		return round(reagent_total / get_resource_cost_w_coeff(being_built, M))

//The build_part_loop fires independently and will build stuff until the queue is over or when it is stopped.
/obj/machinery/r_n_d/fabricator/proc/build_part_loop()
	if(busy || stopped || being_built || stat&(NOPOWER|BROKEN|FORCEDISABLE) || queue.len == 0)
		return
	var/datum/design/D = queue_pop()
	if(!build_part(D))
		if(D)
			queue.Add(D)
		stop_processing_queue()
	sleep(fabricator_cooldown)
	build_part_loop()

/obj/machinery/r_n_d/fabricator/proc/build_part(var/datum/design/part)
	if(!part || being_built) //we're in the middle of something here!
		return

	if(!part.build_path)
		WARNING("[part.name] has a null build path var!")
		return
	if(is_contraband(part) && !hacked)
		stopped = 1
		visible_message("<span class='notice'>The [name] buzzes, \"Safety procedures prevent current queued item from being built.\"</span>")
		return

	if(!remove_materials(part) && !bluespace_materials(part))
		stopped = 1
		visible_message("<span class='notice'>The [name] beeps, \"Not enough materials to complete item.\"</span>")
		return

	being_built = new part.build_path(src)

	busy = 1
	icon_state = "[base_state]_ani"
	if(start_end_anims)
		flick("[base_state]_start",src)
	use_power = MACHINE_POWER_USE_ACTIVE
	updateUsrDialog()
	//message_admins("We're going building with [get_construction_time_w_coeff(part)]")
	sleep(get_construction_time_w_coeff(part))
	use_power = MACHINE_POWER_USE_IDLE
	icon_state = base_state
	if(start_end_anims)
		flick("[base_state]_end",src)
	if(being_built)
		if(!being_built.materials)
			being_built.materials = new /datum/materials(being_built)
		for(var/matID in part.materials)
			if(copytext(matID, 1, 2) != "$") //it's not a material, let's ignore it
				continue
			being_built.materials.storage = initial_materials.Copy()
			being_built.materials.addAmount(matID, get_resource_cost_w_coeff(part,matID)) //slap in what we built with - matching the cost
		if(part.locked && research_flags &LOCKBOXES)
			var/obj/item/weapon/storage/lockbox/L
			//if(research_flags &TRUELOCKS)
			L = new/obj/item/weapon/storage/lockbox/oneuse(src) //Make a lockbox
			L.req_one_access = part.req_lock_access //we set the access from the design
			/*
			else
				L = new /obj/item/weapon/storage/lockbox/unlockable(src) //Make an unlockable lockbox
			*/
			being_built.forceMove(L) //Put the thing in the lockbox
			L.name += " ([being_built.name])"
			being_built = L //Building the lockbox now, with the thing in it
		part.after_craft(being_built,src)
		var/turf/output = get_output()
		being_built.forceMove(get_turf(output))
		being_built.anchored = 0
		if(arcanetampered)
			if(prob(90))
				qdel(being_built)
				being_built = new /obj/item/weapon/bikehorn/rubberducky(get_turf(output)) // BONUS DUCKS! No material refunds
			else
				being_built.arcane_act(usr)
		visible_message("[bicon(src)] \The [src] beeps: \"Successfully completed \the [being_built.name].\"")
		being_built = null
		last_made = part
		wires.SignalIndex(RND_WIRE_JOBFINISHED)
	updateUsrDialog()
	busy = 0
	return 1

/obj/machinery/r_n_d/fabricator/arcane_act(mob/user)
	..()
	return "B'NUS D'CKS!"

//max_length is, from the top of the list, the parts you want to queue down to
/obj/machinery/r_n_d/fabricator/proc/add_part_set_to_queue(set_name, max_length)
	var/list/set_parts = part_sets[set_name]
	if(set_name in part_sets)
		for(var/i = 1; i <= set_parts.len; i++)
			if(max_length > 0 &&  i > max_length)
				break
			var/datum/design/D = set_parts[i]
			add_to_queue(D)
	visible_message("[bicon(src)] <b>[src]</b> beeps: \"[replacetext(set_name, "_", " ")] parts were added to the queue\".")
	return

/obj/machinery/r_n_d/fabricator/proc/add_to_queue(var/datum/design/part)
	if(!istype(queue))
		queue = list()
	if(!part)
		return
	if(part)
		if(is_contraband(part) && !hacked)
			visible_message("<span class='notice'>The [name] buzzes, \"Safety procedures prevent that item from being queued.\"</span>")
			return
		queue.Add(part)
	return queue.len

/obj/machinery/r_n_d/fabricator/proc/remove_from_queue(index)
	if(!isnum(index) || !istype(queue) || (index<1 || index>queue.len))
		return 0
	queue.Cut(index,++index)
	return 1

/obj/machinery/r_n_d/fabricator/proc/is_contraband(var/datum/design/part)
	return

/obj/machinery/r_n_d/fabricator/proc/convert_designs()
	if(!files)
		return
	var/i = 0
	for(var/datum/design/D in files.known_designs)
		if(D.build_type & build_number)
			if(D.category in part_sets)//Checks if it's a valid category
				if(add_part_to_set(D.category, D))//Adds it to said category
					i++
			else
				if(add_part_to_set("Misc", D))//If in doubt, chunk it into the Misc
					i++
	return i

/obj/machinery/r_n_d/fabricator/proc/update_tech()
	if(!files)
		return
	var/output
	var/diff
	var/datum/tech/T = files.known_tech["materials"]
	if(T && T.level > 1)
		var/pmat = 0//Calculations to make up for the fact that these parts and tech modify the same thing
		for(var/obj/item/weapon/stock_parts/manipulator/Ma in component_parts)
			pmat += Ma.rating - 1
		diff = max(round(initial(resource_coeff) - (initial(resource_coeff)*((T.level - 1)+(pmat*2)))/25,0.01), min_cap_C)
		if(resource_coeff!=diff)
			resource_coeff = diff
			output+="Production efficiency increased.<br>"
	T = files.known_tech["programming"]
	if(T && T.level > 1)
		var/ptime = 0
		for(var/obj/item/weapon/stock_parts/micro_laser/Ml in component_parts)
			ptime += Ml.rating - 1
		diff = max(round(initial(time_coeff) - (initial(time_coeff)*((T.level - 1)+(ptime*3)))/25,0.1), min_cap_T)
		if(time_coeff!=diff)
			time_coeff = diff
			output+="Production routines updated.<br>"
	return output


/obj/machinery/r_n_d/fabricator/proc/sync(silent=null)
	var/new_data=0
	var/found = 0
	var/obj/machinery/computer/rdconsole/console
	if(busy)
		visible_message("[bicon(src)] <b>[src]</b> beeps, \"Please wait for completion of current operation.\"")
		return
	if(linked_console)
		console = linked_console
	else
		visible_message("[bicon(src)] <b>[src]</b> beeps, \"Not connected to a server. Please connect from a local console first.\"")
	if(console)
		for(var/ID in console.files.known_tech)
			var/datum/tech/T = console.files.known_tech[ID]
			if(T)
				files.AddTech2Known(T)
		for(var/datum/design/D in console.files.known_designs)
			if(D)
				files.AddDesign2Known(D)
		files.RefreshResearch()
		var/i = convert_designs()
		var/tech_output = update_tech()
		if(!silent)
			temp = "Processed [i] equipment designs.<br>"
			temp += tech_output
			temp += "<a href='?src=\ref[src];clear_temp=1'>Return</a>"
			updateUsrDialog()
		if(i || tech_output)
			new_data=1
	if(new_data)
		visible_message("[bicon(src)] <b>[src]</b> beeps, \"Successfully synchronized with R&D server. New data processed.\"")
	if(!silent && !found)
		temp = "Unable to connect to local R&D Database.<br>Please check your connections and try again.<br><a href='?src=\ref[src];clear_temp=1'>Return</a>"
	updateUsrDialog()

/obj/machinery/r_n_d/fabricator/kick_act(mob/living/H)
	..()
	if(stopped)
		start_processing_queue()

//Makes the machine start build_part_loop() which will build parts until its conditions no longer allow it to
/obj/machinery/r_n_d/fabricator/proc/start_processing_queue()
	stopped=0
	spawn(0) //This way whatever is calling start_processing_queue won't wait until build_part_loop is finished to continue
		build_part_loop()

// Stop processing queue (currently-executing ticks will finish first).
/obj/machinery/r_n_d/fabricator/proc/stop_processing_queue()
	stopped=1

/obj/machinery/r_n_d/fabricator/proc/get_resource_cost_w_coeff(var/datum/design/part as obj,var/resource as text, var/roundto=1)
	return max(1,round(part.materials[resource]*resource_coeff, roundto))

//produces the adjusted time taken to build a component
//different fabricators have different modifiers
//this is in the works, so expect to edit it over time
//MatTotal is a time modifier based on the total material cost of the design, divided by FAB_MAT_BASEMOD
//build_time is a var unique to each fabricator. It's mostly one, but bigger machines get higher build_time
//time_coeff is set by the machine components
/obj/machinery/r_n_d/fabricator/proc/get_construction_time_w_coeff(var/datum/design/part as obj, var/roundto=1)
	return round(/*TechTotal(part)*/(part.MatTotal()/FAB_MAT_BASEMOD)*build_time*time_coeff, roundto)

/obj/machinery/r_n_d/fabricator/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return
	if(!isAdminGhost(user) && (user.stat || user.restrained()))
		return
	if(!allowed(user) && !emagged)
		return

	var/data[0]
	var/queue_list[0]

	for(var/i=1;i<=queue.len;i++)
		var/datum/design/part = queue[i]
		queue_list.Add(list(list("name" = part.name, "commands" = list("remove_from_queue" = i))))

	data["queue"] = queue_list
	data["screen"]=screen
	var/materials_list[0]
		//Get the material names
	for(var/matID in materials.storage)
		var/datum/material/material = materials.getMaterial(matID) // get the ID of the materials
		if(material && materials.storage[matID] > 0)
			materials_list.Add(list(list("name" = material.processed_name, "storage" = materials.storage[matID], "commands" = list("eject" = matID)))) // get the amount of the materials
	data["materials"] = materials_list

	var/parts_list[0] // setup a list to get all the information for parts

	for(var/set_name in part_sets)
		//message_admins("Assiging parts to [set_name]")
		var/list/parts = part_sets[set_name]
		var/list/set_name_list = list()
		var/i = 0
		for(var/datum/design/part in parts)
			//message_admins("Adding the [part.name] to the list")
			i++
			set_name_list.Add(list(list("name" = part.name, "cost" = output_part_cost(part), "time" = get_construction_time_w_coeff(part)/10, "command1" = list("add_to_queue" = "[i][set_name]"), "command2" = list("build" = "[i][set_name]"))))
		parts_list[set_name] = set_name_list
	data["parts"] = parts_list // assigning the parts data to the data sent to UI

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, nano_file, name, FAB_SCREEN_WIDTH, FAB_SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/r_n_d/fabricator/proc/getTopicDesign(var/stringinput = "")
	var/final_digit = 0
	for(var/i = 1, i <= length(stringinput), i++)
		if(!isnum(text2num(copytext(stringinput, i))))
			//message_admins("Breaking on [copytext(stringinput, i)] and [i]")
			final_digit = i
			break
	var/list/part_list = part_sets[copytext(stringinput, final_digit)]
	var/index = text2num(copytext(stringinput, 1, final_digit))
	//message_admins("From [stringinput] we have [index] and [copytext(stringinput, final_digit)]")
	if(!istype(part_list) || part_list.len < index)
		return 0
	return part_list[index]

/obj/machinery/r_n_d/fabricator/Topic(href, href_list)

	if(..()) // critical exploit prevention, do not remove unless you replace it -walter0o
		return
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1
	var/datum/topic_input/topic_filter = new /datum/topic_input(href,href_list)

	if(href_list["remove_from_queue"])
		remove_from_queue(topic_filter.getNum("remove_from_queue"))
		return 1

	if(href_list["eject"])
		var/num = input("Enter amount to eject", "Amount", "5") as num
		if(num)
			amount = clamp(round(text2num(num), 1), 0, 50)
		remove_material(href_list["eject"], amount)
		return 1

	if(href_list["build"])
		var/datum/design/part = getTopicDesign(href_list["build"])
		if(!processing_queue && part)
			build_part(part)
		return 1

	if(href_list["add_to_queue"])
		var/datum/design/part = getTopicDesign(href_list["add_to_queue"])
		if(queue.len > FAB_MAX_QUEUE)
			visible_message("[bicon(src)] <b>[src]</b> beeps, \"Queue is full, please clear or finish.\".")
			return

		add_to_queue(part)
		return 1

	if(href_list["queue_part_set"])
		var/set_name = href_list["queue_part_set"]
		if(queue.len > FAB_MAX_QUEUE)
			visible_message("[bicon(src)] <b>[src]</b> beeps, \"Queue is full, please clear or finish.\".")
			return
		add_part_set_to_queue(set_name)
		return 1

	if(href_list["clear_queue"])
		stop_processing_queue()
		queue = list()
		return 1

	if(href_list["sync"])
		queue = list()
		temp = "Updating local R&D database..."
		updateUsrDialog()
		spawn(30)
			sync()
		return 1

	if(href_list["process_queue"])
		if(!stopped)
			return 0
		start_processing_queue()
		return 1


	if(href_list["screen"])
		var/prevscreen=screen
		screen = text2num(href_list["screen"])
		if(prevscreen==screen)
			return 0
		ui_interact(usr)
		return 1

/obj/machinery/r_n_d/fabricator/npc_tamper_act(mob/living/L)
	if(!part_sets || !part_sets.len)
		return

	var/list/part_set = part_sets[pick(part_sets)]
	if(!part_set || !part_set.len)
		return

	var/new_design = pick(part_set)
	build_part(new_design)

/obj/machinery/r_n_d/fabricator/attack_hand(mob/user as mob)
	if(!isAdminGhost(user) && (user.stat || user.restrained())) //allowed is later on, so we don't check it
		return

	var/turf/exit = get_output()
	if(exit.density)
		visible_message("[bicon(src)] <b>[src]</b> beeps, \"Error! Part outlet is obstructed\".")
		return

	if(stat & BROKEN)
		return

	if(!allowed(user) && !emagged)
		visible_message("<span class='warning'>Unauthorized Access</span>: attempted by <b>[user]</b>")
		return

	..()

/obj/machinery/r_n_d/fabricator/proc/remove_material(var/matID, var/amount)
	var/datum/material/material = materials.getMaterial(matID)
	if(material)
		//var/obj/item/stack/sheet/res = new material.sheettype(src)
		var/total_amount = min(round(materials.storage[matID]/material.cc_per_sheet), amount)
		var/to_spawn = total_amount

		while(to_spawn > 0)
			var/obj/item/stack/sheet/mats
			if(material.sheettype == /obj/item/stack/sheet/metal)
				mats = new /obj/item/stack/sheet/metal(get_turf(src))
			else
				mats = new material.sheettype(src)
			if(to_spawn > mats.max_amount)
				mats.amount = mats.max_amount
				to_spawn -= mats.max_amount
			else
				mats.amount = to_spawn
				to_spawn = 0

			materials.removeAmount(matID, mats.amount * mats.perunit)
			mats.forceMove(src.loc)
		return total_amount
	return 0

/obj/machinery/r_n_d/fabricator/proc/update_buffer_size()
	return
