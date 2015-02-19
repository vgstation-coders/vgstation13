/datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A Toxic chemical."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	custom_metabolism = 0.01

/datum/reagent/toxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	// Toxins are really weak, but without being treated, last very long.
	M.adjustToxLoss(0.2)
	..()
	return


/datum/reagent/plasticide
	name = "Plasticide"
	id = "plasticide"
	description = "Liquid plastic, do not eat."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	custom_metabolism = 0.01

/datum/reagent/plasticide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	// Toxins are really weak, but without being treated, last very long.
	M.adjustToxLoss(0.2)
	..()
	return


/datum/reagent/chefspecial
	// Quiet and lethal, needs atleast 4 units in the person before they'll die
	name = "Chef's Special"
	id = "chefspecial"
	description = "An extremely toxic chemical that will surely end in death."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	custom_metabolism = 0.39

/datum/reagent/chefspecial/on_mob_life(var/mob/living/M as mob,var/alien)
	var/random = rand(150,180)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	switch(data)
		if(0 to 5)
			..()
	if(data >= random)
		if(M.stat != DEAD)
			M.death(0)
			M.attack_log += "\[[time_stamp()]\]<font color='red'>Died a quick and painless death by <font color='green'>Chef Excellence's Special Sauce</font>.</font>"
	data++
	return

/datum/reagent/minttoxin
	name = "Mint Toxin"
	id = "minttoxin"
	description = "Useful for dealing with undesirable customers."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0

/datum/reagent/minttoxin/on_mob_life(var/mob/living/M as mob,var/alien)
	if(!M) M = holder.my_atom
	if (M_FAT in M.mutations)
		M.gib()
	..()
	return

/datum/reagent/stoxin
	name = "Sleep Toxin"
	id = "stoxin"
	description = "An effective hypnotic used to treat insomnia."
	reagent_state = LIQUID
	color = "#E895CC" // rgb: 232, 149, 204

	custom_metabolism = 0.1

/datum/reagent/stoxin/on_mob_life(var/mob/living/M as mob,var/alien)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	switch(data)
		if(1 to 15)
			M.eye_blurry = max(M.eye_blurry, 10)
		if(15 to 25)
			M.drowsyness  = max(M.drowsyness, 20)
		if(25 to INFINITY)
			M.Paralyse(20)
			M.drowsyness  = max(M.drowsyness, 30)
	data++
	..()
	return

/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A highly-reactive chemical element."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/fluorine/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1*REM)
	..()
	return

/datum/reagent/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94

/datum/reagent/mutagen/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(!..())	return
	if(!M.dna) return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	src = null
	if((method==TOUCH && prob(33)) || method==INGEST)
		randmuti(M)
		if(prob(98))
			randmutb(M)
		else
			randmutg(M)
		domutcheck(M, null)
		M.UpdateAppearance()
	return
/datum/reagent/mutagen/on_mob_life(var/mob/living/M as mob)
	if(!M.dna) return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if(!M) M = holder.my_atom
	M.apply_effect(10,IRRADIATE,0)
	..()
	return



/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
	reagent_state = LIQUID
	color = "#49002E" // rgb: 73, 0, 46


			// Clear off wallrot fungi
/datum/reagent/toxin/plantbgone/reaction_turf(var/turf/T, var/volume)
	if(istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/W = T
		if(W.rotting)
			W.rotting = 0
			for(var/obj/effect/E in W) if(E.name == "Wallrot") del E

			for(var/mob/O in viewers(W, null))
				O.show_message(text("\blue The fungi are completely dissolved by the solution!"), 1)

/datum/reagent/toxin/plantbgone/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/effect/alien/weeds/))
		var/obj/effect/alien/weeds/alien_weeds = O
		alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
		alien_weeds.healthcheck()
	else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
		del(O)
	else if(istype(O,/obj/effect/plantsegment))
		if(prob(50)) del(O) //Kills kudzu too.
	else if(istype(O,/obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/tray = O

		if(tray.seed)
			tray.health -= rand(30,50)
			if(tray.pestlevel > 0)
				tray.pestlevel -= 2
			if(tray.weedlevel > 0)
				tray.weedlevel -= 3
			tray.toxins += 4
			tray.check_level_sanity()
			tray.update_icon()

/datum/reagent/toxin/plantbgone/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	src = null
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.dna)
				if(H.species.flags & IS_PLANT) //plantmen take a LOT of damage
					H.adjustToxLoss(50)



/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	description = "Cryptobiolin causes confusion and dizzyness."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/cryptobiolin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.Dizzy(1)
	if(!M.confused) M.confused = 1
	M.confused = max(M.confused, 20)
	holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
	..()
	return



/datum/reagent/carpotoxin
	name = "Carpotoxin"
	id = "carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded spess carp."
	reagent_state = LIQUID
	color = "#003333" // rgb: 0, 51, 51

/datum/reagent/carpotoxin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.adjustToxLoss(2*REM)
	..()
	return

/datum/reagent/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#669900" // rgb: 102, 153, 0

/datum/reagent/zombiepowder/on_mob_life(var/mob/living/carbon/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(volume >= 1) //Hotfix for Fakedeath never ending.
		M.status_flags |= FAKEDEATH
	else
		M.status_flags &= ~FAKEDEATH
	M.adjustOxyLoss(0.5*REM)
	M.adjustToxLoss(0.5*REM)
	M.Weaken(10)
	M.silent = max(M.silent, 10)
	M.tod = worldtime2text()
	..()
	return

/*
/datum/reagent/zombiepowder/Del()
				if(holder && ismob(holder.my_atom))
					var/mob/M = holder.my_atom
					M.status_flags &= ~FAKEDEATH
				..()8
*/

/datum/reagent/chloralhydrate							//Otherwise known as a "Mickey Finn"
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	description = "A powerful sedative."
	reagent_state = SOLID
	color = "#000067" // rgb: 0, 0, 103

/datum/reagent/chloralhydrate/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(!data) data = 1
	data++
	switch(data)
		if(1)
			M.confused += 2
			M.drowsyness += 2
		if(2 to 80)
			M.sleeping += 1
		if(81 to INFINITY)
			M.sleeping += 1
			M:toxloss += (data - 50)
	..()

	return

/datum/reagent/beer2							//copypasta of chloral hydrate, disguised as normal beer for use by emagged brobots
	name = "Beer"
	id = "beer2"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/beer2/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(!data) data = 1
	switch(data)
		if(1)
			M.confused += 2
			M.drowsyness += 2
		if(2 to 50)
			M.sleeping += 1
		if(51 to INFINITY)
			M.sleeping += 1
			M.adjustToxLoss(data - 50)
	data++
	// Sleep toxins should always be consumed pretty fast
	holder.remove_reagent(src.id, 0.4)
	..()
	return


/datum/reagent/amatoxin
	name = "Amatoxin"
	id = "amatoxin"
	description = "A powerful poison derived from certain species of mushroom."
	color = "#792300" // rgb: 121, 35, 0

/datum/reagent/amatoxin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1.5)
	..()
	return

/datum/reagent/amanatin
	name = "Alpha-Amanatin"
	id = "amanatin"
	description = "A deadly poison derived from certain species of Amanita. Sits in the victim's system for a long period of time, then ravages the body."
	color = "#792300" // rgb: 121, 35, 0
	custom_metabolism = 0.01
	var/activated = 0

/datum/reagent/amanatin/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(!data) data = 1
	if(volume <= 3 && data >= 60 && !activated)	//minimum of 1 minute required to be useful
		activated = 1
	if(activated)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(prob(8))
				H << "<span class = 'warning'>You feel violently ill.</span>"
			if(prob(min(data / 10, 100)))	H.vomit()
			var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
			if (istype(L) && !L.is_broken())
				L.take_damage(data * 0.01, 0)
				H.adjustToxLoss(round(data / 20, 1))
			else
				H.adjustToxLoss(round(data / 10, 1))
				data += 4
		holder.remove_reagent(src.id, 0.02)
	switch(data)
		if(1 to 30)
			M.druggy = max(M.druggy, 10)
		if(540 to 600)	//start barfing violently after 9 minutes
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(12))
					H << "<span class = 'warning'>You feel violently ill.</span>"
				H.adjustToxLoss(0.1)
				if(prob(8)) H.vomit()
		if(600 to INFINITY)	//ded in 10 minutes with a minimum of 6 units
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(20))
					H << "<span class = 'sinister'>You feel deathly ill.</span>"
				var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
				if (istype(L) && !L.is_broken())
					L.take_damage(10, 0)
				else
					H.adjustToxLoss(60)
	data++
	..()
	return