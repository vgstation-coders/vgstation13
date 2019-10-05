
/datum/reagent/blood
	name = "Blood"
	description = "Tomatoes made into juice. Probably. What a waste of big, juicy tomatoes, huh?"
	id = BLOOD
	reagent_state = REAGENT_STATE_LIQUID
	color = DEFAULT_BLOOD //rgb: 161, 8, 8
	density = 1.05
	specheatcap = 3.49

	data = list(
		"donor"= null,
		"viruses" = null,
		"blood_DNA" = null,
		"blood_type" = null,
		"blood_colour" = DEFAULT_BLOOD,
		"resistances" = null,
		"trace_chem" = null,
		"virus2" = null,
		"immunity" = null,
		)

/datum/reagent/blood/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

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
						var/block = L.check_contact_sterility(FULL_TORSO)
						var/bleeding = L.check_bodypart_bleeding(FULL_TORSO)
						if(attempt_colony(L,D,"splashed with infected blood"))
						else if (!block)
							if (D.spread & SPREAD_CONTACT)
								L.infect_disease2(D, notes="(Contact, splashed with infected blood)")
							else if (bleeding && (D.spread & SPREAD_BLOOD))
								L.infect_disease2(D, notes="(Blood, splashed with infected blood)")
					else
						L.infect_disease2(D, 1, notes="(Drank/Injected with infected blood)")

		if(ishuman(L) && (method == TOUCH))
			var/mob/living/carbon/human/H = L
			H.bloody_body(self.data["donor"])
			if(self.data["donor"])
				H.bloody_hands(self.data["donor"])
			spawn() //Bloody feet, result of the blood that fell on the floor
				var/obj/effect/decal/cleanable/blood/B = locate() in get_turf(H)

				if(B)
					B.Crossed(H)

			H.update_icons()

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

/datum/reagent/blood/on_merge(var/data)
	if(data["blood_colour"])
		color = data["blood_colour"]
	return ..()

/datum/reagent/blood/on_update(var/atom/A)
	if(data["blood_colour"])
		color = data["blood_colour"]
	return ..()

/datum/reagent/blood/reaction_turf(var/turf/simulated/T, var/volume) //Splash the blood all over the place

	var/datum/reagent/self = src
	if(..())
		return TRUE

	if(volume < 3) //Hardcoded
		return
//	WHY WAS THIS MAKING 2 SPLATTERS? Awfully hardcoded, no need to exist, and this is completely broken colorwise
//
	//var/datum/disease/D = self.data["virus"]
//	if(!self.data["donor"] || ishuman(self.data["donor"]))
//		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //Find some blood here
//		if(!blood_prop) //First blood
//			blood_prop = getFromPool(/obj/effect/decal/cleanable/blood, T)
//			blood_prop.New(T)
//			blood_prop.blood_DNA[self.data["blood_DNA"]] = self.data["blood_type"]
//
//		for(var/datum/disease/D in self.data["viruses"])
//			var/datum/disease/newVirus = D.Copy(1)
//			blood_prop.viruses += newVirus
//

	if(!self.data["donor"] || ishuman(self.data["donor"]))
		blood_splatter(T, self, 1)
	else if(ismonkey(self.data["donor"]))
		var/obj/effect/decal/cleanable/blood/B = blood_splatter(T, self, 1)
		if(B)
			B.blood_DNA["Non-Human DNA"] = "A+"
	else if(isalien(self.data["donor"]))
		var/obj/effect/decal/cleanable/blood/B = blood_splatter(T, self, 1)
		if(B)
			B.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"
	T.had_blood = TRUE
	if(volume >= 5 && !istype(T.loc, /area/chapel)) //Blood desanctifies non-chapel tiles
		T.holy = 0
	return

/datum/reagent/blood/on_removal(var/data)
	if(holder && holder.my_atom)
		var/mob/living/carbon/human/H = holder.my_atom
		if(istype(H))
			if(H.species && H.species.anatomy_flags & NO_BLOOD)
				return 0
	return 1

/datum/reagent/blood/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(istype(O, /obj/item/clothing/mask/stone))
		var/obj/item/clothing/mask/stone/S = O
		S.spikes()

/datum/reagent/water
	name = "Water"
	id = WATER
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DEF7F5" //rgb: 192, 227, 233
	alpha = 128
	specheatcap = 4.184
	density = 1

/datum/reagent/water/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species && H.species.anatomy_flags & ACID4WATER)
			M.adjustToxLoss(REM)
			M.take_organ_damage(0, REM, ignore_inorganics = TRUE)

/datum/reagent/water/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	//Put out fire
	if(method == TOUCH)
		M.ExtinguishMob()
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/datum/disease2/effect/E = C.has_active_symptom(/datum/disease2/effect/thick_skin)
			if(E)
				E.multiplier = max(E.multiplier - rand(1,3), 1)
				to_chat(C, "<span class='notice'>The water quenches your dry skin.</span>")
		if(ishuman(M) || ismonkey(M))
			var/mob/living/carbon/C = M
			if(C.body_alphas[INVISIBLESPRAY])
				C.body_alphas.Remove(INVISIBLESPRAY)
				C.regenerate_icons()
		else if(M.alphas[INVISIBLESPRAY])
			M.alpha = initial(M.alpha)
			M.alphas.Remove(INVISIBLESPRAY)

	//Water now directly damages slimes instead of being a turf check
	if(isslime(M))
		M.adjustToxLoss(rand(15, 20))

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species && H.species.anatomy_flags & ACID4WATER) //oof ouch, water is spicy now
			if(method == TOUCH)
				if(H.check_body_part_coverage(EYES|MOUTH))
					to_chat(H, "<span class='warning'>Your face is protected from a splash of water!</span>")
					return

				if(prob(15) && volume >= 30)
					var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
					if(head_organ)
						if(head_organ.take_damage(0, 25))
							H.UpdateDamageIcon(1)
						head_organ.disfigure("burn")
						H.audible_scream()
				else
					M.take_organ_damage(0, min(15, volume * 2)) //Uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
			else
				M.take_organ_damage(0, min(15, volume * 2))

		else if(isslimeperson(H))

			H.adjustToxLoss(rand(1,3))

/datum/reagent/water/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 3) //Hardcoded
		T.wet(800)

	var/hotspot = (locate(/obj/effect/fire) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air(T:air:total_moles())
		lowertemp.temperature = max(min(lowertemp.temperature-2000, lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/water/reaction_obj(var/obj/O, var/volume)

	var/datum/reagent/self = src
	if(..())
		return 1

	if(O.has_been_invisible_sprayed)
		O.alpha = initial(O.alpha)
		O.has_been_invisible_sprayed = FALSE
		if(ismob(O.loc))
			var/mob/M = O.loc
			M.regenerate_icons()
	if(isturf(O.loc))
		var/turf/T = get_turf(O)
		self.reaction_turf(T, volume)

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()
	else if(istype(O,/obj/machinery/space_heater/campfire))
		var/obj/machinery/space_heater/campfire/campfire = O
		campfire.snuff()
	else if(O.on_fire) // For extinguishing objects on fire
		O.extinguish()
	else if(O.molten) // Molten shit.
		O.molten=0
		O.solidify()

/datum/reagent/water/reaction_animal(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume)
	..()

	if(istype(M,/mob/living/simple_animal/hostile/slime))
		var/mob/living/simple_animal/hostile/slime/S = M
		S.calm()

	if(istype(M,/mob/living/simple_animal/bee))
		var/mob/living/simple_animal/bee/B = M
		B.calming()



//Fast and lethal
/datum/reagent/cyanide
	name = "Cyanide"
	id = CYANIDE
	description = "A highly toxic chemical."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.4
	flags = CHEMFLAG_DISHONORABLE // NO CHEATING
	density = 0.699
	specheatcap = 1.328

/datum/reagent/cyanide/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(4)
	M.adjustOxyLoss(4)
	M.sleeping += 1

/datum/reagent/silicate
	name = "Silicate"
	id = SILICATE
	description = "A compound that can be used to repair and reinforce glass."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C7FFFF" //rgb: 199, 255, 255
	overdose_am = 0
	density = 0.69
	specheatcap =  0.59

/datum/reagent/oxygen
	name = "Oxygen"
	id = OXYGEN
	description = "A colorless, odorless gas."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	density = 1.141
	specheatcap = 0.911

/datum/reagent/oxygen/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(alien && alien == IS_VOX)
		M.adjustToxLoss(REM)

/datum/reagent/copper
	name = "Copper"
	id = COPPER
	description = "A highly ductile metal."
	color = "#6E3B08" //rgb: 110, 59, 8
	specheatcap = 0.385
	density = 8.96

/datum/reagent/nitrogen
	name = "Nitrogen"
	id = NITROGEN
	description = "A colorless, odorless, tasteless gas."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	density = 1.251
	specheatcap = 1.040

/datum/reagent/nitrogen/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(alien && alien == IS_VOX)
		M.adjustOxyLoss(-2 * REM)
		M.adjustToxLoss(-2 * REM)

/datum/reagent/hydrogen
	name = "Hydrogen"
	id = HYDROGEN
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	density = 0.08988
	specheatcap = 13.83

/datum/reagent/potassium
	name = "Potassium"
	id = POTASSIUM
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A0A0A0" //rgb: 160, 160, 160
	specheatcap = 0.75
	density = 0.89

/datum/reagent/mercury
	name = "Mercury"
	id = MERCURY
	description = "A chemical element."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#484848" //rgb: 72, 72, 72
	overdose_am = REAGENTS_OVERDOSE
	specheatcap = 0.14
	density = 13.56

/datum/reagent/mercury/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))

	if(prob(5))
		M.emote(pick("twitch","drool","moan"), null, null, TRUE)

	M.adjustBrainLoss(2)

/datum/reagent/sulfur
	name = "Sulfur"
	id = SULFUR
	description = "A chemical element with a pungent smell."
	reagent_state = REAGENT_STATE_SOLID
	color = "#BF8C00" //rgb: 191, 140, 0
	specheatcap = 0.73
	density = 1.96

/datum/reagent/carbon
	name = "Carbon"
	id = CARBON
	description = "A chemical element, the builing block of life."
	reagent_state = REAGENT_STATE_SOLID
	color = "#1C1300" //rgb: 30, 20, 0
	specheatcap = 0.71
	density = 2.26

/datum/reagent/carbon/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	//Only add one dirt per turf.  Was causing people to crash
	if(!(locate(/obj/effect/decal/cleanable/dirt) in T))
		new /obj/effect/decal/cleanable/dirt(T)

/datum/reagent/chlorine
	name = "Chlorine"
	id = CHLORINE
	description = "A chemical element with a characteristic odour."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	overdose_am = REAGENTS_OVERDOSE
	density = 3.214
	specheatcap = 1.34

/datum/reagent/chlorine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.take_organ_damage(REM, 0, ignore_inorganics = TRUE)

/datum/reagent/fluorine
	name = "Fluorine"
	id = FLUORINE
	description = "A highly-reactive chemical element."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	overdose_am = REAGENTS_OVERDOSE
	density = 1.696
	specheatcap = 0.824

/datum/reagent/fluorine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(REM)

/datum/reagent/sodium
	name = "Sodium"
	id = SODIUM
	description = "A chemical element, readily reacts with water."
	reagent_state = REAGENT_STATE_SOLID
	color = "#808080" //rgb: 128, 128, 128
	specheatcap = 1.23
	density = 0.968

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = PHOSPHORUS
	description = "A chemical element, the backbone of biological energy carriers."
	reagent_state = REAGENT_STATE_SOLID
	color = "#832828" //rgb: 131, 40, 40
	density = 1.823
	specheatcap = 0.769

/datum/reagent/lithium
	name = "Lithium"
	id = LITHIUM
	description = "A chemical element, used as antidepressant."
	reagent_state = REAGENT_STATE_SOLID
	color = "#808080" //rgb: 128, 128, 128
	overdose_am = REAGENTS_OVERDOSE
	specheatcap = 3.56
	density = 0.535

/datum/reagent/lithium/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"), null, null, TRUE)

/datum/reagent/sacid
	name = "Sulphuric acid"
	id = SACID
	description = "A strong mineral acid with the molecular formula H2SO4."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DB5008" //rgb: 219, 80, 8
	custom_metabolism = 0.5
	density = 1.84
	specheatcap = 1.38

/datum/reagent/sacid/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.acidable())
		M.adjustFireLoss(REM)
		M.take_organ_damage(0, REM)

/datum/reagent/sacid/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	if(..())
		return 1

	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				if(H.wear_mask.acidable())
					qdel(H.wear_mask)
					H.wear_mask = null
					H.update_inv_wear_mask()
					to_chat(H, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(H, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

			if(H.head && !istype(H.head, /obj/item/weapon/reagent_containers/glass/bucket))
				if(prob(15) && H.head.acidable())
					qdel(H.head)
					H.head = null
					H.update_inv_head()
					to_chat(H, "<span class='warning'>Your helmet melts away but protects you from the acid</span>")
				else
					to_chat(H, "<span class='warning'>Your helmet protects you from the acid!</span>")
				return

		else if(ismonkey(M))
			var/mob/living/carbon/monkey/MK = M
			if(MK.wear_mask)
				if(MK.wear_mask.acidable())
					qdel(MK.wear_mask)
					MK.wear_mask = null
					MK.update_inv_wear_mask()
					to_chat(MK, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(MK, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

		if(M.acidable())
			if(prob(15) && ishuman(M) && volume >= 30)
				var/mob/living/carbon/human/H = M
				var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
				if(head_organ)
					if(head_organ.take_damage(25, 0))
						H.UpdateDamageIcon(1)
					head_organ.disfigure("burn")
					H.audible_scream()
			else
				M.take_organ_damage(min(15, volume * 2)) //uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
	else
		if(M.acidable())
			M.take_organ_damage(min(15, volume * 2))

/datum/reagent/sacid/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(!O.acidable())
		return

	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(10))
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
		I.desc = "Looks like this was \an [O] some time ago."
		O.visible_message("<span class='warning'>\The [O] melts.</span>")
		qdel(O)
	else if(istype(O,/obj/effect/dummy/chameleon))
		var/obj/effect/dummy/chameleon/projection = O
		projection.disrupt()

/datum/reagent/pacid
	name = "Polytrinic acid"
	id = PACID
	description = "Polytrinic acid is a an extremely corrosive chemical substance."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#8E18A9" //rgb: 142, 24, 169
	custom_metabolism = 0.5
	density = 1.98
	specheatcap = 1.39

/datum/reagent/pacid/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustFireLoss(3 * REM)

/datum/reagent/pacid/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				if(H.wear_mask.acidable())
					qdel(H.wear_mask)
					H.wear_mask = null
					H.update_inv_wear_mask()
					to_chat(H, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(H, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

			if(H.head && !istype(H.head, /obj/item/weapon/reagent_containers/glass/bucket))
				if(prob(15) && H.head.acidable())
					qdel(H.head)
					H.head = null
					H.update_inv_head()
					to_chat(H, "<span class='warning'>Your helmet melts away but protects you from the acid</span>")
				else
					to_chat(H, "<span class='warning'>Your helmet protects you from the acid!</span>")
				return

			if(H.acidable())
				var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
				if(head_organ.take_damage(15, 0))
					H.UpdateDamageIcon(1)
				H.audible_scream()

		else if(ismonkey(M))
			var/mob/living/carbon/monkey/MK = M
			if(MK.wear_mask)
				if(MK.wear_mask.acidable())
					qdel(MK.wear_mask)
					MK.wear_mask = null
					MK.update_inv_wear_mask()
					to_chat(MK, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(MK, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

			if(MK.acidable())
				MK.take_organ_damage(min(15, volume * 4)) //Same deal as sulphuric acid
	else
		if(M.acidable()) //I think someone doesn't know what this does
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
				if(head_organ.take_damage(15, 0))
					H.UpdateDamageIcon(1)
				H.audible_scream()
				head_organ.disfigure("burn")
			else
				M.take_organ_damage(min(15, volume * 4))

/datum/reagent/pacid/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(!O.acidable())
		return

	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)))
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(get_turf(O))
		I.desc = "Looks like this was \an [O] some time ago."
		O.visible_message("<span class='warning'>\The [O] melts.</span>")
		qdel(O)
	else if(istype(O,/obj/effect/plantsegment))
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(get_turf(O))
		I.desc = "Looks like these were some [O.name] some time ago."
		var/obj/effect/plantsegment/K = O
		K.die_off()
	else if(istype(O,/obj/effect/dummy/chameleon))
		var/obj/effect/dummy/chameleon/projection = O
		projection.disrupt()

/datum/reagent/glycerol
	name = "Glycerol"
	id = GLYCEROL
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#808080" //rgb: 128, 128, 128
	density = 4.84
	specheatcap = 1.38

/datum/reagent/radium
	name = "Radium"
	id = RADIUM
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = REAGENT_STATE_SOLID
	color = "#669966" //rgb: 102, 153, 102
	density = 5
	specheatcap = 94

/datum/reagent/radium/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.apply_radiation(2 * REM, RAD_INTERNAL)

	if (!M.immune_system.overloaded && M.virus2.len)
		for(var/ID in M.virus2)
			var/datum/disease2/disease/V = M.virus2[ID]
			if (prob(V.strength / 2))//the stronger the virus, the better higher the chance to trigger
				M.immune_system.Overload()
				return

/datum/reagent/radium/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 3)
		if(!(locate(/obj/effect/decal/cleanable/greenglow) in T))
			new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/iron
	name = "Iron"
	id = IRON
	description = "Pure iron in powdered form, a metal."
	reagent_state = REAGENT_STATE_SOLID
	color = "#666666" //rgb: 102, 102, 102
	specheatcap = 0.45
	density = 7.874

/datum/reagent/gold
	name = "Gold powder"
	id = GOLD
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = REAGENT_STATE_SOLID
	color = "#F7C430" //rgb: 247, 196, 48
	specheatcap = 0.129
	density = 19.3

/datum/reagent/silver
	name = "Silver powder"
	id = SILVER
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = REAGENT_STATE_SOLID
	color = "#D0D0D0" //rgb: 208, 208, 208
	specheatcap = 0.24
	density = 10.49

/datum/reagent/uranium
	name ="Uranium salt"
	id = URANIUM
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = REAGENT_STATE_SOLID
	color = "#B8B8C0" //rgb: 184, 184, 192
	density = 19.05
	specheatcap = 124

/datum/reagent/uranium/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.apply_radiation(1, RAD_INTERNAL)

/datum/reagent/uranium/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 3)
		if(!(locate(/obj/effect/decal/cleanable/greenglow) in T))
			new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/phazon
	name = "Phazon salt"
	id = PHAZON
	description = "The properties of this rare metal are not well-known."
	reagent_state = REAGENT_STATE_SOLID
	color = "#5E02F8" //rgb: 94, 2, 248
	dupeable = FALSE

/datum/reagent/phazon/New()
	..()
	density = rand(1,250)/rand(1,35)
	specheatcap = rand(1,250)/rand(1,35)

/datum/reagent/phazon/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.apply_radiation(5, RAD_INTERNAL)
	if(prob(20))
		M.advanced_mutate()

/datum/reagent/phazon/reaction_animal(var/mob/living/M)
	on_mob_life(M)

/datum/reagent/aluminum
	name = "Aluminum"
	id = ALUMINUM
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A8A8A8" //rgb: 168, 168, 168
	specheatcap = 0.902
	density = 2.7

/datum/reagent/silicon
	name = "Silicon"
	id = SILICON
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A8A8A8" //rgb: 168, 168, 168
	density = 2.33
	specheatcap = 0.712


//Reagents used for plant fertilizers.

/datum/reagent/plasma
	name = "Plasma"
	id = PLASMA
	description = "Plasma in its liquid form."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#500064" //rgb: 80, 0, 100

/datum/reagent/plasma/New()
	..()
	specheatcap = rand(1,150)/rand(1,25)
	density = rand(1,150)/rand(1,25)

/datum/reagent/plasma/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/mob/living/carbon/human/H = M
	if(isplasmaman(H))
		return 1
	else
		M.adjustToxLoss(3 * REM)
	if(holder.has_reagent("inaprovaline"))
		holder.remove_reagent("inaprovaline", 2 * REM)

/datum/reagent/saltwater
	name = "Salt Water"
	id = SALTWATER
	description = "It's water mixed with salt. It's probably not healthy to drink."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255
	density = 1.122
	specheatcap = 6.9036

/datum/reagent/saltwater/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(ishuman(M) && prob(20))
		var/mob/living/carbon/human/H = M
		H.vomit()
		M.adjustToxLoss(2 * REM)

/datum/reagent/saltwater/saline
	name = "Saline"
	id = SALINE
	description = "A solution composed of salt, water, and ammonia. Used in pickling and preservation"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DEF7F5" //rgb: 192, 227, 233
	alpha = 64
	density = 0.622
	specheatcap = 99.27

/datum/reagent/calciumoxide
	name = "Calcium Oxide"
	id = CALCIUMOXIDE
	description = "Quicklime. Reacts strongly with water forming calcium hydrate and generating heat in the process"
	color = "#FFFFFF"
	density = 3.34
	specheatcap = 42.09

/datum/reagent/calciumoxide/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if((H.species && H.species.flags & NO_BREATHE) || M_NO_BREATH in H.mutations)
			return
		M.adjustFireLoss(0.5 * REM)
		if(prob(10))
			M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")

/datum/reagent/calciumhydroxide
	name = "Calcium Hydroxide"
	id = CALCIUMHYDROXIDE
	description = "Hydrated lime, non-toxic."
	color = "#FFFFFF"
	density = 2.211
	specheatcap = 87.45

/datum/reagent/sodium_silicate
	name = "Sodium Silicate"
	id = SODIUMSILICATE
	description = "A white powder, commonly used in cements."
	reagent_state = REAGENT_STATE_SOLID
	color = "#E5E5E5"
	density = 2.61
	specheatcap = 111.8