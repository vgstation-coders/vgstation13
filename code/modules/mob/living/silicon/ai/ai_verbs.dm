/mob/living/silicon/ai/verb/toggle_anchor()
	set category = "AI Commands"
	set name = "Toggle Floor Bolts"

	if(incapacitated() || aiRestorePowerRoutine || !isturf(loc) || busy)
		return

	busy = TRUE
	playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(do_after(src, src, 30))
		anchored = !anchored
		to_chat(src, "You are now <b>[anchored ? "" : "un"]anchored</b>.")
	busy = FALSE

/mob/living/silicon/ai/verb/radio_interact()
	set category = "AI Commands"
	set name = "Radio Configuration"

	if(stat || aiRestorePowerRoutine)
		return

	radio.attack_self(usr)

/mob/living/silicon/ai/verb/rename_photo() //This is horrible but will do for now
	set category = "AI Commands"
	set name = "Modify Photo Files"

	if(stat || aiRestorePowerRoutine)
		return

	var/list/nametemp = list()
	var/find
	var/datum/picture/selection
	if(!aicamera.aipictures.len)
		to_chat(usr, "<span class='danger'>No images saved</span>")
		return
	for(var/datum/picture/t in aicamera.aipictures)
		nametemp += t.fields["name"]
	find = input("Select image to delete or rename.", "Photo Modification") in nametemp
	for(var/datum/picture/q in aicamera.aipictures)
		if(q.fields["name"] == find)
			selection = q
			break

	if(!selection)
		return
	var/choice = input(usr, "Would you like to rename or delete [selection.fields["name"]]?", "Photo Modification") in list("Rename","Delete","Cancel")
	switch(choice)
		if("Cancel")
			return
		if("Delete")
			aicamera.aipictures.Remove(selection)
			qdel(selection)
		if("Rename")
			var/new_name = sanitize(input(usr, "Write a new name for [selection.fields["name"]]:","Photo Modification"))
			if(length(new_name) > 0)
				selection.fields["name"] = new_name
			else
				to_chat(usr, "You must write a name.")

/mob/living/silicon/ai/verb/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"

	if(stat || aiRestorePowerRoutine)
		return
	
	var/selected = input("Select an icon!", "AI", null, null) as null|anything in possible_ai_icon_states

	if(!selected)
		return

	var/chosen_state = possible_ai_icon_states[selected]
	ASSERT(chosen_state)
	chosen_core_icon_state = chosen_state
	update_icon()

/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"

	unset_machine()
	cameraFollow = null
	var/cameralist[0]

	if(usr.isDead())
		to_chat(usr, "You can't change your camera network because you are dead!")
		return

	var/mob/living/silicon/ai/U = usr

	for (var/obj/machinery/camera/C in cameranet.cameras)
		if(!C.can_use())
			continue

		var/list/tempnetwork = difflist(C.network,RESTRICTED_CAMERA_NETWORKS,1)
		if(tempnetwork.len)
			for(var/i in tempnetwork)
				cameralist[i] = i
	var/old_network = network
	network = input(U, "Which network would you like to view?") as null|anything in cameralist

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.forceMove(get_turf(C))
				break
		to_chat(src, "<span class='notice'>Switched to [network] camera network.</span>")

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI Status"

	if(usr.isDead())
		to_chat(usr, "You cannot change your emotional status because you are dead!")
		return

	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions //ai_emotions can be found in code/game/machinery/status_display.dm @ 213 (above the AI status display)

	for (var/obj/machinery/M in status_displays) //change status
		if(istype(M, /obj/machinery/ai_status_display))
			var/obj/machinery/ai_status_display/AISD = M
			AISD.emotion = emote
		//if Friend Computer, change ALL displays
		else if(istype(M, /obj/machinery/status_display))

			var/obj/machinery/status_display/SD = M
			if(emote=="Friend Computer")
				SD.friendc = TRUE
			else
				SD.friendc = FALSE

/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	var/input
	if(alert("Would you like to select a hologram based on a crew member or switch to unique avatar?",,"Crew Member","Unique")=="Crew Member")

		var/personnel_list[] = list()

		for(var/datum/data/record/t in data_core.locked)//Look in data core locked.
			personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["image"]//Pull names, rank, and image.

		if(personnel_list.len)
			input = input("Select a crew member:") as null|anything in personnel_list
			var/icon/character_icon = personnel_list[input]
			if(character_icon)
				qdel(holo_icon)//Clear old icon so we're not storing it in memory.
				holo_icon = getHologramIcon(icon(character_icon))
		else
			alert("No suitable records found. Aborting.")

	else
		var/icon_list[] = list(
		"Default",
		"Floating face",
		"Cortano",
		"Spoopy",
		"343",
		"Auto",
		"Four-Leaf",
		"Yotsuba",
		"Girl",
		"Boy",
		"SHODAN",
		"Corgi",
		"Mothman"
		)
		input = input("Please select a hologram:") as null|anything in icon_list
		if(input)
			qdel(holo_icon)
			holo_icon = null
			switch(input)
				if("Default")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))
				if("Floating face")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo2"))
				if("Cortano")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo3"))
				if("Spoopy")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo4"))
				if("343")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo5"))
				if("Auto")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo6"))
				if("Four-Leaf")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo7"))
				if("Yotsuba")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo8"))
				if("Girl")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo9"))
				if("Boy")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo10"))
				if("SHODAN")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo11"))
				if("Corgi")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo12"))
				if("Mothman")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo13"))

//Toggles the luminosity and applies it by re-entereing the camera.
/mob/living/silicon/ai/verb/toggle_camera_light()
	set name = "Toggle Camera Light"
	set desc = "Toggle internal infrared camera light"
	set category = "AI Commands"

	if(stat != CONSCIOUS)
		return

	camera_light_on = !camera_light_on

	if(!camera_light_on)
		to_chat(src, "Camera lights deactivated.")

		for (var/obj/machinery/camera/C in lit_cameras)
			C.set_light(FALSE)
			lit_cameras = list()

		return

	light_cameras()

	to_chat(src, "Camera lights activated.")

/mob/living/silicon/ai/verb/toggle_station_map()
	set name = "Toggle Station Holomap"
	set desc = "Toggle station holomap on your screen"
	set category = "AI Commands"

	if(isUnconscious())
		return

	station_holomap.toggleHolomap(src,1)

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "AI Commands"

	if(isDead())
		to_chat(src, "You can't send the shuttle back because you are dead!")
		return
	if(istype(usr,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = src
		if(AI.control_disabled)
			to_chat(src, "Wireless control is disabled!")
			return
	recall_shuttle(src)