//Basic chems, basic dispenser buttons

/datum/reagent/aluminum
	name = "Aluminum"
	id = ALUMINUM
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A8A8A8" //rgb: 168, 168, 168
	specheatcap = 0.902
	density = 2.7

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

/datum/reagent/chlorine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_toxinlevel(8)
	T.add_weedlevel(-2)

/datum/reagent/copper
	name = "Copper"
	id = COPPER
	description = "A highly ductile metal."
	color = "#6E3B08" //rgb: 110, 59, 8
	specheatcap = 0.385
	density = 8.96

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
	if(prob(5) && !M.isUnconscious())
		M.emote("stare")

/datum/reagent/fluorine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_toxinlevel(25)

/datum/reagent/hydrogen
	name = "Hydrogen"
	id = HYDROGEN
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	density = 0.08988
	specheatcap = 13.83

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

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = PHOSPHORUS
	description = "A chemical element, the backbone of biological energy carriers."
	reagent_state = REAGENT_STATE_SOLID
	color = "#832828" //rgb: 131, 40, 40
	density = 1.823
	specheatcap = 0.769

/datum/reagent/phosphorus/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_nutrientlevel(1)
	T.add_weedlevel(3)

/datum/reagent/potassium
	name = "Potassium"
	id = POTASSIUM
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A0A0A0" //rgb: 160, 160, 160
	specheatcap = 0.75
	density = 0.89

/datum/reagent/radium
	name = "Radium"
	id = RADIUM
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = REAGENT_STATE_SOLID
	color = COLOR_RADIUM//"#61F09A" //rgb: 101, 242, 156
	density = 5
	specheatcap = 0.094
	flags = CHEMFLAG_PIGMENT
	paint_light = PAINTLIGHT_LIMITED

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

/datum/reagent/radium/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return
	T.add_toxinlevel(2)
	if(T.reagents.get_reagent_amount(id) > 0)
		if(prob(15))
			T.mutate(GENE_MORPHOLOGY)
			T.reagents.remove_reagent(id, 1)

/datum/reagent/silicon
	name = "Silicon"
	id = SILICON
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A8A8A8" //rgb: 168, 168, 168
	density = 2.33
	specheatcap = 0.712

/datum/reagent/sodium
	name = "Sodium"
	id = SODIUM
	description = "A chemical element, readily reacts with water."
	reagent_state = REAGENT_STATE_SOLID
	color = "#808080" //rgb: 128, 128, 128
	specheatcap = 1.23
	density = 0.968

/datum/reagent/sulfur
	name = "Sulfur"
	id = SULFUR
	description = "A chemical element with a pungent smell."
	reagent_state = REAGENT_STATE_SOLID
	color = "#BF8C00" //rgb: 191, 140, 0
	specheatcap = 0.73
	density = 1.96

/datum/reagent/water
	name = "Water"
	id = WATER
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DEF7F5" //rgb: 192, 227, 233
	alpha = 128
	specheatcap = 4.184
	density = 1
	glass_desc = "The father of all refreshments."

/datum/reagent/water/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species && H.species.anatomy_flags & ACID4WATER)
			M.adjustToxLoss(REM)
			M.take_organ_damage(0, REM, ignore_inorganics = TRUE)

/datum/reagent/water/reaction_mob(var/mob/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	//Put out fire
	if(method == TOUCH)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/datum/disease2/effect/E = C.has_active_symptom(/datum/disease2/effect/thick_skin)
			C.make_visible(INVISIBLESPRAY,FALSE)
			if(E)
				E.multiplier = max(E.multiplier - rand(1,3), 1)
				to_chat(C, "<span class='notice'>The water quenches your dry skin.</span>")
		else
			M.make_visible(INVISIBLESPRAY)
		if(isliving(M))
			var/mob/living/L = M
			L.ExtinguishMob()

	//Water now directly damages slimes instead of being a turf check
	if(isslime(M))
		var/mob/living/L = M
		L.adjustToxLoss(rand(15, 20))

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
					H.take_organ_damage(0, min(15, volume * 2))

		else if(isslimeperson(H))

			H.adjustToxLoss(rand(1,3))
	M.clean_act(CLEANLINESS_WATER)

/datum/reagent/water/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(volume >= 3) //Hardcoded
		T.wet(800)

	for (var/obj/effect/decal/cleanable/glue/G in T)
		qdel(G)

	T.clean_act(CLEANLINESS_WATER)

	var/hotspot = (locate(/obj/effect/fire) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air(T:air:total_moles())
		lowertemp.temperature = max(min(lowertemp.temperature-2000, lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/water/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(O.invisibility)
		O.make_visible(INVISIBLESPRAY)

	O.clean_act(CLEANLINESS_WATER)//removes glue and extinguishes fire

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()
	else if(istype(O,/obj/machinery/space_heater/campfire))
		var/obj/machinery/space_heater/campfire/campfire = O
		campfire.putOutFire()
	else if(istype(O, /obj/item/weapon/book/manual/snow))
		var/obj/item/weapon/book/manual/snow/S = O
		S.trigger()
	else if(O.molten) // Molten shit.
		O.molten=0
		O.solidify()
	else if(O.dissolvable() == WATER &&  prob(15))
		O.acid_melt()

/datum/reagent/water/reaction_animal(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume)
	..()

	if(istype(M,/mob/living/simple_animal/hostile/slime))
		var/mob/living/simple_animal/hostile/slime/S = M
		S.calm()

	if(istype(M,/mob/living/simple_animal/bee))
		var/mob/living/simple_animal/bee/B = M
		B.calming()

/datum/reagent/water/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_waterlevel(2)
