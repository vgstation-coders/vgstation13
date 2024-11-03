//Biological reagents such as blood

/datum/reagent/blob_essence
	name = "Blob Essence"
	id = BLOB_ESSENCE
	description = "A thick, transparent liquid extracted from live blob cores."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFD6A0"

/datum/reagent/blob_essence/on_mob_life(var/mob/living/M)
	if (..() || !ishuman(M))
		return

/datum/reagent/blobanine
	name = "Blobanine"
	id = BLOBANINE
	description = "An oily, green substance extracted from a blob."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#81EB00"

/datum/reagent/blobanine/on_mob_life(var/mob/living/M)
	if (..() || !ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	change_eye_color_to_green(H)

/datum/reagent/blobanine/proc/change_eye_color_to_green(var/mob/living/carbon/human/H)
	var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
	if (!E)
		return
	H.my_appearance.r_eyes = 129
	H.my_appearance.g_eyes = 235
	H.my_appearance.b_eyes = 0
	H.update_body()

/datum/reagent/blood
	name = "Blood"
	description = "Tomatoes made into juice. Probably. What a waste of big, juicy tomatoes, huh?"
	id = BLOOD
	reagent_state = REAGENT_STATE_LIQUID
	flags = CHEMFLAG_PIGMENT
	color = DEFAULT_BLOOD //rgb: 161, 8, 8
	density = 1.05
	specheatcap = 3.49
	glass_name = "Tomato Juice Glass"
	glass_desc = "Are you sure this is tomato juice?"
	mug_name = "mug of tomato juice"
	mug_desc = "Are you sure this is tomato juice?"
	flags = CHEMFLAG_PIGMENT
	plant_nutrition = 5
	plant_watering = 1

	data = list(
		"viruses" = null,
		"blood_DNA" = null,
		"blood_type" = null,
		"blood_colour" = DEFAULT_BLOOD,
		"resistances" = null,
		"trace_chem" = null,
		"virus2" = null,
		"immunity" = null,
		"occult" = null,
		)

/datum/reagent/blood/handle_data_mix(var/list/added_data=null, var/added_volume, var/mob/admin)
	//to do: add better ways for blood colors to interact with each other //moved from Chemistry-Holder.dm
	//right now we don't support blood mixing or something similar at all.//update, we now at least support color mixing
	if (admin)
		var/list/species_list = list()
		for(var/species_name in all_species)
			var/datum/species/S = all_species[species_name]
			if (!(S.anatomy_flags & NO_BLOOD))
				species_list["[S.name] ([S.blood_color])"] = S.blood_color
		var/chosen = input(admin,"Blood Color","Choose the Blood Color","#FFFFFF") as null|anything in species_list
		if (chosen)
			data["blood_colour"] = BlendRYB(species_list[chosen], data["blood_colour"], added_volume / (added_volume+volume))
			color = data["blood_colour"]
	else if(added_data)
		if(added_data["virus2"])
			if (!data["virus2"])
				data["virus2"] = list()
			data["virus2"] |= virus_copylist(added_data["virus2"])
		if (added_data["blood_type"])
			data["blood_type"] = combine_blood_types(data["blood_type"], added_data["blood_type"])
		if (added_data["blood_colour"])
			data["blood_colour"] = BlendRYB(added_data["blood_colour"], data["blood_colour"], added_volume / (added_volume+volume))
			color = data["blood_colour"]

/datum/reagent/blood/handle_data_copy(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (admin)
		var/list/species_list = list()
		for(var/species_name in all_species)
			var/datum/species/S = all_species[species_name]
			if (!(S.anatomy_flags & NO_BLOOD))
				species_list["[S.name] ([S.blood_color])"] = S.blood_color
		var/chosen = input(admin,"Blood Color","Choose the Blood Color","#FFFFFF") as null|anything in species_list
		if (chosen)
			data["blood_colour"] = species_list[chosen]
			color = data["blood_colour"]
	else if (added_data)
		data = added_data.Copy()
		if(added_data["virus2"])
			data["virus2"] = virus_copylist(added_data["virus2"])
		if(added_data["blood_colour"])
			data["blood_colour"] = added_data["blood_colour"]
			color = data["blood_colour"]


/datum/reagent/blood/when_drinkingglass_master_reagent(var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/D)
	var/totally_not_blood = "Tomato Juice"

	switch(color)
		if (VOX_BLOOD)//#2299FC
			totally_not_blood = "Space Lube"
		if (INSECT_BLOOD)//#EBECE6
			totally_not_blood = "Milk"
		if (MUSHROOM_BLOOD)//#D3D3D3
			totally_not_blood = "Milk"
		if (PALE_BLOOD)//#272727
			totally_not_blood = "Carbon"
		if (GHOUL_BLOOD)//#7FFF00
			totally_not_blood = "Piccolyn"

	glass_name = "glass of [totally_not_blood]"
	glass_desc = "Are you sure this is [totally_not_blood]?"
	mug_name = "mug of [totally_not_blood]"
	mug_desc = "Are you sure this is [totally_not_blood]?"


/datum/reagent/blood/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	var/datum/reagent/blood/self = src
	if(..())
		return 1

	//--------------OLD DISEASE CODE----------------------
	if(self.data && self.data["viruses"])
		for(var/datum/disease/D in self.data["viruses"])
			//var/datum/disease/virus = new D.type(0, D, 1)
			if(D.spread_type == SPECIAL || D.spread_type == NON_CONTAGIOUS) //We don't spread
				continue
			if(method == TOUCH)
				M.contract_disease(D)
			else //Injected
				M.contract_disease(D, 1, 0)
	//----------------------------------------------------

	if(iscarbon(M))
		var/mob/living/L = M
		if(L.can_be_infected() && self.data && self.data["virus2"]) //Infecting
			var/list/blood_viruses = self.data["virus2"]
			if (istype(blood_viruses) && blood_viruses.len > 0)
				for (var/ID in blood_viruses)
					var/datum/disease2/disease/D = blood_viruses[ID]
					if(method == TOUCH)
						var/block = TRUE
						var/bleeding = FALSE
						for(var/part in zone_sels)
							if(!L.check_contact_sterility(limb_define_to_part_define(part)))
								block = FALSE //Checking all targeted parts for at least one place not sterile
							if(L.check_bodypart_bleeding(limb_define_to_part_define(part)))
								bleeding = TRUE //Checking them all for at least one bleeding
							if(!block && bleeding)
								break
						if(attempt_colony(L,D,"splashed with infected blood"))
						else if (!block)
							if (D.spread & SPREAD_CONTACT)
								L.infect_disease2(D, notes="(Contact, splashed with infected blood)")
							else if (bleeding && (D.spread & SPREAD_BLOOD))
								L.infect_disease2(D, notes="(Blood, splashed with infected blood)")
					else
						L.infect_disease2(D, 1, notes="(Drank/Injected with infected blood)")

		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(method == TOUCH)
				H.bloody_body_from_data(data,0,src)
				if((LIMB_RIGHT_HAND in zone_sels) || (LIMB_LEFT_HAND in zone_sels))
					H.bloody_hands_from_data(data,2,src)
				spawn() //Bloody feet, result of the blood that fell on the floor
					var/obj/effect/decal/cleanable/blood/B = locate() in get_turf(H)

					if(B)
						B.Crossed(H)

				H.update_icons()
			else if(self.data["blood_DNA"])
				var/datum/role/vampire/V = isvampire(H)
				if(V)
					var/mob/living/carbon/human/foundmob
					for(var/datum/data/record/R in sortRecord(data_core.medical))
						if(R.fields["b_dna"] == self.data["blood_DNA"])
							for(var/mob/living/carbon/human/other in player_list)
								if(other.name == R.fields["name"] && other != M)
									foundmob = other
									break
							if(foundmob)
								break
					if(foundmob)
						var/targetref = "/ref[foundmob]"
						var/blood_total_before = V.blood_total
						var/blood_usable_before = V.blood_usable
						var/divisor = (locate(/datum/power/vampire/mature) in V.current_powers) ? min(2,foundmob.stat + 1) : (min(2,foundmob.stat + 1)*2)
						divisor = divisor * BLOOD_UNIT_DRAIN_MULTIPLIER
						if (!(targetref in V.feeders))
							V.feeders[targetref] = 0
						if (V.feeders[targetref] < MAX_BLOOD_PER_TARGET)
							V.blood_total += volume/divisor
						else
							to_chat(H, "<span class='warning'>Their blood quenches your thirst but won't let you become any stronger. You need to find new prey.</span>")
						if(foundmob.stat < DEAD) //alive
							V.blood_usable += volume/divisor
						V.feeders[targetref] += volume/divisor
						if(blood_total_before != V.blood_total)
							to_chat(H, "<span class='notice'>You have accumulated [V.blood_total] unit[V.blood_total > 1 ? "s" : ""] of blood[blood_usable_before != V.blood_usable ?", and have [V.blood_usable] left to use." : "."]</span>")
						V.check_vampire_upgrade()
						V.update_vamp_hud()
					else
						to_chat(H, "<span class='warning'>This blood is lifeless and has no power.</span>")

/datum/reagent/blood/reaction_animal(var/mob/living/simple_animal/M, var/method = TOUCH, var/volume)
	var/datum/reagent/blood/self = src
	if(..())
		return 1

	if(M.can_be_infected())//for now, only mice can be infected among simple_animals.
		var/mob/living/L = M
		if(self.data && self.data["virus2"]) //Infecting
			var/list/blood_viruses = self.data["virus2"]
			if (istype(blood_viruses) && blood_viruses.len > 0)
				for (var/ID in blood_viruses)
					var/datum/disease2/disease/D = blood_viruses[ID]
					if(method == TOUCH)
						var/block = L.check_contact_sterility(FULL_TORSO)
						var/bleeding = L.check_bodypart_bleeding(FULL_TORSO)
						if (!block)
							if (D.spread & SPREAD_CONTACT)
								L.infect_disease2(D, notes="(Contact, splashed with infected blood)")
							else if (bleeding && (D.spread & SPREAD_BLOOD))
								L.infect_disease2(D, notes="(Blood, splashed with infected blood)")
					else
						L.infect_disease2(D, 1, notes="(Drank/Injected with infected blood)")

// Was unused as of 2021
///datum/reagent/blood/on_merge(var/data)
//	if(data["blood_colour"])
//		color = data["blood_colour"]
//	return ..()
///datum/reagent/blood/on_update(var/atom/A)
//	if(data["blood_colour"])
//		color = data["blood_colour"]
//	return ..()

/datum/reagent/blood/reaction_turf(var/turf/simulated/T, var/volume) //Splash the blood all over the place
	var/datum/reagent/self = src
	if(..())
		return TRUE

	if(volume < 3) //Hardcoded
		return

	blood_splatter(T, self, 1)
	T.had_blood = TRUE
	if(volume >= 5 && !istype(T.loc, /area/chapel)) //Blood desanctifies non-chapel tiles
		T.holy = 0
	return

/datum/reagent/blood/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	O.add_blood_from_data(data)

	if(istype(O, /obj/item/clothing/mask/stone))
		var/obj/item/clothing/mask/stone/S = O
		S.spikes()

/datum/reagent/carp_pheromones
	name = "Carp Pheromones"
	id = CARPPHEROMONES
	description = "A disgusting liquid with a horrible smell, which is used by space carps to mark their territory and food."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6AAA96" //rgb: 106, 170, 150
	custom_metabolism = 0.05
	density = 109.06
	specheatcap = ARBITRARILY_LARGE_NUMBER //Contains leporazine, better this than 6 digits

/datum/reagent/carp_pheromones/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(!tick)
		to_chat(M,"<span class='good'><b>You feel more carplike! [pick("Do you, perhaps...?","Maybe... just maybe...")]</b></span>")

	if(volume < 3)
		if(volume <= custom_metabolism)
			to_chat(M,"<span class='danger'>You feel not at all carplike!</span>")
		else if(!(tick%4))
			to_chat(M,"<span class='warning'>You feel less carplike...</span>")

	var/stench_radius = clamp(tick * 0.1, 1, 6) //Stench starts out with 1 tile radius and grows after every 10 life ticks

	if(prob(5)) //5% chance of stinking per life()
		for(var/mob/living/carbon/C in oview(stench_radius, M)) //All other carbons in 4 tile radius (excluding our mob)
			if(C.stat)
				continue
			if(istype(C.wear_mask))
				var/obj/item/clothing/mask/c_mask = C.wear_mask
				if(c_mask.body_parts_covered & MOUTH)
					continue //If the carbon's mouth is covered, let's assume they don't smell it

			to_chat(C, "<span class='warning'>You are engulfed by a [pick("tremendous", "foul", "disgusting", "horrible")] stench emanating from [M]!</span>")

/datum/reagent/killer_pheromones
	name = "Killer Pheromones"
	id = KILLERPHEROMONES
	description = "A viscous liquid with a strong smell that resembles blood and ketchup, which is like blood in the water to killer tomatoes if air was water."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#993300"
	custom_metabolism = 2
	density = 109.06
	var/list/mob/living/simple_animal/hostile/retaliate/horde = list()

/datum/reagent/killer_pheromones/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(!tick)
		to_chat(M,"<span class='bad'><b>You feel like [pick("you're alerting a horde", "something is waiting to pounce on you", "carnivorous beings are nearby")]! [pick("Do you, perhaps...?","Maybe... just maybe...")]</b></span>")

	if(volume < 3)
		if(volume <= custom_metabolism)
			to_chat(M,"<span class='good'>You feel [pick("like the coast is clear", "out of danger", "less threatened")]!</span>")
		else if(!(tick%4))
			to_chat(M,"<span class='notice'>You feel [pick("further from danger", "like you're losing something chasing you", "less hunted down")]...</span>")

	var/stench_radius = clamp(volume * 0.1, 1, 6) //Stench starts out with 1 tile radius and grows after every 10 reagents on you
	
	var/alerted = 0
	for(var/mob/living/simple_animal/hostile/retaliate/R in view(stench_radius, M)) //All other retaliating hostile mobs in radius
		if(R == M || R.stat || R.hostile || (M in R.enemies))
			continue

		R.Retaliate()
		horde += R
		alerted++
		break

	if(alerted >= 2)
		to_chat(M,"<span class='danger'>YOU HAVE ALERTED THE HORDE!</span>")

/datum/reagent/killer_pheromones/reagent_deleted()
	if(..())
		return 1
	if(!holder)
		return
	var/mob/M =  holder.my_atom
	for(var/mob/living/simple_animal/hostile/retaliate/R in horde)
		R.enemies -= M

/datum/reagent/ectoplasm
	name = "Ectoplasm"
	id = ECTOPLASM
	description = "Pure, distilled spooky."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#21d389b4"
	density = 0.05
	custom_metabolism = 0.01
	var/spookvision = FALSE

/datum/reagent/ectoplasm/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(!spookvision && tick >= 5 && volume >= 1) //ghostsight after 10s and having more than 1u inside
		spookvision = TRUE
		to_chat(M, "<span class='notice'>You start seeing through the veil!</span>")
		M.see_invisible = SEE_INVISIBLE_OBSERVER
		M.see_invisible_override = SEE_INVISIBLE_OBSERVER

	if(spookvision && volume < 1)
		spookvision = FALSE
		to_chat(M, "<span class='notice'>Your otherworldly sight suddenly vanishes!</span>")
		M.see_invisible = initial(M.see_invisible)
		M.see_invisible_override = 0

	if(isskellington(M) || isskelevox(M) || islich(M))	//Slightly better than DD for spooks
		playsound(M, 'sound/effects/rattling_bones.ogg', 100, 1)
		if(M.getOxyLoss())
			M.adjustOxyLoss(-3)
			holder.remove_reagent(ECTOPLASM, 0.1)
		if(M.getBruteLoss())
			M.heal_organ_damage(3, 0)
			holder.remove_reagent(ECTOPLASM, 0.1)
		if(M.getFireLoss())
			M.heal_organ_damage(0, 3)
			holder.remove_reagent(ECTOPLASM, 0.1)
		if(M.getToxLoss())
			M.adjustToxLoss(-3)
			holder.remove_reagent(ECTOPLASM, 0.1)

/datum/reagent/greygoo // A very powerful mothership neurostimulant and anti hallucinogenic. Toxic for other species and less effective, but still usable
	name = "Grey Goo"
	id = GREYGOO
	description = "A viscous grey substance of unknown origin."
	reagent_state = REAGENT_STATE_LIQUID
	dupeable = FALSE
	color = "#B5B5B5" //rgb: 181, 181, 181
	custom_metabolism = 0.1
	pain_resistance = 50

/datum/reagent/greygoo/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1

	if(holder.has_any_reagents(list(MERCURY, IMPEDREZENE, SPACE_DRUGS)))
		holder.remove_reagents(list(MERCURY, IMPEDREZENE, SPACE_DRUGS), 5 * REM)
	if(holder.has_any_reagents(list(MINDBREAKER, SPIRITBREAKER)))
		holder.remove_reagents(list(MINDBREAKER, SPIRITBREAKER), 3 * REM) // The only chemical that removes spiritbreaker besides adminordrazine

	if(alien && alien == IS_GREY) // A nice brain scrub for greys, cleaning out any damage, hallucinations, confusion, and dizziness
		if(ishuman(M))
			M.adjustBrainLoss(-10)
			M.hallucination = 0
			M.dizziness = 0
			M.confused = 0
			if(prob(5))
				to_chat(M, "<span class='notice'>[pick("You feel a pleasant equilibrium settle across your mind.","You feel much more focused.","Your mind is clear and lucid.")]</span>")
	else // Still a pretty effective brain scrub for other species, but cures brain damage half as effectively and causes some toxin damage
		if(ishuman(M))
			M.adjustBrainLoss(-5)
			M.hallucination = 0
			M.dizziness = 0
			M.confused = 0
			M.adjustToxLoss(1)

/datum/reagent/grue_bile
	name = "Grue Bile"
	id = GRUE_BILE
	description = "A noxious substance produced in the body of a grue."
	reagent_state = REAGENT_STATE_LIQUID
	color = GRUE_BLOOD
	custom_metabolism = 0.01
	density = 1.25
	specheatcap = 2.2
	pain_resistance = -25 //increases pain a bit

/datum/reagent/grue_bile/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustToxLoss(0.1) //Does some toxin damage
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/eyes/E= H.internal_organs_by_name["eyes"] //damages the eyes
		if(E && !istype(E, /datum/organ/internal/eyes/monstrous) && !E.robotic) //doesn't harm monstrous or robotic eyes
			E.damage += 0.5

/datum/reagent/ironrot
	name = "Ironrot"
	id = IRONROT
	description = "A mutated fungal compound that causes rapid rotting in iron infrastructures."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#005200" //moldy green

/datum/reagent/ironrot/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(volume >= 5 && T.can_thermite && istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/W = T
		W.rot()

/datum/reagent/ironrot/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustToxLoss(2 * REM)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/chest/C = H.get_organ(LIMB_CHEST)
		for(var/datum/organ/internal/I in C.internal_organs)
			if(I.robotic == 2)
				I.take_damage(10, 0)//robo organs get damaged by ingested ironrot

/datum/reagent/ironrot/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if(method == TOUCH)
		if(issilicon(M))//borgs are hurt on touch by this chem
			M.adjustFireLoss(10)
			M.adjustBruteLoss(10)
//todo : mech and pod damage

/datum/reagent/mucus
	name = "Mucus"
	id = MUCUS
	description = "A slippery aqueous secretion produced by, and covering, mucous membranes.  Problematic for Asthmatics."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#13BC5E"
	custom_metabolism = 0.01

/datum/reagent/mucus/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(M_ASTHMA in H.mutations)
			H.adjustOxyLoss(2)
			if(prob(30))
				H.emote("gasp", null, null, TRUE)

//Petritricin = cockatrice juice
//Lore explanation for it affecting worn items (like hardsuits), but not items dropped on the ground that it was splashed over:
//Pure petritricin can stonify any matter, organic or unorganic. However, if it's outside of a living organism, it rapidly deterogates
//until it is only strong enough to affect organic matter.
//When introduced to organic matter, petritricin converts living cells to produce more of itself, and the freshly produced substance
//can affect items worn close enough to the body
/datum/reagent/petritricin
	name = "Petritricin"
	id = PETRITRICIN
	description = "Petritricin is a venom produced by cockatrices. The extraction process causes a major potency loss, but a right dose of this can still petrify somebody."
	color = "#002000" //rgb: 0, 32, 0
	dupeable = FALSE

	var/min_to_start = 1 //At least 1 unit is needed for petriication to start
	var/is_being_petrified = FALSE
	var/stage

/datum/reagent/petritricin/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(issilicon(M))
		return
	var/mob/living/carbon/C
	if(iscarbon(M))
		C = M
	if(volume >= min_to_start && !is_being_petrified)
		is_being_petrified = TRUE
	if(is_being_petrified)
		if(holder.has_any_reagents(ACIDS))
			to_chat(M, "<span class='notice'>You feel a wave of relief as your muscles loosen up.</span>")
			C.pain_shock_stage = max(0, C.pain_shock_stage - 300)
			is_being_petrified = FALSE
			holder.del_reagent(PETRITRICIN)
			return
		switch(stage)
			if(1)
				//Second message is shown to hallucinating mobs
				M.simple_message("<span class='userdanger'>You are slowing down. Moving is extremely painful for you.</span>",\
				"<span class='notice'>You feel like Michelangelo di Lodovico Buonarroti Simoni trapped in a foreign body.</span>")
				if(istype(C))
					C.pain_shock_stage += 300
				M.audible_scream()
			if(2)
				M.simple_message("<span class='userdanger'>Your skin starts losing color and cracking. Your body becomes numb.</span>",\
				"<span class='notice'>You decide to channel your inner Italian sculptor to create a beautiful statue.</span>")
				M.Stun(3)
			if(3)
				if(M.turn_into_statue(1))
					M.simple_message("<span class='userdanger'>You have been turned to stone by ingesting petritricin.</span>",\
					"<span class='notice'>You've created a masterwork statue of David!</span>")
					is_being_petrified = FALSE
		stage = stage + 1

/datum/reagent/roach_shell
	name = "Cockroach Chitin"
	id = ROACHSHELL
	description = "Looks like somebody's been shelling peanuts."
	reagent_state = REAGENT_STATE_SOLID
	color = "#8B4513"

/datum/reagent/slimejelly
	name = "Slime Jelly"
	id = SLIMEJELLY
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#801E28" //rgb: 128, 30, 40
	density = 0.8
	specheatcap = 1.24

/datum/reagent/slimejelly/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1
	var/mob/living/carbon/human/human = M
	if(!isslimeperson(human))
		if(prob(10))
			to_chat(M, "<span class='warning'>Your insides are burning!</span>")
			M.adjustToxLoss(rand(20, 60) * REM)
	if(prob(40))
		M.heal_organ_damage(5 * REM, 0)

/datum/reagent/vomit
	name = "Vomit"
	id = VOMIT
	description = "Stomach acid mixed with partially digested chunks of food."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#EACF9D" //rgb: 234, 207, 157. Pale yellow
	density = 1.35
	specheatcap = 5.2

/datum/reagent/vomit/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustToxLoss(0.1)

/datum/reagent/vomit/reaction_turf(turf/simulated/T, volume)
	if(..())
		return 1

	if(volume >= 3)
		if(!(locate(/obj/effect/decal/cleanable/vomit) in T))
			new /obj/effect/decal/cleanable/vomit(T)
