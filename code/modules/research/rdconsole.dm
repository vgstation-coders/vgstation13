
/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The imprinting and construction menus do NOT require toxins access to access but all the other menus do. However, if you leave it
on a menu, nothing is to stop the person from using the options on that menu (although they won't be able to change to a different
one). You can also lock the console on the settings menu if you're feeling paranoid and you don't want anyone messing with it who
doesn't have toxins access.

*/
/obj/machinery/computer/rdconsole
	name = "R&D Console"
	desc = "A console used to interface with R&D tools."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	var/datum/techweb/stored_research					//Reference to global science techweb.
	var/obj/item/disk/tech_disk/t_disk	//Stores the technology disk.
	var/obj/item/disk/design_disk/d_disk	//Stores the design disk.
	circuit = /obj/item/circuitboard/computer/rdconsole

	var/obj/machinery/rnd/destructive_analyzer/linked_destroy	//Linked Destructive Analyzer
	var/obj/machinery/rnd/production/protolathe/linked_lathe				//Linked Protolathe
	var/obj/machinery/rnd/production/circuit_imprinter/linked_imprinter	//Linked Circuit Imprinter

	req_access = list(ACCESS_TOX)	//lA AND SETTING MANIPULATION REQUIRES SCIENTIST ACCESS.

	//UI VARS
	var/screen = RDSCREEN_MENU
	var/back = RDSCREEN_MENU
	var/locked = FALSE
	var/tdisk_uple = FALSE
	var/ddisk_uple = FALSE
	var/datum/techweb_node/selected_node
	var/datum/design/selected_design
	var/selected_category
	var/list/datum/design/matching_designs
	var/disk_slot_selected
	var/searchstring = ""
	var/searchtype = ""
	var/ui_mode = RDCONSOLE_UI_MODE_NORMAL

	var/research_control = TRUE

/obj/machinery/computer/rdconsole/production
	research_control = FALSE

/proc/CallMaterialName(ID)
	if (copytext(ID, 1, 2) == "$" && GLOB.materials_list[ID])
		var/datum/material/material = GLOB.materials_list[ID]
		return material.name

	else if(GLOB.chemical_reagents_list[ID])
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[ID]
		return reagent.name
	return "ERROR: Report This"

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/rnd/D in oview(3,src))
		if(D.linked_console != null || D.disabled || D.panel_open)
			continue
		if(istype(D, /obj/machinery/rnd/destructive_analyzer))
			if(linked_destroy == null)
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/production/protolathe))
			if(linked_lathe == null)
				var/obj/machinery/rnd/production/protolathe/P = D
				if(!P.console_link)
					continue
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/production/circuit_imprinter))
			if(linked_imprinter == null)
				var/obj/machinery/rnd/production/circuit_imprinter/C = D
				if(!C.console_link)
					continue
				linked_imprinter = D
				D.linked_console = src

/obj/machinery/computer/rdconsole/Initialize()
	. = ..()
	stored_research = SSresearch.science_tech
	stored_research.consoles_accessing[src] = TRUE
	matching_designs = list()
	SyncRDevices()

/obj/machinery/computer/rdconsole/Destroy()
	if(stored_research)
		stored_research.consoles_accessing -= src
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	if(t_disk)
		t_disk.forceMove(get_turf(src))
		t_disk = null
	if(d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	matching_designs = null
	selected_node = null
	selected_design = null
	return ..()

/obj/machinery/computer/rdconsole/attackby(obj/item/D, mob/user, params)
	//Loading a disk into it.
	if(istype(D, /obj/item/disk))
		if(istype(D, /obj/item/disk/tech_disk))
			if(t_disk)
				to_chat(user, "<span class='danger'>A technology disk is already loaded!</span>")
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, "<span class='danger'>[D] is stuck to your hand!</span>")
				return
			t_disk = D
		else if (istype(D, /obj/item/disk/design_disk))
			if(d_disk)
				to_chat(user, "<span class='danger'>A design disk is already loaded!</span>")
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, "<span class='danger'>[D] is stuck to your hand!</span>")
				return
			d_disk = D
		else
			to_chat(user, "<span class='danger'>Machine cannot accept disks in that format.</span>")
			return
		to_chat(user, "<span class='notice'>You insert [D] into \the [src]!</span>")
	else if(!(linked_destroy && linked_destroy.busy) && !(linked_lathe && linked_lathe.busy) && !(linked_imprinter && linked_imprinter.busy))
		. = ..()

/obj/machinery/computer/rdconsole/proc/research_node(id, mob/user)
	if(!stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		say("Node unlock failed: Either already researched or not available!")
		return FALSE
	var/datum/techweb_node/TN = SSresearch.techweb_nodes[id]
	if(!istype(TN))
		say("Node unlock failed: Unknown error.")
		return FALSE
	var/price = TN.get_price(stored_research)
	if(stored_research.research_points >= price)
		investigate_log("[key_name(user)] researched [id]([price]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
		if(stored_research == SSresearch.science_tech)
			SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("id" = "[id]", "name" = TN.display_name, "price" = "[price]", "time" = SQLtime()))
		if(stored_research.research_node(SSresearch.techweb_nodes[id]))
			say("Sucessfully researched [TN.display_name].")
			var/logname = "Unknown"
			if(isAI(user))
				logname = "AI: [user.name]"
			if(iscarbon(user))
				var/obj/item/card/id/idcard = user.get_active_held_item()
				if(istype(idcard))
					logname = "User: [idcard.registered_name]"
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/I = H.wear_id
				if(istype(I))
					var/obj/item/card/id/ID = I.GetID()
					if(istype(ID))
						logname = "User: [ID.registered_name]"
			stored_research.research_logs += "[logname] researched node id [id] for [price] points."
			return TRUE
		else
			say("Failed to research node: Internal database error!")
			return FALSE
	say("Not enough research points...")
	return FALSE

/obj/machinery/computer/rdconsole/on_deconstruction()
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	..()

/obj/machinery/computer/rdconsole/emag_act(mob/user)
	if(!(obj_flags & EMAGGED))
		to_chat(user, "<span class='notice'>You disable the security protocols</span>")
		playsound(src, "sparks", 75, 1)
		obj_flags |= EMAGGED
	return ..()

/obj/machinery/computer/rdconsole/proc/list_categories(list/categories, menu_num as num)
	if(!categories)
		return

	var/line_length = 1
	var/list/l = "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			l += "</tr><tr>"
			line_length = 1

		l += "<td><A href='?src=[REF(src)];category=[C];switch_screen=[menu_num]'>[C]</A></td>"
		line_length++

	l += "</tr></table></div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_header()
	var/list/l = list()
	l += "<div class='statusDisplay'><b>[stored_research.organization] Research and Development Network</b>"
	l += "Available points: [round(stored_research.research_points)] (+[round(stored_research.last_bitcoins * 60)] / minute)"
	l += "Security protocols: [obj_flags & EMAGGED ? "<font color='red'>Disabled</font>" : "<font color='green'>Enabled</font>"]"
	l += "<a href='?src=[REF(src)];switch_screen=[RDSCREEN_MENU]'>Main Menu</a> | <a href='?src=[REF(src)];switch_screen=[back]'>Back</a></div>[RDSCREEN_NOBREAK]"
	l += "[ui_mode == 1? "<span class='linkOn'>Normal View</span>" : "<a href='?src=[REF(src)];ui_mode=1'>Normal View</a>"] | [ui_mode == 2? "<span class='linkOn'>Expert View</span>" : "<a href='?src=[REF(src)];ui_mode=2'>Expert View</a>"] | [ui_mode == 3? "<span class='linkOn'>List View</span>" : "<a href='?src=[REF(src)];ui_mode=3'>List View</a>"]"
	return l

/obj/machinery/computer/rdconsole/proc/ui_main_menu()
	var/list/l = list()
	if(research_control)
		l += "<H2><a href='?src=[REF(src)];switch_screen=[RDSCREEN_TECHWEB]'>Technology</a>"
	if(d_disk)
		l += "<hr><a href='?src=[REF(src)];switch_screen=[RDSCREEN_DESIGNDISK]'>Design Disk</a>"
	if(t_disk)
		l += "<hr><a href='?src=[REF(src)];switch_screen=[RDSCREEN_TECHDISK]'>Tech Disk</a>"
	if(linked_destroy)
		l += "<hr><a href='?src=[REF(src)];switch_screen=[RDSCREEN_DECONSTRUCT]'>Destructive Analyzer</a>"
	if(linked_lathe)
		l += "<hr><a href='?src=[REF(src)];switch_screen=[RDSCREEN_PROTOLATHE]'>Protolathe</a>"
	if(linked_imprinter)
		l += "<hr><a href='?src=[REF(src)];switch_screen=[RDSCREEN_IMPRINTER]'>Circuit Imprinter</a>"
	l += "<hr><a href='?src=[REF(src)];switch_screen=[RDSCREEN_SETTINGS]'>Settings</a></H2>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_locked()
	return list("<h3><a href='?src=[REF(src)];switch_screen=[RDSCREEN_MENU];unlock_console=1'>SYSTEM LOCKED</a></h3></br>")

/obj/machinery/computer/rdconsole/proc/ui_settings()
	var/list/l = list()
	l += "<div class='statusDisplay'><h3>R&D Console Settings:</h3>"
	l += "<A href='?src=[REF(src)];switch_screen=[RDSCREEN_DEVICE_LINKING]'>Device Linkage Menu</A>"
	l += "<A href='?src=[REF(src)];lock_console=1'>Lock Console</A></div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_device_linking()
	var/list/l = list()
	l += "<A href='?src=[REF(src)];switch_screen=[RDSCREEN_SETTINGS]'>Settings Menu</A><div class='statusDisplay'>"
	l += "<h3>R&D Console Device Linkage Menu:</h3>"
	l += "<A href='?src=[REF(src)];find_device=1'>Re-sync with Nearby Devices</A>"
	l += "<h3>Linked Devices:</h3>"
	l += linked_destroy? "* Destructive Analyzer <A href='?src=[REF(src)];disconnect=destroy'>Disconnect</A>" : "* No Destructive Analyzer Linked"
	l += linked_lathe? "* Protolathe <A href='?src=[REF(src)];disconnect=lathe'>Disconnect</A>" : "* No Protolathe Linked"
	l += linked_imprinter? "* Circuit Imprinter <A href='?src=[REF(src)];disconnect=imprinter'>Disconnect</A>" : "* No Circuit Imprinter Linked"
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_protolathe_header()
	var/list/l = list()
	l += "<div class='statusDisplay'><A href='?src=[REF(src)];switch_screen=[RDSCREEN_PROTOLATHE]'>Protolathe Menu</A>"
	l += "<A href='?src=[REF(src)];switch_screen=[RDSCREEN_PROTOLATHE_MATERIALS]'><B>Material Amount:</B> [linked_lathe.materials.total_amount] / [linked_lathe.materials.max_amount]</A>"
	l += "<A href='?src=[REF(src)];switch_screen=[RDSCREEN_PROTOLATHE_CHEMICALS]'><B>Chemical volume:</B> [linked_lathe.reagents.total_volume] / [linked_lathe.reagents.maximum_volume]</A></div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_protolathe_category_view()	//Legacy code
	RDSCREEN_UI_LATHE_CHECK
	var/list/l = list()
	l += ui_protolathe_header()
	l += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3>"
	var/coeff = linked_lathe.efficiency_coeff
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		if(!(selected_category in D.category)|| !(D.build_type & PROTOLATHE))
			continue
		if(!(isnull(linked_lathe.allowed_department_flags) || (D.departmental_flags & linked_lathe.allowed_department_flags)))
			continue
		var/temp_material
		var/c = 50
		var/t

		var/all_materials = D.materials + D.reagents_list
		for(var/M in all_materials)
			t = linked_lathe.check_mat(D, M)
			temp_material += " | "
			if (t < 1)
				temp_material += "<span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
			else
				temp_material += " [all_materials[M]/coeff] [CallMaterialName(M)]"
			c = min(c,t)

		if (c >= 1)
			l += "<A href='?src=[REF(src)];build=[D.id];amount=1'>[D.name]</A>[RDSCREEN_NOBREAK]"
			if(c >= 5)
				l += "<A href='?src=[REF(src)];build=[D.id];amount=5'>x5</A>[RDSCREEN_NOBREAK]"
			if(c >= 10)
				l += "<A href='?src=[REF(src)];build=[D.id];amount=10'>x10</A>[RDSCREEN_NOBREAK]"
			l += "[temp_material][RDSCREEN_NOBREAK]"
		else
			l += "<span class='linkOff'>[D.name]</span>[temp_material][RDSCREEN_NOBREAK]"
		l += ""
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_protolathe()		//Legacy code
	RDSCREEN_UI_LATHE_CHECK
	var/list/l = list()
	l += ui_protolathe_header()

	l += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='hidden' name='type' value='proto'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><HR>"

	l += list_categories(linked_lathe.categories, RDSCREEN_PROTOLATHE_CATEGORY_VIEW)

	return l

/obj/machinery/computer/rdconsole/proc/ui_protolathe_search()		//Legacy code
	RDSCREEN_UI_LATHE_CHECK
	var/list/l = list()
	l += ui_protolathe_header()
	var/coeff = linked_lathe.efficiency_coeff
	for(var/datum/design/D in matching_designs)
		if(!(isnull(linked_lathe.allowed_department_flags) || (D.departmental_flags & linked_lathe.allowed_department_flags)))
			continue
		var/temp_material
		var/c = 50
		var/t
		var/all_materials = D.materials + D.reagents_list
		for(var/M in all_materials)
			t = linked_lathe.check_mat(D, M)
			temp_material += " | "
			if (t < 1)
				temp_material += "<span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
			else
				temp_material += " [all_materials[M]/coeff] [CallMaterialName(M)]"
			c = min(c,t)

		if (c >= 1)
			l += "<A href='?src=[REF(src)];build=[D.id];amount=1'>[D.name]</A>[RDSCREEN_NOBREAK]"
			if(c >= 5)
				l += "<A href='?src=[REF(src)];build=[D.id];amount=5'>x5</A>[RDSCREEN_NOBREAK]"
			if(c >= 10)
				l += "<A href='?src=[REF(src)];build=[D.id];amount=10'>x10</A>[RDSCREEN_NOBREAK]"
			l += "[temp_material][RDSCREEN_NOBREAK]"
		else
			l += "<span class='linkOff'>[D.name]</span>[temp_material][RDSCREEN_NOBREAK]"
		l += ""
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_protolathe_materials()		//Legacy code
	RDSCREEN_UI_LATHE_CHECK
	var/list/l = list()
	l += ui_protolathe_header()
	l += "<div class='statusDisplay'><h3>Material Storage:</h3>"
	for(var/mat_id in linked_lathe.materials.materials)
		var/datum/material/M = linked_lathe.materials.materials[mat_id]
		l += "* [M.amount] of [M.name]: "
		if(M.amount >= MINERAL_MATERIAL_AMOUNT) l += "<A href='?src=[REF(src)];ejectsheet=[M.id];eject_amt=1'>Eject</A> [RDSCREEN_NOBREAK]"
		if(M.amount >= MINERAL_MATERIAL_AMOUNT*5) l += "<A href='?src=[REF(src)];ejectsheet=[M.id];eject_amt=5'>5x</A> [RDSCREEN_NOBREAK]"
		if(M.amount >= MINERAL_MATERIAL_AMOUNT) l += "<A href='?src=[REF(src)];ejectsheet=[M.id];eject_amt=50'>All</A>[RDSCREEN_NOBREAK]"
		l += ""
	l += "</div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/computer/rdconsole/proc/ui_protolathe_chemicals()		//Legacy code
	RDSCREEN_UI_LATHE_CHECK
	var/list/l = list()
	l += ui_protolathe_header()
	l += "<div class='statusDisplay'><A href='?src=[REF(src)];disposeallP=1'>Disposal All Chemicals in Storage</A>"
	l += "<h3>Chemical Storage:</h3>"
	for(var/datum/reagent/R in linked_lathe.reagents.reagent_list)
		l += "[R.name]: [R.volume]"
		l += "<A href='?src=[REF(src)];disposeP=[R.id]'>Purge</A>"
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_circuit_header()		//Legacy Code
	var/list/l = list()
	l += "<div class='statusDisplay'><A href='?src=[REF(src)];switch_screen=[RDSCREEN_IMPRINTER]'>Circuit Imprinter Menu</A>"
	l += "<A href='?src=[REF(src)];switch_screen=[RDSCREEN_IMPRINTER_MATERIALS]'><B>Material Amount:</B> [linked_imprinter.materials.total_amount] / [linked_imprinter.materials.max_amount]</A>"
	l += "<A href='?src=[REF(src)];switch_screen=[RDSCREEN_IMPRINTER_CHEMICALS]'><B>Chemical volume:</B> [linked_imprinter.reagents.total_volume] / [linked_imprinter.reagents.maximum_volume]</A></div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_circuit()		//Legacy code
	RDSCREEN_UI_IMPRINTER_CHECK
	var/list/l = list()
	l += ui_circuit_header()
	l += "<h3>Circuit Imprinter Menu:</h3>"

	l += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='hidden' name='type' value='imprint'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><HR>"

	l += list_categories(linked_imprinter.categories, RDSCREEN_IMPRINTER_CATEGORY_VIEW)
	return l

/obj/machinery/computer/rdconsole/proc/ui_circuit_category_view()	//Legacy code
	RDSCREEN_UI_IMPRINTER_CHECK
	var/list/l = list()
	l += ui_circuit_header()
	l += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3>"

	var/coeff = linked_imprinter.efficiency_coeff
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		if(!(selected_category in D.category) || !(D.build_type & IMPRINTER))
			continue
		if(!(isnull(linked_imprinter.allowed_department_flags) || (D.departmental_flags & linked_imprinter.allowed_department_flags)))
			continue
		var/temp_materials
		var/check_materials = TRUE

		var/all_materials = D.materials + D.reagents_list

		for(var/M in all_materials)
			temp_materials += " | "
			if (!linked_imprinter.check_mat(D, M))
				check_materials = FALSE
				temp_materials += " <span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
			else
				temp_materials += " [all_materials[M]/coeff] [CallMaterialName(M)]"
		if (check_materials)
			l += "<A href='?src=[REF(src)];imprint=[D.id]'>[D.name]</A>[temp_materials]"
		else
			l += "<span class='linkOff'>[D.name]</span>[temp_materials]"
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_circuit_search()	//Legacy code
	RDSCREEN_UI_IMPRINTER_CHECK
	var/list/l = list()
	l += ui_circuit_header()
	l += "<div class='statusDisplay'><h3>Search results:</h3>"

	var/coeff = linked_imprinter.efficiency_coeff
	for(var/datum/design/D in matching_designs)
		if(!(isnull(linked_imprinter.allowed_department_flags) || (D.departmental_flags & linked_imprinter.allowed_department_flags)))
			continue
		var/temp_materials
		var/check_materials = TRUE
		var/all_materials = D.materials + D.reagents_list
		for(var/M in all_materials)
			temp_materials += " | "
			if (!linked_imprinter.check_mat(D, M))
				check_materials = FALSE
				temp_materials += " <span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
			else
				temp_materials += " [all_materials[M]/coeff] [CallMaterialName(M)]"
		if (check_materials)
			l += "<A href='?src=[REF(src)];imprint=[D.id]'>[D.name]</A>[temp_materials]"
		else
			l += "<span class='linkOff'>[D.name]</span>[temp_materials]"
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_circuit_chemicals()		//legacy code
	RDSCREEN_UI_IMPRINTER_CHECK
	var/list/l = list()
	l += ui_circuit_header()
	l += "<A href='?src=[REF(src)];disposeallI=1'>Disposal All Chemicals in Storage</A><div class='statusDisplay'>"
	l += "<h3>Chemical Storage:</h3>"
	for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
		l += "[R.name]: [R.volume]"
		l += "<A href='?src=[REF(src)];disposeI=[R.id]'>Purge</A>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_circuit_materials()	//Legacy code!
	RDSCREEN_UI_IMPRINTER_CHECK
	var/list/l = list()
	l += ui_circuit_header()
	l += "<h3><div class='statusDisplay'>Material Storage:</h3>"
	for(var/mat_id in linked_imprinter.materials.materials)
		var/datum/material/M = linked_imprinter.materials.materials[mat_id]
		l += "* [M.amount] of [M.name]: "
		if(M.amount >= MINERAL_MATERIAL_AMOUNT) l += "<A href='?src=[REF(src)];imprinter_ejectsheet=[M.id];eject_amt=1'>Eject</A> [RDSCREEN_NOBREAK]"
		if(M.amount >= MINERAL_MATERIAL_AMOUNT*5) l += "<A href='?src=[REF(src)];imprinter_ejectsheet=[M.id];eject_amt=5'>5x</A> [RDSCREEN_NOBREAK]"
		if(M.amount >= MINERAL_MATERIAL_AMOUNT) l += "<A href='?src=[REF(src)];imprinter_ejectsheet=[M.id];eject_amt=50'>All</A>[RDSCREEN_NOBREAK]</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_techdisk()		//Legacy code
	RDSCREEN_UI_TDISK_CHECK
	var/list/l = list()
	l += "<div class='statusDisplay'>Disk Operations: <A href='?src=[REF(src)];clear_tech=0'>Clear Disk</A>"
	l += "<A href='?src=[REF(src)];eject_tech=1'>Eject Disk</A>"
	l += "<A href='?src=[REF(src)];updt_tech=0'>Upload All</A>"
	l += "<A href='?src=[REF(src)];copy_tech=1'>Load Technology to Disk</A></div>"
	l += "<div class='statusDisplay'><h3>Stored Technology Nodes:</h3>"
	for(var/i in t_disk.stored_research.researched_nodes)
		var/datum/techweb_node/N = t_disk.stored_research.researched_nodes[i]
		l += "<A href='?src=[REF(src)];view_node=[i];back_screen=[screen]'>[N.display_name]</A>"
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_designdisk()		//Legacy code
	RDSCREEN_UI_DDISK_CHECK
	var/list/l = list()
	l += "Disk Operations: <A href='?src=[REF(src)];clear_design=0'>Clear Disk</A><A href='?src=[REF(src)];updt_design=0'>Upload All</A><A href='?src=[REF(src)];eject_design=1'>Eject Disk</A>"
	for(var/i in 1 to d_disk.max_blueprints)
		l += "<div class='statusDisplay'>"
		if(d_disk.blueprints[i])
			var/datum/design/D = d_disk.blueprints[i]
			l += "<A href='?src=[REF(src)];view_design=[D.id]'>[D.name]</A>"
			l += "Operations: <A href='?src=[REF(src)];updt_design=[i]'>Upload to database</A> <A href='?src=[REF(src)];clear_design=[i]'>Clear Slot</A>"
		else
			l += "Empty Slot Operations: <A href='?src=[REF(src)];switch_screen=[RDSCREEN_DESIGNDISK_UPLOAD];disk_slot=[i]'>Load Design to Slot</A>"
		l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_designdisk_upload()	//Legacy code
	RDSCREEN_UI_DDISK_CHECK
	var/list/l = list()
	l += "<A href='?src=[REF(src)];switch_screen=[RDSCREEN_DESIGNDISK];back_screen=[screen]'>Return to Disk Operations</A><div class='statusDisplay'>"
	l += "<h3>Load Design to Disk:</h3>"
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		l += "[D.name] "
		l += "<A href='?src=[REF(src)];copy_design=[disk_slot_selected];copy_design_ID=[D.id]'>Copy to Disk</A>"
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_deconstruct()		//Legacy code
	RDSCREEN_UI_DECONSTRUCT_CHECK
	var/list/l = list()
	if(!linked_destroy.loaded_item)
		l += "<div class='statusDisplay'>No item loaded. Standing-by...</div>"
	else
		l += "<div class='statusDisplay'>[RDSCREEN_NOBREAK]"
		l += "<table><tr><td>[icon2html(linked_destroy.loaded_item, usr)]</td><td><b>[linked_destroy.loaded_item.name]</b> <A href='?src=[REF(src)];eject_item=1'>Eject</A></td></tr></table>[RDSCREEN_NOBREAK]"
		l += "Select a node to boost by deconstructing this item. This item can boost:"

		var/anything = FALSE
		var/list/boostable_nodes = techweb_item_boost_check(linked_destroy.loaded_item)
		for(var/id in boostable_nodes)
			anything = TRUE
			var/worth = boostable_nodes[id]
			var/datum/techweb_node/N = get_techweb_node_by_id(id)

			l += "<div class='statusDisplay'>[RDSCREEN_NOBREAK]"
			if (stored_research.researched_nodes[N.id])  // already researched
				l += "<span class='linkOff'>[N.display_name]</span>"
				l += "This node has already been researched."
			else if (worth == 0)  // reveal only
				if (stored_research.hidden_nodes[N.id])
					l += "<A href='?src=[REF(src)];deconstruct=[N.id]'>[N.display_name]</A>"
					l += "This node will be revealed."
				else
					l += "<span class='linkOff'>[N.display_name]</span>"
					l += "This node has already been revealed."
			else  // boost by the difference
				var/difference = min(worth, N.research_cost) - stored_research.boosted_nodes[N.id]
				if (difference > 0)
					l += "<A href='?src=[REF(src)];deconstruct=[N.id]'>[N.display_name]</A>"
					l += "This node will be boosted by [difference] points."
				else
					l += "<span class='linkOff'>[N.display_name]</span>"
					l += "This node has already been boosted.</span>"
			l += "</div>[RDSCREEN_NOBREAK]"

		// point deconstruction and material reclamation use the same ID to prevent accidentally missing the points
		var/point_value = techweb_item_point_check(linked_destroy.loaded_item)
		if(point_value)
			anything = TRUE
			l += "<div class='statusDisplay'>[RDSCREEN_NOBREAK]"
			if (stored_research.deconstructed_items[linked_destroy.loaded_item.type])
				l += "<span class='linkOff'>Point Deconstruction</span>"
				l += "This item's [point_value] point\s have already been claimed."
			else
				l += "<A href='?src=[REF(src)];deconstruct=[RESEARCH_MATERIAL_RECLAMATION_ID]'>Point Deconstruction</A>"
				l += "This item is worth [point_value] point\s!"
			l += "</div>[RDSCREEN_NOBREAK]"

		var/list/materials = linked_destroy.loaded_item.materials
		if (materials.len)
			l += "<div class='statusDisplay'><A href='?src=[REF(src)];deconstruct=[RESEARCH_MATERIAL_RECLAMATION_ID]'>Material Reclamation</A>"
			for (var/M in materials)
				l += "* [CallMaterialName(M)] x [materials[M]]"
			l += "</div>[RDSCREEN_NOBREAK]"
			anything = TRUE

		if (!anything)
			l += "Nothing!"

		l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_techweb()
	var/list/l = list()
	if(ui_mode != RDCONSOLE_UI_MODE_LIST)
		var/list/columns = list()
		var/max_tier = 0
		for (var/node_ in stored_research.tiers)
			var/datum/techweb_node/node = node_
			var/tier = stored_research.tiers[node]
			LAZYINITLIST(columns["[tier]"])  // String hackery to make the numbers associative
			columns["[tier]"] += ui_techweb_single_node(node, minimal=(tier != 1))
			max_tier = max(max_tier, tier)

		l += "<table><tr><th align='left'>Researched</th><th align='left'>Available</th><th align='left'>Future</th></tr><tr>[RDSCREEN_NOBREAK]"
		for(var/tier in 0 to max_tier)
			l += "<td valign='top'>[RDSCREEN_NOBREAK]"
			l += columns["[tier]"]
			l += "</td>[RDSCREEN_NOBREAK]"
		l += "</tr></table>[RDSCREEN_NOBREAK]"
	else
		var/list/avail = list()			//This could probably be optimized a bit later.
		var/list/unavail = list()
		var/list/res = list()
		for(var/v in stored_research.researched_nodes)
			res += stored_research.researched_nodes[v]
		for(var/v in stored_research.available_nodes)
			if(stored_research.researched_nodes[v])
				continue
			avail += stored_research.available_nodes[v]
		for(var/v in stored_research.visible_nodes)
			if(stored_research.available_nodes[v])
				continue
			unavail += stored_research.visible_nodes[v]
		l += "<h2>Technology Nodes:</h2>[RDSCREEN_NOBREAK]"
		l += "<div><h3>Available for Research:</h3>"
		for(var/datum/techweb_node/N in avail)
			var/not_unlocked = (stored_research.available_nodes[N.id] && !stored_research.researched_nodes[N.id])
			var/has_points = (stored_research.research_points >= N.get_price(stored_research))
			var/research_href = not_unlocked? (has_points? "<A href='?src=[REF(src)];research_node=[N.id]'>Research</A>" : "<span class='linkOff bad'>Not Enough Points</span>") : null
			l += "<A href='?src=[REF(src)];view_node=[N.id];back_screen=[screen]'>[N.display_name]</A>[research_href]"
		l += "</div><div><h3>Locked Nodes:</h3>"
		for(var/datum/techweb_node/N in unavail)
			l += "<A href='?src=[REF(src)];view_node=[N.id];back_screen=[screen]'>[N.display_name]</A>"
		l += "</div><div><h3>Researched Nodes:</h3>"
		for(var/datum/techweb_node/N in res)
			l += "<A href='?src=[REF(src)];view_node=[N.id];back_screen=[screen]'>[N.display_name]</A>"
		l += "</div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/computer/rdconsole/proc/machine_icon(atom/item)
	return icon2html(initial(item.icon), usr, initial(item.icon_state), SOUTH)

/obj/machinery/computer/rdconsole/proc/ui_techweb_single_node(datum/techweb_node/node, selflink=TRUE, minimal=FALSE)
	var/list/l = list()
	if (stored_research.hidden_nodes[node.id])
		return l
	var/price = node.get_price(stored_research)
	var/display_name = node.display_name
	if (selflink)
		display_name = "<A href='?src=[REF(src)];view_node=[node.id];back_screen=[screen]'>[display_name]</A>"
	l += "<div class='statusDisplay technode'><b>[display_name]</b> [RDSCREEN_NOBREAK]"
	if(minimal)
		l += "<br>[node.description]"
	else
		if(stored_research.researched_nodes[node.id])
			l += "<span class='linkOff'>Researched</span>"
		else if(stored_research.available_nodes[node.id])
			if(stored_research.research_points >= price)
				l += "<A href='?src=[REF(src)];research_node=[node.id]'>[price]</A>"
			else
				l += "<span class='linkOff'>[price]</span>"  // gray - too expensive
		else
			l += "<span class='linkOff bad'>[price]</span>"  // red - missing prereqs
		if(ui_mode == RDCONSOLE_UI_MODE_NORMAL)
			l += "[node.description]"
			for(var/i in node.designs)
				var/datum/design/D = node.designs[i]
				l += "<span data-tooltip='[D.name]' onclick='location=\"?src=[REF(src)];view_design=[i];back_screen=[screen]\"'>[D.icon_html(usr)]</span>[RDSCREEN_NOBREAK]"
	l += "</div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/computer/rdconsole/proc/ui_techweb_nodeview()
	RDSCREEN_UI_SNODE_CHECK
	var/list/l = list()
	if(stored_research.hidden_nodes[selected_node.id])
		l += "<div><h3>ERROR: RESEARCH NODE UNKNOWN.</h3></div>"
		return

	l += "<table><tr>[RDSCREEN_NOBREAK]"
	if (length(selected_node.prerequisites))
		l += "<th align='left'>Requires</th>[RDSCREEN_NOBREAK]"
	l += "<th align='left'>Current Node</th>[RDSCREEN_NOBREAK]"
	if (length(selected_node.unlocks))
		l += "<th align='left'>Unlocks</th>[RDSCREEN_NOBREAK]"

	l += "</tr><tr>[RDSCREEN_NOBREAK]"
	if (length(selected_node.prerequisites))
		l += "<td valign='top'>[RDSCREEN_NOBREAK]"
		for (var/i in selected_node.prerequisites)
			l += ui_techweb_single_node(selected_node.prerequisites[i])
		l += "</td>[RDSCREEN_NOBREAK]"
	l += "<td valign='top'>[RDSCREEN_NOBREAK]"
	l += ui_techweb_single_node(selected_node, selflink=FALSE)
	l += "</td>[RDSCREEN_NOBREAK]"
	if (length(selected_node.unlocks))
		l += "<td valign='top'>[RDSCREEN_NOBREAK]"
		for (var/i in selected_node.unlocks)
			l += ui_techweb_single_node(selected_node.unlocks[i])
		l += "</td>[RDSCREEN_NOBREAK]"

	l += "</tr></table>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/computer/rdconsole/proc/ui_techweb_designview()		//Legacy code
	RDSCREEN_UI_SDESIGN_CHECK
	var/list/l = list()
	var/datum/design/D = selected_design
	l += "<div><table><tr><td>[D.icon_html(usr)]</td><td><b>[D.name]</b></td></tr></table>[RDSCREEN_NOBREAK]"
	if(D.build_type)
		var/lathes = list()
		if(D.build_type & IMPRINTER)
			lathes += "<span data-tooltip='Circuit Imprinter'>[machine_icon(/obj/machinery/rnd/production/circuit_imprinter)]</span>[RDSCREEN_NOBREAK]"
			if (linked_imprinter && D.id in stored_research.researched_designs)
				l += "<A href='?src=[REF(src)];search=1;type=imprint;to_search=[D.name]'>Imprint</A>"
		if(D.build_type & PROTOLATHE)
			lathes += "<span data-tooltip='Protolathe'>[machine_icon(/obj/machinery/rnd/production/protolathe)]</span>[RDSCREEN_NOBREAK]"
			if (linked_lathe && D.id in stored_research.researched_designs)
				l += "<A href='?src=[REF(src)];search=1;type=proto;to_search=[D.name]'>Construct</A>"
		if(D.build_type & AUTOLATHE)
			lathes += "<span data-tooltip='Autolathe'>[machine_icon(/obj/machinery/autolathe)]</span>[RDSCREEN_NOBREAK]"
		if(D.build_type & MECHFAB)
			lathes += "<span data-tooltip='Exosuit Fabricator'>[machine_icon(/obj/machinery/mecha_part_fabricator)]</span>[RDSCREEN_NOBREAK]"
		if(D.build_type & BIOGENERATOR)
			lathes += "<span data-tooltip='Biogenerator'>[machine_icon(/obj/machinery/biogenerator)]</span>[RDSCREEN_NOBREAK]"
		if(D.build_type & LIMBGROWER)
			lathes += "<span data-tooltip='Limbgrower'>[machine_icon(/obj/machinery/limbgrower)]</span>[RDSCREEN_NOBREAK]"
		if(D.build_type & SMELTER)
			lathes += "<span data-tooltip='Smelter'>[machine_icon(/obj/machinery/mineral/processing_unit)]</span>[RDSCREEN_NOBREAK]"
		l += "Construction types:"
		l += lathes
		l += ""
	l += "Required materials:"
	var/all_mats = D.materials + D.reagents_list
	for(var/M in all_mats)
		l += "* [CallMaterialName(M)] x [all_mats[M]]"
	l += "Unlocked by:"
	for (var/node in D.unlocked_by)
		l += ui_techweb_single_node(node)
	l += "[RDSCREEN_NOBREAK]</div>"
	return l

//Fuck TGUI.
/obj/machinery/computer/rdconsole/proc/generate_ui()
	var/list/ui = list()
	ui += ui_header()
	if(locked)
		ui += ui_locked()
	else
		switch(screen)
			if(RDSCREEN_MENU)
				ui += ui_main_menu()
			if(RDSCREEN_TECHWEB)
				ui += ui_techweb()
			if(RDSCREEN_TECHWEB_NODEVIEW)
				ui += ui_techweb_nodeview()
			if(RDSCREEN_TECHWEB_DESIGNVIEW)
				ui += ui_techweb_designview()
			if(RDSCREEN_DESIGNDISK)
				ui += ui_designdisk()
			if(RDSCREEN_DESIGNDISK_UPLOAD)
				ui += ui_designdisk_upload()
			if(RDSCREEN_TECHDISK)
				ui += ui_techdisk()
			if(RDSCREEN_DECONSTRUCT)
				ui += ui_deconstruct()
			if(RDSCREEN_PROTOLATHE)
				ui += ui_protolathe()
			if(RDSCREEN_PROTOLATHE_CATEGORY_VIEW)
				ui += ui_protolathe_category_view()
			if(RDSCREEN_PROTOLATHE_MATERIALS)
				ui += ui_protolathe_materials()
			if(RDSCREEN_PROTOLATHE_CHEMICALS)
				ui += ui_protolathe_chemicals()
			if(RDSCREEN_PROTOLATHE_SEARCH)
				ui += ui_protolathe_search()
			if(RDSCREEN_IMPRINTER)
				ui += ui_circuit()
			if(RDSCREEN_IMPRINTER_CATEGORY_VIEW)
				ui += ui_circuit_category_view()
			if(RDSCREEN_IMPRINTER_MATERIALS)
				ui += ui_circuit_materials()
			if(RDSCREEN_IMPRINTER_CHEMICALS)
				ui += ui_circuit_chemicals()
			if(RDSCREEN_IMPRINTER_SEARCH)
				ui += ui_circuit_search()
			if(RDSCREEN_SETTINGS)
				ui += ui_settings()
			if(RDSCREEN_DEVICE_LINKING)
				ui += ui_device_linking()
	for(var/i in 1 to length(ui))
		if(!findtextEx(ui[i], RDSCREEN_NOBREAK))
			ui[i] += "<br>"
		ui[i] = replacetextEx(ui[i], RDSCREEN_NOBREAK, "")
	return ui.Join("")

/obj/machinery/computer/rdconsole/Topic(raw, ls)
	if(..())
		return
	add_fingerprint(usr)
	usr.set_machine(src)
	if(ls["switch_screen"])
		back = screen
		screen = text2num(ls["switch_screen"])
	if(ls["ui_mode"])
		ui_mode = text2num(ls["ui_mode"])
	if(ls["lock_console"])
		if(allowed(usr))
			lock_console(usr)
		else
			to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
	if(ls["unlock_console"])
		if(allowed(usr))
			unlock_console(usr)
		else
			to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
	if(ls["find_device"])
		SyncRDevices()
		say("Resynced with nearby devices.")
	if(ls["back_screen"])
		back = text2num(ls["back_screen"])
	if(ls["build"]) //Causes the Protolathe to build something.
		if(QDELETED(linked_lathe))
			say("No Protolathe Linked!")
			return
		if(linked_lathe.busy)
			say("Warning: Protolathe busy!")
		else
			linked_lathe.user_try_print_id(ls["build"], ls["amount"])
	if(ls["imprint"])
		if(QDELETED(linked_imprinter))
			say("No Circuit Imprinter Linked!")
			return
		if(linked_imprinter.busy)
			say("Warning: Imprinter busy!")
		else
			linked_imprinter.user_try_print_id(ls["imprint"])
	if(ls["category"])
		selected_category = ls["category"]
	if(ls["disconnect"]) //The R&D console disconnects with a specific device.
		switch(ls["disconnect"])
			if("destroy")
				if(QDELETED(linked_destroy))
					say("No Deconstructive Analyzer Linked!")
					return
				linked_destroy.linked_console = null
				linked_destroy = null
			if("lathe")
				if(QDELETED(linked_lathe))
					say("No Protolathe Linked!")
					return
				linked_lathe.linked_console = null
				linked_lathe = null
			if("imprinter")
				if(QDELETED(linked_imprinter))
					say("No Circuit Imprinter Linked!")
					return
				linked_imprinter.linked_console = null
				linked_imprinter = null
	if(ls["eject_design"]) //Eject the design disk.
		eject_disk("design")
		screen = RDSCREEN_MENU
		say("Ejecting Design Disk")
	if(ls["eject_tech"]) //Eject the technology disk.
		eject_disk("tech")
		screen = RDSCREEN_MENU
		say("Ejecting Technology Disk")
	if(ls["deconstruct"])
		if(QDELETED(linked_destroy))
			say("No Deconstructive Analyzer Linked!")
			return
		linked_destroy.user_try_decon_id(ls["deconstruct"], usr)
	//Protolathe Materials
	if(ls["disposeP"])  //Causes the protolathe to dispose of a single reagent (all of it)
		if(QDELETED(linked_lathe))
			say("No Protolathe Linked!")
			return
		linked_lathe.reagents.del_reagent(ls["disposeP"])
	if(ls["disposeallP"]) //Causes the protolathe to dispose of all it's reagents.
		if(QDELETED(linked_lathe))
			say("No Protolathe Linked!")
			return
		linked_lathe.reagents.clear_reagents()
	if(ls["ejectsheet"]) //Causes the protolathe to eject a sheet of material
		if(QDELETED(linked_lathe))
			say("No Protolathe Linked!")
			return
		linked_lathe.materials.retrieve_sheets(text2num(ls["eject_amt"]), ls["ejectsheet"])
	//Circuit Imprinter Materials
	if(ls["disposeI"])  //Causes the circuit imprinter to dispose of a single reagent (all of it)
		if(QDELETED(linked_imprinter))
			say("No Circuit Imprinter Linked!")
			return
		linked_imprinter.reagents.del_reagent(ls["disposeI"])
	if(ls["disposeallI"]) //Causes the circuit imprinter to dispose of all it's reagents.
		if(QDELETED(linked_imprinter))
			say("No Circuit Imprinter Linked!")
			return
		linked_imprinter.reagents.clear_reagents()
	if(ls["imprinter_ejectsheet"]) //Causes the imprinter to eject a sheet of material
		if(QDELETED(linked_imprinter))
			say("No Circuit Imprinter Linked!")
			return
		linked_imprinter.materials.retrieve_sheets(text2num(ls["eject_amt"]), ls["imprinter_ejectsheet"])
	if(ls["disk_slot"])
		disk_slot_selected = text2num(ls["disk_slot"])
	if(ls["research_node"])
		if(!research_control)
			return				//honestly should call them out for href exploiting :^)
		if(!SSresearch.science_tech.available_nodes[ls["research_node"]])
			return			//Nope!
		research_node(ls["research_node"], usr)
	if(ls["clear_tech"]) //Erase la on the technology disk.
		if(QDELETED(t_disk))
			say("No Technology Disk Inserted!")
			return
		qdel(t_disk.stored_research)
		t_disk.stored_research = new
		say("Wiping technology disk.")
	if(ls["copy_tech"]) //Copy some technology la from the research holder to the disk.
		if(QDELETED(t_disk))
			say("No Technology Disk Inserted!")
			return
		stored_research.copy_research_to(t_disk.stored_research)
		screen = RDSCREEN_TECHDISK
		say("Downloading to technology disk.")
	if(ls["clear_design"]) //Erases la on the design disk.
		if(QDELETED(d_disk))
			say("No Design Disk Inserted!")
			return
		var/n = text2num(ls["clear_design"])
		if(!n)
			for(var/i in 1 to d_disk.max_blueprints)
				d_disk.blueprints[i] = null
				say("Wiping design disk.")
		else
			var/datum/design/D = d_disk.blueprints[n]
			say("Wiping design [D.name] from design disk.")
			d_disk.blueprints[n] = null
	if(ls["search"]) //Search for designs with name matching pattern
		searchstring = ls["to_search"]
		searchtype = ls["type"]
		rescan_views()
		if(searchtype == "proto")
			screen = RDSCREEN_PROTOLATHE_SEARCH
		else
			screen = RDSCREEN_IMPRINTER_SEARCH
	if(ls["updt_tech"]) //Uple the research holder with information from the technology disk.
		if(QDELETED(t_disk))
			say("No Technology Disk Inserted!")
			return
		say("Uploading technology disk.")
		t_disk.stored_research.copy_research_to(stored_research)
	if(ls["copy_design"]) //Copy design la from the research holder to the design disk.
		if(QDELETED(d_disk))
			say("No Design Disk Inserted!")
			return
		var/slot = text2num(ls["copy_design"])
		var/datum/design/D = stored_research.researched_designs[ls["copy_design_ID"]]
		if(D)
			var/autolathe_friendly = TRUE
			if(D.reagents_list.len)
				autolathe_friendly = FALSE
				D.category -= "Imported"
			else
				for(var/x in D.materials)
					if( !(x in list(MAT_METAL, MAT_GLASS)))
						autolathe_friendly = FALSE
						D.category -= "Imported"

			if(D.build_type & (AUTOLATHE|PROTOLATHE|CRAFTLATHE)) // Specifically excludes circuit imprinter and mechfab
				D.build_type = autolathe_friendly ? (D.build_type | AUTOLATHE) : D.build_type
				D.category |= "Imported"
			d_disk.blueprints[slot] = D
		screen = RDSCREEN_DESIGNDISK
	if(ls["eject_item"]) //Eject the item inside the destructive analyzer.
		if(QDELETED(linked_destroy))
			say("No Deconstructive Analyzer Linked!")
			return
		if(linked_destroy.busy)
			to_chat(usr, "<span class='danger'>The destructive analyzer is busy at the moment.</span>")
		else if(linked_destroy.loaded_item)
			linked_destroy.unload_item()
			screen = RDSCREEN_MENU
	if(ls["view_node"])
		selected_node = SSresearch.techweb_nodes[ls["view_node"]]
		screen = RDSCREEN_TECHWEB_NODEVIEW
	if(ls["view_design"])
		selected_design = SSresearch.techweb_designs[ls["view_design"]]
		screen = RDSCREEN_TECHWEB_DESIGNVIEW
	if(ls["updt_design"]) //Uples the research holder with design la from the design disk.
		if(QDELETED(d_disk))
			say("No design disk found.")
			return
		var/n = text2num(ls["updt_design"])
		if(!n)
			for(var/D in d_disk.blueprints)
				if(D)
					stored_research.add_design(D)
		else
			stored_research.add_design(d_disk.blueprints[n])

	updateUsrDialog()

/obj/machinery/computer/rdconsole/ui_interact(mob/user)
	. = ..()
	var/datum/browser/popup = new(user, "rndconsole", name, 900, 600)
	popup.add_stylesheet("techwebs", 'html/browser/techwebs.css')
	popup.set_content(generate_ui())
	popup.open()

/obj/machinery/computer/rdconsole/proc/tdisk_uple_complete()
	tdisk_uple = FALSE
	updateUsrDialog()

/obj/machinery/computer/rdconsole/proc/ddisk_uple_complete()
	ddisk_uple = FALSE
	updateUsrDialog()

/obj/machinery/computer/rdconsole/proc/eject_disk(type)
	if(type == "design")
		d_disk.forceMove(get_turf(src))
		d_disk = null
	if(type == "tech")
		t_disk.forceMove(get_turf(src))
		t_disk = null

/obj/machinery/computer/rdconsole/proc/rescan_views()
	var/compare
	matching_designs.Cut()
	if(searchtype == "proto")
		compare = PROTOLATHE
	else if(searchtype == "imprint")
		compare = IMPRINTER
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		if(!(D.build_type & compare))
			continue
		if(findtext(D.name,searchstring))
			matching_designs.Add(D)

/obj/machinery/computer/rdconsole/proc/check_canprint(datum/design/D, buildtype)
	var/amount = 50
	if(buildtype == IMPRINTER)
		if(QDELETED(linked_imprinter))
			return FALSE
		for(var/M in D.materials + D.reagents_list)
			amount = min(amount, linked_imprinter.check_mat(D, M))
			if(amount < 1)
				return FALSE
	else if(buildtype == PROTOLATHE)
		if(QDELETED(linked_lathe))
			return FALSE
		for(var/M in D.materials + D.reagents_list)
			amount = min(amount, linked_lathe.check_mat(D, M))
			if(amount < 1)
				return FALSE
	else
		return FALSE
	return amount

/obj/machinery/computer/rdconsole/proc/lock_console(mob/user)
	locked = TRUE

/obj/machinery/computer/rdconsole/proc/unlock_console(mob/user)
	locked = FALSE

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	req_access = null
	req_access_txt = "29"

/obj/machinery/computer/rdconsole/robotics/Initialize()
	. = ..()
	if(circuit)
		circuit.name = "R&D Console - Robotics (Computer Board)"
		circuit.build_path = /obj/machinery/computer/rdconsole/robotics

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"

/obj/machinery/computer/rdconsole/experiment
	name = "E.X.P.E.R.I-MENTOR R&D Console"
