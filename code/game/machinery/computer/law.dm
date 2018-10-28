/obj/machinery/computer/lawupload
	name = "Law Upload"
	desc = "Used to upload laws to the silicons using a cheap radio transceiver."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/lawupload"
	light_color = "#555555"
	var/mob/living/silicon/current = null

/obj/machinery/computer/lawupload/proc/validate_use(var/mob/user, var/ignore_target=TRUE)
	if(stat & NOPOWER)
		to_chat(user, "\The [name] has no power!")
		return FALSE
	if(stat & BROKEN)
		to_chat(user, "\The [name] is broken!")
		return FALSE
	if(isobserver(user))
		to_chat(user, "<span class='rose'>Your ghostly hand goes right through \the [name]!</span>")
		return
	if(!ignore_target)
		if(!current)
			to_chat(user, "You haven't selected a target silicon to transmit laws to!")
			return FALSE
		if(!same_zlevel())
			to_chat(user, "<span class='danger'>Unable to establish a connection</span>: \The [name] too far away from [current.name]!")
			return FALSE
		if(!current.CanChangeLaws()) //THE FOLLOWING CODE HAS SO MUCH SNOWFLAKE YOU CAN BASICALLY MAP SNOWMAP ON TOP OF IT
			if(isAI(current))
				var/mob/living/silicon/ai/current_ai = current
				if(current_ai.aiRestorePowerRoutine)
					to_chat(user, "Upload failed. Only a faint signal is being detected from [current_ai.name], and it is not responding to our requests. It may be low on power.")
					return FALSE
			to_chat(user, "Upload failed. No signal is being detected from [current.name]")
			return FALSE

 	//commented out until someone adds the nuke event to blob meteors
	//var/datum/faction/blob_conglomerate/conglomerate = find_active_faction_by_type(/datum/faction/blob_conglomerate)
	//if(conglomerate)
	//	to_chat(usr, "Law uploads have been disabled by Nanotrasen!")
	//	return FALSE

	return TRUE

/obj/machinery/computer/lawupload/proc/install_module(var/obj/item/weapon/aiModule/M,var/mob/user)
	if(!validate_use(user, FALSE))
		return FALSE
	if(!M.validate(current.laws,current,user))
		return FALSE
	if(!M.upload(current.laws,current,user))
		return FALSE
	return TRUE

/obj/machinery/computer/lawupload/proc/announce_law_changes(var/mob/user)
	var/list/announce_targets = list()
	announce_targets += current
	if(isAI(current)) //Why isn't this handled in AI code?
		var/mob/living/silicon/ai/current_ai = current
		for(var/mob/living/silicon/robot/R in current_ai.connected_robots)
			announce_targets += R

	for(var/mob/living/silicon/S in announce_targets)
		S << sound('sound/machines/lawsync.ogg')	
		to_chat(S, "These are your laws now:")
		S.show_laws()
	to_chat(user, "<span class='notice'>Upload complete. [current.name]'s laws have been modified.</span>")

/obj/machinery/computer/lawupload/proc/same_zlevel()
	if(!current)
		return FALSE
	var/turf/T = get_turf(current)
	if(!atoms_share_level(T, src))
		return FALSE
	return TRUE

/obj/machinery/computer/lawupload/attackby(obj/item/weapon/O, mob/user)
	if(!validate_use(user, FALSE))
		return

	if(istype(O, /obj/item/weapon/aiModule))
		if(install_module(O,user))
			announce_law_changes(user)
		return
	
	if(istype(O, /obj/item/weapon/planning_frame))
		var/obj/item/weapon/planning_frame/frame = O
		if(frame.modules.len > 0)
			to_chat(user, "<span class='notice'>You begin to load \the [frame] into \the [name]...</span>")
			if(do_after(user, src, 50))
				var/failed = FALSE
				for(var/i=1;i<=frame.modules.len;i++)
					var/obj/item/weapon/aiModule/M = frame.modules[i]
					to_chat(user, "<span class='notice'>Running [M]...</span>")
					if(!install_module(M,user))
						failed = TRUE
						break
					if(!failed)
						announce_law_changes(user)
						return
		else
			to_chat(user, "<span class='warning'>It's empty, doofus.</span>")
			return
	..()

/obj/machinery/computer/lawupload/attack_hand(var/mob/user)
	if(!validate_use(user))
		return
	var/list/silicon_targets = null
	var/picked_silicon = null

	for(var/mob/living/silicon/S in get_active_ais_and_free_cyborgs())
		var/name = null
		if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			name = "[R.real_name] ([R.modtype]) - [R.braintype]"
		if(isAI(S))
			name = "[S.real_name] - AI"

		if(name)
			silicon_targets[name] = S

	picked_silicon = input(user,"Silicon signals detected:", "Target selection") in silicon_targets
	current = silicon_targets[picked_silicon]
	to_chat(user, "[current ? "[picked_silicon] selected for law changes." : "No target detected." ]")
		

/obj/machinery/computer/lawupload/longrange
	name = "Long Range Law Upload"
	desc = "Used to upload laws to the silicons using a powerful subspace transceiver."
	circuit = "/obj/item/weapon/circuitboard/lawupload/longrange"

/obj/machinery/computer/lawupload/longrange/same_zlevel()
	return TRUE