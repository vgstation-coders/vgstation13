//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter. It also contains the /datum/research holder with all the known/possible technology paths and device designs.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The imprinting and construction menus do NOT require toxins access to access but all the other menus do. However, if you leave it
on a menu, nothing is to stop the person from using the options on that menu (although they won't be able to change to a different
one). You can also lock the console on the settings menu if you're feeling paranoid and you don't want anyone messing with it who
doesn't have toxins access.

When a R&D console is destroyed or even partially disassembled, you lose all research data on it. However, there are two ways around
this dire fate:
- The easiest way is to go to the settings menu and select "Sync Database with Network." That causes it to upload (but not download)
it's data to every other device in the game. Each console has a "disconnect from network" option that'll will cause data base sync
operations to skip that console. This is useful if you want to make a "public" R&D console or, for example, give the engineers
a circuit imprinter with certain designs on it and don't want it accidentally updating. The downside of this method is that you have
to have physical access to the other console to send data back. Note: An R&D console is on CentCom so if a random griffan happens to
cause a ton of data to be lost, an admin can go send it back.
- The second method is with Technology Disks and Design Disks. Each of these disks can hold a single technology or design datum in
it's entirety. You can then take the disk to any R&D console and upload it's data to it. This method is a lot more secure (since it
won't update every console in existence) but it's more of a hassle to do. Also, the disks can be stolen.


*/
#define RESEARCH_MAX_Q_LEN 30
/obj/machinery/computer/rdconsole
	name = "R&D Console"
	icon_state = "rdcomp"
	circuit = "/obj/item/weapon/circuitboard/rdconsole"
	var/datum/research/files							//Stores all the collected research data.
	var/obj/item/weapon/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/weapon/disk/design_disk/d_disk = null	//Stores the design disk.

	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/r_n_d/fabricator/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/r_n_d/fabricator/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

	var/list/obj/machinery/linked_machines = list()
	var/list/research_machines = list(
		/obj/machinery/r_n_d/fabricator/protolathe,
		/obj/machinery/r_n_d/destructive_analyzer,
		/obj/machinery/r_n_d/fabricator/circuit_imprinter,
		/obj/machinery/r_n_d/fabricator/mech,
		/obj/machinery/r_n_d/fabricator/pod,
		/obj/machinery/r_n_d/fabricator/mechanic_fab,
		/obj/machinery/r_n_d/fabricator/mechanic_fab/flatpacker,
		/obj/machinery/r_n_d/reverse_engine,
		/obj/machinery/r_n_d/blueprinter
		)
	var/screen = 1.0	//Which screen is currently showing.
	var/id = 0			//ID of the computer (for server restrictions).
	var/sync = 1		//If sync = 0, it doesn't show up on Server Control Console

	var/list/filtered = list( //Filters categories in the protolathe menu
		"protolathe" = list(),
		"imprinter" = list()
	)
	var/autorefresh = 1 //Prevents the window from being updated while queueing items

	req_access = list(access_rnd)	//Data and setting manipulation requires scientist access.

	starting_materials = list()

	light_color = LIGHT_COLOR_PINK

	var/part_sets = list(
		"Stock Parts" = list(),
		"Bluespace" = list(),
		"Anomaly" = list(),
		"Data" = list(),
		"Engineering" = list(),
		"Medical" = list(),
		"Surgery" = list(),
		"Mining" = list(),
		"Robotics" = list(),
		"Weapons" = list(),
		"Armor" = list(),
		"Misc" = list(),
		)

/obj/machinery/computer/rdconsole/Destroy()
	. = ..()
	for(var/obj/machinery/r_n_d/R in linked_machines)
		R.linked_console = null
		linked_machines -= R
		R.update_icon()

	if(linked_destroy)
		linked_destroy.linked_console	= null
		linked_destroy.update_icon()
		linked_destroy					= null

	if(linked_imprinter)
		linked_imprinter.linked_console	= null
		linked_imprinter.update_icon()
		linked_imprinter				= null

	if(linked_lathe)
		linked_lathe.linked_console		= null
		linked_lathe.update_icon()
		linked_lathe					= null

/obj/machinery/computer/rdconsole/proc/Maximize()
	files.known_tech = tech_list.Copy()
	for(var/datum/tech/KT in files.known_tech)
		if(KT.level < KT.max_level)
			KT.level=KT.max_level

/obj/machinery/computer/rdconsole/proc/CallTechName(var/ID) //A simple helper proc to find the name of a tech with a given ID.
	var/datum/tech/check_tech
	var/return_name = ""

	for (var/T in typesof(/datum/tech) - /datum/tech)
		check_tech = T

		if (initial(check_tech.id) == ID)
			return_name = initial(check_tech.name)
			break

	return return_name

/obj/machinery/computer/rdconsole/proc/CallMaterialName(var/ID)
	var/return_name = null
	if (copytext(ID, 1, 2) == "$")
		var/datum/material/mat = materials.getMaterial(ID)
		return mat.processed_name
	else
		for(var/R in typesof(/datum/reagent) - /datum/reagent)
			var/datum/reagent/T = new R()
			if(T.id == ID)
				return_name = T.name
				break
	return return_name

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	var/area/this_area = get_area(src)
	if(!isarea(this_area) || isspace(this_area))
		say("Unable to process synchronization")
		return


	for(var/obj/machinery/r_n_d/D in rnd_machines) //any machine in the room, just for funsies
		var/area/D_area = get_area(D)
		if(D.linked_console != null || D.disabled || D.panel_open || !D_area || (D_area != this_area))
			continue
		if(D.type in research_machines)
			linked_machines += D
			D.linked_console = src
			D.update_icon()
	for(var/obj/machinery/r_n_d/D in linked_machines)
		if(linked_lathe && linked_destroy && linked_imprinter)
			break // stop if we have all of our linked
		switch(D.type)
			if(/obj/machinery/r_n_d/fabricator/protolathe)
				if(!linked_lathe)
					linked_lathe = D
			if(/obj/machinery/r_n_d/destructive_analyzer)
				if(!linked_destroy)
					linked_destroy = D
			if(/obj/machinery/r_n_d/fabricator/circuit_imprinter)
				if(!linked_imprinter)
					linked_imprinter = D
	if(linked_lathe)
		linked_lathe.part_sets = part_sets
	return

//Have it automatically push research to the centcomm server so wild griffins can't fuck up R&D's work --NEO
/obj/machinery/computer/rdconsole/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in machines)
		for(var/datum/tech/T in files.known_tech)
			C.files.AddTech2Known(T)
		for(var/datum/design/D in files.known_designs)
			C.files.AddDesign2Known(D)
		C.files.RefreshResearch()


/obj/machinery/computer/rdconsole/New()
	..()
	files = new /datum/research(src) //Setup the research data holder.
	if(!id)
		for(var/obj/machinery/r_n_d/server/centcom/S in machines)
			S.initialize()
			break

/obj/machinery/computer/rdconsole/initialize()
	SyncRDevices()

/*	Instead of calling this every tick, it is only being called when needed
/obj/machinery/computer/rdconsole/process()
	griefProtection()
*/

/obj/machinery/computer/rdconsole/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
	if(..())
		return
	if(istype(D, /obj/item/weapon/disk))
		if(t_disk || d_disk)
			to_chat(user, "A disk is already loaded into the machine.")
			return

		if(istype(D, /obj/item/weapon/disk/tech_disk))
			if(user.drop_item(D,src))
				t_disk = D
		else if (istype(D, /obj/item/weapon/disk/design_disk))
			if(user.drop_item(D,src))
				d_disk = D
		else
			to_chat(user, "<span class='warning'>Machine cannot accept disks in that format.</span>")
			return

		to_chat(user, "<span class='notice'>You add the disk to the machine!</span>")

	src.updateUsrDialog()
	return

/obj/machinery/computer/rdconsole/emag(mob/user)
	playsound(src, 'sound/effects/sparks4.ogg', 75, 1)
	emagged = 1
	if(user)
		to_chat(user, "<span class='notice'>You disable the security protocols</span>")

/obj/machinery/computer/rdconsole/proc/deconstruct_item(mob/user)
	if(!linked_destroy || linked_destroy.busy || !linked_destroy.loaded_item)
		return
	if(isLocked() || (linked_destroy.stat & (NOPOWER|BROKEN)) || (stat & (NOPOWER|BROKEN)))
		return
	linked_destroy.busy = 1
	screen = 0.1
	updateUsrDialog()
	flick("d_analyzer_process", linked_destroy)

	spawn(24)
		if(linked_destroy)
			if(!linked_destroy.hacked)
				if(!linked_destroy.loaded_item)
					to_chat(user, "<span class='warning'>The destructive analyzer appears to be empty.</span>")
					screen = 1.0
					linked_destroy.busy = 0
					return
				if(linked_destroy.loaded_item.reliability >= 90)
					var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
					for(var/T in temp_tech)
						files.UpdateTech(T, temp_tech[T])
				if(linked_destroy.loaded_item.reliability < 100 && linked_destroy.loaded_item.crit_fail)
					files.UpdateDesign(linked_destroy.loaded_item.type)
				if(linked_lathe && linked_destroy.loaded_item.materials) //Also sends salvaged materials to a linked protolathe, if any.
					for(var/matID in linked_destroy.loaded_item.materials.storage) //Transfers by ID
						linked_lathe.materials.addAmount(matID, linked_destroy.loaded_item.materials.storage[matID])
				linked_destroy.loaded_item = null
			for(var/obj/I in linked_destroy.contents)
				for(var/mob/M in I.contents)
					M.death()
				if(istype(I,/obj/item/stack/sheet)) //Only deconstructs one sheet at a time instead of the entire stack
					var/obj/item/stack/sheet/S = I
					if(S.amount > 1)
						S.amount--
						linked_destroy.loaded_item = S
					else
						qdel(S)
						S = null
						linked_destroy.icon_state = "d_analyzer"
				else
					if(!(I in linked_destroy.component_parts))
						qdel(I)
						I = null
						linked_destroy.icon_state = "d_analyzer"
			use_power(250)
			screen = 1.0
			updateUsrDialog()
			linked_destroy.busy = 0

/obj/machinery/computer/rdconsole/Topic(href, href_list)
	if(..())
		return

	var/updateAfter = 1 //STOP

	add_fingerprint(usr)

	if(isLocked() && !allowed(usr))
		to_chat(usr, "Unauthorized Access.")
		return

	usr.set_machine(src)

	if(href_list["menu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		var/temp_screen = text2num(href_list["menu"])
		if(temp_screen <= 1.1 || (2 <= temp_screen && 4.9 >= temp_screen) || src.allowed(usr) || emagged) //Unless you are making something, you need access.
			screen = temp_screen
		else
			to_chat(usr, "Unauthorized Access.")

	else if(href_list["updt_tech"]) //Update the research holder with information from the technology disk.
		screen = 0.0
		spawn(50)
			screen = 1.2
			files.AddTech2Known(t_disk.stored)
			if(t_disk.stored.new_category && !(t_disk.stored.new_category in part_sets))
				part_sets += t_disk.stored.new_category
				part_sets[t_disk.stored.new_category] = list()
				if(linked_lathe)
					linked_lathe.part_sets = part_sets
			updateUsrDialog()
			griefProtection() //Update centcomm too

	else if(href_list["hax"]) // aww shit
		if(!usr.client.holder)
			return
		if (alert("Are you sure you want to do this? This will maximize every research level!", "Admin R&D console Hax.", "Yes", "No") != "Yes")
			return TRUE
		screen = 0.0
		spawn(50)
			Maximize()
			screen = 1.0
			updateUsrDialog()
			griefProtection() //Update centcomm too

	else if(href_list["clear_tech"]) //Erase data on the technology disk.
		t_disk.stored = null

	else if(href_list["eject_tech"]) //Eject the technology disk.
		t_disk:forceMove(src.loc)
		t_disk = null
		screen = 1.0

	else if(href_list["copy_tech"]) //Copys some technology data from the research holder to the disk.
		for(var/datum/tech/T in files.known_tech)
			if(href_list["copy_tech_ID"] == T.id)
				t_disk.stored = T
				break
		screen = 1.2

	else if(href_list["updt_design"]) //Updates the research holder with design data from the design disk.
		screen = 0.0
		spawn(50)
			screen = 1.4
			files.AddDesign2Known(d_disk.blueprint)
			updateUsrDialog()
			griefProtection() //Update centcomm too

	else if(href_list["clear_design"]) //Erases data on the design disk.
		d_disk.blueprint = null

	else if(href_list["eject_design"]) //Eject the design disk.
		d_disk:forceMove(src.loc)
		d_disk = null
		screen = 1.0

	else if(href_list["copy_design"]) //Copy design data from the research holder to the design disk.
		for(var/datum/design/D in files.known_designs)
			if(href_list["copy_design_ID"] == D.id)
				d_disk.blueprint = D
				break
		screen = 1.4

	else if(href_list["eject_item"]) //Eject the item inside the destructive analyzer.
		if(linked_destroy)
			if(linked_destroy.busy)
				to_chat(usr, "<span class='warning'>The destructive analyzer is busy at the moment.</span>")

			else if(linked_destroy.loaded_item)
				linked_destroy.loaded_item.forceMove(linked_destroy.loc)
				linked_destroy.loaded_item = null
				linked_destroy.icon_state = "d_analyzer"
				screen = 2.1

	else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
		if(linked_destroy)
			if(linked_destroy.busy)
				to_chat(usr, "<span class='warning'>The destructive analyzer is busy at the moment.</span>")
			else
				var/choice = input("Proceeding will destroy loaded item.") in list("Proceed", "Cancel")
				if(choice == "Cancel" || !linked_destroy)
					return

				deconstruct_item(usr)

	else if(href_list["lock"]) //Lock the console from use by anyone without tox access.
		if(src.allowed(usr))
			screen = text2num(href_list["lock"])
		else
			to_chat(usr, "Unauthorized Access.")

	else if(href_list["sync"]) //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
		screen = 0.0
		if(!sync)
			to_chat(usr, "<span class='warning'>You must connect to the network first!</span>")
		else
			griefProtection() //Putting this here because I dont trust the sync process
			spawn(30)
				if(src)
					for(var/obj/machinery/r_n_d/server/S in machines)
						var/server_processed = 0
						if(S.disabled)
							continue
						if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
							for(var/datum/tech/T in files.known_tech)
								S.files.AddTech2Known(T)
							for(var/datum/design/D in files.known_designs)
								S.files.AddDesign2Known(D)
							S.files.RefreshResearch()
							server_processed = 1
						if(((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom)) || S.hacked)
							for(var/datum/tech/T in S.files.known_tech)
								files.AddTech2Known(T)
							for(var/datum/design/D in S.files.known_designs)
								files.AddDesign2Known(D)
							files.RefreshResearch()
							server_processed = 1
						if(!istype(S, /obj/machinery/r_n_d/server/centcom) && server_processed)
							S.produce_heat(100)
					screen = 1.6
					updateUsrDialog()

	else if(href_list["togglesync"]) //Prevents the console from being synced by other consoles. Can still send data.
		sync = !sync

	else if(href_list["build"]) //Causes the Protolathe to build something.
		if (!autorefresh)
			updateAfter = 0 //STOP
		if(linked_lathe)
			var/datum/design/being_built = null
			for(var/datum/design/D in files.known_designs)
				if(D.id == href_list["build"])
					being_built = D
					break
			if(being_built)
				var/power = 2000
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] / 5)
				power = max(2000, power)
				//screen = 0.3
				var/n
				if (href_list["customamt"])
					n = round(input("Queue how many? (Maximum [RESEARCH_MAX_Q_LEN - linked_lathe.queue.len])", "Protolathe Queue") as num|null)
					if (!linked_lathe)
						return //in case the 'lathe gets unlinked or destroyed or someshit while the popup is open
				else
					n = text2num(href_list["n"])
				n = Clamp(n, 0, RESEARCH_MAX_Q_LEN - linked_lathe.queue.len)
				for(var/i=1;i<=n;i++)
					use_power(power)
					linked_lathe.queue += being_built
				if(href_list["now"]=="1")
					linked_lathe.stopped=0

	else if(href_list["imprint"]) //Causes the Circuit Imprinter to build something.
		if (!autorefresh)
			updateAfter = 0 //STOP
		if(linked_imprinter)
			var/datum/design/being_built = null

			if(linked_imprinter.queue.len >= RESEARCH_MAX_Q_LEN)
				to_chat(usr, "<span class=\"warning\">Maximum number of items in production queue exceeded.</span>")
				return

			for(var/datum/design/D in files.known_designs)
				if(D.id == href_list["imprint"])
					being_built = D
					break
			if(being_built)
				var/power = 2000
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] / 5)
				power = max(2000, power)
				var/n
				if (href_list["customamt"])
					n = round(input("Queue how many? (Maximum [RESEARCH_MAX_Q_LEN - linked_imprinter.queue.len])", "Circuit Imprinter Queue") as num|null)
					if (!linked_imprinter)
						return //in case the imprinter gets unlinked or destroyed or someshit while the popup is open
				else
					n = text2num(href_list["n"])
				n = Clamp(n, 0, RESEARCH_MAX_Q_LEN - linked_imprinter.queue.len)
				for(var/i=1;i<=n;i++)
					linked_imprinter.queue += being_built
					use_power(power)
				if(href_list["now"]=="1")
					linked_imprinter.stopped=0

	else if(href_list["disposeI"] && linked_imprinter)  //Causes the circuit imprinter to dispose of a single reagent (all of it)
		if(!src.allowed(usr))
			to_chat(usr, "Unauthorized Access.")
			return
		var/obj/item/weapon/reagent_containers/RC = locate(href_list["beakerI"])
		if(RC && RC in linked_imprinter.component_parts)
			RC.reagents.del_reagent(href_list["disposeI"])
		linked_imprinter.update_buffer_size()

	else if(href_list["disposeallI"] && linked_imprinter) //Causes the circuit imprinter to dispose of all it's reagents.
		if(!src.allowed(usr))
			to_chat(usr, "Unauthorized Access.")
			return
		if(alert("Are you sure you want to flush all reagents?", "Reagents Purge Confirmation", "Continue", "Cancel") == "Continue")
			for(var/obj/item/weapon/reagent_containers/RC in linked_imprinter.component_parts)
				RC.reagents.clear_reagents()
			linked_imprinter.update_buffer_size()

	else if(href_list["removeQItem"]) //Causes the protolathe to dispose of all it's reagents.
		var/i=text2num(href_list["removeQItem"])
		switch(href_list["device"])
			if("protolathe")
				if(linked_lathe)
					linked_lathe.queue.Cut(i,i+1)
			if("imprinter")
				if(linked_imprinter)
					linked_imprinter.queue.Cut(i,i+1)

	else if(href_list["clearQ"]) //Causes the protolathe to dispose of all it's reagents.
		switch(href_list["device"])
			if("protolathe")
				if(linked_lathe)
					linked_lathe.queue.len = 0
			if("imprinter")
				if(linked_imprinter)
					linked_imprinter.queue.len = 0

	else if(href_list["setProtolatheStopped"] && linked_lathe) //Causes the protolathe to dispose of all it's reagents.
		linked_lathe.stopped=(href_list["setProtolatheStopped"]=="1")

	else if(href_list["setImprinterStopped"] && linked_imprinter) //Causes the protolathe to dispose of all it's reagents.
		linked_imprinter.stopped=(href_list["setImprinterStopped"]=="1")

	else if(href_list["lathe_ejectsheet"] && linked_lathe) //Causes the protolathe to eject a sheet of material
		if(!src.allowed(usr))
			to_chat(usr, "Unauthorized Access.")
			return
		var/desired_num_sheets = text2num(href_list["lathe_ejectsheet_amt"])
		if (desired_num_sheets <= 0)
			return
		var/matID=href_list["lathe_ejectsheet"]
		var/datum/material/M=linked_lathe.materials.getMaterial(matID)
		if(!istype(M))
			warning("PROTOLATHE: Unknown material [matID]! ([href])")
		else
			var/obj/item/stack/sheet/sheet = new M.sheettype(linked_lathe.get_output())
			var/available_num_sheets = round(linked_lathe.materials.storage[matID]/sheet.perunit)
			if(available_num_sheets>0)
				sheet.amount = min(available_num_sheets, desired_num_sheets)
				linked_lathe.materials.removeAmount(matID, sheet.amount * sheet.perunit)
			else
				qdel (sheet)
				sheet = null
	else if(href_list["imprinter_ejectsheet"] && linked_imprinter) //Causes the protolathe to eject a sheet of material
		if(!src.allowed(usr))
			to_chat(usr, "Unauthorized Access.")
			return
		var/desired_num_sheets = text2num(href_list["imprinter_ejectsheet_amt"])
		if (desired_num_sheets <= 0)
			return
		var/matID=href_list["imprinter_ejectsheet"]
		var/datum/material/M=linked_imprinter.materials.getMaterial(matID)
		if(!istype(M))
			warning("IMPRINTER: Unknown material [matID]! ([href])")
		else
			var/obj/item/stack/sheet/sheet = new M.sheettype(linked_imprinter.get_output())
			var/available_num_sheets = round(linked_imprinter.materials.storage[matID]/sheet.perunit)
			if(available_num_sheets>0)
				sheet.amount = min(available_num_sheets, desired_num_sheets)
				linked_imprinter.materials.removeAmount(matID, sheet.amount * sheet.perunit)
			else
				qdel (sheet)
				sheet = null

	else if(href_list["find_device"]) //The R&D console looks for devices nearby to link up with.
		screen = 0.0
		spawn(20)
			SyncRDevices()
			screen = 1.7
			updateUsrDialog()

	else if(href_list["disconnect"]) //The R&D console disconnects with a specific device.
		switch(href_list["disconnect"])
			if("destroy")
				linked_destroy.linked_console = null
				linked_destroy.update_icon()
				linked_destroy = null
			if("lathe")
				linked_lathe.linked_console = null
				linked_lathe.update_icon()
				linked_lathe = null
			if("imprinter")
				linked_imprinter.linked_console = null
				linked_imprinter.update_icon()
				linked_imprinter = null

	else if(href_list["reset"]) //Reset the R&D console's database.
		griefProtection()
		var/choice = alert("R&D Console Database Reset", "Are you sure you want to reset the R&D console's database? Data lost cannot be recovered.", "Continue", "Cancel")
		if(choice == "Continue")
			screen = 0.0
			qdel(files)
			files = new /datum/research(src)
			spawn(20)
				screen = 1.6
				updateUsrDialog()

	else if(href_list["toggleCategory"]) //Filter or unfilter a category
		var/cat = href_list["toggleCategory"]
		var/machine = href_list["machine"]
		if (cat in filtered[machine])
			filtered[machine] -= cat
		else
			filtered[machine] += cat

	else if(href_list["toggleAllCategories"]) //Filter all categories, if all are filtered, clear filter.
		var/machine = href_list["machine"]
		var/list/tempfilter = filtered[machine] //t-thanks BYOND
		if(tempfilter.len == (machine == "protolathe" ? linked_lathe.part_sets.len : linked_imprinter.part_sets.len))
			filtered[machine] = list()
		else
			filtered[machine] = list()
			if (machine == "protolathe")
				for(var/name_set in linked_lathe.part_sets)
					filtered[machine] += name_set
			else
				for(var/name_set in linked_imprinter.part_sets)
					filtered[machine] += name_set

	else if(href_list["toggleAutoRefresh"]) //STOP
		autorefresh = !autorefresh

	if (updateAfter)
		updateUsrDialog()
	return

/obj/machinery/computer/rdconsole/proc/protolathe_header()
	var/list/options=list()
	if(screen!=3.1)
		options += "<A href='?src=\ref[src];menu=3.1'>Design Selection</A>"
	if(screen!=3.2)
		options += "<A href='?src=\ref[src];menu=3.2'>Material Storage</A>"
	if(screen!=3.4)
		options += "<A href='?src=\ref[src];menu=3.4'>Production Queue</A> ([linked_lathe.queue.len])"
	return {"\[<A href='?src=\ref[src];menu=1.0'>Main Menu</A>\]
	<div class="header">[jointext(options," || ")]</div><hr />"}

/obj/machinery/computer/rdconsole/proc/CircuitImprinterHeader()
	var/list/options=list()
	if(screen!=4.1)
		options += "<A href='?src=\ref[src];menu=4.1'>Design Selection</A>"
	if(screen!=4.3)
		options += "<A href='?src=\ref[src];menu=4.3'>Material Storage</A>"
	if(screen!=4.2)
		options += "<A href='?src=\ref[src];menu=4.2'>Chemical Storage</A>"
	if(screen!=4.4)
		options += "<A href='?src=\ref[src];menu=4.4'>Production Queue</A> ([linked_imprinter.queue.len])"
	return {"\[<A href='?src=\ref[src];menu=1.0'>Main Menu</A>\]
	<div class=\"header\">[jointext(options," || ")]</div><hr />"}

/obj/machinery/computer/rdconsole/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	user.set_machine(src)
	var/dat = list("<style>a:link {color: #0066CC} a:visited {color: #0066CC}</style>")
	files.RefreshResearch()
	switch(screen) //A quick check to make sure you get the right screen when a device is disconnected.
		if(2 to 2.9)
			if(linked_destroy == null)
				screen = 2.0
			else if(linked_destroy.loaded_item == null)
				screen = 2.1
			else
				screen = 2.2
		if(3 to 3.9)
			if(linked_lathe == null)
				screen = 3.0
		if(4 to 4.9)
			if(linked_imprinter == null)
				screen = 4.0

	switch(screen)

		//////////////////////R&D CONSOLE SCREENS//////////////////
		if(0.0)
			dat += "Updating Database...."

		if(0.1)
			dat += "Processing and Updating Database..."

		if(0.2)

			dat += {"SYSTEM LOCKED<BR><BR>
				<A href='?src=\ref[src];lock=1.6'>Unlock</A>"}
		if(0.3)
			dat += "Constructing Prototypes. Please Wait..."

		if(0.4)
			dat += "Imprinting Circuit. Please Wait..."

		if(1.0) //Main Menu

			dat += {"Main Menu:<BR><BR>
				<A href='?src=\ref[src];menu=1.1'>Current Research Levels</A><BR>"}
			if(t_disk)
				dat += "<A href='?src=\ref[src];menu=1.2'>Disk Operations</A><BR>"
			else if(d_disk)
				dat += "<A href='?src=\ref[src];menu=1.4'>Disk Operations</A><BR>"
			else
				dat += "(Please Insert Disk)<BR>"
			if(linked_destroy != null)
				dat += "<A href='?src=\ref[src];menu=2.2'>Destructive Analyzer Menu</A><BR>"
			if(linked_lathe != null)
				dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Construction Menu</A><BR>"
			if(linked_imprinter != null)
				dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Construction Menu</A><BR>"
			if(user.client.holder)
				dat += "<A href='?src=\ref[src];hax=1'>MAXIMUM SCIENCE</A><BR>"
			dat += "<A href='?src=\ref[src];menu=1.6'>Settings</A>"

		if(1.1) //Research viewer
			dat += "Current Research Levels:<BR><BR>"
			for(var/datum/tech/T in files.known_tech)

				dat += {"[T.name]<BR>
					* Level: [T.level]<BR>
					* Summary: [T.desc]<HR>"}
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(1.2) //Technology Disk Menu


			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>
				Disk Contents: (Technology Data Disk)<BR><BR>"}
			if(t_disk.stored == null)

				dat += {"The disk has no data stored on it.<HR>
					Operations:
					<A href='?src=\ref[src];menu=1.3'>Load Tech to Disk</A> || "}
			else

				dat += {"Name: [t_disk.stored.name]<BR>
					Level: [t_disk.stored.level]<BR>
					Description: [t_disk.stored.desc]<HR>
					Operations:
					<A href='?src=\ref[src];updt_tech=1'>Upload to Database</A> ||
					<A href='?src=\ref[src];clear_tech=1'>Clear Disk</A> || "}
			dat += "<A href='?src=\ref[src];eject_tech=1'>Eject Disk</A>"

		if(1.3) //Technology Disk submenu

			dat += {"<BR><A href='?src=\ref[src];menu=1.0'>Main Menu</A> ||
				<A href='?src=\ref[src];menu=1.2'>Return to Disk Operations</A><HR>
				Load Technology to Disk:<BR><BR>"}
			for(var/datum/tech/T in files.known_tech)

				dat += {"[T.name]
					<A href='?src=\ref[src];copy_tech=1;copy_tech_ID=[T.id]'>(Copy to Disk)</A><BR>"}
		if(1.4) //Design Disk menu.
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			if(d_disk.blueprint == null)

				dat += {"The disk has no data stored on it.<HR>
					Operations:
					<A href='?src=\ref[src];menu=1.5'>Load Design to Disk</A> || "}
			else

				dat += {"Name: [d_disk.blueprint.name]<BR>
					Level: [Clamp(d_disk.blueprint.reliability + rand(-15,15), 0, 100)]<BR>"}
				switch(d_disk.blueprint.build_type)
					if(IMPRINTER)
						dat += "Lathe Type: Circuit Imprinter<BR>"
					if(PROTOLATHE)
						dat += "Lathe Type: Proto-lathe<BR>"
					if(AUTOLATHE)
						dat += "Lathe Type: Auto-lathe<BR>"
				dat += "Required Materials:<BR>"
				for(var/M in d_disk.blueprint.materials)
					if(copytext(M, 1, 2) == "$")
						dat += "* [copytext(M, 2)] x [d_disk.blueprint.materials[M]]<BR>"
					else
						dat += "* [M] x [d_disk.blueprint.materials[M]]<BR>"

				dat += {"<HR>Operations:
					<A href='?src=\ref[src];updt_design=1'>Upload to Database</A> ||
					<A href='?src=\ref[src];clear_design=1'>Clear Disk</A> || "}
			dat += "<A href='?src=\ref[src];eject_design=1'>Eject Disk</A>"

		if(1.5) //Technology disk submenu

			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A> ||
				<A href='?src=\ref[src];menu=1.4'>Return to Disk Operations</A><HR>
				Load Design to Disk:<BR><BR>"}
			for(var/datum/design/D in files.known_designs)

				dat += {"[D.name]
					<A href='?src=\ref[src];copy_design=1;copy_design_ID=[D.id]'>(Copy to Disk)</A><BR>"}
		if(1.6) //R&D console settings

			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>
				R&D Console Setting:<BR><BR>"}
			if(sync)

				dat += {"<A href='?src=\ref[src];sync=1'>Sync Database with Network</A><BR>
					<A href='?src=\ref[src];togglesync=1'>Disconnect from Research Network</A><BR>"}
			else
				dat += "<A href='?src=\ref[src];togglesync=1'>Connect to Research Network</A><BR>"

			dat += {"<A href='?src=\ref[src];menu=1.7'>Device Linkage Menu</A><BR>
				<A href='?src=\ref[src];lock=0.2'>Lock Console</A><BR>
				<A href='?src=\ref[src];reset=1'>Reset R&D Database.</A><BR>"}
		if(1.7) //R&D device linkage

			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A> ||
				<A href='?src=\ref[src];menu=1.6'>Settings Menu</A><HR>
				R&D Console Device Linkage Menu:<BR><BR>
				<A href='?src=\ref[src];find_device=1'>Re-sync with Nearby Devices</A><BR>
				Linked Devices:<BR>"}
			var/remain_link = linked_machines
			if(linked_destroy)
				dat += "* Destructive Analyzer <A href='?src=\ref[src];disconnect=destroy'>(Disconnect)</A><BR>"
				remain_link -= linked_destroy
			else
				dat += "* (No Destructive Analyzer Linked)<BR>"
			if(linked_lathe)
				dat += "* Protolathe <A href='?src=\ref[src];disconnect=lathe'>(Disconnect)</A><BR>"
				remain_link -= linked_lathe
			else
				dat += "* (No Protolathe Linked)<BR>"
			if(linked_imprinter)
				dat += "* Circuit Imprinter <A href='?src=\ref[src];disconnect=imprinter'>(Disconnect)</A><BR>"
				remain_link -= linked_imprinter
			else
				dat += "* (No Circuit Imprinter Linked)<BR>"
			if(remain_link)
				for(var/obj/machinery/r_n_d/R in remain_link)
					dat += "* [R.name] <BR>"

		////////////////////DESTRUCTIVE ANALYZER SCREENS////////////////////////////
		if(2.0)

			dat += {"NO DESTRUCTIVE ANALYZER LINKED TO CONSOLE<BR><BR>
				<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"}
		if(2.1)

			dat += {"No Item Loaded. Standing-by...<BR><HR>
				<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"}
		if(2.2)

			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>
				Deconstruction Menu<HR>
				Name: [linked_destroy.loaded_item.name]<BR>
				Origin Tech:<BR>"}
			var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
			for(var/T in temp_tech)
				dat += "* [CallTechName(T)] [temp_tech[T]]<BR>"

			dat += {"<HR><A href='?src=\ref[src];deconstruct=1'>Deconstruct Item</A> ||
				<A href='?src=\ref[src];eject_item=1'>Eject Item</A> || "}
		/////////////////////PROTOLATHE SCREENS/////////////////////////
		if(3.0)

			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>
				NO PROTOLATHE LINKED TO CONSOLE<BR><BR>"}
		if(3.1)

			dat += protolathe_header()+{"Protolathe Construction Menu \[<A href='?src=\ref[src];toggleAutoRefresh=1'>Auto-Refresh: [autorefresh ? "ON" : "OFF"]</A>\]<HR>"}
			dat += "Filter: "
			for(var/name_set in linked_lathe.part_sets)
				if (name_set in filtered["protolathe"])
					dat += "<A href='?src=\ref[src];toggleCategory=[name_set];machine=["protolathe"]' style='color: #A66300'>[name_set]</a> / "
				else
					dat += "<A href='?src=\ref[src];toggleCategory=[name_set];machine=["protolathe"]' style='color: #0066CC'>[name_set]</a> / "
			dat += "<A href='?src=\ref[src];toggleAllCategories=1;machine=["protolathe"]' style='color: #0066CC'>Filter All</a><HR>"

			for(var/name_set in linked_lathe.part_sets)
				if(name_set in filtered["protolathe"])
					continue
				dat += "<h2>[name_set]</h2><ul>"
				for(var/datum/design/D in files.known_designs)
					if(!(D.build_type & PROTOLATHE) || D.category != name_set)
						continue
					var/temp_dat = "[D.name] [linked_lathe.output_part_cost(D)]"
					var/upTo=10
					for(var/M in D.materials)
						var/num_units_avail=linked_lathe.check_mat(D,M)
						if(num_units_avail)
							upTo = min(upTo, num_units_avail)
						else
							break
					if (upTo)
						dat += {"<li>
							<A href='?src=\ref[src];build=[D.id];n=1;now=1'>[temp_dat]</A> Queue: "}
						if(upTo>=5)
							dat += "<A href='?src=\ref[src];build=[D.id];n=5'>(&times;5)</A>"
						if(upTo>=10)
							dat += "<A href='?src=\ref[src];build=[D.id];n=10'>(&times;10)</A>"
						dat += "<A href='?src=\ref[src];build=[D.id];customamt=1'>(Custom)</A>"
						dat += "</li>"
					else
						dat += "<li>[temp_dat]</li>"
				dat += "</ul>"

		if(3.2) //Protolathe Material Storage Sub-menu

			dat += protolathe_header()+{"Material Storage<ul>"}


			for(var/matID in linked_lathe.materials.storage)
				var/datum/material/M=linked_lathe.materials.getMaterial(matID)
				dat += "<li>[linked_lathe.materials.storage[matID]] cm<sup>3</sup> of [M.processed_name]"
				if(linked_lathe.materials.storage[matID] >= M.cc_per_sheet)
					dat += " - <A href='?src=\ref[src];lathe_ejectsheet=[matID];lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
					if(linked_lathe.materials.storage[matID] >= (M.cc_per_sheet*5))
						dat += "<A href='?src=\ref[src];lathe_ejectsheet=[matID];lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
					dat += "<A href='?src=\ref[src];lathe_ejectsheet=[matID];lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
				else
					dat += " - <em>(Empty)</em>"
				dat += "</li>"
			dat += "</ul>"

		if(3.4) //Protolathe Queue Management
			dat += protolathe_header()+"Production Queue<BR><HR><ul>"
			for(var/i=1;i<=linked_lathe.queue.len;i++)
				var/datum/design/I=linked_lathe.queue[i]
				dat += "<li>Name: [I.name]"
				if(linked_lathe.stopped)
					dat += "<A href='?src=\ref[src];removeQItem=[i];device=protolathe'>(Remove)</A></li>"
			dat += "</ul><A href='?src=\ref[src];clearQ=1;device=protolathe'>Remove All Queued Items</A><br />"
			if(linked_lathe.stopped)
				dat += "<A href='?src=\ref[src];setProtolatheStopped=0' style='color:green'>Start Production</A>"
			else
				dat += "<A href='?src=\ref[src];setProtolatheStopped=1' style='color:red'>Stop Production</A>"

		///////////////////CIRCUIT IMPRINTER SCREENS////////////////////
		if(4.0)

			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>
				NO CIRCUIT IMPRINTER LINKED TO CONSOLE<BR><BR>"}
		if(4.1)

			dat += {"[CircuitImprinterHeader()]
				Circuit Imprinter Menu \[<A href='?src=\ref[src];toggleAutoRefresh=1'>Auto-Refresh: [autorefresh ? "ON" : "OFF"]</A>\]<BR>
				<b>Material Amount:</b> [linked_imprinter.TotalMaterials()] cm<sup>3</sup><BR>
				<b>Chemical Volume:</b> [linked_imprinter.get_total_volume()] units<HR>"}
			dat += "Filter: "
			for(var/name_set in linked_imprinter.part_sets)
				if (name_set in filtered["imprinter"])
					dat += "<A href='?src=\ref[src];toggleCategory=[name_set];machine=["imprinter"]' style='color: #A66300'>[name_set]</a> / "
				else
					dat += "<A href='?src=\ref[src];toggleCategory=[name_set];machine=["imprinter"]' style='color: #0066CC'>[name_set]</a> / "
			dat += "<A href='?src=\ref[src];toggleAllCategories=1;machine=["imprinter"]' style='color: #0066CC'>Filter All</a><HR>"

			for(var/name_set in linked_imprinter.part_sets)
				if(name_set in filtered["imprinter"])
					continue
				dat += "<h2>[name_set]</h2><ul>"
				for(var/datum/design/D in files.known_designs)
					if(!(D.build_type & IMPRINTER) || D.category != name_set)
						continue
					var/temp_dat = "[D.name] [linked_imprinter.output_part_cost(D)]"
					var/upTo=10
					for(var/M in D.materials)
						var/num_units_avail=linked_imprinter.check_mat(D,M)
						if(num_units_avail)
							upTo = min(upTo, num_units_avail)
						else
							break
					if (upTo)
						dat += {"<li><A href='?src=\ref[src];imprint=[D.id];n=1;now=1'>[temp_dat]</A> Queue: "}
						if(upTo>=5)
							dat += "<A href='?src=\ref[src];imprint=[D.id];n=5'>(&times;5)</A>"
						if(upTo>=10)
							dat += "<A href='?src=\ref[src];imprint=[D.id];n=10'>(&times;10)</A>"
						dat += "<A href='?src=\ref[src];imprint=[D.id];customamt=1'>(Custom)</A>"
						dat += "</li>"
					else
						dat += "<li>[temp_dat]</li>"
				dat += "</ul>"

		if(4.2)

			dat += {"[CircuitImprinterHeader()]
				Chemical Storage<HR>"}

			var/beaker_index = 0
			for(var/obj/item/weapon/reagent_containers/RC in linked_imprinter.component_parts)
				beaker_index++
				dat += "<b>Reservoir [beaker_index] &mdash; [RC.name]:</b><BR>"
				if(RC.reagents.reagent_list && RC.reagents.reagent_list.len)
					for(var/datum/reagent/R in RC.reagents.reagent_list)
						dat += {"[R.name] | Units: [R.volume]
							<A href='?src=\ref[src];disposeI=[R.id];beakerI=\ref[RC]'>(Purge)</A><BR>"}
				else
					dat += "<em>(Empty)</em><BR>"
				dat += "<BR>"
			dat += "<A href='?src=\ref[src];disposeallI=1'><U>Disposal All Chemicals in Storage</U></A><BR>"

		if(4.3)

			dat += {"[CircuitImprinterHeader()]
				Material Storage<HR><ul>"}


			for(var/matID in linked_imprinter.materials.storage)
				var/datum/material/M=linked_imprinter.materials.getMaterial(matID)
				if(!(matID in linked_imprinter.allowed_materials))
					continue
				dat += "<li>[linked_imprinter.materials.storage[matID]] cm<sup>3</sup> of [M.processed_name]"
				if(linked_imprinter.materials.storage[matID] >= M.cc_per_sheet)
					dat += " - <A href='?src=\ref[src];imprinter_ejectsheet=[matID];imprinter_ejectsheet_amt=1'>(1 Sheet)</A> "
					if(linked_imprinter.materials.storage[matID] >= (M.cc_per_sheet*5))
						dat += "<A href='?src=\ref[src];imprinter_ejectsheet=[matID];imprinter_ejectsheet_amt=5'>(5 Sheets)</A> "
					dat += "<A href='?src=\ref[src];imprinter_ejectsheet=[matID];imprinter_ejectsheet_amt=50'>(Max Sheets)</A>"
				else
					dat += " - <em>(Empty)</em>"
				dat += "</li>"
			dat += "</ul>"

		if(4.4) //Imprinter Queue Management
			dat += CircuitImprinterHeader()+"Production Queue<BR><HR><ul>"
			for(var/i=1;i<=linked_imprinter.queue.len;i++)
				var/datum/design/I=linked_imprinter.queue[i]
				dat += "<li>Name: [I.name]"
				if(linked_imprinter.stopped)
					dat += "<A href='?src=\ref[src];removeQItem=[i];device=imprinter'>(Remove)</A></li>"
			dat += "</ul><A href='?src=\ref[src];clearQ=1;device=imprinter'>Remove All Queued Items</A><br />"
			if(linked_imprinter.stopped)
				dat += "<A href='?src=\ref[src];setImprinterStopped=0' style='color:green'>Start Production</A>"
			else
				dat += "<A href='?src=\ref[src];setImprinterStopped=1' style='color:red'>Stop Production</A>"

	dat = jointext(dat,"")
	user << browse("<TITLE>Research and Development Console</TITLE><HR>[dat]", "window=rdconsole;size=575x400")
	onclose(user, "rdconsole")

/obj/machinery/computer/rdconsole/proc/isLocked() //magic numbers ahoy!
	return screen == 0.2

/obj/machinery/computer/rdconsole/npc_tamper_act(mob/living/L) //Turn on the destructive analyzer
	//Item making happens when the gremlin tampers with the circuit imprinter / protolathe. They don't need this console for that
	deconstruct_item(L)

/obj/machinery/computer/rdconsole/mommi
	name = "MoMMI R&D Console"
	id = 3
	req_access = list(access_rnd)
	circuit = "/obj/item/weapon/circuitboard/rdconsole/mommi"

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	id = 2
	req_one_access = list(access_robotics)
	req_access=list()
	circuit = "/obj/item/weapon/circuitboard/rdconsole/robotics"

/obj/machinery/computer/rdconsole/mechanic
	name = "Mechanics R&D Console"
	id = 4
	req_one_access = list(access_mechanic)
	req_access=list()
	circuit = "/obj/item/weapon/circuitboard/rdconsole/mechanic"

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"
	id = 1
	req_access = list(access_rnd)
	circuit = "/obj/item/weapon/circuitboard/rdconsole"

/obj/machinery/computer/rdconsole/pod
	name = "Pod Bay R&D Console"
	id = 5
	req_access=list()
	circuit = "/obj/item/weapon/circuitboard/rdconsole/pod"
