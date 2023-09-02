

var/const/TOUCH = 1
var/const/INGEST = 2

#define NO_REACTION 0
#define NON_DISCRETE_REACTION 1
#define DISCRETE_REACTION 2

///////////////////////////////////////////////////////////////////////////////////

/datum/reagents
	var/list/datum/reagent/reagent_list = new/list()
	var/list/amount_cache=list() //-- N3X
	var/total_volume = 0
	var/maximum_volume = 100
	var/atom/my_atom = null
	var/last_ckey_transferred_to_this = ""	//The ckey of the last player who transferred reagents into this reagent datum.
	var/chem_temp = T20C
	var/obscured = FALSE

/datum/reagents/New(maximum=100)
	maximum_volume = maximum

	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if (!chemical_reagents_list)
		//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
		chemical_reagents_list = list()

		for (var/path in typesof(/datum/reagent) - /datum/reagent)
			var/datum/reagent/D = new path()
			if(D.id == EXPLICITLY_INVALID_REAGENT_ID)
				continue
			chemical_reagents_list[D.id] = D

	if (!chemical_reactions_list)
		//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
		// It is filtered into multiple lists within a list.
		// For example:
		// chemical_reaction_list[PLASMA] is a list of all reactions relating to plasma

		chemical_reactions_list = list()

		for (var/path in typesof(/datum/chemical_reaction) - /datum/chemical_reaction)

			var/datum/chemical_reaction/D = new path()
			var/list/reaction_ids = list()

			if(D.required_reagents && D.required_reagents.len)
				var/reaction = D.required_reagents[1]
				if(islist(reaction))
					var/list/L = reaction
					for(var/content in L)
						reaction_ids += content
				else
					reaction_ids += reaction

			// Create filters based on each reagent id in the required reagents list
			for(var/id in reaction_ids)
				if(!chemical_reactions_list[id])
					chemical_reactions_list[id] = list()
				chemical_reactions_list[id] += D
				//previously we broke here, which meant that we were only testing the first reagent - even if the first reagent was a list
				//now we no longer break because we didn't add all the reagents to reaction_ids - we want to add the reaction to everything in
				//reaction_ids, which will be over everything in the first reagent in the table


/datum/reagents/proc/remove_any(var/amount=1)
	var/total_transfered = 0
	var/current_list_element = 1

	current_list_element = rand(1,reagent_list.len)

	while(total_transfered != amount)
		if(total_transfered >= amount)
			break
		if(is_empty() || !reagent_list.len)
			break

		if(current_list_element > reagent_list.len)
			current_list_element = 1
		var/datum/reagent/current_reagent = reagent_list[current_list_element]

		src.remove_reagent(current_reagent.id, 1)

		current_list_element++
		total_transfered++

		//src.update_total() // This is called from fucking remove_agent() -- N3X

	handle_reactions()
	return total_transfered

/datum/reagents/proc/get_master_reagent()
	var/the_reagent = null
	var/the_volume = 0

	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_reagent = A
	return the_reagent

/datum/reagents/proc/get_master_reagent_name()
	var/the_name = null
	var/the_volume = 0
	for(var/datum/reagent/R in reagent_list)
		if(R.volume > the_volume)
			var/reg_name = R.name
			if (istype(R,/datum/reagent/vaccine))
				var/datum/reagent/vaccine/vaccine = R
				var/vaccines = ""
				for (var/A in vaccine.data["antigen"])
					vaccines += "[A]"
				if (vaccines == "")
					vaccines = "blank"
				reg_name = "[reg_name] ([vaccines])"
			the_volume = R.volume
			the_name = reg_name

	return the_name

/datum/reagents/proc/get_master_reagent_id()
	var/the_id = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_id = A.id

	return the_id

/* Transfers reagents from one reagents datum to another.
 * target: Can be either a specific reagents datum, or an atom (in which case the atom's respective reagent datum will be used)
 * amount: Desired amount to transfer. If the target doesn't have enough space, it will only transfer as much as possible rather than the full amount.
 * multiplier: Magically multiplies the amount of reagents that the target will receive (does not affect how much is removed from the source)
 * preserve_data: If false, the reagents data will be lost. Useful if you use data for some strange stuff and don't want it to be transferred.
 * log_transfer: If true, will log the transfer of these reagents to the chemistry investigation file. If the reagents transferred contain a logged reagent, it will also alert admins.
 * whodunnit: If available, the mob that directly caused this transfer. Used for logging.
 */
/datum/reagents/proc/trans_to(var/target, var/amount=1, var/multiplier=1, var/preserve_data=1, var/log_transfer = FALSE, var/mob/whodunnit)
	if (!target)
		return

	var/datum/reagents/R
	if (istype(target, /datum/reagents))
		R = target
	else
		var/atom/movable/AM = target
		if (!AM.reagents || src.is_empty())
			return
		else
			R = AM.reagents

	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null

	if(istype(R.my_atom, /obj))
		var/obj/O = R.my_atom
		if(!O.log_reagents)
			log_transfer = FALSE
	var/list/logged_message = list()
	var/list/adminwarn_message = list()

	for (var/datum/reagent/current_reagent in src.reagent_list)
		if (!current_reagent)
			continue
		if (current_reagent.id == BLOOD && iscarbon(target))
			var/mob/living/carbon/C = target
			C.inject_blood(my_atom, amount)
			continue
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = current_reagent.data
		if(log_transfer)
			logged_message += "[current_reagent_transfer]u of [current_reagent.name]"
			if(current_reagent.id in reagents_to_log)
				adminwarn_message += "[current_reagent_transfer]u of <span class='warning'>[current_reagent.name]</span>"
		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, chem_temp)
		src.remove_reagent(current_reagent.id, current_reagent_transfer)

	for(var/datum/reagent/reagent_datum in R.reagent_list) //Wake up all of the reagents in our target, let them know we did stuff
		reagent_datum.post_transfer(src)

	// Called from add/remove_agent. -- N3X
	//src.update_total()
	//R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	if(whodunnit)
		R.last_ckey_transferred_to_this = key_name(whodunnit, include_name = FALSE)

	if(log_transfer && logged_message.len)
		var/turf/T = get_turf(my_atom)
		if(!T) //we got removed, duh
			T = get_turf(R.my_atom)
		minimal_investigation_log(I_CHEMS, "[whodunnit ? "[key_name(whodunnit)]" : "(N/A, last user processed: [usr.ckey])"] \
		transferred [english_list(logged_message)] from \a [my_atom] \ref[my_atom] to \a [R.my_atom] \ref[R.my_atom].", prefix=" ([T.x],[T.y],[T.z])")
		if(adminwarn_message.len)
			message_admins("[whodunnit ? "[key_name_and_info(whodunnit)] " : "(unknown whodunnit, last whodunnit processed: [usr.ckey])"]\
			has transferred [english_list(adminwarn_message)] from \a [my_atom] (<A HREF='?_src_=vars;Vars=\ref[my_atom]'>VV</A>) to \a [R.my_atom] (<A HREF='?_src_=vars;Vars=\ref[R.my_atom]'>VV</A>).\
			[whodunnit ? " [formatJumpTo(whodunnit)]" : ""]")

	return amount

//I totally cannot tell why this proc exists
/datum/reagents/proc/trans_to_holder(var/datum/reagents/target, var/amount=1, var/multiplier=1, var/preserve_data=1)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	if (!target || src.is_empty())
		return
	var/datum/reagents/R = target
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if (!current_reagent)
			continue
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = current_reagent.data

		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, chem_temp)
		src.remove_reagent(current_reagent.id, current_reagent_transfer)

	// Called from add/remove_agent. -- N3X
	//src.update_total()
	//R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount
/*
trans_to_atmos(var/datum/gas_mixture/target, var/amount=1, var/multiplier=1, var/preserve_data=1)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	if (!target )
		return
	if (!target.aerosols || src.total_volume<=0)
		return
	var/datum/reagents/R = target.aerosols
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if (!current_reagent)
			continue
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = current_reagent.data

		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data)
		src.remove_reagent(current_reagent.id, current_reagent_transfer)

	src.update_total()
	R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount
*/

//Pretty straightforward, remove from all of our chemicals at once, as if transfering to a nonexistant container or something.
/datum/reagents/proc/remove_all(var/amount=1)
	amount = min(amount, src.total_volume)
	var/part = amount / src.total_volume
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if (!current_reagent)
			continue
		if(src.remove_reagent(current_reagent.id, current_reagent.volume * part))
			. = 1 //We removed SOMETHING.
	src.handle_reactions()

/datum/reagents/proc/copy_to(var/obj/target, var/amount=1, var/multiplier=1, var/preserve_data=1)
	if(!target)
		return
	if(!target.reagents || src.is_empty())
		return
	var/datum/reagents/R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = current_reagent.data
		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, chem_temp)

	// Called from add/remove_agent. -- N3X
	//src.update_total()
	//R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount

/datum/reagents/proc/trans_id_to(var/obj/target, var/reagent, var/amount=1, var/preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
	if (!target)
		return
	if (src.is_empty() || !src.get_reagent_amount(reagent))
		return
	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents)
			return
		R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if(current_reagent.id == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			R.add_reagent(current_reagent.id, amount, trans_data, chem_temp)
			src.remove_reagent(current_reagent.id, amount, 1)
			break

	// Called from add/remove_agent. -- N3X
	//src.update_total()
	//R.update_total()
	R.handle_reactions()
	//src.handle_reactions() Don't need to handle reactions on the source since you're (presumably isolating and) transferring a specific reagent.
	return amount

/*
	if (!target)
		return
	var/total_transfered = 0
	var/current_list_element = 1
	var/datum/reagents/R = target.reagents
	var/trans_data = null
	//if(R.total_volume + amount > R.maximum_volume) return 0

	current_list_element = rand(1,reagent_list.len) //Eh, bandaid fix.

	while(total_transfered != amount)
		if(total_transfered >= amount)
			break //Better safe than sorry.
		if(total_volume <= 0 || !reagent_list.len)
			break
		if(R.total_volume >= R.maximum_volume)
			break

		if(current_list_element > reagent_list.len)
			current_list_element = 1
		var/datum/reagent/current_reagent = reagent_list[current_list_element]
		if(preserve_data)
			trans_data = current_reagent.data
		R.add_reagent(current_reagent.id, (1 * multiplier), trans_data)
		src.remove_reagent(current_reagent.id, 1)

		current_list_element++
		total_transfered++

	// Called from add/remove_agent. -- N3X
	//src.update_total()
	//R.update_total()
	R.handle_reactions()
	handle_reactions()

	return total_transfered
*/

/datum/reagents/proc/metabolize(var/mob/living/M, var/alien)
	if(M && chem_temp != M.bodytemperature)
		chem_temp = M.bodytemperature
		handle_reactions()
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(M && R)
			R.on_mob_life(M, alien)
			if(R)
				R.metabolize(M)
	if(M.addicted_chems)
		for(var/B in M.addicted_chems.reagent_list)
			var/datum/reagent/R2 = B
			if(M && R2 && !has_reagent_type(R2.type))
				R2.on_withdrawal(M)
	for(var/reagent_id in M.tolerated_chems)
		if(!has_reagent(reagent_id))
			var/datum/reagent/R3 = chemical_reagents_list[reagent_id]
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
				if(L)
					var/reagent_efficiency = 1
					if(reagent_id in L.reagent_efficiencies)
						reagent_efficiency = L.reagent_efficiencies[reagent_id]
					M.tolerated_chems[reagent_id] = max(0, M.tolerated_chems[reagent_id] - (L.efficiency * reagent_efficiency * R3.tolerance_increase))
					return
			// If we aren't human, we don't have a liver, so just remove tolerance the old fashioned way.
			M.tolerated_chems[reagent_id] = max(0, M.tolerated_chems[reagent_id] - R3.tolerance_increase)
	update_total()

/datum/reagents/proc/update_aerosol(var/mob/M)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(M && R)
			R.on_mob_life(M)
	update_total()

/datum/reagents/proc/handle_reactions()
	if(!my_atom)
		return //sanity check
	if(my_atom.flags & NOREACT)
		return //Yup, no reactions here. No siree.

	var/any_reactions
	var/reaction_occured
	do
		reaction_occured = 0
		for(var/R in amount_cache) // Usually a small list
			for(var/datum/chemical_reaction/C as anything in chemical_reactions_list[R]) // Was a big list but now it should be smaller since we filtered it with our reagent id
				switch(handle_reaction(C))
					if(DISCRETE_REACTION)
						any_reactions = 1
						break
					if(NON_DISCRETE_REACTION)
						any_reactions = 1
						reaction_occured = 1
						break
	while(reaction_occured)

	if(any_reactions)
		update_total()
	return 0

/datum/reagents/proc/handle_reaction(var/datum/chemical_reaction/C, var/requirement_override = FALSE, var/multiplier_override = 1)

	if(!requirement_override)

		if((C.required_temp && (C.is_cold_recipe ? (chem_temp > C.required_temp) : (chem_temp < C.required_temp))))
			return NO_REACTION

		var/total_required_catalysts = C.required_catalysts.len
		for(var/B in C.required_catalysts)
			if(amount_cache[B] >= C.required_catalysts[B])
				total_required_catalysts--
		if(total_required_catalysts)
			return NO_REACTION

		if(C.required_container && !istype(my_atom, C.required_container))
			return NO_REACTION

		if(!C.required_condition_check(src))
			return NO_REACTION

	var/list/multipliers = new/list()

	if(C.react_discretely || requirement_override)
		multipliers += 1 //Only once

	var/total_required_reagents = C.required_reagents.len
	var/req_reag_amt
	for(var/B in C.required_reagents)
		req_reag_amt = C.required_reagents[B]
		if(islist(B))
			var/list/L = B
			for(var/D in L)
				if(amount_cache[D] < req_reag_amt)
					continue
				total_required_reagents--
				multipliers += round(amount_cache[D] / req_reag_amt)
				break
		else
			if(amount_cache[B] < req_reag_amt)
				break
			total_required_reagents--
			multipliers += round(amount_cache[B] / req_reag_amt)

	if(!total_required_reagents || requirement_override)
		var/multiplier = min(multipliers) * multiplier_override
		var/preserved_data = null
		for(var/B in C.required_reagents)
			req_reag_amt = C.required_reagents[B]
			if(islist(B))
				var/list/L = B
				for(var/D in L)
					if(amount_cache[D] >= req_reag_amt)
						if(!preserved_data)
							preserved_data = get_data(D)
						remove_reagent(D, (multiplier * req_reag_amt), safety = 1)
						break
			else
				if(!preserved_data)
					preserved_data = get_data(B)
				remove_reagent(B, (multiplier * req_reag_amt), safety = 1)

		chem_temp += C.reaction_temp_change

		var/created_volume = C.result_amount*multiplier
		if(C.result)
			feedback_add_details("chemical_reaction","[C.result][created_volume]")
			multiplier = max(multiplier, 1) //this shouldnt happen ...
			add_reagent(C.result, created_volume, null, chem_temp)
			if (preserved_data)
				set_data(C.result, preserved_data)

			//add secondary products
			for(var/S in C.secondary_results)
				add_reagent(S, C.result_amount * C.secondary_results[S] * multiplier, reagtemp = chem_temp)

		if(C.quiet)
			C.log_reaction(src, created_volume)
		else
			if(istype(my_atom, /mob/living/carbon/human))
				my_atom.visible_message("<span class='notice'>[my_atom] shudders a little.</span>","<span class='notice'>You shudder a little.</span>")
				//Since the are no fingerprints to be had here, we'll trust the attack logs to log this
			else if(istype(my_atom, /obj/item/weapon/grenade/chem_grenade))
				my_atom.visible_message("<span class='caution'>[bicon(my_atom)] Something comes out of \the [my_atom].</span>")
				//Logging inside chem_grenade.dm, prime()
			else
				my_atom.visible_message("<span class='notice'>[bicon(my_atom)] The solution begins to bubble.</span>")
				C.log_reaction(src, created_volume)
			if(!(my_atom.flags & SILENTCONTAINER))
				playsound(my_atom, 'sound/effects/bubbles.ogg', 80, 1)

		C.on_reaction(src, created_volume)
		if(C.react_discretely)
			return DISCRETE_REACTION //We want to exit without continuing the loop.
		return NON_DISCRETE_REACTION
	return NO_REACTION

/datum/reagents/proc/isolate_reagent(var/reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id != reagent)
			del_reagent(R.id,update_totals=0)
	// Only call ONCE. -- N3X
	update_total()
	my_atom.on_reagent_change()

/datum/reagents/proc/isolate_any_reagent(var/list/protected_reagents)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		var/protected = FALSE
		for(var/B in protected_reagents)
			if(R.id == B)
				protected = TRUE
		if (protected == FALSE)
			del_reagent(R.id,update_totals=0)
	update_total()
	my_atom.on_reagent_change()

/datum/reagents/proc/del_reagent(var/reagent, var/update_totals=1)
	var/total_dirty=0
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id == reagent)
			R.reagent_deleted()
			reagent_list -= A
			R.holder = null
			total_dirty=1
			break

	if(total_dirty && update_totals)
		update_total()
		my_atom.on_reagent_change()
	return total_dirty

/datum/reagents/proc/update_total()
	total_volume = 0
	amount_cache.len = 0
	obscured = FALSE
	for(var/datum/reagent/R in reagent_list)
		if(R.volume < R.custom_metabolism/2) //Used to be 0.1, changing this to custom_metabolism/2 to alter balance as little as possible since the default metabolism is 0.2
			del_reagent(R.id,update_totals=0)
		else
			total_volume += R.volume
			amount_cache += list(R.id = R.volume)
		if(R.flags & CHEMFLAG_OBSCURING)
			obscured = TRUE
	return 0

/datum/reagents/proc/clear_reagents()
	amount_cache.len = 0
	for(var/datum/reagent/R in reagent_list)
		del_reagent(R.id,update_totals=0)
	// Only call ONCE. -- N3X
	update_total()
	if(my_atom)
		my_atom.on_reagent_change()
	return 0

/datum/reagents/proc/reaction(var/atom/A, var/method=TOUCH, var/volume_modifier=0, var/amount_override = 0, var/list/zone_sels = ALL_LIMBS)
	if (isliving(A))
		handle_reagents_mob_thermal_interaction(A, method, zone_sels, amount_override)
	for (var/datum/reagent/R in reagent_list)
		var/amount_splashed = amount_override ? amount_override : (R.volume + volume_modifier)
		if (ismob(A))
			if (isanimal(A))
				R.reaction_animal(A, method, amount_splashed)
			else
				R.reaction_mob(A, method, amount_splashed, zone_sels)
		else if (isturf(A))
			R.reaction_turf(A, amount_splashed)
		else if (istype(A, /obj))
			R.reaction_obj(A, amount_splashed)

/datum/reagents/proc/reaction_dropper(var/atom/A, var/volume_modifier=0)

	if (ismob(A))
		if (isliving(A))
			handle_reagents_mob_thermal_interaction(A, TOUCH, TARGET_EYES)
		for(var/datum/reagent/R in reagent_list)
			R.reaction_dropper_mob(A)

	else if(istype(A, /obj))
		for(var/datum/reagent/R in reagent_list)
			R.reaction_dropper_obj(A, R.volume+volume_modifier)

#define SCALD_PAINFUL 15
#define SCALD_AGONIZING 30

/datum/reagents/proc/handle_reagents_mob_thermal_interaction(mob/living/L, method, list/zone_sels = ALL_LIMBS, volume_used)
	if (!total_volume)
		return
	if (!isliving(L))
		return
	var/ignore_thermal_prot = FALSE
	if (method == INGEST) //Eating or drinking burns the mouth (head) regardless of targeting and isn't blocked by head thermal protection.
		zone_sels = TARGET_MOUTH
		ignore_thermal_prot = TRUE
	var/burn_dmg = L.get_splash_burn_damage(volume_used ? volume_used : total_volume, chem_temp)
	var/datum/organ/external/which_organ
	if (ishuman(L)) //Although monkeys can wear clothes, only humans have explicit organs that can be covered by specific worn items, so for now only humans get protection here. If this is expanded to include things like monkeys wearing clothes and getting non-organ-specific thermal protection, this could be changed to use type inheritance.
		var/mob/living/carbon/human/H = L
		which_organ = H.get_organ(pick(zone_sels))
		if (!ignore_thermal_prot)
			burn_dmg = round(burn_dmg * H.getthermalprot(which_organ))
	if (burn_dmg)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/post_mod_predicted_dmg = burn_dmg * L.burn_damage_modifier
			var/custom_pain_msg
			if (post_mod_predicted_dmg >= SCALD_AGONIZING)
				var/first = pick("A searing", "A roaring", "A blazing", "An exquisite")
				var/list/second_list = list("torrent", "sea", "wall", "inferno", "river")
				if (first != "A roaring")
					second_list += "roar" //don't say "roaring roar"
				custom_pain_msg = "[first] [pick(second_list)] of agony [pick("envelops", "cascades through", "courses through", "rushes into", "consumes", "fills")] [which_organ ? "your " + which_organ.display_name : "you"]!"
			else if (post_mod_predicted_dmg >= SCALD_PAINFUL)
				var/second = pick("rush", "wave", "lance", "spike")
				var/list/third_list = list("shoots through", "stabs through", "washes through")
				if (second != "lance")
					third_list += "lances through" //don't say "lance lances"
				custom_pain_msg = "[pick("A burning", "A searing", "A boiling")] [second] of pain [pick(third_list)] [which_organ ? "your " + which_organ.display_name : "you"]!"
			else
				custom_pain_msg = "Pain sears [which_organ ? " your " + which_organ.display_name : ""]!"
			H.custom_pain(custom_pain_msg, post_mod_predicted_dmg >= SCALD_AGONIZING, post_mod_predicted_dmg >= SCALD_PAINFUL)
		L.apply_effect(burn_dmg * 5, AGONY) //pain
		L.apply_damage(burn_dmg, BURN, which_organ)

#undef SCALD_PAINFUL
#undef SCALD_AGONIZING

/datum/reagents/proc/get_equalized_temperature(temperature_A, thermalmass_A, temperature_B, thermalmass_B)
	//Gets the equalized temperature of two thermal masses
	if(temperature_A == temperature_B)
		return temperature_A
	if(thermalmass_A + thermalmass_B)
		return ((temperature_A * thermalmass_A) + (temperature_B * thermalmass_B)) / (thermalmass_A + thermalmass_B)
	else
		warning("[usr] tried to equalize the temperature of a thermally-massless mixture.")
		return T0C+20 //Sanity but this shouldn't happen.

/datum/reagents/proc/add_reagent(var/reagent, var/amount, var/list/data=null, var/reagtemp = T0C+20)
	if(!my_atom)
		return 0
	if(!amount)
		return 0
	if(!isnum(amount))
		return 1
	update_total()
	if(total_volume + amount > maximum_volume)
		amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldn't happen. Will happen.
	for (var/datum/reagent/R in reagent_list)
		if (R.id == reagent)

			//Equalize temperatures
			chem_temp = get_equalized_temperature(chem_temp, get_thermal_mass(), reagtemp, amount * R.density * R.specheatcap * CC_PER_U)

			R.volume += amount
			update_total()
			my_atom.on_reagent_change()

			if(!isnull(data))
				if (reagent == BLOOD)
				//to do: add better ways for blood colors to interact with each other
				//right now we don't support blood mixing or something similar at all.
					if(R.data["virus2"] && data["virus2"])
						R.data["virus2"] |= virus_copylist(data["virus2"])
				else if (reagent == VACCINE)
					R.data["antigen"] |= data["antigen"]
				else
					R.data = data //just in case someone adds a new reagent with a data var

			handle_reactions()
			return 0

	var/datum/reagent/D = chemical_reagents_list[reagent]
	if(D)

		var/datum/reagent/R = new D.type()

		//Equalize temperatures
		chem_temp = get_equalized_temperature(chem_temp, get_thermal_mass(), reagtemp, amount * R.density * R.specheatcap * CC_PER_U)

		reagent_list += R
		R.holder = src
		R.volume = amount

		if(!isnull(data))
			if (reagent == BLOOD)
				R.data = data.Copy()
				if(data["virus2"])
					R.data["virus2"] |= virus_copylist(data["virus2"])
				if(data["blood_colour"])
					R.color = data["blood_colour"]
			else if (reagent == VACCINE)
				R.data = data.Copy()
			else
				R.data = data
		else if (reagent == VACCINE)
			R.data = list("antigen" = list())

		R.on_introduced()

		update_total()
		my_atom.on_reagent_change()
		handle_reactions()
		return 0
	else
		warning("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")

	handle_reactions()

	return 1

/datum/reagents/proc/remove_reagent(var/reagent, var/amount, var/safety)//Added a safety check for the trans_id_to

	if(!isnum(amount))
		return 1

	for (var/datum/reagent/R in reagent_list)
		if (R.id == reagent)
			return remove_that_reagent(R, amount, safety)
	return 1

/datum/reagents/proc/remove_reagents(var/list/reagent_list, var/amount, var/safety)
	if(!isnum(amount))
		return 1

	for(var/id in reagent_list)
		if(has_reagent(id))
			remove_reagent(id, amount, safety)
	return 1

/datum/reagents/proc/remove_any_reagents(var/list/reagent_list, var/amount, var/safety)
	if(!isnum(amount))
		return 0
	for(var/id in reagent_list)
		if(has_reagent(id))
			amount -= remove_reagent(id, amount, safety)
			if(amount <= 0)
				return 1
	return 0

/datum/reagents/proc/remove_reagent_by_type(var/reagent_type, var/amount, var/safety)
	if(!isnum(amount))
		return 1

	var/datum/reagent/R = get_reagent_by_type(type, amount)
	if(R)
		remove_that_reagent(R, amount, safety)

/datum/reagents/proc/remove_reagents_by_type(var/list/reagent_types, var/amount, var/safety)
	if(!isnum(amount))
		return 1

	for(var/datum/reagent/R in reagent_list)
		if(is_type_in_list(R, reagent_types))
			remove_that_reagent(R, amount, safety)

/datum/reagents/proc/remove_that_reagent(var/datum/reagent/R, var/amount, var/safety)
	if(!isnum(amount))
		return 1

	if(!R.on_removal(amount))
		return 0 //handled and reagent says fuck no
	R.volume -= amount
	update_total()
	if(!safety)//So it does not handle reactions when it need not to
		handle_reactions()
	if(my_atom)
		my_atom.on_reagent_change()
	return 0


/**************************************
 *  RETURNS A BOOL NOW, USE get_reagent IF YOU NEED TO GET ONE.
 **************************************/
/datum/reagents/proc/has_reagent(var/reagent, var/amount = 0)
	// N3X: Caching shit.
	// Only cache if not using get (since we only track bools)
	var/amount_in_cache = amount_cache[reagent]
	return amount_in_cache ? amount_in_cache >= amount : 0

/datum/reagents/proc/has_only_any(list/good_reagents)
    var/found_any_good_reagent = FALSE
    for(var/reagent in amount_cache)
        if(!good_reagents.Find(reagent))
            return FALSE
        found_any_good_reagent = TRUE
    return found_any_good_reagent

/datum/reagents/proc/has_reagent_type(var/reagent_type, var/amount = -1, var/strict = 0)
	if(!ispath(reagent_type,/datum/reagent))
		return 0

	for(var/datum/reagent/R in reagent_list)
		if(strict && !R.type == reagent_type)
			continue
		if(!istype(R,reagent_type))
			continue
		return R.volume >= max(0,amount)

/datum/reagents/proc/has_any_reagents(var/list/input_reagents, var/amount = -1)		//returns true if any of the input reagents are found
	. = FALSE
	for(var/i in input_reagents)
		if(has_reagent(i, amount))
			return TRUE

/datum/reagents/proc/has_all_reagents(var/list/input_reagents, var/amount = -1)		//returns true if all of the input reagents are found
	for(var/i in input_reagents)
		if(!has_reagent(i, amount))
			return FALSE
	return TRUE

/datum/reagents/proc/get_reagent(var/reagent, var/amount = -1)
	// SLOWWWWWWW
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id == reagent)
			if(!amount)
				return R
			else
				if(R.volume >= amount)
					return R
			return 0
	return 0

/datum/reagents/proc/get_reagent_by_type(var/reagent_type, var/amount = -1, var/strict)
	if(!ispath(reagent_type,/datum/reagent))
		return 0

	for(var/datum/reagent/R in reagent_list)
		if(strict && R.type != reagent_type)
			continue
		if(!istype(R, reagent_type))
			continue
		return R
	return 0

/datum/reagents/proc/get_reagent_amount(var/reagent)
	return amount_cache[reagent] + 0 //Convert null to 0.

/datum/reagents/proc/get_reagents()
	var/res = ""
	for(var/datum/reagent/A in reagent_list)
		if (res != "")
			res += ","
		res += A.name

	return res

// Admin logging.
/datum/reagents/proc/get_reagent_ids(var/and_amount=0)
	var/list/stuff = list()
	for(var/datum/reagent/A in reagent_list)
		if(and_amount)
			stuff += "[get_reagent_amount(A.id)]u of [A.id]"
		else
			stuff += A.id
	return english_list(stuff, "no reagents")

/datum/reagents/proc/get_sportiness()
	var/sportiness = 1
	for(var/datum/reagent/R in reagent_list)
		sportiness *= R.sport
	return sportiness

/datum/reagents/proc/remove_all_type(var/reagent_type, var/amount, var/strict = 0, var/safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum(amount))
		return 1

	var/has_removed_reagent = 0

	for(var/datum/reagent/R in reagent_list)
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.id, amount, safety)

	return has_removed_reagent

//two helper functions to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(var/reagent_id)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
//						to_chat(world, "proffering a data-carrying reagent ([reagent_id])")
			return D.data

/datum/reagents/proc/set_data(var/reagent_id, var/new_data)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
//						to_chat(world, "reagent data set ([reagent_id])")
			D.data = new_data

/datum/reagents/Destroy()
	for(var/datum/reagent/reagent in reagent_list)
		qdel(reagent)

	reagent_list.Cut()

	if(my_atom)
		my_atom.reagents = null
		my_atom = null
	..()

/**
 * Helper proc to retrieve the 'bad' reagents in the holder. Used for logging.
 * Example of result: "5u of Polytrinic Acid, 5u of Cyanide, and 15u of Mindbreaker Toxin"
 */
/datum/reagents/proc/write_logged_reagents()
	. = list()

	for(var/datum/reagent/R in reagent_list)
		if(R.id in reagents_to_log) //reagents_to_log being a global list in objs.dm
			. += "[R.volume]u of [R.name]"

	return english_list(., nothing_text = "")

/datum/reagents/proc/log_bad_reagents(var/mob/user, var/atom/A)
	var/badreagents = write_logged_reagents()
	if(badreagents)
		add_gamelogs(user, "used \a [A] containing [badreagents]", admin = TRUE, tp_link = TRUE)

/datum/reagents/proc/is_empty()
	return total_volume <= 0

/datum/reagents/proc/is_full()
	return total_volume >= maximum_volume

/datum/reagents/proc/get_overall_mass() //currently unused
	//M = DV
	var/overall_mass = 0
	for(var/datum/reagent/R in reagent_list)
		overall_mass += R.density * R.volume
	return overall_mass * CC_PER_U

/datum/reagents/proc/get_thermal_mass()
	var/total_thermal_mass = 0
	for(var/datum/reagent/R in reagent_list)
		total_thermal_mass += R.volume * R.density * R.specheatcap
	return total_thermal_mass * CC_PER_U

/datum/reagents/proc/heating(var/power_transfer, var/received_temperature)
	/*
	Q/mc = deltaT
	Q = heat energy transferred (Joules)
	m = mass of the liquid
	c = specific heat capacity of the liquid
	deltaT = change in temperature of the liquid
	*/
	if(received_temperature == chem_temp || !total_volume || !reagent_list.len)
		return
	var/energy = power_transfer
	var/temp_change = (energy / (get_thermal_mass()))
	if(power_transfer > 0)
		chem_temp = min(chem_temp + temp_change, received_temperature)
	else
		chem_temp = max(chem_temp + temp_change, received_temperature, 0)
	handle_reactions()

/datum/reagents/proc/get_examine(var/mob/user, var/vis_override, var/blood_type)
	if(obscured && !vis_override)
		to_chat(user, "<span class='info'>You can't quite make out the contents.</span>")
		return
	if (istype(my_atom,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass) && reagent_list.len)
		to_chat(user, "<span class='info'>It contains [total_volume] units of what looks like [get_master_reagent_name()].</span>")
		return
	to_chat(user, "It contains:")
	if(!user.hallucinating())
		if(reagent_list.len)
			for(var/datum/reagent/R in reagent_list)
				if(blood_type && R.id == BLOOD)
					var/type = R.data["blood_type"]
					to_chat(user, "<span class='info'>[R.volume] units of [R.name], of type [type]</span>")
				else
					to_chat(user, "<span class='info'>[R.volume] units of [R.name]</span>")
		else
			to_chat(user, "<span class='info'>Nothing.</span>")

	else //Show stupid things to hallucinating mobs
		var/list/fake_reagents = list("Water", "Orange juice", "Banana juice", "Tungsten", "Chloral Hydrate", "Helium",\
			"Sea water", "Energy drink", "Gushin' Granny", "Salt", "Sugar", "something yellow", "something red", "something blue",\
			"something suspicious", "something smelly", "something sweet", "Soda", "something that reminds you of home",\
			"Chef's Special")
		for(var/i, i < rand(1,10), i++)
			var/fake_amount = rand(1,30)
			var/fake_reagent = pick(fake_reagents)
			fake_reagents -= fake_reagent

			to_chat(user, "<span class='info'>[fake_amount] units of [fake_reagent]</span>")

///////////////////////////////////////////////////////////////////////////////////


/proc/reagent_name(id)
	var/datum/reagent/D = chemical_reagents_list[id]
	if(D)
		return D.name

/*
 * Convenience proc to create a reagents holder for an atom
 * max_vol is maximum volume of holder
 */
/atom/proc/create_reagents(const/max_vol)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src

/datum/reagents/send_to_past(var/duration)
	var/static/list/resettable_vars = list(
		"being_sent_to_past",
		"reagent_list",
		"amount_cache",
		"total_volume",
		"maximum_volume",
		"my_atom",
		"chem_temp",
		"gcDestroyed")

	reset_vars_after_duration(resettable_vars, duration, TRUE)

	for(var/y in reagent_list)
		var/datum/reagent/R = y
		R.send_to_past(duration)

//written for ethylredoxrazine, but might be fun for turning water into wine or something
/datum/reagents/proc/convert_some_of_type(var/datum/reagent/convert_from_type, var/datum/reagent/convert_to_type,var/convert_amount)
	if(my_atom.flags & NOREACT)
		return //Yup, no reactions here. No siree.
	var/total_amount_converted = 0

	for(var/datum/reagent/itsareagent in reagent_list)
		if(istype(itsareagent, convert_from_type))
			var/amount_to_convert
			amount_to_convert = min(itsareagent.volume, convert_amount)
			total_amount_converted += amount_to_convert
			remove_that_reagent(itsareagent, amount_to_convert)
	return add_reagent(initial(convert_to_type.id), total_amount_converted)

/datum/reagents/proc/convert_all_to_id(var/reagent_id, var/list/whitelisted_ids)
	if(my_atom.flags & NOREACT)
		return //Yup, no reactions here. No siree.
	if(!reagent_list.len)
		return
	if(reagent_list.len == 1)
		var/datum/reagent/the_one_and_only = reagent_list[1]
		if(the_one_and_only.id == reagent_id || (the_one_and_only.id in whitelisted_ids)) //work's done
			return

	var/total_amount_converted = 0
	for(var/datum/reagent/reagent_datum in reagent_list)
		if(reagent_datum.id == reagent_id || (reagent_datum.id in whitelisted_ids))
			continue
		total_amount_converted += reagent_datum.volume
		remove_that_reagent(reagent_datum, reagent_datum.volume)

	if(!(my_atom.flags & SILENTCONTAINER))
		playsound(my_atom, 'sound/effects/bubbles.ogg', 50, 1)

	return add_reagent(reagent_id, total_amount_converted)

#undef NO_REACTION
#undef NON_DISCRETE_REACTION
#undef DISCRETE_REACTION
