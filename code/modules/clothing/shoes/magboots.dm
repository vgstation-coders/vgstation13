/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/base_state = "magboots"
	var/magpulse = 0
	var/mag_slow = MAGBOOTS_SLOWDOWN_HIGH
//	clothing_flags = NOSLIP //disabled by default
	actions_types = list(/datum/action/item_action/toggle_magboots)
	species_fit = list(VOX_SHAPED)
	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/magboots

	var/stomp_attack_power = 45
	var/stomp_delay = 3 SECONDS
	var/stomp_boot = "magboot"
	var/stomp_hit = "crushes"
	var/anchoring_system_examine = "Its mag-pulse traction system appears to be"

/obj/item/clothing/shoes/magboots/on_kick(mob/living/carbon/human/user, mob/living/victim)
	if(!stomp_attack_power)
		return

	var/turf/T = get_turf(src)
	var/datum/organ/external/affecting = victim.get_organ(user.get_unarmed_damage_zone(victim))

	if(magpulse && victim.lying && T == victim.loc && !istype(T, /turf/space)) //To stomp on somebody, you have to be on the same tile as them. You can't be in space, and they have to be lying
		//NUCLEAR MAGBOOT STUMP INCOMING (it takes 3 seconds)

		user.visible_message("<span class='danger'>\The [user] slowly raises \his [stomp_boot] above the lying [victim.name], preparing to stomp on \him.</span>")
		toggle()

		if(do_after(user, src, stomp_delay))
			if(magpulse)
				return //Magboots enabled
			if(!victim.lying || (victim.loc != T))
				return //Victim moved

			user.attack_log += "\[[time_stamp()]\] Magboot-stomped <b>[user] ([user.ckey])</b>"
			victim.attack_log += "\[[time_stamp()]\] Was magboot-stomped by <b>[src] ([victim.ckey])</b>"

			victim.visible_message("<span class='danger'>\The [user] [stomp_hit] \the [victim] with the activated [src.name]!", "<span class='userdanger'>\The [user] [stomp_hit] you with \his [src.name]!</span>")
			victim.apply_damage(stomp_attack_power, BRUTE, affecting)
			playsound(get_turf(victim), 'sound/effects/gib3.ogg', 100, 1)
		else
			return

		toggle()
		playsound(get_turf(victim), 'sound/mecha/mechstep.ogg', 100, 1)

/obj/item/clothing/shoes/magboots/proc/toggle()
	if(usr.isUnconscious())
		return
	if(src.magpulse)
		src.clothing_flags &= ~NOSLIP
		src.slowdown = NO_SLOWDOWN
		src.magpulse = 0
		icon_state = "[base_state]0"
		to_chat(usr, "You disable the mag-pulse traction system.")
	else
		src.clothing_flags |= NOSLIP
		src.slowdown = mag_slow
		src.magpulse = 1
		icon_state = "[base_state]1"
		to_chat(usr, "You enable the mag-pulse traction system.")
	usr.update_inv_shoes()	//so our mob-overlays update

/obj/item/clothing/shoes/magboots/attack_self()
	src.toggle()
	..()
	return

/obj/item/clothing/shoes/magboots/examine(mob/user)
	..()
	var/state = " disabled."
	if(src.clothing_flags&NOSLIP)
		state = " enabled."
	to_chat(user, "<span class='info'>[anchoring_system_examine][state]</span>")

//CE
/obj/item/clothing/shoes/magboots/elite
	desc = "Advanced magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "advanced magboots"
	icon_state = "CE-magboots0"
	base_state = "CE-magboots"
	mag_slow = MAGBOOTS_SLOWDOWN_LOW

//Atmos techies die angry
/obj/item/clothing/shoes/magboots/atmos
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle. These are painted in the colors of an atmospheric technician."
	name = "atmospherics magboots"
	icon_state = "atmosmagboots0"
	base_state = "atmosmagboots"

//Paramedic
/obj/item/clothing/shoes/magboots/para
	name = "Paramedic magboots"
	icon_state = "para_magboots0"
	base_state = "para_magboots"

//Death squad
/obj/item/clothing/shoes/magboots/deathsquad
	desc = "Very expensive and advanced magnetic boots, used only by the elite during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "deathsquad magboots"
	icon_state = "DS-magboots0"
	base_state = "DS-magboots"
	mag_slow = NO_SLOWDOWN

//Syndicate
/obj/item/clothing/shoes/magboots/syndie
	name = "blood-red magboots"
	desc = "Reverse-engineered red magnetic boots that have a heavy magnetic pull. A tag on it says \"Property of Gorlex Marauders\"."
	icon_state = "syndiemag0"
	base_state = "syndiemag"
	species_fit = list(VOX_SHAPED)

//Captain
/obj/item/clothing/shoes/magboots/captain
	desc = "A relic predating magboots, these ornate greaves have retractable spikes in the soles to maintain grip."
	name = "captain's greaves"
	icon_state = "capboots0"
	base_state = "capboots"
	anchoring_system_examine = "Its anchoring spikes appear to be"

/obj/item/clothing/shoes/magboots/captain/toggle()
	//set name = "Toggle Floor Grip"
	if(usr.isUnconscious())
		return
	if(src.magpulse)
		src.clothing_flags &= ~NOSLIP
		src.slowdown = NO_SLOWDOWN
		src.magpulse = 0
		icon_state = "[base_state]0"
		to_chat(usr, "You stop ruining the carpet.")
	else
		src.clothing_flags |= NOSLIP
		src.slowdown = mag_slow
		src.magpulse = 1
		icon_state = "[base_state]1"
		to_chat(usr, "Small spikes shoot from your shoes and dig into the flooring, bracing you.")