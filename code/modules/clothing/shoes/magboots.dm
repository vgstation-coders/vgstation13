/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle. They're large enough to be worn over other footwear."
	name = "magboots"
	icon_state = "magboots0"
	var/base_state = "magboots"
//	clothing_flags = NOSLIP //disabled by default
	actions_types = list(/datum/action/item_action/toggle_magboots)
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/magboots
	w_class = W_CLASS_LARGE

	var/stomp_attack_power = 45
	var/stomp_delay = 3 SECONDS
	var/stomp_boot = "magboot"
	var/stomp_hit = "crushes"
	var/anchoring_system_examine = "Its mag-pulse traction system appears to be"

	var/obj/item/clothing/shoes/stored_shoes = null	//Shoe holder

/obj/item/clothing/shoes/magboots/mob_can_equip(mob/living/carbon/human/user, slot, disable_warning = 0)
	var/mob/living/carbon/human/H = user
	if(!istype(H) || stored_shoes)
		return ..()
	if(slot != slot_shoes)
		return CANNOT_EQUIP
	if(H.shoes)
		stored_shoes = H.shoes
		if(stored_shoes.w_class >= w_class)
			if(!disable_warning)
				to_chat(H, "<span class='danger'>You are unable to wear \the [src] as \the [H.shoes] are in the way.</span>")
			stored_shoes = null
			return CANNOT_EQUIP
		H.remove_from_mob(stored_shoes)
		stored_shoes.forceMove(src)

	if(!..())
		if(stored_shoes)
			if(!H.equip_to_slot_if_possible(stored_shoes, slot_shoes))
				stored_shoes.forceMove(get_turf(src))
			stored_shoes = null
		return CANNOT_EQUIP

	if(stored_shoes)
		to_chat(H, "<span class='info'>You slip \the [src] on over \the [stored_shoes].</span>")
	return CAN_EQUIP

/obj/item/clothing/shoes/magboots/unequipped(mob/living/carbon/human/H, var/from_slot = null)
	..()
	if(from_slot == slot_shoes && istype(H))
		if(stored_shoes)
			if(!H.equip_to_slot_if_possible(stored_shoes, slot_shoes))
				stored_shoes.forceMove(get_turf(src))
			stored_shoes = null

/obj/item/clothing/shoes/magboots/verb/toggle_magboots()
	set src in usr
	set name = "Toggle Magboots"
	set category = "Object"
	if (!usr || loc != usr)
		return
	return togglemagpulse(usr) // Sanity is handled there.

/obj/item/clothing/shoes/magboots/on_kick(mob/living/carbon/human/user, mob/living/victim)
	if(!stomp_attack_power)
		return

	var/turf/T = get_turf(src)
	var/datum/organ/external/affecting = victim.get_organ(user.get_unarmed_damage_zone(victim))

	if((clothing_flags & MAGPULSE) && victim.lying && T == victim.loc && !istype(T, /turf/space)) //To stomp on somebody, you have to be on the same tile as them. You can't be in space, and they have to be lying
		//NUCLEAR MAGBOOT STUMP INCOMING (it takes 3 seconds)

		user.visible_message("<span class='danger'>\The [user] slowly raises \his [stomp_boot] above the lying [victim], preparing to stomp on \him.</span>")
		togglemagpulse(user)

		if(do_after(user, src, stomp_delay))
			if((clothing_flags & MAGPULSE))
				return //Magboots enabled
			if(!victim.lying || (victim.loc != T))
				return //Victim moved

			user.attack_log += "\[[time_stamp()]\] Magboot-stomped <b>[user] ([user.ckey])</b>"
			victim.attack_log += "\[[time_stamp()]\] Was magboot-stomped by <b>[src] ([victim.ckey])</b>"

			victim.visible_message("<span class='danger'>\The [user] [stomp_hit] \the [victim] with the activated [src.name]!", "<span class='userdanger'>\The [user] [stomp_hit] you with \his [src.name]!</span>")
			victim.apply_damage(stomp_attack_power, BRUTE, affecting)
			playsound(victim, 'sound/effects/gib3.ogg', 100, 1)
		else
			return

		togglemagpulse(user)
		playsound(victim, 'sound/mecha/mechstep.ogg', 100, 1)

/obj/item/clothing/shoes/magboots/attack_self()
	src.togglemagpulse()
	..()
	return

/obj/item/clothing/shoes/magboots/emag_act(var/mob/user)
	emagged = TRUE
	spark(src)
	clothing_flags &= ~(NOSLIP | MAGPULSE)
	slowdown = SHACKLE_SHOES_SLOWDOWN
	icon_state = "[base_state]1"
	to_chat(user, "<span class='danger'>You override the mag-pulse traction system!</span>")
	user.update_inv_shoes()	//so our mob-overlays update

/obj/item/clothing/shoes/magboots/attackby(var/obj/item/O, var/mob/user)
	..()
	if(issolder(O) && emagged)
		var/obj/item/tool/solder/S = O
		if(S.remove_fuel(10,user))
			O.playtoolsound(user.loc, 25)
			emagged = FALSE
			slowdown = NO_SLOWDOWN
			icon_state = "[base_state]0"
			to_chat(user, "<span class='notice'>You restore the mag-pulse traction system.</span>")
			user.update_inv_shoes()	//so our mob-overlays update

/obj/item/clothing/shoes/magboots/togglemagpulse(var/mob/user = usr)
	if(user.isUnconscious())
		return
	if(emagged)
		to_chat(user, "<span class='warning'>The mag-pulse traction system cannot be turned off!</span>")
		return
	if(clothing_flags & MAGPULSE)
		clothing_flags &= ~(NOSLIP | MAGPULSE)
		slowdown = NO_SLOWDOWN
		icon_state = "[base_state]0"
		to_chat(user, "You disable the mag-pulse traction system.")
	else
		clothing_flags |= (NOSLIP | MAGPULSE)
		slowdown = mag_slow
		icon_state = "[base_state]1"
		to_chat(user, "You enable the mag-pulse traction system.")
	user.update_inv_shoes()	//so our mob-overlays update

/obj/item/clothing/shoes/magboots/examine(mob/user)
	..()
	var/state = " disabled."
	if(src.clothing_flags&MAGPULSE)
		state = " enabled."
	to_chat(user, "<span class='info'>[anchoring_system_examine][state]</span>")

//CE
/obj/item/clothing/shoes/magboots/elite
	desc = "Advanced magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "advanced magboots"
	icon_state = "CE-magboots0"
	base_state = "CE-magboots"
	mag_slow = MAGBOOTS_SLOWDOWN_LOW
	species_fit = list(VOX_SHAPED)

//Atmos techies die angry
/obj/item/clothing/shoes/magboots/atmos
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle. These are painted in the colors of an atmospheric technician."
	name = "atmospherics magboots"
	icon_state = "atmosmagboots0"
	base_state = "atmosmagboots"
	species_fit = list(VOX_SHAPED)

//Paramedic
/obj/item/clothing/shoes/magboots/para
	name = "Paramedic magboots"
	icon_state = "para_magboots0"
	base_state = "para_magboots"

//Trauma Team
/obj/item/clothing/shoes/magboots/trauma
	name = "Trauma Team magboots"
	icon_state = "trauma_magboots0"
	base_state = "trauma_magboots"

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
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/shoes/magboots/syndie/elite
	name = "advanced blood-red magboots"
	desc = "Reverse-engineered red magnetic boots that have a heavy magnetic pull. These ones include brand new magnet technology stolen from NT. A tag on it says \"Property of Gorlex Marauders\"."
	icon_state = "syndiemag0"
	base_state = "syndiemag"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	mag_slow = MAGBOOTS_SLOWDOWN_LOW

/obj/item/clothing/shoes/magboots/syndie/emag_act() // not emaggable
	return

//Captain
/obj/item/clothing/shoes/magboots/captain
	desc = "A relic predating magboots, these ornate greaves have retractable spikes in the soles to maintain grip."
	name = "captain's greaves"
	icon_state = "capboots0"
	base_state = "capboots"
	anchoring_system_examine = "Its anchoring spikes appear to be"

//Magnificent
/obj/item/clothing/shoes/magboots/magnificent
	desc = "The secret meaning of what mag stands for."
	name = "magnificent mag boots"
	icon_state = "MAGNIFICENTboots0"
	base_state = "MAGNIFICENTboots"

/obj/item/clothing/shoes/magboots/captain/togglemagpulse(var/mob/user = usr)
	//set name = "Toggle Floor Grip"
	if(user.isUnconscious())
		return
	if((clothing_flags & MAGPULSE))
		clothing_flags &= ~(NOSLIP | MAGPULSE)
		slowdown = NO_SLOWDOWN
		icon_state = "[base_state]0"
		to_chat(user, "You stop ruining the carpet.")
		return 0
	else
		clothing_flags |= (NOSLIP | MAGPULSE)
		slowdown = mag_slow
		icon_state = "[base_state]1"
		to_chat(user, "Small spikes shoot from your shoes and dig into the flooring, bracing you.")
		return 1


/obj/item/clothing/shoes/magboots/funk
	name = "neo-soviet funk boots"
	desc = "The top secret plan to end Cold war 2 was not through tactical nuclear exchange and espionage, but through an intense dance-off between the Neo-Soviet Premier and the United Fronts President."
	icon_state = "funk"
	base_state = "funk"
	var/funk_level = 0
	canremove = 0

/obj/item/clothing/shoes/magboots/funk/togglemagpulse(var/mob/user = usr)
	if(user.isUnconscious())
		return
	if(funk_level >= 11) //WE HAVE GONE TOO FAR, COMRADE
		return
	user.visible_message("<span class = 'warning'>[usr] dials up \the [src]'s funk level to [funk_level+1]</span>")
	funk_level++
	if(funk_level >= 2)
		clothing_flags |= (NOSLIP | MAGPULSE)

/obj/item/clothing/shoes/magboots/funk/step_action()
	..()
	var/mob/living/carbon/human/H = loc
	//Evaluate L-RUSS levels
	var/russian = 1
	if(H.head)
		if(H.head.type == /obj/item/clothing/head/bearpelt)
			russian+=1
		if(H.head.type == /obj/item/clothing/head/bearpelt/real)
			russian+=2
	if(!H.w_uniform)
		russian++
	else
		if(H.w_uniform.type == /obj/item/clothing/under/russobluecamooutfit || istype(H.w_uniform, /obj/item/clothing/under/neorussian))
			russian+=2
	if(findtext("putin",lowertext(H.name)))
		russian+=5
	else if(findtext("ivan",lowertext(H.name)) || findtext("yuri",lowertext(H.name)) || findtext("vlad",lowertext(H.name) && !findtext("putin",lowertext(H.name))) || findtext("lenin",lowertext(H.name)) || findtext("boris",lowertext(H.name)) || findtext("sasha",lowertext(H.name)) || findtext("misha",lowertext(H.name)) || findtext("sergei",lowertext(H.name)))
		russian+=3
	if(H.reagents.has_reagent(VODKA)) //REAL vodka, not any derivative of greyshit vodka
		russian+=2

	if(funk_level > 2 && prob((50/russian)**funk_level))
		var/datum/organ/external/foot = H.pick_usable_organ(LIMB_LEFT_FOOT, LIMB_RIGHT_FOOT)
		if(foot.take_damage((rand(1, 3)/10)*funk_level, 0))
			H.UpdateDamageIcon()

	if(funk_level > 4 && prob((10/russian)*funk_level))
		H.reagents.add_reagent(HYPERZINE, 1)

	/** IT WAS TOO MUCH, SERGEI
	if(funk_level > 5 && prob((20/russian)*funk_level)) //IT IS TOO LATE, SERGEI
		step_rand(H)
	**/
	if(funk_level > 6 && prob((10/russian)*funk_level))
		H.reagents.add_reagent(HYPOZINE, 1)

	if(funk_level > 9 && prob((5/russian)*funk_level))
		explosion(get_turf(src), round(((1*funk_level)+russian)*0.25), round(((1*funk_level)+russian)*0.5), round((1*funk_level)+russian))

	if(prob((funk_level/russian)*2)) //IT WAS ALWAYS TOO LATE
		togglemagpulse(H)

/obj/item/clothing/shoes/magboots/funk/OnMobDeath(var/mob/living/carbon/human/wearer)
	var/mob/living/carbon/human/W = wearer
	W.drop_from_inventory(src)
	funk_level = 0
	canremove = 1
	clothing_flags &= ~(NOSLIP | MAGPULSE)
