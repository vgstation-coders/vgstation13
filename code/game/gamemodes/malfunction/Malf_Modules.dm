// TO DO:
/*
epilepsy flash on lights
delay round message
microwave makes robots
dampen radios
reactivate cameras - done
eject engine
core sheild
cable stun
rcd light flash thingy on matter drain



*/
#define MALFUNCTION "Malfunction"
/datum/AI_Module
	var/uses = 0
	var/module_name
	var/mod_pick_name
	var/description = ""
	var/engaged = 0
	var/cost = 5
	var/one_time = 0

	var/spell/power_type = null


/datum/AI_Module/large/
	uses = 1

/datum/AI_Module/small/
	uses = 5
	
/datum/AI_Module/proc/on_purchase(mob/living/silicon/ai/user) //What happens when a module is purchased, by default gives the AI the spell/adds charges to their existing spell if they have it
	if(power_type)
		for(var/spell/S in user.spell_list)
			if (istype(S,power_type))
				S.charge_counter += uses
				return
		user.add_spell(new power_type, "grey_spell_ready",/obj/screen/movable/spell_master/malf)
	
/datum/AI_Module/large/fireproof_core
	module_name = "Core upgrade"
	mod_pick_name = "coreup"
	description = "An upgrade to improve core resistance, making it immune to fire and heat. This effect is permanent."
	cost = 50
	one_time = 1
	
/datum/AI_Module/large/fireproof_core/on_purchase(mob/living/silicon/ai/user)
	user.ai_flags |= COREFIRERESIST
	to_chat(user, "<span class='warning'>Core fireproofed.</span>")

/datum/AI_Module/large/upgrade_turrets
	module_name = "AI Turret upgrade"
	mod_pick_name = "turret"
	description = "Improves the firing speed and health of all AI turrets. This effect is permanent."
	cost = 50
	one_time = 1

/datum/AI_Module/large/upgrade_turrets/on_purchase(mob/living/silicon/ai/user)
	for(var/obj/machinery/turret/turret in machines)
		turret.health += 30
		turret.shot_delay = 20
	to_chat(user, "<span class='warning' Turrets upgraded.</span>")
	
/datum/AI_Module/large/disable_rcd
	module_name = "RCD disable"
	mod_pick_name = "rcd"
	description = "Send a specialised pulse to break all RCD devices on the station."
	cost = 50

	power_type = /spell/aoe_turf/disable_rcd

/spell/aoe_turf/disable_rcd
	name = "Disable RCDs"
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 1
	hud_state = "rcd_disable"
	override_base = "grey"
	
/spell/aoe_turf/disable_rcd/cast(list/targets, mob/user)
	for(var/obj/item/device/rcd/matter/engineering/rcd in world)
		rcd.disabled = 1
	for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in world)
		rcd.disabled = 1
	to_chat(src, "RCD-disabling pulse emitted.")

/datum/AI_Module/small/overload_machine
	module_name = "Machine overload"
	mod_pick_name = "overload"
	description = "Overloads an electrical machine, causing a small explosion. 2 uses."
	uses = 2
	cost = 15
	power_type = /spell/targeted/overload_machine
	
/spell/targeted/overload_machine
	name = "Overload Machine"
	panel = MALFUNCTION
	spell_flags = WAIT_FOR_CLICK
	range = GLOBALCAST
	charge_type = Sp_CHARGES
	charge_max = 2
	hud_state = "overload"
	override_base = "grey"
	
/spell/targeted/overload_machine/is_valid_target(var/atom/target)
	if (istype(target, /obj/machinery))
		var/obj/machinery/M = target
		return M.can_overload()
	else
		to_chat(holder, "That is not a machine.")
	
/spell/targeted/overload_machine/cast(var/list/targets, mob/user)
	var/obj/machinery/M = targets[1]
	M.visible_message("<span class='notice'>You hear a loud electrical buzzing sound!</span>")
	spawn(50)
		explosion(get_turf(M), -1, 1, 2, 3) //C4 Radius + 1 Dest for the machine
		qdel(M)

/datum/AI_Module/large/place_cyborg_transformer
	module_name = "Robotic Factory (Removes Shunting)"
	mod_pick_name = "cyborgtransformer"
	description = "Build a machine anywhere, using expensive nanomachines, that can convert a living human into a loyal cyborg slave when placed inside."
	cost = 100
	
	power_type = /spell/aoe_turf/conjure/place_transformer
	
/spell/aoe_turf/conjure/place_transformer
	name = "Place Robotic Factory"
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 1
	spell_flags = WAIT_FOR_CLICK | NODUPLICATE | IGNORESPACE | IGNOREDENSE
	range = GLOBALCAST
	summon_type = list(/obj/machinery/transformer/conveyor)
	hud_state = "autoborger"
	override_base = "grey"
	
/spell/aoe_turf/conjure/place_transformer/before_target(mob/user)
	var/mob/living/silicon/ai/A = user
	if(!istype(A))
		return 1
	if(!isturf(A.loc)) // AI must be in it's core.
		return 1
	return 0
	
/spell/aoe_turf/conjure/place_transformer/is_valid_target(var/atom/target)
	// Make sure there is enough room.
	if(!isturf(target))
		return 0
	var/turf/middle = target
	var/list/turfs = list(middle, locate(middle.x - 1, middle.y, middle.z), locate(middle.x + 1, middle.y, middle.z))
	var/alert_msg = "There isn't enough room. Make sure you are placing the machine in a clear area and on a floor."
	for(var/T in turfs)
		// Make sure the turfs are clear and the correct type.
		if(!istype(T, /turf/simulated/floor))
			alert(src, alert_msg)
			return
		var/turf/simulated/floor/F = T
		for(var/atom/movable/AM in F.contents)
			if(AM.density)
				alert(src, alert_msg)
				return
	var/datum/camerachunk/C = cameranet.getCameraChunk(middle.x, middle.y, middle.z)
	if(!C.visibleTurfs[middle])
		alert(holder, "We cannot get camera vision of this location.")
		return 0
	return 1
	
/spell/aoe_turf/conjure/place_transformer/cast(var/list/targets,mob/user)
	// All clear, place the transformer
	..()
	playsound(targets[1], 'sound/effects/phasein.ogg', 100, 1)
	var/mob/living/silicon/ai/A = user
	A.can_shunt = 0
	to_chat(user, "You cannot shunt anymore.")

/datum/AI_Module/large/highrescams
	module_name = "High Resolution Cameras"
	mod_pick_name = "High Res Cameras"
	description = "Allows the AI to better interpret the actions of the crew! Read papers and their lips from his cameras!"
	cost = 10
	one_time = 1

/datum/AI_Module/large/highrescams/on_purchase(mob/living/silicon/ai/user)
	user.ai_flags |= HIGHRESCAMS
	user.eyeobj.high_res = 1
	to_chat(user, "Cameras upgraded.")

/datum/AI_Module/small/blackout
	module_name = "Blackout"
	mod_pick_name = "blackout"
	description = "Attempts to overload the lighting circuits on the station, destroying some bulbs. 3 uses."
	uses = 3
	cost = 15

	power_type = /spell/aoe_turf/blackout

/spell/aoe_turf/blackout
	name = "Blackout"
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 3
	hud_state = "blackout"
	override_base = "grey"
	
/spell/aoe_turf/blackout/cast(var/list/targets, mob/user)
	for(var/obj/machinery/power/apc/apc in power_machines)
		if(prob(30*apc.overload))
			apc.overload_lighting()
		else
			apc.overload++

/datum/AI_Module/small/interhack
	module_name = "Fake Centcom Announcement"
	mod_pick_name = "interhack"
	description = "Gain control of the station's automated announcement system, allowing you to create up to 3 fake Centcom announcements - completely undistinguishable from real ones."
	cost = 15
	uses = 3
	power_type = /spell/aoe_turf/interhack

/spell/aoe_turf/interhack
	name = "Fake Announcement"
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 3
	hud_state = "fakemessage"
	override_base = "grey"
	
/spell/aoe_turf/interhack/cast(var/list/targets,mob/user)

	//Create a list which looks like this
	//list( "Alert 1" = /datum/command_alert_1, "Alert 5" = /datum/command_alert_5, ...)
	//Then ask the AI to pick one announcement from the list

	var/list/possible_announcements = typesof(/datum/command_alert)
	for(var/A in possible_announcements)
		var/datum/command_alert/CA = A
		possible_announcements[initial(CA.name)] = A
		possible_announcements.Remove(A)

	var/chosen_announcement = input(user, "Select a fake announcement to send out.", "Interhack") as null|anything in possible_announcements
	if(!chosen_announcement)
		to_chat(user, "Selection cancelled.")
		return 1
	if(!charge_counter)
		to_chat(user, "No more charges.")
		return 1
	command_alert(possible_announcements[chosen_announcement])
	log_game("[key_name(user)] faked a centcom announcement: [possible_announcements[chosen_announcement]]!")
	message_admins("[key_name(user)] faked a centcom announcement: [possible_announcements[chosen_announcement]]!")

/datum/AI_Module/small/reactivate_camera
	module_name = "Reactivate camera"
	mod_pick_name = "recam"
	description = "Reactivates a currently disabled camera. 10 uses."
	uses = 10
	cost = 15

	power_type = /spell/targeted/reactivate_camera

/spell/targeted/reactivate_camera
	name = "Reactivate Camera"
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 10
	range = GLOBALCAST
	spell_flags = WAIT_FOR_CLICK
	hud_state = "camera_reactivate"
	override_base = "grey"
	var/list/camera_images = list()
	
/spell/targeted/reactivate_camera/before_channel(mob/user)
	for(var/obj/machinery/camera/C in cameranet.cameras)
		if(C.status)
			continue
		var/image/I = image(C.icon, C.icon_state)
		I.appearance = C.appearance
		I.plane = ABOVE_LIGHTING_LAYER
		I.alpha = 128
		I.loc = C
		camera_images += I
	user.client.images += camera_images
	
/spell/targeted/reactivate_camera/channel_spell(mob/user = usr, skipcharge = 0, force_remove = 0)
	if(!..())
		return 0
	if(!force_remove && !currently_channeled)
		if(user.client)
			user.client.images -= camera_images
			camera_images.len = 0
	return 1
	
/spell/targeted/reactivate_camera/is_valid_target(var/atom/target)
	if(!istype (target, /obj/machinery/camera))
		to_chat(holder, "That's not a camera.")
		return 0
	else
		var/obj/machinery/camera/C = target
		if(C.status)
			to_chat(holder, "This camera is either active, or not repairable.")
			return 0
	return 1
	
/spell/targeted/reactivate_camera/cast(var/list/targets,mob/user)
	var/obj/machinery/camera/C = targets[1]
	C.deactivate(user)
	if(user.client)
		user.client.images -= camera_images
	camera_images.len = 0
	
/datum/AI_Module/small/upgrade_camera
	module_name = "Upgrade Camera"
	mod_pick_name = "upgradecam"
	description = "Upgrades a camera to have X-Ray vision, Motion and be EMP-Proof. 10 uses."
	uses = 10
	cost = 15
	power_type = /spell/targeted/upgrade_camera

/spell/targeted/upgrade_camera
	name = "Upgrade Camera"
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 10
	spell_flags = WAIT_FOR_CLICK
	range = GLOBALCAST
	hud_state = "camera_upgrade"
	override_base = "grey"
	
/spell/targeted/upgrade_camera/is_valid_target(var/atom/target)
	if(!istype(target, /obj/machinery/camera))
		to_chat(holder, "That is not a camera.")
		return 0
	var/obj/machinery/camera/C = target
	if(!C.assembly)
		return 0
	if(C.isXRay() && C.isEmpProof() && C.isMotion())
		to_chat(holder, "This camera is already upgraded!")
		return 0
	return 1
	
/spell/targeted/upgrade_camera/cast(var/list/targets,mob/user)
	var/obj/machinery/camera/C = targets[1]
	if(!C.isXRay())
		C.upgradeXRay()
		//Update what it can see.
		cameranet.updateVisibility(C, 0)
		
	if(!C.isEmpProof())
		C.upgradeEmpProof()

	if(!C.isMotion())
		C.upgradeMotion()
		// Add it to machines that process
		machines |= C

	C.visible_message("<span class='notice'>[bicon(C)] *beep*</span>")
	to_chat(user, "Camera successully upgraded!")

/spell/aoe_turf/module_picker
	name = "Select Module"
	panel = MALFUNCTION
	var/datum/module_picker/MP
	charge_max = 10
	hud_state = "choose_module"
	override_base = "grey"
	
/spell/aoe_turf/module_picker/New()
	..()
	MP = new /datum/module_picker
	
/spell/aoe_turf/module_picker/Destroy()
	qdel(MP)
	MP = null
	..()
	
/spell/aoe_turf/module_picker/cast(var/list/targets, mob/user)
	MP.use(user)
	
/datum/module_picker
	var/temp = null
	var/processing_time = 100
	var/list/possible_modules = list()

/datum/module_picker/New()
	for(var/type in typesof(/datum/AI_Module))
		var/datum/AI_Module/AM = new type
		if(AM.power_type || AM.one_time)
			src.possible_modules += AM

/datum/module_picker/proc/use(mob/user)
	var/dat
	dat += {"<B>Select use of processing time: (currently #[src.processing_time] left.)</B><BR>
			<HR>
			<B>Install Module:</B><BR>
			<I>The number afterwards is the amount of processing time it consumes.</I><BR>"}
	for(var/datum/AI_Module/module in src.possible_modules)
		dat += "<A href='byond://?src=\ref[src];buy=1;module=\ref[module]'>[module.module_name]</A> <A href='byond://?src=\ref[src];desc=1;module=\ref[module]'>?</A>([module.cost])<BR>"
	dat += "<HR>"
	if (src.temp)
		dat += "[src.temp]"
	var/datum/browser/popup = new(user, "modpicker", "Malf Module Menu")
	popup.set_content(dat)
	popup.open()

/datum/module_picker/Topic(href, href_list)
	..()

	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/A = usr
	
	if(href_list["buy"])
		var/datum/AI_Module/AM = locate(href_list["module"])
		if(AM.cost > src.processing_time)
			temp = "You cannot afford this module."
			return

			// Give the power and take away the money.
		AM.on_purchase(A)
		temp = AM.description
		src.processing_time -= AM.cost
		if(AM.one_time)
			possible_modules -= AM
		stat_collection.malf.bought_modules += AM.module_name

	if(href_list["desc"])
		var/datum/AI_Module/AM = locate(href_list["module"])
		temp = AM.description

	src.use(usr)
