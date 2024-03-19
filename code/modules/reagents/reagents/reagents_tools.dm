//Chemicals designed for utility/tool use, like cleaners.

/datum/reagent/ammonia
	name = "Ammonia"
	id = AMMONIA
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = REAGENT_STATE_GAS
	color = "#404030" //rgb: 64, 64, 48
	density = 0.51
	specheatcap = 14.38

/datum/reagent/ammonia/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_nutrientlevel(10)
	T.add_planthealth(1)

/datum/reagent/fuel
	name = "Welding Fuel"
	id = FUEL
	description = "Required for welders. Flamable."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#660000" //rgb: 102, 0, 0
	density = 1.1
	specheatcap = 0.68
	glass_icon_state = "dr_gibb_glass"
	glass_desc = "Unless you are an industrial tool, this is probably not safe for consumption."

/datum/reagent/fuel/reaction_obj(var/obj/O, var/volume)
	var/datum/reagent/self = src
	if(..())
		return 1
	if(isturf(O.loc))
		var/turf/T = get_turf(O)
		self.reaction_turf(T, volume)

/datum/reagent/fuel/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(!(locate(/obj/effect/decal/cleanable/liquid_fuel) in T))
		new /obj/effect/decal/cleanable/liquid_fuel(T, volume)

/datum/reagent/fuel/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustToxLoss(1)

/datum/reagent/glue
	name = "Glue"
	id = GLUE
	description = "A powerful and fast-acting bonding agent. Also used as a medium to produce acrylic paint."
	color = COLOR_GLUE //rgb: 255, 255, 204
	var/glue_duration = 1 MINUTES
	var/glue_state_to_set = GLUE_STATE_TEMP
	var/turning_into_paint = FALSE

/datum/reagent/glue/reaction_turf(var/turf/T, var/volume)
	if(..())
		return TRUE
	if (isfloor(T))
		if (!(locate(/obj/effect/decal/cleanable/glue) in T))
			new /obj/effect/decal/cleanable/glue(T)

/datum/reagent/glue/reaction_obj(var/obj/O, var/volume)
	if(..())
		return TRUE

	var/glue_data = list(
		"viruses"		=null,
		"blood_DNA"		="glue",
		"blood_colour"	= COLOR_GLUE,
		"blood_type"	="glue",
		"resistances"	=null,
		"trace_chem"	=null,
		"virus2" 		=list(),
		"immunity" 		=null,
		)

	O.add_blood_from_data(glue_data)//visible glue
	O.glue_act(glue_duration, glue_state_to_set)

/datum/reagent/glue/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return TRUE

	if(iscarbon(M))
		var/glue_data = list(
			"viruses"		=null,
			"blood_DNA"		="glue",
			"blood_colour"	= COLOR_GLUE,
			"blood_type"	="glue",
			"resistances"	=null,
			"trace_chem"	=null,
			"virus2" 		=list(),
			"immunity" 		=null,
			)

		var/mob/living/carbon/H = M
		for(var/obj/item/I in H.held_items)
			I.add_blood_from_data(glue_data)
			I.glue_act(glue_duration, glue_state_to_set)

		for(var/obj/item/clothing/C in M.get_equipped_items())
			C.add_blood_from_data(glue_data)
			C.glue_act(glue_duration, glue_state_to_set)
		H.regenerate_icons()

/datum/reagent/glue/special_behaviour()
	if (turning_into_paint)
		return
	var/datum/reagent/paint_exists = null
	var/list/non_paint_pigments = list()
	for (var/datum/reagent/R in holder.reagent_list)
		if ((R.id == ACRYLIC) || (R.id == NANOPAINT))//we exclude flax oil so players can turn it into acrylic if they want to get rid of any alpha
			paint_exists = R
		else if (R.flags & CHEMFLAG_PIGMENT)
			non_paint_pigments += R
	var/mixed_pigment_color = mix_color_from_reagents(non_paint_pigments)

	if (!mixed_pigment_color)//no pigments?
		if (paint_exists)
			paint_exists.volume += volume//if there's already acrylic or nano paint we just increase its volume
			holder.del_reagent(id)
	else
		turning_into_paint = TRUE
		holder.add_reagent(ACRYLIC, volume, list("color" = mixed_pigment_color))
		holder.del_reagent(id)

/datum/reagent/lube
	name = "Space Lube"
	id = LUBE
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#009CA8" //rgb: 0, 156, 168
	overdose_am = REAGENTS_OVERDOSE
	density = 1.11775
	specheatcap = 2.71388

/datum/reagent/lube/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(volume >= 1)
		T.wet(800, TURF_WET_LUBE)

/datum/reagent/luminol
	name = "Luminol"
	id = LUMINOL
	description = "A chemical that exhibits chemiluminescence in the presence of blood due to the iron and copper in the hemoglobin."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255

/datum/reagent/luminol/reaction_mob(var/mob/living/M, var/method = TOUCH)
	if(ishuman(M) && (method == TOUCH))
		var/mob/living/carbon/human/H = M
		H.apply_luminol()

/datum/reagent/luminol/reaction_turf(var/turf/simulated/T)
	if(..())
		return TRUE
	T.apply_luminol()

/datum/reagent/luminol/reaction_obj(var/obj/O, var/volume)
	if(..())
		return TRUE
	O.apply_luminol()

/datum/reagent/pacid
	name = "Polytrinic Acid"
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

/datum/reagent/pacid/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				if(H.wear_mask.dissolvable() == PACID)
					qdel(H.wear_mask)
					H.wear_mask = null
					H.update_inv_wear_mask()
					to_chat(H, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(H, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

			if(H.head && !istype(H.head, /obj/item/weapon/reagent_containers/glass/bucket))
				if(prob(15) && H.head.dissolvable() == PACID)
					qdel(H.head)
					H.head = null
					H.update_inv_head()
					to_chat(H, "<span class='warning'>Your helmet melts away but protects you from the acid</span>")
				else
					to_chat(H, "<span class='warning'>Your helmet protects you from the acid!</span>")
				return

			if(H.dissolvable() == PACID)
				var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
				if(head_organ.take_damage(min(15, volume * 4), 0))
					H.UpdateDamageIcon(1)
				H.audible_scream()

		else if(ismonkey(M))
			var/mob/living/carbon/monkey/MK = M
			if(MK.wear_mask)
				if(MK.wear_mask.dissolvable() == PACID)
					qdel(MK.wear_mask)
					MK.wear_mask = null
					MK.update_inv_wear_mask()
					to_chat(MK, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(MK, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

			if(MK.dissolvable() == PACID)
				MK.take_organ_damage(min(15, volume * 4), 0) //Same deal as sulphuric acid
	else
		if(M.dissolvable() == PACID) //I think someone doesn't know what this does
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
				if(head_organ.take_damage(min(15, volume * 4), 0))
					H.UpdateDamageIcon(1)
				H.audible_scream()
				head_organ.disfigure("burn")
			else
				M.take_organ_damage(min(15, volume * 4), 0)

/datum/reagent/pacid/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(!(O.dissolvable() == PACID))
		return

	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)))
		O.acid_melt()
	else if(istype(O,/obj/effect/plantsegment))
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(get_turf(O))
		I.desc = "Looks like these were some [O.name] some time ago."
		var/obj/effect/plantsegment/K = O
		K.die_off()
	else if(istype(O,/obj/effect/dummy/chameleon))
		var/obj/effect/dummy/chameleon/projection = O
		projection.disrupt()

/datum/reagent/pacid/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_toxinlevel(20)

/datum/reagent/sacid
	name = "Sulphuric Acid"
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

	if(M.dissolvable() == PACID)	//not PACID but it'll do
		M.adjustFireLoss(REM)
		M.take_organ_damage(0, REM)

/datum/reagent/sacid/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				if(H.wear_mask.dissolvable() == PACID)
					qdel(H.wear_mask)
					H.wear_mask = null
					H.update_inv_wear_mask()
					to_chat(H, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(H, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

			if(H.head && !istype(H.head, /obj/item/weapon/reagent_containers/glass/bucket))
				if(prob(15) && H.head.dissolvable() == PACID)
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
				if(MK.wear_mask.dissolvable() == PACID)
					qdel(MK.wear_mask)
					MK.wear_mask = null
					MK.update_inv_wear_mask()
					to_chat(MK, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(MK, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

		if(M.dissolvable() == PACID)
			if(prob(15) && ishuman(M) && volume >= 30)
				var/mob/living/carbon/human/H = M
				var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
				if(head_organ)
					if(head_organ.take_damage(min(25, volume * 2), 0))
						H.UpdateDamageIcon(1)
					head_organ.disfigure("burn")
					H.audible_scream()
			else
				M.take_organ_damage(min(15, volume * 2), 0) //uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
	else
		if(M.dissolvable() == PACID)
			M.take_organ_damage(min(15, volume * 2), 0)

/datum/reagent/sacid/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(!(O.dissolvable() == PACID)) //not PACID but it will do
		return

	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(10))
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
		I.desc = "Looks like this was \an [O] some time ago."
		O.visible_message("<span class='warning'>\The [O] melts.</span>")
		qdel(O)
	else if(istype(O,/obj/effect/dummy/chameleon))
		var/obj/effect/dummy/chameleon/projection = O
		projection.disrupt()

/datum/reagent/sacid/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_toxinlevel(2)

/datum/reagent/sodium_polyacrylate
	name = "Sodium Polyacrylate"
	id = SODIUM_POLYACRYLATE
	description = "A super absorbent polymer that can absorb water based substances."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFFFFF"
	density = 1.22
	specheatcap = 4.14

/datum/reagent/sodium_polyacrylate/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(T.is_wet())
		if(!locate(/obj/effect/decal/cleanable/molten_item) in T)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(T)
			I.desc = "A bit of gel left over from sodium polyacrylate absorbing liquid."
		T.dry(TURF_WET_LUBE) //Absorbs water or lube

/datum/reagent/space_cleaner
	name = "Space Cleaner"
	id = CLEANER
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A5F0EE" //rgb: 165, 240, 238
	density = 0.76
	specheatcap = 60.17
	var/clean_level = CLEANLINESS_SPACECLEANER

/datum/reagent/space_cleaner/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	O.clean_blood()
	O.clean_act(clean_level)

/datum/reagent/space_cleaner/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(volume >= 1)
		for (var/obj/effect/decal/cleanable/C in T)
			qdel(C)

		if (T.advanced_graffiti)
			T.overlays -= T.advanced_graffiti_overlay
			T.advanced_graffiti_overlay = null
			qdel(T.advanced_graffiti)

		T.clean_blood()

		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(5, 10))

		for(var/mob/living/carbon/human/H in T)
			if(isslimeperson(H))
				H.adjustToxLoss(rand(5, 10)/10)

		T.clean_act(clean_level)

/datum/reagent/space_cleaner/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if(iscarbon(M))
		var/mob/living/carbon/H = M
		for(var/obj/item/I in H.held_items)
			I.clean_act(clean_level)

		for(var/obj/item/clothing/C in M.get_equipped_items())
			if(C.clean_blood())
				H.update_inv_by_slot(C.slot_flags)

	M.clean_act(clean_level)

/datum/reagent/space_cleaner/bleach
	name = "Bleach"
	id = BLEACH
	description = "A strong cleaning compound. Corrosive and toxic when applied to soft tissue. Do not swallow."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FBFCFF" //rgb: 251, 252, 255
	density = 6.84
	specheatcap = 3.5
	clean_level = CLEANLINESS_BLEACH

/datum/reagent/space_cleaner/bleach/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	for(var/atom/A in T)
		A.clean_blood()
		A.clean_act(clean_level)

	for(var/obj/item/I in T)
		I.decontaminate()

/datum/reagent/space_cleaner/bleach/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.color = ""

	switch(tick)
		if(1 to 10)
			M.adjustBruteLoss(3 * REM) //soft tissue damage
		if(10 to INFINITY)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(5))
					H.emote("me", 1, "coughs up blood!")
					H.drip(10)
				else if(prob(5))
					H.vomit()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.anatomy_flags & MULTICOLOR && !(initial(H.species.anatomy_flags) & MULTICOLOR))
			H.species.anatomy_flags &= ~MULTICOLOR
			H.update_body()
	M.adjustToxLoss(4 * REM)

/datum/reagent/space_cleaner/bleach/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if(method == TOUCH && ((TARGET_EYES in zone_sels) || (LIMB_HEAD in zone_sels)))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/eyes_covered = H.get_body_part_coverage(EYES)
			if(eyes_covered)
				to_chat(H,"<span class='warning'>Your [eyes_covered] protects your eyes from the bleach!</span>")
				return
			else //This stuff is a little more corrosive but less irritative than pepperspray
				H.audible_scream()
				to_chat(H,"<span class='danger'>You are sprayed directly in the eyes with bleach!</span>")
				H.eye_blurry = max(M.eye_blurry, 15)
				H.eye_blind = max(M.eye_blind, 5)
				H.adjustBruteLoss(2)
				var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
				E.take_damage(5, 1)
				H.custom_pain("Your [E] burn horribly!", 1)
				H.apply_damage(2, BRUTE, LIMB_HEAD)

/datum/reagent/thermite
	name = "Thermite"
	id = THERMITE
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	reagent_state = REAGENT_STATE_SOLID
	color = "#673910" //rgb: 103, 57, 16
	density = 3.91
	specheatcap = 0.37

/datum/reagent/thermite/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(volume >= 5 && T.can_thermite)
		T.thermite = 1
		T.overlays.len = 0
		T.overlays = image('icons/effects/effects.dmi', icon_state = "thermite")

/datum/reagent/thermite/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustFireLoss(2 * REM)

/datum/reagent/vaporsalt
	name = "Vapor Salts"
	id = VAPORSALT
	description = "A strange mineral found in alien plantlife that has been observed to vaporize some liquids."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#BDE5F2"
	specheatcap = 1.02 //SHC of air
	density = 1.225

/datum/reagent/vaporsalt/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(T.is_wet())
		T.dry(TURF_WET_LUBE) //Cleans water or lube
		var/obj/effect/smoke/S = new /obj/effect/smoke(T)
		S.time_to_live = 10 //unusually short smoke
		//We don't need to start up the system because we only want to smoke one tile.
