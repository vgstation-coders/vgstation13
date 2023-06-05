//////////////////////////////////////////
//				SCP 294					//
//										//
//	This is a child of a chemistry		//
//	dispenser. Info of how it works at	//
//	http://www.scp-wiki.net/scp-294		//
//										//
//////////////////////////////////////////

/obj/machinery/chem_dispenser/scp_294
	name = "\improper strange coffee machine"
	desc = "It appears to be a standard coffee vending machine, the only noticeable difference being an entry touchpad with buttons corresponding to a Galactic Common QWERTY keyboard."
	icon = 	'icons/obj/vending.dmi'
	icon_state = COFFEE
	energy = 10
	max_energy = 10
	amount = 10
	dispensable_reagents = null
	var/list/prohibited_reagents = list(ADMINORDRAZINE, PROCIZINE)
	var/list/emagged_only_reagents = list(XENOMICROBES, MEDNANOBOTS)

	machine_flags = FIXED2WORK | EMAGGABLE | WRENCHMOVE
	mech_flags = MECH_SCAN_FAIL

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)

/obj/machinery/chem_dispenser/scp_294/update_chem_list()
	return

/obj/machinery/chem_dispenser/scp_294/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return
	if((user.stat && !isobserver(user)) || user.restrained())
		return
	if(!chemical_reagents_list || !chemical_reagents_list.len)
		return
	// this is the data which will be sent to the ui
	var/data[0]
	data["isBeakerLoaded"] = container ? 1 : 0

	var containerContents[0]
	var containerCurrentVolume = 0
	if(container && container.reagents && container.reagents.reagent_list.len)
		for(var/datum/reagent/R in container.reagents.reagent_list)
			containerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			containerCurrentVolume += R.volume
	data["beakerContents"] = containerContents

	if (container)
		data["beakerCurrentVolume"] = containerCurrentVolume
		data["beakerMaxVolume"] = container.volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "scp_294.tmpl", "[src.name]", 390, 315)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/chem_dispenser/scp_294/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return 0 // don't update UIs attached to this object

	if(href_list["ejectBeaker"])
		if(container)
			detach()

	if(href_list["input"])
		var/input_reagent = copytext(sanitize(input("Enter the name of any liquid", "Input") as text),1,MAX_MESSAGE_LEN)
		input_reagent = lowertext(input_reagent) // Lowercase for easier parsing
		if(findtext(input_reagent,"a cup of ")) // These appear at the start of a lot of requests in the SCP so parse these properly too
			input_reagent = replacetext(input_reagent,"a cup of ","")
		else if(findtext(input_reagent,"cup of ",0,7))
			input_reagent = replacetext(input_reagent,"cup of ","")
		if(!container) // Spawn a paper cup like in SCP if no container is inserted
			container = new/obj/item/weapon/reagent_containers/food/drinks/sillycup(src)
		var/obj/item/weapon/reagent_containers/X = src.container
		var/datum/reagents/U = X.reagents
		if(!U)
			if(!X.gcDestroyed)
				X.create_reagents(X.volume)
			else
				QDEL_NULL(X)
				return
		var/space = U.maximum_volume - U.total_volume

		if(!arcanetampered)
			var/chemfound = FALSE
			var/mob/living/mobfound = null
			var/bloodonly = 0 // This is a number for subtraction purposes, see below
			// First checks for all living mobs to see if input matches their name to take stuff from, like the cup of joe in the original SCP
			for(var/mob/living/L in mob_list)
				var/list/mob_name_parts = splittext(L.name," ")
				if(findtext(input_reagent,"'s blood"))
					bloodonly = 1
					input_reagent = replacetext(input_reagent,"'s blood","")
				if(input_reagent == L.name || (input_reagent in mob_name_parts))
					mobfound = L
					break
			// Then searches through the list of all reagents and ignores case, plus converts spaces into either nothing or underscores for IDs
			// (due to no consistent alternating between either)
			for(var/reagent_id in chemical_reagents_list)
				var/datum/reagent/R = chemical_reagents_list[reagent_id]
				if(input_reagent == lowertext(R.name) || input_reagent == lowertext(reagent_id) || lowertext(reagent_id) == replacetext(input_reagent," ","") || lowertext(reagent_id) == replacetext(input_reagent," ","_"))
					input_reagent = reagent_id
					chemfound = TRUE
					break
			if(mobfound && mobfound.reagents && !(mobfound.status_flags & GODMODE) && !(mobfound.flags & INVULNERABLE))
				if(!mobfound.reagents.total_volume) // Stops division by zero runtime
					bloodonly = TRUE
				// Take half from each unless only taking blood, then take all from blood instead
				mobfound.take_blood(X, (min(amount, energy * 10, space)) / (2 - bloodonly))
				if(!bloodonly)
					mobfound.reagents.trans_to(U, (min(amount, energy * 10, space)) / 2)
				energy = max(energy - min(amount, energy * 10, space) / 10, 0)
			else if(chemfound && !(input_reagent in prohibited_reagents) && !((input_reagent in emagged_only_reagents) && !emagged))
				U.add_reagent(input_reagent, min(amount, energy * 10, space))
				energy = max(energy - min(amount, energy * 10, space) / 10, 0)
			else
				say("OUT OF RANGE")
		else
			U.add_reagent(APPLEJUICE, min(amount, energy * 10, space)) // room temperature superconductor
			energy = max(energy - min(amount, energy * 10, space) / 10, 0)

	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/chem_dispenser/scp_294/update_icon()
	return

/obj/machinery/chem_dispenser/scp_294/emag_act()
	..()
	emagged = TRUE
