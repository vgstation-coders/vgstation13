/obj/item/weapon/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	starting_materials = list(MAT_IRON = 500)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL
	var/obj/target = null // this can be used to override disk tracking on normal pinpointers (ie. for shunted malf ais)
	var/active = FALSE
	var/watches_nuke = TRUE
	var/pinpointable = TRUE//is it being tracked by the pinpointer pinpointer
var/list/pinpointerpinpointer_list = list()

/obj/item/weapon/pinpointer/New()
	..()
	pinpointer_list.Add(src)
	if (pinpointable == TRUE)
		pinpointerpinpointer_list.Add(src)

/obj/item/weapon/pinpointer/Destroy()
	fast_objects -= src
	pinpointer_list.Remove(src)
	pinpointerpinpointer_list.Remove(src)

	..()

/obj/item/weapon/pinpointer/dissolvable()
	return FALSE

/obj/item/weapon/pinpointer/attack_self()
	if(!active)
		active = TRUE
		workdisk()
		to_chat(usr,"<span class='notice'>You activate \the [src]</span>")
		playsound(src, 'sound/items/healthanalyzer.ogg', 30, 1)
		fast_objects += src
	else
		active = FALSE
		icon_state = "pinoff"
		to_chat(usr,"<span class='notice'>You deactivate \the [src]</span>")
		fast_objects -= src

/obj/item/weapon/pinpointer/proc/workdisk()
	process()

/obj/item/weapon/pinpointer/process()
	if(target)
		point_at(target)
		return
	point_at(nukedisk)

/obj/item/weapon/pinpointer/proc/point_at(atom/target)
	if(!active)
		return
	if(!target)
		icon_state = "pinonnull"
		return

	var/turf/T = get_turf(target)
	var/turf/L = get_turf(src)
	update_icon(L,T)

/obj/item/weapon/pinpointer/update_icon(turf/location,turf/target)
	if(!target || !location)
		icon_state = "pinonnull"
		return
	if(target.z != location.z)
		icon_state = "pinonnull"
	else
		dir = get_dir(location,target)
		switch(get_dist(location,target))
			if(-1)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"

/obj/item/weapon/pinpointer/examine(mob/user)
	..()
	if(watches_nuke)
		var/bomb_timeleft
		for(var/obj/machinery/nuclearbomb/bomb in machines)
			if(bomb.timing)
				bomb_timeleft = bomb.timeleft
		if(bomb_timeleft)
			to_chat(user,"<span class='danger'>Extreme danger. Arming signal detected. Time remaining: [bomb_timeleft]</span>")
		else
			to_chat(user,"<span class='info'>No active nuclear devices detected.</span>")

/obj/item/weapon/pinpointer/advpinpointer
	name = "Advanced Pinpointer"
	icon = 'icons/obj/device.dmi'
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
	var/mode = 0  // Mode 0 locates disk, mode 1 locates coordinates.
	var/turf/location = null
	watches_nuke = FALSE
	pinpointable = FALSE
	var/list/item_paths = list()

/obj/item/weapon/pinpointer/advpinpointer/New()
	for(var/index in potential_theft_objectives)
		var/list/datumlist = potential_theft_objectives[index]
		for(var/D in datumlist)
			var/datum/theft_objective/O = D
			var/obj/Dtypepath = initial(O.typepath)
			item_paths[initial(Dtypepath.name)] = Dtypepath


/obj/item/weapon/pinpointer/advpinpointer/attack_self()
	if(!active)
		active = TRUE
		fast_objects += src
		process()
		to_chat(usr,"<span class='notice'>You activate the pinpointer</span>")
	else
		fast_objects -= src
		active = FALSE
		icon_state = "pinoff"
		to_chat(usr,"<span class='notice'>You deactivate the pinpointer</span>")

/obj/item/weapon/pinpointer/advpinpointer/process()
	switch(mode)
		if(0)
			point_at(nukedisk)
		if(1)
			point_at(location)
		if(2)
			point_at(target)

/obj/item/weapon/pinpointer/advpinpointer/AltClick(var/mob/user)
	if((usr.incapacitated() || !Adjacent(usr)))
		return
	toggle_mode()

/obj/item/weapon/pinpointer/advpinpointer/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in view(1)

	active = FALSE
	icon_state = "pinoff"
	target=null
	location = null

	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Location", "Disk Recovery", "Other Signature"))
		if("Location")
			mode = 1

			var/locationx = input(usr, "Please input the x coordinate to search for.", "Location?" , "") as num
			if(!locationx || !Adjacent(usr))
				return
			var/locationy = input(usr, "Please input the y coordinate to search for.", "Location?" , "") as num
			if(!locationy || !Adjacent(usr))
				return

			var/turf/locationz = get_turf(src)
			location = locate(locationx,locationy,locationz.z)
			to_chat(usr, "<span class='notice'>You set the pinpointer to locate ([locationx], [locationy], [locationz.z])</span>")

			return attack_self()

		if("Disk Recovery")
			mode = 0
			return attack_self()

		if("Other Signature")
			mode = 2
			switch(alert("Search for item signature or DNA fragment?" , "Signature Mode Select" , "" , "Item" , "DNA"))
				if("Item")
					var/targetitem = input("Select item to search for.", "Item Mode Select","") as null|anything in item_paths
					if(!targetitem)
						return
					target=locate(item_paths[targetitem])
					if(!target)
						to_chat(usr,"Failed to locate [targetitem]!")
						return
					to_chat(usr,"You set the pinpointer to locate [targetitem]")
				if("DNA")
					var/DNAstring = input("Input DNA string to search for." , "Please Enter String." , "")
					if(!DNAstring)
						return
					for(var/mob/living/carbon/M in mob_list)
						if(!M.dna)
							continue
						if(M.dna.unique_enzymes == DNAstring)
							target = M
							break

			return attack_self()


///////////////////////
//nuke op pinpointers//
///////////////////////


/obj/item/weapon/pinpointer/nukeop
	var/mode = 0	//Mode 0 locates disk, mode 1 locates the shuttle
	var/obj/machinery/computer/shuttle_control/syndicate/home = null
	pinpointable = FALSE


/obj/item/weapon/pinpointer/nukeop/attack_self(mob/user as mob)
	if(!active)
		active = TRUE
		if(!mode)
			to_chat(user,"<span class='notice'>Authentication Disk Locator active.</span>")
		else
			to_chat(user,"<span class='notice'>Shuttle Locator active.</span>")
		process()
		fast_objects += src
	else
		active = FALSE
		icon_state = "pinoff"
		to_chat(user,"<span class='notice'>You deactivate the pinpointer.</span>")
		fast_objects -= src


/obj/item/weapon/pinpointer/nukeop/process()
	if(mode)		//Check in case the mode changes while operating
		worklocation()
	else
		workdisk()

/obj/item/weapon/pinpointer/nukeop/workdisk()
	if(bomb_set)	//If the bomb is set, lead to the shuttle
		mode = 1	//Ensures worklocation() continues to work
		worklocation()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator active.")			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	point_at(nukedisk)

/obj/item/weapon/pinpointer/nukeop/proc/worklocation()
	if(!bomb_set)
		mode = 0
		workdisk()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
		visible_message("<span class='notice'>Authentication Disk Locator active.</span>")
		return
	if(!home)
		home = locate()
		if(!home)
			icon_state = "pinonnull"
			return
	point_at(home)

/obj/item/weapon/pinpointer/pdapinpointer
	name = "pda pinpointer"
	desc = "A pinpointer that has been illegally modified to track the PDA of a crewmember for malicious reasons."
	watches_nuke = FALSE
	pinpointable = FALSE
	var/dna_profile
	var/nextuse

/obj/item/weapon/pinpointer/pdapinpointer/examine(mob/user)
	..()
	var/timeuntil = altFormatTimeDuration(max(0, nextuse-world.time))
	to_chat(user, "<span class='notice'>[src] [timeuntil ? "can select a target again in [timeuntil]." : "is ready to select a new target!"]</span>") 
	

/obj/item/weapon/pinpointer/pdapinpointer/attack_self()
	if(!active)
		active = TRUE
		process()
		fast_objects += src
		to_chat(usr,"<span class='notice'>You activate the pinpointer</span>")
	else
		active = FALSE
		fast_objects -= src
		icon_state = "pinoff"
		to_chat(usr,"<span class='notice'>You deactivate the pinpointer</span>")

/obj/item/weapon/pinpointer/pdapinpointer/process()
	point_at(target)

/obj/item/weapon/pinpointer/pdapinpointer/verb/select_pda()
	set category = "Object"
	set name = "Select pinpointer target"
	set src in view(1)
	
	if(usr.stat || !src.Adjacent(usr))
		return
	
	if(!dna_profile)
		dna_profile = usr.dna.unique_enzymes
		to_chat(usr, "<span class='notice'>You submit a DNA sample to [src]</span>")
	else if(dna_profile != usr.dna.unique_enzymes)
		to_chat(usr, "<span class='warning'>[src] refuses to operate.</span>")
		return
	else if(nextuse - world.time > 0)
		to_chat(usr, "<span class='warning'>[src] is still recalibrating.</span>")
		return

	var/list/L = list()
	L["Cancel"] = "Cancel"
	var/length = 1
	for (var/obj/item/device/pda/P in PDAs)
		var/turf/T = get_turf(P)
		if(P.name != "\improper PDA" && T.z != map.zCentcomm)
			L[text("([length]) [P.name]")] = P
			length++

	var/t = input("Select pinpointer target.") as null|anything in L
	if(t == "Cancel")
		return
	if(nextuse - world.time > 0)
		return
	target = L[t]
	if(!target)
		to_chat(usr,"Failed to locate [target]!")
		return
	active = TRUE
	point_at(target)
	nextuse = world.time + 2 MINUTES
	to_chat(usr,"You set the pinpointer to locate [target]")

/obj/item/weapon/pinpointer/pdapinpointer/AltClick()
	if(select_pda())
		return
	return ..()

/obj/item/weapon/pinpointer/pdapinpointer/examine(mob/user)
	..()
	if (target)
		to_chat(user,"<span class='notice'>Tracking [target]</span>")

//////////////////////////
//pinpointer pinpointers//
//////////////////////////

/obj/item/weapon/pinpointer/pinpointerpinpointer
	name = "pinpointer pinpointer"
	desc = "Where did that darn pinpointer go? Hmmm... well, good thing I have this trusty pinpointer pinpointer to find it."
	watches_nuke = FALSE
	pinpointable = FALSE


/obj/item/weapon/pinpointer/pinpointerpinpointer/New()
	..()
	overlays += "pinpointerpinpointer"

/obj/item/weapon/pinpointer/pinpointerpinpointer/process()
	var/closest_distance = INFINITY
	var/turf/L = get_turf(src)
	for(var/atom/P in pinpointerpinpointer_list)
		var/turf/T = get_turf(P)
		var/dist_P = abs(cheap_pythag((L.x - T.x), (L.y - T.y)))
		if(dist_P < closest_distance)
			closest_distance = dist_P
			target = P
	point_at(target)
	..()

/obj/item/weapon/pinpointer/implant
	name = "implant pinpointer"
	watches_nuke = FALSE
	var/debug_alerted = FALSE // I don't want to spam the console like a madman

/obj/item/weapon/pinpointer/implant/process()
	var/closest_distance = INFINITY
	var/turf/this_pos = get_turf(src)
	target = null
	for(var/mob/living/dude in living_mob_list)
		var/turf/dude_pos = get_turf(dude)
		if(!dude_pos)
			if(!debug_alerted)
				log_debug("Pinpointer found [dude] of type [dude.type] in nullspace! It being there might be valid or not, please investigate. REF: [ref(dude)]")
				debug_alerted = TRUE
			continue
		if(dude_pos.z != this_pos.z || dude.stat == DEAD || !dude.is_implanted(/obj/item/weapon/implant/loyalty))
			continue
		var/distance = abs(cheap_pythag(this_pos.x - dude_pos.x, this_pos.y - dude_pos.y))
		if(distance < closest_distance)
			closest_distance = distance
			target = dude
	point_at(target)
