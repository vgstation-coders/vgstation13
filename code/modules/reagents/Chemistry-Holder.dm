var/const/TOUCH = 1
var/const/INGEST = 2

/atom/proc/create_reagents(const/max_vol)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src



// Stolen from ConnectionGroup (ZAS)
// Needs a real chemist to fix the constants, I don't know what they fuck they are.
// At the very least, the volumes are wrong. - N3X 4/3/2015
/proc/share_reagent_heat(var/datum/reagents/A, var/datum/reagents/B)
	//This implements a simplistic version of the Stefan-Boltzmann law.
	var/energy_delta = ((A.chem_temp - B.chem_temp) ** 4) * 5.6704e-8 * 2.5  //* connecting_tiles * 2.5
	var/maximum_energy_delta = max(0, A.chem_temp * A.get_heat_capacity() * A.total_volume, B.chem_temp * B.get_heat_capacity() * B.total_volume)
	if(maximum_energy_delta > abs(energy_delta))
		if(energy_delta < 0)
			maximum_energy_delta *= -1
		energy_delta = maximum_energy_delta

	A.chem_temp -= energy_delta / (A.get_heat_capacity() * A.total_volume)
	B.chem_temp += energy_delta / (B.get_heat_capacity() * B.total_volume)

///////////////////
// /datum/reagents
///////////////////
/datum/reagents
	var/list/datum/reagent/addiction_list = new/list()
	var/addiction_tick = 1
	var/list/amount_cache = list() //-- N3X
	var/chem_temp = 150
	var/last_tick = 1
	var/maximum_volume = 100
	var/atom/my_atom
	var/list/datum/reagent/reagent_list = new/list()
	var/total_volume = 0

/datum/reagents/Destroy()
	for(var/datum/reagent/reagent in reagent_list)
		reagent.Destroy()

	if(my_atom)
		my_atom = null

/datum/reagents/New(maximum=100)
	maximum_volume = maximum

	if(!chemical_reagents_list)

		var/paths = typesof(/datum/reagent) - /datum/reagent
		chemical_reagents_list = list()
		for(var/path in paths)
			var/datum/reagent/D = new path()
			chemical_reagents_list[D.id] = D
	if(!chemical_reactions_list)

		var/paths = typesof(/datum/chemical_reaction) - /datum/chemical_reaction
		chemical_reactions_list = list()

		for(var/path in paths)

			var/datum/chemical_reaction/D = new path()
			var/list/reaction_ids = list()

			if(D.required_reagents && D.required_reagents.len)
				for(var/reaction in D.required_reagents)
					reaction_ids += reaction

			for(var/id in reaction_ids)
				if(!chemical_reactions_list[id])
					chemical_reactions_list[id] = list()
				chemical_reactions_list[id] += D
				break // Don't bother adding ourselves to other reagent ids, it is redundant.

/datum/reagents/proc/add_reagent(var/reagent, var/amount, var/list/data=null)
	if(!my_atom)
		return 0
	if(!isnum(amount)) return 1
	update_total()
	if(total_volume + amount > maximum_volume)
		amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.

	for(var/A in reagent_list)

		var/datum/reagent/R = A
		if (R.id == reagent)
			R.volume += amount
			update_total()
			my_atom.on_reagent_change()

			if(R.id == "blood" && reagent == "blood")
				if(R.data && data)

					if(R.data["viruses"] || data["viruses"])

						var/list/mix1 = R.data["viruses"]
						var/list/mix2 = data["viruses"]

						var/list/to_mix = list()

						for(var/datum/disease/advance/AD in mix1)
							to_mix += AD
						for(var/datum/disease/advance/AD in mix2)
							to_mix += AD

						var/datum/disease/advance/AD = Advance_Mix(to_mix)
						if(AD)
							var/list/preserve = list(AD)
							for(var/D in R.data["viruses"])
								if(!istype(D, /datum/disease/advance))
									preserve += D
							R.data["viruses"] = preserve

			handle_reactions()
			return 0

	var/datum/reagent/D = chemical_reagents_list[reagent]
	if(D)

		var/datum/reagent/R = new D.type()
		reagent_list += R
		R.holder = src
		R.volume = amount
		SetViruses(R, data) // Includes setting data

		update_total()
		my_atom.on_reagent_change()
		handle_reactions()
		return 0
	else
		warning("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")

	handle_reactions()

	return 1

/datum/reagents/proc/clear_reagents()
	amount_cache.len = 0
	for(var/datum/reagent/R in reagent_list)
		del_reagent(R.id,update_totals=0)

	update_total()
	if(my_atom)
		my_atom.on_reagent_change()
	return 0

/datum/reagents/proc/conditional_update(var/atom/A, )
	for(var/datum/reagent/R in reagent_list)
		R.on_update (A)
	update_total()

/datum/reagents/proc/conditional_update_move(var/atom/A, var/Running = 0)
	for(var/datum/reagent/R in reagent_list)
		R.on_move (A, Running)
	update_total()

/datum/reagents/proc/copy_to(var/obj/target, var/amount=1, var/multiplier=1, var/preserve_data=1)
	if(!target)
		return
	if(!target.reagents || src.total_volume<=0)
		return
	var/datum/reagents/R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = current_reagent.data
		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data)

	R.handle_reactions()
	src.handle_reactions()
	return amount

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

/datum/reagents/proc/get_data(var/reagent_id)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)

			return D.data

/datum/reagents/proc/get_master_reagent_id()
	var/the_id = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_id = A.id

	return the_id

/datum/reagents/proc/get_master_reagent_name()
	var/the_name = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_name = A.name

	return the_name

/datum/reagents/proc/get_reagent(var/reagent, var/amount = -1)

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

/datum/reagents/proc/get_reagent_amount(var/reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id == reagent)
			return R.volume

	return 0

/datum/reagents/proc/get_heat_capacity()
	var/total_heat_capacity = 0

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		total_heat_capacity += (R.volume * R.heat_capacity)

	return total_heat_capacity

// Energy can be negative, min/max are used to specify how cold the heat/cold source is.
/datum/reagents/proc/process_heat(var/energy, var/min_temp=0, var/max_temp=200)
	chem_temp = Clamp(chem_temp+(energy / get_heat_capacity()), min_temp, max_temp)

/datum/reagents/proc/get_reagent_ids(var/and_amount=0)
	var/list/stuff = list()
	for(var/datum/reagent/A in reagent_list)
		if(and_amount)
			stuff += "[get_reagent_amount(A.id)]U of [A.id]"
		else
			stuff += A.id
	return english_list(stuff)

/datum/reagents/proc/get_reagents()
	var/res = ""
	for(var/datum/reagent/A in reagent_list)
		if (res != "") res += ","
		res += A.name

	return res

/datum/reagents/proc/handle_reactions()
	if(!my_atom) return //sanity check
	if(my_atom.flags & NOREACT) return //Yup, no reactions here. No siree.

	var/reaction_occured = 0
	do
		reaction_occured = 0
		for(var/datum/reagent/R in reagent_list) // Usually a small list
			for(var/reaction in chemical_reactions_list[R.id]) // Was a big list but now it should be smaller since we filtered it with our reagent id

				if(!reaction)
					continue

				var/datum/chemical_reaction/C = reaction

				var/total_required_reagents = C.required_reagents.len
				var/total_matching_reagents = 0
				var/total_required_catalysts = C.required_catalysts.len
				var/total_matching_catalysts= 0
				var/matching_container = 0
				var/matching_other = 0
				var/list/multipliers = new/list()

				for(var/B in C.required_reagents)
					if(!has_reagent(B, C.required_reagents[B]))	break
					total_matching_reagents++
					multipliers += round(get_reagent_amount(B) / C.required_reagents[B])
				for(var/B in C.required_catalysts)
					if(!has_reagent(B, C.required_catalysts[B]))	break
					total_matching_catalysts++

				if(!C.required_container)
					matching_container = 1

				else
					if(my_atom.type == C.required_container)
						matching_container = 1

				if(!C.required_other)
					matching_other = 1

				else
					/*if(istype(my_atom, /obj/item/slime_core))
						var/obj/item/slime_core/M = my_atom

						if(M.POWERFLAG == C.required_other && M.Uses > 0) // added a limit to slime cores -- Muskets requested this
							matching_other = 1*/

					if(istype(my_atom, /obj/item/slime_extract))
						var/obj/item/slime_extract/M = my_atom

						if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
							matching_other = 1

				if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other && chem_temp >= C.min_temperature && chem_temp <= C.max_temperature)
					var/multiplier = min(multipliers)
					var/preserved_data = null
					for(var/B in C.required_reagents)
						if(!preserved_data)
							preserved_data = get_data(B)
						remove_reagent(B, (multiplier * C.required_reagents[B]), safety = 1)

					var/created_volume = 0
					if(C.results)
						for(var/new_chem_id in C.results)
							var/new_chem_amt = C.results[new_chem_id]
							feedback_add_details("chemical_reaction","[new_chem_id]|[new_chem_amt*multiplier]")
							multiplier = max(multiplier, 1) //this shouldnt happen ...
							var/new_amount = new_chem_amt*multiplier
							add_reagent(new_chem_id, new_amount)
							set_data(new_chem_id, preserved_data)
							created_volume += new_amount

					if	(istype(my_atom, /obj/item/weapon/grenade/chem_grenade))
						my_atom.visible_message("<span class='caution'>\icon[my_atom] Something comes out of \the [my_atom].</span>")
					else if	(istype(my_atom, /mob/living/carbon/human))
						my_atom.visible_message("<span class='notice'>[my_atom] shudders a little.</span>","<span class='notice'>You shudder a little.</span>")
					else
						my_atom.visible_message("<span class='notice'>\icon[my_atom] [C.mix_message].</span>")

					if(istype(my_atom, /obj/item/slime_extract))
						var/obj/item/slime_extract/ME2 = my_atom
						ME2.Uses--
						if(ME2.Uses <= 0) // give the notification that the slime core is dead
							if (!istype(ME2.loc, /obj/item/weapon/grenade/chem_grenade))
								ME2.visible_message("<span class='notice'>\icon[my_atom.icon_state] \The [my_atom]'s power is consumed in the reaction.</span>")
							ME2.name = "used slime extract"
							ME2.desc = "This extract has been used up."

					playsound(get_turf(my_atom), 'sound/effects/bubbles.ogg', 80, 1)

					C.on_reaction(src, created_volume)
					reaction_occured = 1
					break

	while(reaction_occured)
	update_total()
	return 0

/datum/reagents/proc/has_reagent(var/reagent, var/amount = -1)

	if(reagent in amount_cache)
		return amount_cache[reagent] >= max(0,amount)
	return 0

/datum/reagents/proc/isolate_reagent(var/reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id != reagent)
			del_reagent(R.id,update_totals=0)

	update_total()
	my_atom.on_reagent_change()

// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/reagents/proc/metabolize(var/mob/M)
	if(M)
		chem_temp = M.bodytemperature
		handle_reactions()
	if(last_tick == 3)
		last_tick = 1
		for(var/A in reagent_list)
			var/datum/reagent/R = A
			if(M && R)
				if(R.volume >= R.overdose_threshold && !R.overdosed && R.overdose_threshold > 0)
					R.overdosed = 1
					M << "<span class = 'userdanger'>You feel like you took too much of [R.name]!</span>"
					R.overdose_start(M)
				if(R.volume >= R.addiction_threshold && !is_type_in_list(R, addiction_list) && R.addiction_threshold > 0)
					var/datum/reagent/new_reagent = new R.type()
					addiction_list.Add(new_reagent)
				if(R.overdosed)
					R.overdose_process(M)
				if(is_type_in_list(R,addiction_list))
					for(var/datum/reagent/addicted_reagent in addiction_list)
						if(istype(R, addicted_reagent))
							addicted_reagent.addiction_stage = -15 // you're satisfied for a good while.
				R.on_mob_life(M)
	if(addiction_tick == 6)
		addiction_tick = 1
		for(var/A in addiction_list)
			var/datum/reagent/R = A
			if(M && R)
				if(R.addiction_stage <= 0)
					R.addiction_stage++
				if(R.addiction_stage > 0 && R.addiction_stage <= 10)
					R.addiction_act_stage1(M)
					R.addiction_stage++
				if(R.addiction_stage > 10 && R.addiction_stage <= 20)
					R.addiction_act_stage2(M)
					R.addiction_stage++
				if(R.addiction_stage > 20 && R.addiction_stage <= 30)
					R.addiction_act_stage3(M)
					R.addiction_stage++
				if(R.addiction_stage > 30 && R.addiction_stage <= 40)
					R.addiction_act_stage4(M)
					R.addiction_stage++
				if(R.addiction_stage > 40)
					M << "<span class = 'notice'>You feel like you've gotten over your need for [R.name].</span>"
					addiction_list.Remove(R)
	addiction_tick++
	last_tick++
	update_total()

/datum/reagents/proc/reaction(var/atom/A, var/method=TOUCH, var/volume_modifier=0)
	switch(method)
		if(TOUCH)
			for(var/datum/reagent/R in reagent_list)
				if(ismob(A))
					spawn(0)
						if(!R) return
						else R.reaction_mob(A, TOUCH, R.volume+volume_modifier)
				if(isturf(A))
					spawn(0)
						if(!R) return
						else R.reaction_turf(A, R.volume+volume_modifier)
				if(isobj(A))
					spawn(0)
						if(!R) return
						else R.reaction_obj(A, R.volume+volume_modifier)
		if(INGEST)
			for(var/datum/reagent/R in reagent_list)
				if(ismob(A) && R)
					spawn(0)
						if(!R) return
						else R.reaction_mob(A, INGEST, R.volume+volume_modifier)
				if(isturf(A) && R)
					spawn(0)
						if(!R) return
						else R.reaction_turf(A, R.volume+volume_modifier)
				if(isobj(A) && R)
					spawn(0)
						if(!R) return
						else R.reaction_obj(A, R.volume+volume_modifier)
	return

/datum/reagents/proc/remove_all_type(var/reagent_type, var/amount, var/strict = 0, var/safety = 1)
	if(!isnum(amount)) return 1

	var/has_removed_reagent = 0

	for(var/datum/reagent/R in reagent_list)
		var/matches = 0

		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1

		if(matches)

			has_removed_reagent = remove_reagent(R.id, amount, safety)

	return has_removed_reagent

/datum/reagents/proc/remove_any(var/amount=1)
	var/total_transfered = 0
	var/current_list_element = 1

	current_list_element = rand(1,reagent_list.len)

	while(total_transfered != amount)
		if(total_transfered >= amount) break
		if(total_volume <= 0 || !reagent_list.len) break

		if(current_list_element > reagent_list.len) current_list_element = 1
		var/datum/reagent/current_reagent = reagent_list[current_list_element]

		src.remove_reagent(current_reagent.id, 1)

		current_list_element++
		total_transfered++

	handle_reactions()
	return total_transfered

/datum/reagents/proc/remove_reagent(var/reagent, var/amount, var/safety)

	if(!isnum(amount)) return 1

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id == reagent)
			R.volume -= amount
			update_total()
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()
			if(my_atom)
				my_atom.on_reagent_change()
			return 0

	return 1

/datum/reagents/proc/set_data(var/reagent_id, var/new_data)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)

			D.data = new_data

/datum/reagents/proc/trans_id_to(var/obj/target, var/reagent, var/amount=1, var/preserve_data=1)
	if (!target)
		return
	if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
		return

	var/datum/reagents/R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if(current_reagent.id == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			R.add_reagent(current_reagent.id, amount, trans_data)
			src.remove_reagent(current_reagent.id, amount, 1)
			break

	share_reagent_heat(src,R)

	R.handle_reactions()

	return amount

	/*
	if (!target) return
	var/total_transfered = 0
	var/current_list_element = 1
	var/datum/reagents/R = target.reagents
	var/trans_data = null
	//if(R.total_volume + amount > R.maximum_volume) return 0

	current_list_element = rand(1,reagent_list.len) //Eh, bandaid fix.

	while(total_transfered != amount)
		if(total_transfered >= amount) break //Better safe than sorry.
		if(total_volume <= 0 || !reagent_list.len) break
		if(R.total_volume >= R.maximum_volume) break

		if(current_list_element > reagent_list.len) current_list_element = 1
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

/datum/reagents/proc/trans_to(var/target, var/amount=1, var/multiplier=1, var/preserve_data=1)
	if (!target)
		return
	var/datum/reagents/R
	if (istype(target, /datum/reagents))
		R = target
	else
		var/atom/movable/AM = target
		if (!AM.reagents || src.total_volume<=0)
			return
		else
			R = AM.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if (!current_reagent)
			continue
		if (current_reagent.id == "blood" && ishuman(target))
			var/mob/living/carbon/human/H = target
			H.inject_blood(my_atom, amount)
			continue
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = current_reagent.data

		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data)
		src.remove_reagent(current_reagent.id, current_reagent_transfer)


	share_reagent_heat(src,R)
	R.handle_reactions()
	src.handle_reactions()
	return amount

/datum/reagents/proc/trans_to_holder(var/datum/reagents/target, var/amount=1, var/multiplier=1, var/preserve_data=1)
	if (!target || src.total_volume<=0)
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

		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data)
		src.remove_reagent(current_reagent.id, current_reagent_transfer)


	share_reagent_heat(src,R)
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

/datum/reagents/proc/update_aerosol(var/mob/M)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(M && R)
			R.on_mob_life(M)
	update_total()

/datum/reagents/proc/update_total()
	total_volume = 0
	amount_cache.len = 0
	for(var/datum/reagent/R in reagent_list)
		if(R.volume < 0.1)
			del_reagent(R.id,update_totals=0)
		else
			total_volume += R.volume
			amount_cache[R.id] = R.volume
	return 0
