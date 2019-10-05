/*	The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
	so that it can continue working when the reagent is deleted while the proc is still active.

	Always call parent on reaction_mob, reaction_obj, reaction_turf, on_mob_life and Destroy() so that the sanities can be handled
	Failure to do so will lead to serious problems

	Are you adding a toxic reagent? Remember to update bees_apiary.dm 's lists of toxic reagents accordingly.

	Not sure what to have your density and SHC as? No IRL equivalent you can google? Use the components of the reagent
		density = (for(components of recipe) total_mass += component density* component volume)/volume of result. E.G
			6 SALINE = 3 SODIUMCHLORIDE, 5 WATER, 1 AMMONIA
				density = ((1 + (2.09*3) + (1*5) + (0.51*1))/6) = 2.22 (rounded to 2dp)

		SHC = (for(components of recipe) total_SHC *= component SHC)
*/

/datum/reagent
	var/name = "Reagent"
	var/id = REAGENT
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = REAGENT_STATE_SOLID
	var/list/data = null
	var/volume = 0
	var/nutriment_factor = 0
	var/pain_resistance = 0
	var/sport = 1 //High sport helps you show off on a treadmill. Multiplicative
	var/custom_metabolism = REAGENTS_METABOLISM
	var/custom_plant_metabolism = HYDRO_SPEED_MULTIPLIER
	var/overdose_am = 0
	var/overdose_tick = 0
	var/tick
	//var/list/viruses = list()
	var/color = "#000000" //rgb: 0, 0, 0 (does not support alpha channels - yet!)
	var/alpha = 255
	var/dupeable = TRUE	//whether the reagent can be duplicated by standard reagent duplication methods such as a service borg shaker or odysseus
	var/flags = 0
	var/density = 1 //(g/cm^3) Everything is water unless specified otherwise. round to 2dp
	var/specheatcap = 1 //how much energy in joules it takes to heat this thing up by 1 degree (J/g). round to 2dp

/datum/reagent/proc/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(M))
		return 1

	var/datum/reagent/self = src //Note : You need to declare self again (before the parent call) to use it in your chemical, see blood
	src = null

	//If the chemicals are in a smoke cloud, do not let the chemicals "penetrate" into the mob's system (balance station 13) -- Doohl
	if(self.holder && !istype(self.holder.my_atom, /obj/effect/effect/smoke/chem))
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

			if(prob(chance) && !block)
				if(M.reagents)
					M.reagents.add_reagent(self.id, self.volume/2) //Hardcoded, transfer half of volume

	if (M.mind)
		for (var/role in M.mind.antag_roles)
			var/datum/role/R = M.mind.antag_roles[role]
			R.handle_splashed_reagent(self.id)

/datum/reagent/proc/reaction_animal(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume)
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(M))
		return 1

	var/datum/reagent/self = src
	src = null

	M.reagent_act(self.id, method, volume)

/datum/reagent/proc/reaction_obj(var/obj/O, var/volume)
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(O))
		return 1

	src = null

/datum/reagent/proc/reaction_turf(var/turf/simulated/T, var/volume)
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(T))
		return 1

	src = null

/datum/reagent/proc/metabolize(var/mob/living/M)
	tick++
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
		if(L)
			L.metabolize_reagent(src.id, custom_metabolism)
			return
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

	if(is_overdosing())
		on_overdose(M)

	if (M.mind)
		for (var/role in M.mind.antag_roles)
			var/datum/role/R = M.mind.antag_roles[role]
			R.handle_reagent(id)

/datum/reagent/proc/is_overdosing() //Too much chems, or been in your system too long
	return (overdose_am && volume >= overdose_am) || (overdose_tick && tick >= overdose_tick)

/datum/reagent/proc/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return

	holder.remove_reagent(src.id, custom_plant_metabolism)

/datum/reagent/proc/on_move(var/mob/M)
	return

//Called after add_reagents creates a new reagent
/datum/reagent/proc/on_introduced(var/data)
	return

//Called when two reagents are mixing
/datum/reagent/proc/on_merge(var/data)
	return

/datum/reagent/proc/on_update(var/atom/A)
	return

/datum/reagent/proc/on_removal(var/data)
	return 1

/datum/reagent/proc/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)

/datum/reagent/proc/OnTransfer()
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

	spawn(duration + 1)
		var/datum/reagents/R = holder
		R.reagent_list.Add(src)

/datum/reagent/Destroy()
	if(istype(holder))
		holder.reagent_list -= src
		holder = null
	..()
