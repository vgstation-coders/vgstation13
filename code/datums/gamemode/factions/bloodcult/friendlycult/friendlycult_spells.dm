


/spell/cult/friendly_trace_rune //For cyborg module
	name = "Trace Rune"
	desc = "(1 BLOOD) Use available blood to write down words. Three words form a friendly rune."
	hud_state = "cult_word"
	override_base = "grey"
	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = "<span class='warning'>You cannot write another word just yet.</span>"
	still_recharging_msg = "<span class='warning'>You cannot write another word just yet.</span>"

	cast_delay = 15

	var/list/data = list()
	var/datum/friendly_cultword/word = null
	var/obj/effect/friendly_rune/rune = null
	var/datum/friendly_rune_spell/spell = null
	var/remember = 0
	var/blood_cost = 1
	
/spell/cult/friendly_trace_rune/choose_targets(var/mob/user = usr)
	return list(user)
	
/spell/cult/friendly_trace_rune/before_channel(mob/user)
	if(remember)
		remember = 0
	else
		spell = null
	return 0
	
/spell/cult/friendly_trace_rune/spell_do_after(var/mob/user, var/delay, var/numticks = 3)
	if(!istype(user.loc, /turf))
		to_chat(user, "<span class='warning'>You do not have enough space to write a proper rune.</span>")
		return 0

	var/turf/T = get_turf(user)
	var/obj/effect/friendly_rune/rune = locate() in T

	if(rune)
		if (rune.invisibility == INVISIBILITY_OBSERVER)
			to_chat(user, "<span class='warning'>You can feel the presence of a concealed rune here, you have to reveal it before you can add more words to it.</span>")
			return 0
		else if (rune.word1 && rune.word2 && rune.word3)
			to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
			return 0


	if(!spell)
		var/list/available_runes = list()
		var/i = 1
		for(var/subtype in subtypesof(/datum/friendly_rune_spell))
			var/datum/friendly_rune_spell/instance = subtype
			available_runes.Add("\Roman[i]-[initial(instance.name)]")
			available_runes["\Roman[i]-[initial(instance.name)]"] = instance
			i++
		var/spell_name = input(user,"Choose a rune to draw.", "Trace Complete Rune", null) as null|anything in available_runes
		spell = available_runes[spell_name]
			
	var/datum/friendly_cultword/instance
	if(!rune)
		instance = initial(spell.word1)
	else if (rune.word1.type != initial(spell.word1))
		to_chat(user, "<span class='warning'>This rune's first word conflicts with the [initial(spell.name)] rune's syntax.</span>")
		return 0
	else if (!rune.word2)
		instance = initial(spell.word2)
	else if (rune.word2.type != initial(spell.word2))
		to_chat(user, "<span class='warning'>This rune's second word conflicts with the [initial(spell.name)] rune's syntax.</span>")
		return 0
	else if (!rune.word3)
		instance = initial(spell.word3)
	else //Should never happen
		to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
		return 0

	word = initial(instance.english)

	if(!word)
		return 0

	data = use_available_blood_silicon(user, blood_cost)
	if(data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
		return 0

	if(rune)
		user.visible_message("<span class='warning'>\The [user] chants and paints more symbols on the floor.</span>",\
				"<span class='warning'>You add another word to the rune.</span>",\
				"<span class='warning'>You hear chanting.</span>")
	else
		user.visible_message("<span class='warning'>\The [user] begins to chant and paint symbols on the floor.</span>",\
				"<span class='warning'>You begin drawing a rune on the floor.</span>",\
				"<span class='warning'>You hear some chanting.</span>")

	var/datum/friendly_cultword/r_word = friendly_cultwords[word]
	user.whisper("...[r_word.rune]...")
	
	return ..()

/spell/cult/friendly_trace_rune/cast(var/list/targets, var/mob/user)
	..()
	if (rune && rune.word1 && rune.word2 && rune.word3)
		to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
		return
	if (friendly_write_rune_word(get_turf(user) ,data["blood"] ,word = friendly_cultwords[word]) > 1)
		remember = 1
		perform(user) //Recursion


/spell/cult/friendly_erase_rune
	name = "Erase Rune"
	desc = "Remove the last word written of the friendly rune you're standing above."
	hud_state = "cult_erase"
	override_base = "grey"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

/spell/cult/friendly_erase_rune/choose_targets(var/mob/user = usr)
	return list(user)

/spell/cult/friendly_erase_rune/cast(var/list/targets, var/mob/living/carbon/user)
	..()
	var/removed_word = friendly_erase_rune_word(get_turf(user))
	if (removed_word)
		to_chat(user, "<span class='notice'>You hastily scrub away the [removed_word] rune.</span>")
	else
		to_chat(user, "<span class='warning'>There aren't any rune words left to erase.</span>")


		
/proc/iscultistsilicon(var/user)
	if(istype(user, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/target = user
		if(target.module && /obj/item/borg/upgrade/cult in target.module.upgrades)
			return 1
	return 0
	
	
/proc/use_available_blood_silicon(var/mob/user, var/amount_needed = 0,var/previous_result = "", var/tribute = 0) //Works for both carbons and silicons, could just replace the base one with this but whatever
	//Blood Communion
	var/communion = 0
	var/communion_data = null
	var/total_accumulated = 0
	var/total_needed = amount_needed
	if (!tribute && iscultist(user))
		var/datum/role/cultist/mycultist = user.mind.GetRole(CULTIST)
		if (mycultist in blood_communion)
			communion = 1
			amount_needed = max(1,round(amount_needed * 4 / 5))//saving 20% blood
			var/list/tributers = list()
			for (var/datum/role/cultist/cultist in blood_communion)
				if (cultist.antag && cultist.antag.current)
					var/mob/living/L = cultist.antag.current
					if (istype(L) && L != user)
						tributers.Add(L)
			var/total_per_tribute = max(1,round(amount_needed/max(1,tributers.len+1)))
			var/tributer_size = tributers.len
			for (var/i = 1 to tributer_size)
				var/mob/living/L = pick(tributers)//so it's not always the first one that pays the first blood unit.
				tributers.Remove(L)
				var/data = use_available_blood(L, total_per_tribute, "", 1)
				if (data[BLOODCOST_RESULT] != BLOODCOST_FAILURE)
					total_accumulated += data[BLOODCOST_TOTAL]
				if (total_accumulated >= amount_needed - total_per_tribute)//could happen if the cost is less than 1 per tribute
					communion_data = data//in which case, the blood will carry the data that paid for it
					break

	//Getting nearby blood sources
	var/list/data = get_available_blood_silicon(user, amount_needed-total_accumulated)

	var/datum/reagent/blood/blood

	//Flavour text and blood data transfer
	switch (data[BLOODCOST_RESULT])
		if (BLOODCOST_TRIBUTE)//if the drop of blood was paid for through blood communion, let's get the reference to the blood they used because we can
			blood = new()
			blood.data["blood_colour"] = DEFAULT_BLOOD
			if (communion_data && communion_data[BLOODCOST_RESULT])
				switch(communion_data[BLOODCOST_RESULT])
					if (BLOODCOST_TARGET_HANDS)
						var/mob/living/carbon/human/HU = communion_data[BLOODCOST_USER]
						blood.data["blood_colour"] = HU.hand_blood_color
						if (HU.blood_DNA && HU.blood_DNA.len)
							var/blood_DNA = pick(HU.blood_DNA)
							blood.data["blood_DNA"] = blood_DNA
							blood.data["blood_type"] = HU.blood_DNA[blood_DNA]
					if (BLOODCOST_TARGET_SPLATTER)
						var/obj/effect/decal/cleanable/blood/B = communion_data[BLOODCOST_TARGET_SPLATTER]
						blood = new()
						blood.data["blood_colour"] = B.basecolor
						if (B.blood_DNA.len)
							var/blood_DNA = pick(B.blood_DNA)
							blood.data["blood_DNA"] = blood_DNA
							blood.data["blood_type"] = B.blood_DNA[blood_DNA]
						blood.data["virus2"] = B.virus2
					if (BLOODCOST_TARGET_GRAB)
						var/mob/living/carbon/human/HU = communion_data[BLOODCOST_TARGET_GRAB]
						blood = get_blood(HU.vessel)
					if (BLOODCOST_TARGET_BLEEDER)
						var/mob/living/carbon/human/HU = communion_data[BLOODCOST_TARGET_BLEEDER]
						blood = get_blood(HU.vessel)
					if (BLOODCOST_TARGET_HELD)
						var/obj/item/weapon/reagent_containers/G = communion_data[BLOODCOST_TARGET_HELD]
						blood = locate() in G.reagents.reagent_list
					if (BLOODCOST_TARGET_BLOODPACK)
						var/obj/item/weapon/reagent_containers/blood/B = communion_data[BLOODCOST_TARGET_BLOODPACK]
						blood = locate() in B.reagents.reagent_list
					if (BLOODCOST_TARGET_CONTAINER)
						var/obj/item/weapon/reagent_containers/G = communion_data[BLOODCOST_TARGET_CONTAINER]
						blood = locate() in G.reagents.reagent_list
					if (BLOODCOST_TARGET_USER)
						var/mob/living/carbon/human/HU = communion_data[BLOODCOST_USER]
						blood = get_blood(HU.vessel)
			if (!tribute && previous_result != BLOODCOST_TRIBUTE)
				user.visible_message("<span class='warning'>Drips of blood seem to appear out of thin air around \the [user], and fall onto the floor!</span>",
									"<span class='rose'>An ally has lent you a drip of their blood for your ritual.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_HANDS)
			var/mob/living/carbon/human/H = user
			blood = new()
			blood.data["blood_colour"] = H.hand_blood_color
			if (H.blood_DNA && H.blood_DNA.len)
				var/blood_DNA = pick(H.blood_DNA)
				blood.data["blood_DNA"] = blood_DNA
				blood.data["blood_type"] = H.blood_DNA[blood_DNA]
			if (!tribute && previous_result != BLOODCOST_TARGET_HANDS)
				user.visible_message("<span class='warning'>The blood on \the [user]'s hands drips onto the floor!</span>",
									"<span class='rose'>You let the blood smeared on your hands join the pool of your summoning.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_SPLATTER)
			var/obj/effect/decal/cleanable/blood/B = data[BLOODCOST_TARGET_SPLATTER]
			blood = new()
			blood.data["blood_colour"] = B.basecolor
			if (B.blood_DNA.len)
				var/blood_DNA = pick(B.blood_DNA)
				blood.data["blood_DNA"] = blood_DNA
				blood.data["blood_type"] = B.blood_DNA[blood_DNA]
			blood.data["virus2"] = B.virus2
			if (!tribute && previous_result != BLOODCOST_TARGET_SPLATTER)
				user.visible_message("<span class='warning'>The blood on the floor below \the [user] starts moving!</span>",
									"<span class='rose'>You redirect the flow of blood inside the splatters on the floor toward the pool of your summoning.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_GRAB)
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_GRAB]
			blood = get_blood(H.vessel)
			if (!tribute && previous_result != BLOODCOST_TARGET_GRAB)
				user.visible_message("<span class='warning'>\The [user] stabs their nails inside \the [data[BLOODCOST_TARGET_GRAB]], drawing blood from them!</span>",
									"<span class='rose'>You stab your nails inside \the [data[BLOODCOST_TARGET_GRAB]] to draw some blood from them.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_BLEEDER)
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_BLEEDER]
			blood = get_blood(H.vessel)
			if (!tribute && previous_result != BLOODCOST_TARGET_BLEEDER)
				user.visible_message("<span class='warning'>\The [user] dips their fingers inside \the [data[BLOODCOST_TARGET_BLEEDER]]'s wounds!</span>",
									"<span class='rose'>You dip your fingers inside \the [data[BLOODCOST_TARGET_BLEEDER]]'s wounds to draw some blood from them.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_HELD)
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_HELD]
			blood = locate() in G.reagents.reagent_list
			if (!tribute && previous_result != BLOODCOST_TARGET_HELD)
				user.visible_message("<span class='warning'>\The [user] tips \the [data[BLOODCOST_TARGET_HELD]], pouring blood!</span>",
									"<span class='rose'>You tip \the [data[BLOODCOST_TARGET_HELD]] to pour the blood contained inside.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_BLOODPACK)
			var/obj/item/weapon/reagent_containers/blood/B = data[BLOODCOST_TARGET_BLOODPACK]
			blood = locate() in B.reagents.reagent_list
			if (!tribute && previous_result != BLOODCOST_TARGET_BLOODPACK)
				user.visible_message("<span class='warning'>\The [user] squeezes \the [data[BLOODCOST_TARGET_BLOODPACK]], pouring blood!</span>",
									"<span class='rose'>You squeeze \the [data[BLOODCOST_TARGET_BLOODPACK]] to pour the blood contained inside.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_CONTAINER)
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_CONTAINER]
			blood = locate() in G.reagents.reagent_list
			if (!tribute && previous_result != BLOODCOST_TARGET_CONTAINER)
				user.visible_message("<span class='warning'>\The [user] dips their fingers inside \the [data[BLOODCOST_TARGET_CONTAINER]], covering them in blood!</span>",
									"<span class='rose'>You dip your fingers inside \the [data[BLOODCOST_TARGET_CONTAINER]], covering them in blood.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_USER)
			if (!tribute)
				if (data[BLOODCOST_HOLES_BLOODPACK])
					to_chat(user, "<span class='warning'>You must puncture \the [data[BLOODCOST_TARGET_BLOODPACK]] before you can squeeze blood from it!</span>")
				else if (data[BLOODCOST_LID_HELD])
					to_chat(user, "<span class='warning'>Remove \the [data[BLOODCOST_TARGET_HELD]]'s lid first!</span>")
				else if (data[BLOODCOST_LID_CONTAINER])
					to_chat(user, "<span class='warning'>Remove \the [data[BLOODCOST_TARGET_CONTAINER]]'s lid first!</span>")
			var/mob/living/carbon/human/H = user
			blood = get_blood(H.vessel)
			if (previous_result != BLOODCOST_TARGET_USER)
				if(!tribute && istype(H))
					var/obj/item/weapon/W = H.get_active_hand()
					if (W && W.sharpness_flags & SHARP_BLADE)
						to_chat(user, "<span class='rose'>You slice open your finger with \the [W] to let a bit of blood flow.</span>")
					else
						var/obj/item/weapon/W2 = H.get_inactive_hand()
						if (W2 && W2.sharpness_flags & SHARP_BLADE)
							to_chat(user, "<span class='rose'>You slice open your finger with \the [W] to let a bit of blood flow.</span>")
						else
							to_chat(user, "<span class='rose'>You bite your finger and let the blood pearl up.</span>")
		if (BLOODCOST_FAILURE)
			if (!tribute)
				if (data[BLOODCOST_HOLES_BLOODPACK])
					to_chat(user, "<span class='danger'>You must puncture \the [data[BLOODCOST_TARGET_BLOODPACK]] before you can squeeze blood from it!</span>")
				else if (data[BLOODCOST_LID_HELD])
					to_chat(user, "<span class='danger'>Remove \the [data[BLOODCOST_TARGET_HELD]]'s lid first!</span>")
				else if (data[BLOODCOST_LID_CONTAINER])
					to_chat(user, "<span class='danger'>Remove \the [data[BLOODCOST_TARGET_HELD]]'s lid first!</span>")
				else
					to_chat(user, "<span class='danger'>There is no blood available. Not even in your own body!</span>")

	//Blood is only consumed if there is enough of it
	if (!data[BLOODCOST_FAILURE])
		if (data[BLOODCOST_TARGET_HANDS])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_HANDS]
			var/mob/living/carbon/human/H = user
			H.bloody_hands = max(0, H.bloody_hands - data[BLOODCOST_AMOUNT_HANDS])
			if (!H.bloody_hands)
				H.clean_blood()
				H.update_inv_gloves()
		if (data[BLOODCOST_TARGET_SPLATTER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_SPLATTER]
			var/obj/effect/decal/cleanable/blood/B = data[BLOODCOST_TARGET_SPLATTER]
			B.amount = max(0 , B.amount - data[BLOODCOST_AMOUNT_SPLATTER])
		if (data[BLOODCOST_TARGET_GRAB])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_GRAB]
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_GRAB]
			H.vessel.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_GRAB])
			H.take_overall_damage(data[BLOODCOST_AMOUNT_GRAB] ? 0.1 : 0)
		if (data[BLOODCOST_TARGET_BLEEDER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_BLEEDER]
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_BLEEDER]
			H.vessel.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_BLEEDER])
			H.take_overall_damage(data[BLOODCOST_AMOUNT_BLEEDER] ? 0.1 : 0)
		if (data[BLOODCOST_TARGET_HELD])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_HELD]
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_HELD]
			G.reagents.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_HELD])
		if (data[BLOODCOST_TARGET_BLOODPACK])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_BLOODPACK]
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_BLOODPACK]
			G.reagents.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_BLOODPACK])
		if (data[BLOODCOST_TARGET_CONTAINER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_CONTAINER]
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_CONTAINER]
			G.reagents.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_CONTAINER])
		if (data[BLOODCOST_TARGET_USER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_USER]
			var/mob/living/carbon/human/H = user
			var/blood_before = H.vessel.get_reagent_amount(BLOOD)
			H.vessel.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_USER])
			var/blood_after = H.vessel.get_reagent_amount(BLOOD)
			if (blood_before > BLOOD_VOLUME_SAFE && blood_after < BLOOD_VOLUME_SAFE)
				to_chat(user, "<span class='sinister'>You start looking pale.</span>")
			else if (blood_before > BLOOD_VOLUME_WARN && blood_after < BLOOD_VOLUME_WARN)
				to_chat(user, "<span class='sinister'>You feel weak from the lack of blood.</span>")
			else if (blood_before > BLOOD_VOLUME_OKAY && blood_after < BLOOD_VOLUME_OKAY)
				to_chat(user, "<span class='sinister'>You are about to pass out from the lack of blood.</span>")
			else if (blood_before > BLOOD_VOLUME_BAD && blood_after < BLOOD_VOLUME_BAD)
				to_chat(user, "<span class='sinister'>You have trouble focusing, things will go bad if you keep using your blood.</span>")
			else if (blood_before > BLOOD_VOLUME_SURVIVE && blood_after < BLOOD_VOLUME_SURVIVE)
				to_chat(user, "<span class='sinister'>It will be all over soon.</span>")
			H.take_overall_damage(data[BLOODCOST_AMOUNT_USER] ? 0.1 : 0)

	if (communion && data[BLOODCOST_TOTAL] + total_accumulated >= amount_needed)
		data[BLOODCOST_TOTAL] = max(data[BLOODCOST_TOTAL], total_needed)
	data["blood"] = blood
	return data
	
/proc/get_available_blood_silicon(var/mob/user, var/amount_needed = 0)
	var/data = list(
		BLOODCOST_TARGET_BLEEDER = null,
		BLOODCOST_AMOUNT_BLEEDER = 0,
		BLOODCOST_TARGET_GRAB = null,
		BLOODCOST_AMOUNT_GRAB = 0,
		BLOODCOST_TARGET_HANDS = null,
		BLOODCOST_AMOUNT_HANDS = 0,
		BLOODCOST_TARGET_HELD = null,
		BLOODCOST_AMOUNT_HELD = 0,
		BLOODCOST_LID_HELD = 0,
		BLOODCOST_TARGET_SPLATTER = null,
		BLOODCOST_AMOUNT_SPLATTER = 0,
		BLOODCOST_TARGET_BLOODPACK = null,
		BLOODCOST_AMOUNT_BLOODPACK = 0,
		BLOODCOST_HOLES_BLOODPACK = 0,
		BLOODCOST_TARGET_CONTAINER = null,
		BLOODCOST_AMOUNT_CONTAINER = 0,
		BLOODCOST_LID_CONTAINER = 0,
		BLOODCOST_TARGET_USER = null,
		BLOODCOST_AMOUNT_USER = 0,
		BLOODCOST_RESULT = "",
		BLOODCOST_TOTAL = 0,
		BLOODCOST_USER = null,
		)
	var/turf/T = get_turf(user)
	var/amount_gathered = 0

	data[BLOODCOST_RESULT] = user

	if (amount_needed == 0)//the cost was probably 1u, and already paid for by blood communion from another cultist
		data[BLOODCOST_RESULT] = BLOODCOST_TRIBUTE
		return data

	//Is there blood on our hands?
	var/mob/living/carbon/human/H_user = user
	if (istype (H_user) && H_user.bloody_hands)
		data[BLOODCOST_TARGET_HANDS] = H_user
		var/blood_gathered = min(amount_needed,H_user.bloody_hands)
		data[BLOODCOST_AMOUNT_HANDS] = blood_gathered
		amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_HANDS
		return data

	//Is there a fresh blood splatter on the turf?
	for (var/obj/effect/decal/cleanable/blood/B in T)
		var/blood_volume = B.amount
		if (blood_volume && B.counts_as_blood)
			data[BLOODCOST_TARGET_SPLATTER] = B
			var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
			data[BLOODCOST_AMOUNT_SPLATTER] = blood_gathered
			amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_SPLATTER
		return data

	//Is the cultist currently grabbing a bleeding mob/corpse that still has blood in it?
	var/obj/item/weapon/grab/Grab = locate() in user
	if (Grab)
		if(ishuman(Grab.affecting))
			var/mob/living/carbon/human/H = Grab.affecting
			if(!(H.species.flags & NO_BLOOD))
				for(var/datum/organ/external/org in H.organs)
					if(org.status & ORGAN_BLEEDING)
						var/blood_volume = round(H.vessel.get_reagent_amount(BLOOD))
						var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
						data[BLOODCOST_TARGET_GRAB] = H
						data[BLOODCOST_AMOUNT_GRAB] = blood_gathered
						amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_GRAB
		return data

	//Is there a bleeding mob/corpse on the turf that still has blood in it?
	for (var/mob/living/carbon/human/H in T)
		if(H.species.flags & NO_BLOOD)
			continue
		if(user != H)
			for(var/datum/organ/external/org in H.organs)
				if(org.status & ORGAN_BLEEDING)
					var/blood_volume = round(H.vessel.get_reagent_amount(BLOOD))
					var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
					data[BLOODCOST_TARGET_BLEEDER] = H
					data[BLOODCOST_AMOUNT_BLEEDER] = blood_gathered
					amount_gathered += blood_gathered
					break
		if (data[BLOODCOST_TARGET_BLEEDER])
			break

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_BLEEDER
		return data

	for(var/obj/item/weapon/reagent_containers/G_held in H_user.held_items) //Accounts for if the person has multiple grasping organs
		if (!istype(G_held) || !round(G_held.reagents.get_reagent_amount(BLOOD)))
			continue
		if(istype(G_held, /obj/item/weapon/reagent_containers/blood)) //Bloodbags have their own functionality
			var/obj/item/weapon/reagent_containers/blood/blood_pack = G_held
			var/blood_volume = round(blood_pack.reagents.get_reagent_amount(BLOOD))
			if (blood_volume)
				data[BLOODCOST_TARGET_BLOODPACK] = blood_pack
				if (blood_pack.holes)
					var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
					data[BLOODCOST_AMOUNT_BLOODPACK] = blood_gathered
					amount_gathered += blood_gathered
				else
					data[BLOODCOST_HOLES_BLOODPACK] = 1
			if (amount_gathered >= amount_needed)
				data[BLOODCOST_RESULT] = BLOODCOST_TARGET_BLOODPACK
				return data

		else
			var/blood_volume = round(G_held.reagents.get_reagent_amount(BLOOD))
			if (blood_volume)
				data[BLOODCOST_TARGET_HELD] = G_held
				if (G_held.is_open_container())
					var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
					data[BLOODCOST_AMOUNT_HELD] = blood_gathered
					amount_gathered += blood_gathered
				else
					data[BLOODCOST_LID_HELD] = 1

			if (amount_gathered >= amount_needed)
				data[BLOODCOST_RESULT] = BLOODCOST_TARGET_HELD
				return data
				
	var/mob/living/silicon/robot/robot_user = user
	if(istype(robot_user)) 
		var/module_items = list(robot_user.module_state_1,robot_user.module_state_2,robot_user.module_state_3) //This function allows robot modules to be used as blood sources. Somewhat important, considering silicons have no blood.
		for(var/obj/item/weapon/reagent_containers/G_held in module_items)
			if (!istype(G_held) || !round(G_held.reagents.get_reagent_amount(BLOOD)))
				continue
			if(istype(G_held, /obj/item/weapon/reagent_containers/blood)) //Bloodbags have their own functionality
				var/obj/item/weapon/reagent_containers/blood/blood_pack = G_held
				var/blood_volume = round(blood_pack.reagents.get_reagent_amount(BLOOD))
				if (blood_volume)
					data[BLOODCOST_TARGET_BLOODPACK] = blood_pack
					if (blood_pack.holes)
						var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
						data[BLOODCOST_AMOUNT_BLOODPACK] = blood_gathered
						amount_gathered += blood_gathered
					else
						data[BLOODCOST_HOLES_BLOODPACK] = 1
				if (amount_gathered >= amount_needed)
					data[BLOODCOST_RESULT] = BLOODCOST_TARGET_BLOODPACK
					return data

			else
				var/blood_volume = round(G_held.reagents.get_reagent_amount(BLOOD))
				if (blood_volume)
					data[BLOODCOST_TARGET_HELD] = G_held
					if (G_held.is_open_container())
						var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
						data[BLOODCOST_AMOUNT_HELD] = blood_gathered
						amount_gathered += blood_gathered
					else
						data[BLOODCOST_LID_HELD] = 1

				if (amount_gathered >= amount_needed)
					data[BLOODCOST_RESULT] = BLOODCOST_TARGET_HELD
					return data

	//Is there a reagent container on the turf that has blood in it?
	for (var/obj/item/weapon/reagent_containers/G in T)
		var/blood_volume = round(G.reagents.get_reagent_amount(BLOOD))
		if (blood_volume)
			data[BLOODCOST_TARGET_CONTAINER] = G
			if (G.is_open_container())
				var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
				data[BLOODCOST_AMOUNT_CONTAINER] = blood_gathered
				amount_gathered += blood_gathered
				break
			else
				data[BLOODCOST_LID_CONTAINER] = 1

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_CONTAINER
		return data

	//Does the user have blood? (the user can pay in blood without having to bleed first)
	if(istype(H_user) && !(H_user.species.flags & NO_BLOOD))
		var/blood_volume = round(H_user.vessel.get_reagent_amount(BLOOD))
		var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
		data[BLOODCOST_TARGET_USER] = H_user
		data[BLOODCOST_AMOUNT_USER] = blood_gathered
		amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_USER
		return data

	data[BLOODCOST_RESULT] = BLOODCOST_FAILURE
	return data