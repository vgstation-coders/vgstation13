

//How to copypaste human life code and pretend it won't fuck up everything for ALIEN LARVAE : The Novel : The Story : The Legend : The Epic : The Game
//But seriously, someone's gonna have to look more in depth into this to get rid of useless shit

/mob/living/carbon/alien/larva

	var/temperature_alert = TEMP_ALARM_SAFE


/mob/living/carbon/alien/larva/Life()
	//set background = 1
	if (!loc)
		return
	if (monkeyizing)
		return
	if(timestopped)
		return 0 //under effects of time magick

	..()
	var/datum/gas_mixture/enviroment = loc.return_air()
	if (stat != DEAD) //still breathing

		// GROW!
		if(growth < LARVA_GROW_TIME)
			growth++

		//First, resolve location and get a breath
		if(SSair.current_cycle%4==2)
			//Only try to take a breath every 4 seconds, unless suffocating
			spawn(0) breathe()
		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)
		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()


	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	//Handle temperature/pressure differences between body and environment
	handle_environment(enviroment)

	//stuff in the stomach
	//handle_stomach()

	update_canmove()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	//some kind of bug in canmove() isn't properly calling update_icons, so this is here as a placeholder
	update_icons()

	if(client)
		handle_regular_hud_updates()


/mob/living/carbon/alien/larva

/mob/living/carbon/alien/larva/proc/breathe()


	if(reagents.has_any_reagents(LEXORINS))
		return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		return

	var/datum/gas_mixture/environment = loc.return_air()
	var/datum/gas_mixture/breath
	// HACK NEED CHANGING LATER
	if(health < 0)
		losebreath++

	if(losebreath>0) //Suffocating so do not take a breath
		losebreath--
		if (prob(75)) //High chance of gasping for air
			spawn emote("gasp")
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = get_breath_from_internal(BREATH_VOLUME)

		//No breath from internal atmosphere so get breath from location
		if(!breath)
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
			else if(istype(loc, /turf/))
				/*if(environment.return_pressure() > ONE_ATMOSPHERE)
					// Loads of air around (pressure effect will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
					breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
				else
					*/
					// Not enough air around, take a percentage of what's there to model this properly
				breath = environment.remove_volume(CELL_VOLUME * BREATH_PERCENTAGE)

				// Handle chem smoke effect  -- Doohl
				for(var/obj/effect/smoke/chem/smoke in view(1, src))
					if(smoke.reagents.total_volume)
						smoke.reagents.reaction(src, INGEST, amount_override = min(smoke.reagents.total_volume,10)/(smoke.reagents.reagent_list.len))
						spawn(5)
							if(smoke)
								smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
						break // If they breathe in the nasty stuff once, no need to continue checking


		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	handle_breath(breath)

	if(breath)
		loc.assume_air(breath)


/mob/living/carbon/alien/larva/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if (!contents.Find(internal))
			internal = null

		var/obj/item/mask = get_item_by_slot(slot_wear_mask)
		if (!mask || !(mask.clothing_flags & MASKINTERNALS) )
			internal = null
		if(internal)
			if (internals)
				internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if (internals)
				internals.icon_state = "internal0"
	return null

/mob/living/carbon/alien/larva/proc/handle_breath(datum/gas_mixture/breath)
	if((status_flags & GODMODE) || (flags & INVULNERABLE))
		return

	if(!breath || (breath.total_moles == 0))
		//Aliens breathe in vaccuum
		return 0

	var/toxins_used = 0
	breath.volume = BREATH_VOLUME
	breath.update_values()

	//Partial pressure of the toxins in our breath
	var/Toxins_pp = breath.partial_pressure(GAS_PLASMA)

	if(Toxins_pp) // Detect toxins in air

		AdjustPlasma(breath[GAS_PLASMA] * 250)
		toxins_alert = max(toxins_alert, 1)

		toxins_used = breath[GAS_PLASMA]

	else
		toxins_alert = 0

	//Breathe in toxins and out oxygen
	breath.adjust_multi(
		GAS_PLASMA, -toxins_used,
		GAS_OXYGEN, toxins_used)

	if(breath.temperature > (T0C+66) && !(M_RESIST_HEAT in mutations)) // Hot air hurts :(
		if(prob(20))
			to_chat(src, "<span class='danger'>You feel a searing heat in your lungs !</span>")
		fire_alert = max(fire_alert, 1)
	else
		fire_alert = 0

	//Temporary fixes to the alerts.

	return 1


/mob/living/carbon/alien/larva/proc/handle_chemicals_in_body()
	if(reagents)
		reagents.metabolize(src)

	if(M_FAT in mutations)
		if(nutrition < 100)
			if(prob(round((50 - nutrition) / 100)))
				to_chat(src, "<span class='notice'>You feel fit again!</span>")
				mutations.Add(M_FAT)
	else
		if(nutrition > 500)
			if(prob(5 + round((nutrition - LARVA_GROW_TIME) / 2)))
				to_chat(src, "<span class='danger'>You suddenly feel blubbery!</span>")
				mutations.Add(M_FAT)

	burn_calories(2*HUNGER_FACTOR / 3)
	if(!stat)
		burn_calories(HUNGER_FACTOR / 3)
	if (drowsyness > 0)
		drowsyness = max(0, drowsyness - 1)
		eye_blurry = max(2, eye_blurry)
		if (prob(5))
			sleeping += 1
			Paralyse(5)

	remove_confused(1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 5)
		jitteriness = max(0, jitteriness - 5)
	else
		dizziness = max(0, dizziness - 1)
		jitteriness = max(0, jitteriness - 1)

	updatehealth()

	return //TODO: DEFERRED

/mob/living/carbon/alien/larva/check_dead()
	if((health < -25 || !has_brain()) && !(status_flags & BUDDHAMODE))
		death()
		blinded = 1
		silent = 0
		return 1

/mob/living/carbon/alien/larva/handle_regular_status_updates()
	. = ..()
	if(stat != DEAD)	//ALIVE. LIGHTS ARE ON

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 25) || (0 > health) )
			//if( health <= 20 && prob(1) )
			//	spawn(0)
			//		emote("gasp")
			if(!reagents.has_any_reagents(list(INAPROVALINE,PRESLOMITE)))
				adjustOxyLoss(1)

		if(paralysis)
			AdjustParalysis(-2)
			blinded = 1
			stat = status_flags & BUDDHAMODE ? CONSCIOUS : UNCONSCIOUS
		else if(sleeping)
			sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = status_flags & BUDDHAMODE ? CONSCIOUS : UNCONSCIOUS
			if( prob(10) && health )
				spawn(0)
					emote("hiss_")
		//CONSCIOUS
		else
			stat = CONSCIOUS

		/*	What in the living hell is this?*/
		if(move_delay_add > 0)
			move_delay_add = max(0, move_delay_add - rand(1, 2))

/mob/living/carbon/alien/larva/handle_regular_hud_updates()

	if(isDead() || (M_XRAY in mutations))
		change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
	else if(!isDead())
		change_sight(adding = SEE_MOBS, removing = SEE_TURFS|SEE_OBJS)
		see_in_dark = 4
		see_invisible = SEE_INVISIBLE_MINIMUM

	if(healths)
		if(!isDead())
			switch(health)
				if(25 to INFINITY)
					healths.icon_state = "health0"
				if(19 to 25)
					healths.icon_state = "health1"
				if(13 to 19)
					healths.icon_state = "health2"
				if(7 to 13)
					healths.icon_state = "health3"
				if(0 to 7)
					healths.icon_state = "health4"
				else
					healths.icon_state = "health5"
		else
			healths.icon_state = "health6"

	update_pull_icon()

	if(toxins_alert)
		throw_alert(SCREEN_ALARM_TOXINS, /obj/abstract/screen/alert/tox/alien)
	else
		clear_alert(SCREEN_ALARM_TOXINS)
	if(oxygen_alert)
		throw_alert(SCREEN_ALARM_BREATH, /obj/abstract/screen/alert/carbon/breath/alien)
	else
		clear_alert(SCREEN_ALARM_BREATH)
	if(fire_alert)
		throw_alert(SCREEN_ALARM_FIRE, /obj/abstract/screen/alert/carbon/burn/fire/alien)
	else
		clear_alert(SCREEN_ALARM_FIRE)

	standard_damage_overlay_updates()

	if(!isDead())
		if(machine)
			if(!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(client && !client.adminobs)
				reset_view(null)

	return TRUE

/mob/living/carbon/alien/larva/proc/handle_random_events()
	return
