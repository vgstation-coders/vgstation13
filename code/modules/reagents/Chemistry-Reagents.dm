/*	The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
	so that it can continue working when the reagent is deleted while the proc is still active.

	Always call parent on reaction_mob, reaction_obj, reaction_turf, on_mob_life and Destroy() so that the sanities can be handled
	Failure to do so will lead to serious problems

	Are you adding a toxic reagent? Remember to update bees_apiary.dm 's lists of toxic reagents accordingly.

	REGARDING SPECHEATCAP, IF YOU'RE NOT SURE JUST KEEP IT AT WATER'S OR AT 1. IF YOU GET SOMETHING IN THE HUNDREDS OR HIGHER YOU'RE PROBABLY DOING SOMETHING VERY WRONG

	It is very common to use REAGENTS_METABOLISM (0.2) or REM / REGEANTS_EFFECT_MULTIPLIER (0.5) in the reagent files.

*/

/datum/reagent
	var/name = "Reagent"
	var/id = REAGENT
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = REAGENT_STATE_SOLID
	var/data = null
	var/volume = 0
	var/nutriment_factor = 0
	var/pain_resistance = 0
	var/sport = SPORTINESS_NONE //High sport helps you show off on a treadmill. Multiplicative
	var/custom_metabolism = REAGENTS_METABOLISM
	var/overdose_am = 0
	var/overdose_tick = 0
	var/tick = 0
	var/real_tick = 0 // For advanced reagent scanners
	//var/list/viruses = list()
	var/color = "#000000" //rgb: 0, 0, 0 (does not support alpha channels - yet!)
	var/alpha = 255
	var/dupeable = TRUE	//whether the reagent can be duplicated by standard reagent duplication methods such as a service borg shaker or odysseus
	var/flags = 0
	var/density = 1 //(g/cm^3) Everything is water unless specified otherwise. round to 2dp
	var/specheatcap = 1 //how much energy in joules it takes to heat this thing up by 1 degree (J/g). round to 2dp
	var/glass_icon_state = null
	var/glass_desc = null //for reagents with a different desc in a glass
	var/glass_name = null //defaults to "glass of [reagent name]"
	var/light_color = null
	var/flammable = 0
	var/glass_isGlass = 1
	var/mug_icon_state = null
	var/mug_name = null
	var/mug_desc = null
	var/addictive = FALSE
	var/tolerance_increase = null  //for tolerance, if set above 0, will increase each by that amount on tick.
	var/paint_light = PAINTLIGHT_NONE
	var/adj_temp = 0//keep between -1.5,20 to prevent people from freezing/burning themselves

/datum/reagent/proc/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS, var/allow_permeability = TRUE, var/list/splashplosion=list())
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(M))
		return 1
	if((src.id in M.tolerated_chems) && M.tolerated_chems[src.id] && M.tolerated_chems[src.id] >= volume)
		return 1

	var/datum/reagent/self = src //Note : You need to declare self again (before the parent call) to use it in your chemical, see blood
	src = null

	//If the chemicals are in a smoke cloud, do not let the chemicals "penetrate" into the mob's system (balance station 13) -- Doohl
	if(self.holder && allow_permeability && !istype(self.holder.my_atom, /obj/effect/smoke/chem))
		if(method == TOUCH)

			var/chance = 1
			var/block  = 0

			for(var/obj/item/clothing/C in M.get_equipped_items())
				if(C.permeability_coefficient < chance)
					chance = C.permeability_coefficient

				//Hardcode, but convenient until protection is fixed
				if(istype(C, /obj/item/clothing/suit/bio_suit))
					if(prob(75))
						block = 1

				if(istype(C, /obj/item/clothing/head/bio_hood))
					if(prob(75))
						block = 1

			chance = chance * 100

			if(self.id == HOLYWATER && istype(self.holder.my_atom, /obj/item/weapon/reagent_containers/food/drinks/bottle/holywater))
				if(M.reagents)
					M.reagents.add_reagent(self.id, min(5,self.volume/2)) //holy water flasks only splash 5u at a time. But for deconversion purposes they will always be ingested.
			else if(prob(chance) && !block)
				if(M.reagents)
					M.reagents.add_reagent(self.id, self.volume/2) //Hardcoded, transfer half of volume

	if (M.mind)
		for (var/role in M.mind.antag_roles)
			var/datum/role/R = M.mind.antag_roles[role]
			R.handle_splashed_reagent(self.id)

	if(self.tolerance_increase)
		M.tolerated_chems[self.id] += self.tolerance_increase

/datum/reagent/proc/reaction_dropper_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	if((src.id in M.tolerated_chems) && M.tolerated_chems[src.id] && M.tolerated_chems[src.id] >= volume)
		return 1
	var/datum/reagent/self = src //Note : You need to declare self again (before the parent call) to use it in your chemical, see blood
	src = null
	if(M.reagents)
		M.reagents.add_reagent(self.id, self.volume) //Hardcoded, transfer half of volume

	if (M.mind)
		for (var/role in M.mind.antag_roles)
			var/datum/role/R = M.mind.antag_roles[role]
			R.handle_splashed_reagent(self.id)

	if(self.tolerance_increase)
		M.tolerated_chems[self.id] += self.tolerance_increase

/datum/reagent/proc/reaction_dropper_obj(var/obj/O, var/volume)
	reaction_obj(O, volume)

/datum/reagent/proc/reaction_animal(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume, var/list/splashplosion=list())
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(M))
		return 1

	var/datum/reagent/self = src
	src = null

	M.reagent_act(self.id, method, volume)

/datum/reagent/proc/reaction_obj(var/obj/O, var/volume, var/list/splashplosion=list())
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(O))
		return 1

	src = null

/datum/reagent/proc/reaction_turf(var/turf/simulated/T, var/volume, var/list/splashplosion=list())
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(T))
		return 1

	src = null

/datum/reagent/proc/metabolize(var/mob/living/M)
	tick++
	real_tick++
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
		if(L)
			L.metabolize_reagent(src.id, custom_metabolism)
			return
	if(holder)
		holder.remove_reagent(src.id, custom_metabolism) // If we aren't human, we don't have a liver, so just metabolize it the old fashioned way.

/datum/reagent/proc/on_mob_life(var/mob/living/M, var/alien)
	set waitfor = 0

	if(!holder)
		return 1
	if(!M)
		M = holder.my_atom //Try to find the mob through the holder
	if(!istype(M)) //Still can't find it, abort
		return 1
	if(M.mind)
		if((M.mind.special_role == HIGHLANDER || M.mind.special_role == BOMBERMAN) && src.flags & CHEMFLAG_DISHONORABLE)
			// TODO: HONORABLE_* checks.
			return 1
		if(dupeable && reagent_state == REAGENT_STATE_LIQUID && volume>=5 && ischangeling(M))
			var/datum/role/changeling/C = M.mind.GetRole(CHANGELING)
			if(!C.absorbed_chems.Find(id))
				C.absorbed_chems.Add(id)
				to_chat(M, "<span class = 'notice'>We have learned [src].</span>")

	if((src.id in M.tolerated_chems) && M.tolerated_chems[src.id] && M.tolerated_chems[src.id] >= volume)
		return 1
	if(is_overdosing())
		on_overdose(M)

	if (M.mind)
		for (var/role in M.mind.antag_roles)
			var/datum/role/R = M.mind.antag_roles[role]
			R.handle_reagent(id)

	if(addictive && M.addicted_chems)
		M.addicted_chems.add_reagent(src.id, custom_metabolism)
	if(tolerance_increase)
		M.tolerated_chems[src.id] += tolerance_increase

	M.nutrition += nutriment_factor * (M.size <= SIZE_SMALL ? 2 : 1)	//More nourishing if small
	if(M.nutrition < 0) //Prevent from going into negatives
		M.nutrition = 0

	if(adj_temp > 0 && M.bodytemperature <= 325) //310 is the normal bodytemp. 310.055, keeping possible temp adjust effect below a total of 350 will keep the screen alarm weak
		M.bodytemperature = max(310, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(adj_temp < 0 && M.bodytemperature >= 309.5)
		M.bodytemperature = min(310, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/proc/is_overdosing() //Too much chems, or been in your system too long
	return (overdose_am && volume >= overdose_am) || (overdose_tick && tick >= overdose_tick)

/datum/reagent/proc/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return

	holder.remove_reagent(src.id, 1)

//Called after add_reagents creates a new reagent
/datum/reagent/proc/on_introduced(var/data)
	return

/datum/reagent/proc/on_removal(var/amount)
	return 1

//Called every tick when listed as an addicted chemical
/datum/reagent/proc/on_withdrawal(var/mob/living/M)
	if(!holder)
		return 1
	if(!M)
		M = holder.my_atom //Try to find the mob through the holder
	if(!istype(M)) //Still can't find it, abort
		return 1
	if(M.addicted_chems)
		M.addicted_chems.remove_reagent(src.id, custom_metabolism)
	tick++
	real_tick++

//Has to be a reagents datum for on_withdrawal()
/mob/living/var/datum/reagents/addicted_chems
//Associative lists for tolerance formatted like (REAGENT_ID = amount)
/mob/living/var/list/tolerated_chems

//Completely unimplemented as of 2021, commenting out
///datum/reagent/proc/on_move(var/mob/M)
//	return
///datum/reagent/proc/on_merge(var/data)
///	return
///datum/reagent/proc/on_update(var/atom/A)
//	return

/datum/reagent/proc/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)

//Called when reagentcontainer A transfers into reagentcontainer B (this /datum/reagent belongs to B, i.e. we are the catchers here)
/datum/reagent/proc/post_transfer(var/datum/reagents/donor)
	return

/datum/reagent/send_to_past(var/duration)
	var/static/list/resettable_vars = list(
		"being_sent_to_past",
		"name",
		"id",
		"description",
		"holder",
		"reagent_state",
		"data",
		"volume",
		"gcDestroyed",
		"tick")

	reset_vars_after_duration(resettable_vars, duration, TRUE)

/datum/reagent/Destroy()
	if(istype(holder))
		holder.reagent_list -= src
		holder = null
	..()

/datum/reagent/proc/when_drinkingglass_master_reagent(var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/D) //rip steve
	return

/datum/reagent/proc/handle_data_mix(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data = added_data

/datum/reagent/proc/handle_data_copy(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data = added_data

/datum/reagent/proc/handle_additional_data(var/list/additional_data=null)//used by xenoarch
	return

/datum/reagent/proc/special_behaviour()//used by nano-paints. called on all reagents in a container after another agent was added.
	return

/datum/reagent/proc/reagent_deleted()
	return
