//Tools that you don't need to activate

/obj/item/mecha_parts/mecha_equipment/passive/rack
	name = "\improper Exosuit-Mounted Rack"
	desc = "A locking storage rack for the outside of an exosuit. (Can be attached to: Any exosuit)"
	icon_state = "mecha_rack"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_MAGNETS + "=3;"
	is_activateable = FALSE
	var/obj/item/weapon/storage/mechrack/rack

/obj/item/mecha_parts/mecha_equipment/passive/rack/New()
	..()
	rack = new(src)
	rack.mech_part = src

/obj/item/mecha_parts/mecha_equipment/passive/rack/Destroy()
	rack.empty_contents_to(chassis)
	QDEL_NULL(rack)
	..()

/obj/item/mecha_parts/mecha_equipment/passive/rack/detach(atom/moveto=null)
	rack.empty_contents_to(chassis)
	..()

/obj/item/weapon/storage/mechrack
	name = "exosuit storage rack"
	desc = "A large rack for an exosuit."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_rack"
	fits_max_w_class = W_CLASS_LARGE
	max_combined_w_class = 28
	slot_flags = 0
	rustle_sound = "rustle-metal"
	var/obj/item/mecha_parts/mecha_equipment/mech_part

/obj/item/weapon/storage/mechrack/Destroy()
	mech_part = null
	..()

/obj/item/weapon/storage/mechrack/distance_interact(mob/user)
	var/obj/mecha/M = mech_part.chassis
	if(istype(M) && M.operation_allowed(user))
		if(in_range(user,M))
			playsound(M, 'sound/effects/rustle-metal.ogg', 50, 1, -5)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/passive/runningboard
	name = "\improper Powered Exosuit Running Board"
	desc = "A running board with a power lifter attachment to catapult the pilot quickly into the cockpit. (Can be attached to: Working exosuits)"
	icon_state = "mecha_runningboard"
	origin_tech = Tc_MATERIALS + "=6;"
	is_activateable = FALSE

/obj/item/mecha_parts/mecha_equipment/passive/runningboard/can_attach(obj/mecha/working/W)
	if(..())
		if(istype(W))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/passive/killdozer_kit
	name = "ripley killdozer kit"
	desc = "A set of thick armor plates and gun mounts."
	icon = 'icons/obj/device.dmi'
	icon_state = "modkit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	is_activateable = FALSE
	origin_tech = Tc_MATERIALS + "=3;" + Tc_MAGNETS + "=3;" + Tc_SYNDICATE + "=2;"
	starting_materials = list(MAT_IRON = 112500, MAT_GLASS = 500)
	
/obj/item/mecha_parts/mecha_equipment/passive/killdozer_kit/can_attach(obj/mecha/working/W)
	if(!..())
		return 0
	if(istype(W,/obj/mecha/working/ripley))
		return 1
	
/obj/item/mecha_parts/mecha_equipment/passive/killdozer_kit/attach(obj/mecha/working/ripley/R)
	..()
	R.mech_sprites = list("killdozer","killdozer_clean")
	R.icon_state = "killdozer"
	R.initial_icon = "killdozer"
	R.damage_absorption = list("brute"=0.01,"fire"=0.05,"bullet"=0.01,"laser"=0.05,"energy"=0.05,"bomb"=0.1) //good fucking luck killing it without ions
	R.step_in = 2.5 //make it as slow as the mk2 ripley
	R.fast_pressure_step_in = 2.5
	R.slow_pressure_step_in = 4
	R.enclosed = TRUE //so bullets no longer hit the pilot

/obj/item/mecha_parts/mecha_equipment/passive/killdozer_kit/detach()
	return 0
