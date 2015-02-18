/datum/chemical_reaction/explosion_potassium
	name = "Explosion"
	id = "explosion_potassium"
	required_reagents = list("water" = 1, "potassium" = 1)
	reaction_description = "Creates a violent explosion."

/datum/chemical_reaction/explosion_potassium/on_reaction(var/datum/reagents/holder, var/created_volume)
	send_admin_alert(holder, reaction_name="water/potassium explosion")
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/10, 1), holder.my_atom, 0, 0)
	e.holder_damage(holder.my_atom)
	if(isliving(holder.my_atom))
		e.amount *= 0.5
		var/mob/living/L = holder.my_atom
		if(L.stat!=DEAD)
			e.amount *= 0.5
	e.start()
	holder.clear_reagents()
	return

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	id = "emp_pulse"
	required_reagents = list("uranium" = 1, "iron" = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	reaction_description = "Creates an EMP pulse."

/datum/chemical_reaction/emp_pulse/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
	holder.clear_reagents()
	return

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	id = "glycerol"
	required_reagents = list("cornoil" = 3, "sacid" = 1)
	results = list("glycerol" = 1)

// TODO: Don't explode unless dropped or shot.
/datum/chemical_reaction/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	required_reagents = list("glycerol" = 1, "pacid" = 1, "sacid" = 1)
	//results = list("nitroglycerin" = 2)
	reaction_description = "Creates a violent explosion."

/datum/chemical_reaction/nitroglycerin/on_reaction(var/datum/reagents/holder, var/created_volume)
	send_admin_alert(holder, reaction_name="nitroglycerin explosion")
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/2, 1), holder.my_atom, 0, 0)
	e.holder_damage(holder.my_atom)
	if(isliving(holder.my_atom))
		e.amount *= 0.5
		var/mob/living/L = holder.my_atom
		if(L.stat!=DEAD)
			e.amount *= 0.5
	e.start()

	holder.clear_reagents()
	return

/datum/chemical_reaction/flash_powder
	name = "Flash powder"
	id = "flash_powder"
	required_reagents = list("aluminum" = 1, "potassium" = 1, "sulfur" = 1 )
	reaction_description = "Creates a loud explosion and a bright flash of light."

/datum/chemical_reaction/flash_powder/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, location)
	s.start()

	playsound(get_turf(src), 'sound/effects/phasein.ogg', 25, 1)

	var/eye_safety = 0

	for(var/mob/living/carbon/M in viewers(get_turf(holder.my_atom), null))
		if(iscarbon(M))
			eye_safety = M.eyecheck()

		if (get_dist(M, location) <= 3)
			if(eye_safety < 1)
				flick("e_flash", M.flash)
				M.Weaken(15)
		else if (get_dist(M, location) <= 5)
			if(eye_safety < 1)
				flick("e_flash", M.flash)
				M.Stun(5)


		/*
		/datum/chemical_reaction/smoke
			name = "Smoke"
			id = "smoke"
			result = null
			required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1 )
			result_amount = null
			secondary = 1
			/datum/chemical_reaction/smoke/on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				var/datum/effect/system/bad_smoke_spread/S = new /datum/effect/system/bad_smoke_spread
				S.attach(location)
				S.set_up(10, 0, location)
				playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
				spawn(0)
					S.start()
					sleep(10)
					S.start()
					sleep(10)
					S.start()
					sleep(10)
					S.start()
					sleep(10)
					S.start()
				holder.clear_reagents()
				return	*/

/datum/chemical_reaction/chemsmoke
	name = "Chemsmoke"
	id = "chemsmoke"
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)
	reaction_description = "Generates a thick cloud of smoke."

/datum/chemical_reaction/chemsmoke/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
	S.attach(location)
	S.set_up(holder, 10, 0, location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
		S.start()
		sleep(10)
		S.start()
	holder.clear_reagents()
	return

