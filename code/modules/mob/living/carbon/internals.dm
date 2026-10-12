/mob/living/carbon
	var/oxygen_alert = FALSE
	var/toxins_alert = FALSE
	var/fire_alert = FALSE
	var/pressure_alert = FALSE
	var/temperature_alert = TEMP_ALARM_SAFE
	var/failed_last_breath = FALSE //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.
	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/co2overloadtime = null
	//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_max = 0.5
	var/safe_toxins_mask = 5
	var/SA_para_min = 0.5
	var/SA_sleep_min = 5
	var/oxygen_used = 0

/mob/living/carbon/proc/has_breathing_mask()
	return is_wearing_item(/obj/item/clothing/mask, slot_wear_mask)

/mob/living/carbon/proc/internals_candidates() //These are checked IN ORDER.
	return get_all_slots() + held_items

/mob/living/carbon/human/internals_candidates() //Humans have a lot of slots, so let's give priority to some of them
	var/list/priority = list(s_store, back, belt, l_store, r_store)
	if(wear_suit && isrig(wear_suit)) //Don't forget the rigsuit!
		var/obj/item/clothing/suit/space/rig/rig = wear_suit
		if(rig.T)
			priority += rig.T
	return priority | get_all_slots() | held_items //| operator ensures there are no duplicates

/mob/living/carbon/proc/get_internals_tank()
	for(var/obj/item/weapon/tank/T in internals_candidates())
		//We found a tank!
		if(istype(T, /obj/item/weapon/tank/jetpack)) //Oh... But it's a jetpack... We'll use it if we have to, but let's see if we find something better first
			if(!.) //We already had another jetpack
				. = T
			continue
		else //It's the real deal!
			return T

// Set internals on or off.
/mob/living/carbon/proc/toggle_internals(var/mob/living/user, var/obj/item/weapon/tank/T)
	if(user.incapacitated())
		return

	if(internal)
		internal.add_fingerprint(user)
		equip_internals(null)
		if(user != src)
			if(!user.isGoodPickpocket())
				visible_message("<span class='warning'>\The [user] shuts off \the [src]'s internals!</span>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has disabled [src.name]'s ([src.ckey]) internals.</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='red'>Internals disabled by [user.name] ([user.ckey]).</font>")
			log_attack("[user.name] ([user.ckey]) has disabled [src.name]'s ([src.ckey]) internals.")
		else
			to_chat(user, "<span class='notice'>No longer running on internals.</span>")
		return 1
	else
		if(!has_breathing_mask())
			if(user != src)
				to_chat(user, "<span class='warning'>\The [src] is not wearing a breathing mask.</span>")
			else
				to_chat(user, "<span class='warning'>You are not wearing a breathing mask.</span>")
			return
		if(!T || !T.Adjacent()) //We can be given a specific tank to connect to
			T = get_internals_tank()
			if(!T)
				var/breathes = OXYGEN
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					breathes = H.species.breath_type
				if(user != src)
					to_chat(user, "<span class='warning'>\The [src] does not have \an [breathes] tank.</span>")
				else
					to_chat(user, "<span class='warning'>You don't have \an [breathes] tank.</span>")
				return
		T.add_fingerprint(user)
		equip_internals(T)
		if(user != src)
			var/gas_contents = T.air_contents.english_contents_list()
			if(!user.isGoodPickpocket())
				to_chat(user, "<span class='notice'>\The [user] has enabled [src]'s internals.</span>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has enabled [src.name]'s ([src.ckey]) internals (Gas contents: [gas_contents]).</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='red'>Internals enabled by [user.name] ([user.ckey]) (Gas contents: [gas_contents]).</font>")
			log_attack("[user.name] ([user.ckey]) has enabled [src.name]'s ([src.ckey]) internals (Gas contents: [gas_contents]).")
		else
			to_chat(src, "<span class='notice'>You are now running on internals from \the [T].</span>")
		return 1

/mob/living/carbon/proc/equip_internals(obj/item/weapon/tank/tank)
	internal = tank
	update_internals()

/mob/living/carbon/proc/update_internals()
	if(internals)
		internals.icon_state = "internal-oxy-[internal ? "1" : "0"]"

/mob/living/carbon/human/update_internals()
	if(internals)
		var/breath_string = "oxy"
		if(species)
			switch(species.breath_type)
				if(GAS_NITROGEN)
					breath_string = "nitro"
				if(GAS_PLASMA)
					breath_string = "plasma"
		internals.icon_state = "internal-[breath_string]-[internal ? "1" : "0"]"

/mob/living/carbon/proc/breathe()
	if(!needs_to_breathe())
		return
	if(nobreath)
		nobreath--
		return

	var/breathes_lungs = breathe_lungs()

	var/datum/gas_mixture/environment = loc.return_air()
	var/datum/gas_mixture/breath
	//HACK NEED CHANGING LATER
	if(health < config.health_threshold_crit || !breathes_lungs)
		losebreath++
	if(losebreath > 0) //Suffocating so do not take a breath
		losebreath--
		if(prob(10)) //Gasp per 10 ticks? Sounds about right.
			spawn()
				emote("gasp")
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = get_breath_from_internal(BREATH_VOLUME) // Super hacky -- TLE
		//breath = get_breath_from_internal(0.5) // Manually setting to old BREATH_VOLUME amount -- TLE

		//No breath from internal atmosphere so get breath from location
		if(!breath)
			if(check_breath_block())
				// Breathing blocked
			else if(isobj(loc))
				var/obj/location_as_object = loc
				breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
			else if(isturf(loc))
				if(environment)
					breath = environment.remove_volume(CELL_VOLUME * BREATH_PERCENTAGE)

				if(breath && !check_breath_block(BLOCK_GAS_SMOKE_EFFECT))
					for(var/obj/effect/smoke/chem/smoke in view(1, src))
						if(smoke.reagents && smoke.reagents.total_volume)
							smoke.reagents.reaction(src, INGEST, amount_override = min(smoke.reagents.total_volume,10)/(smoke.reagents.reagent_list.len))
							spawn(5)
								if(smoke && smoke.reagents)
									smoke.reagents.copy_to(src, 10)
							break

					breath_airborne_diseases()

		else
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	if(breath && wear_mask && wear_mask.heat_conductivity < 1)
		var/temp_difference = bodytemperature - breath.temperature
		var/temp_change = (1 - wear_mask.heat_conductivity) * temp_difference
		breath.temperature += temp_change

	handle_breath(breath)

	handle_species_environment(environment, src)

	if(breath)
		loc.assume_air(breath)
/*
		//Spread some viruses while we are at it
		if(virus2 && virus2.len > 0)
			//if(get_infection_chance(src))//checking our own infection protections, so we don't spread an airborne virus if we're wearing internals
			//	for(var/mob/living/M in range(1,src))
			//		if(can_be_infected(M))
			//			spread_disease_to(src,M)
*/

/mob/living/carbon/proc/needs_to_breathe()
	if(flags & INVULNERABLE)
		return FALSE
	if(reagents.has_any_reagents(LEXORINS))
		return FALSE
	if(M_NO_BREATH in mutations)
		return FALSE //No breath mutation means no breathing.
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) //This is an annoying hack given that cryo cells are supposed to be oxygenated, but fuck it
		return FALSE
	return TRUE

/mob/living/carbon/proc/breathe_lungs()
	return TRUE

/mob/living/carbon/proc/handle_species_environment(var/datum/gas_mixture/environment)
	return

/mob/living/carbon/proc/check_breath_block(var/flag_check = BLOCK_BREATHING)
	return

/mob/living/carbon/proc/handle_breath(datum/gas_mixture/breath)
	if((status_flags & GODMODE) || (flags & INVULNERABLE))
		return

	if(!breath || (breath.total_moles == 0))
		adjustOxyLoss(7)

		oxygen_alert = max(oxygen_alert, 1)

		return 0

	//Partial pressure of the O2 in our breath
	var/O2_pp = breath.partial_pressure(GAS_OXYGEN)
	// Same, but for the toxins
	var/Toxins_pp = breath.partial_pressure(GAS_PLASMA)
	// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
	var/CO2_pp = breath.partial_pressure(GAS_CARBON)

	if(O2_pp < safe_oxygen_min) 			// Too little oxygen
		if(prob(20))
			spawn(0) emote("gasp")
		if (O2_pp == 0)
			O2_pp = 0.01
		var/ratio = safe_oxygen_min/O2_pp
		adjustOxyLoss(min(5*ratio, 7)) // Don't fuck them up too fast (space only does 7 after all!)
		oxygen_used = breath[GAS_OXYGEN]*ratio/6
		oxygen_alert = max(oxygen_alert, 1)
	/*else if (O2_pp > safe_oxygen_max) 		// Too much oxygen (commented this out for now, I'll deal with pressure damage elsewhere I suppose)
		spawn(0) emote("cough")
		var/ratio = O2_pp/safe_oxygen_max
		oxyloss += 5*ratio
		oxygen_used = breath[GAS_OXYGEN]*ratio/6
		oxygen_alert = max(oxygen_alert, 1)*/
	else 									// We're in safe limits
		adjustOxyLoss(-5)
		oxygen_used = breath[GAS_OXYGEN]/6
		oxygen_alert = 0

	breath.adjust_multi(
		GAS_OXYGEN, -oxygen_used,
		GAS_CARBON, oxygen_used)

	if(CO2_pp > safe_co2_max)
		if(!co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Paralyse(3)
			adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
			if(world.time - co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
				adjustOxyLoss(8)
		if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
			emote("cough")

	else
		co2overloadtime = 0

	if(Toxins_pp > safe_toxins_max) // Too much toxins
		var/ratio = (breath[GAS_PLASMA]/safe_toxins_max) * 10
		//adjustToxLoss(clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))	//Limit amount of damage toxin exposure can do per second
		if(wear_mask)
			if(wear_mask.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
				if(breath[GAS_PLASMA] > safe_toxins_mask)
					ratio = (breath[GAS_PLASMA]/safe_toxins_mask) * 10
				else
					ratio = 0
		if(ratio)
			if(reagents)
				reagents.add_reagent(PLASMA, clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
			toxins_alert = max(toxins_alert, 1)
	else
		toxins_alert = 0

	var/SA_pp = breath.partial_pressure(GAS_SLEEPING)
	if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
		Paralyse(3) // 3 gives them one second to wake up and run away a bit!
		if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
			sleeping = max(sleeping+2, 10)
	else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
		if(prob(20))
			spawn(0) emote(pick("giggle", "laugh"))


	if(breath.temperature > (T0C+66)) // Hot air hurts :(
		if(prob(20))
			to_chat(src, "<span class='warning'>You feel a searing heat in your lungs!</span>")
		fire_alert = max(fire_alert, 2)

	//Temporary fixes to the alerts.

	return 1
