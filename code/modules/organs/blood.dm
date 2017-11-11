/****************************************************
				BLOOD SYSTEM
****************************************************/
#define BLOODLOSS_SPEED_MULTIPLIER 0.75

//Blood levels
var/const/BLOOD_VOLUME_MAX = 560
var/const/BLOOD_VOLUME_SAFE = 501
var/const/BLOOD_VOLUME_WARN = 392
var/const/BLOOD_VOLUME_OKAY = 336
var/const/BLOOD_VOLUME_BAD = 224
var/const/BLOOD_VOLUME_SURVIVE = 122

/mob/living/carbon/human/var/datum/reagents/vessel	//Container for blood and BLOOD ONLY. Do not transfer other chems here.
/mob/living/carbon/human/var/var/pale = 0			//Should affect how mob sprite is drawn, but currently doesn't.

//Initializes blood vessels
/mob/living/carbon/human/proc/make_blood()
	if(vessel)
		return

	vessel = new/datum/reagents(600)
	vessel.my_atom = src

	if(species && species.anatomy_flags & NO_BLOOD) //We want the var for safety but we can do without the actual blood.
		return

	vessel.add_reagent(BLOOD,560)
	spawn(1)
		fixblood()

//Resets blood data
/mob/living/carbon/human/proc/fixblood()
	for(var/datum/reagent/blood/B in vessel.reagent_list)
		if(B.id == BLOOD)
			B.data = list(	"donor"=src,"viruses"=null,"blood_DNA"=dna.unique_enzymes,"blood_colour"= species.blood_color,"blood_type"=dna.b_type,	\
							"resistances"=null,"trace_chem"=null, "virus2" = null, "antibodies" = null)
			B.color = B.data["blood_colour"]

// Takes care blood loss and regeneration
/mob/living/carbon/human/proc/handle_blood()


	if(species && species.anatomy_flags & NO_BLOOD)
		return

	if(stat != DEAD && bodytemperature >= 170)	//Dead or cryosleep people do not pump the blood.

		var/blood_volume = round(vessel.get_reagent_amount(BLOOD))

		//Blood regeneration if there is some space
		if(blood_volume < BLOOD_VOLUME_MAX && blood_volume)
			var/datum/reagent/blood/B = locate() in vessel.reagent_list //Grab some blood
			if(B) // Make sure there's some blood at all
				if(B.data["donor"] != src) //If it's not theirs, then we look for theirs
					for(var/datum/reagent/blood/D in vessel.reagent_list)
						if(D.data["donor"] == src)
							B = D
							break

				B.volume += 0.1 // regenerate blood VERY slowly
				if (reagents.has_reagent(NUTRIMENT))	//Getting food speeds it up
					B.volume += 0.6
					reagents.remove_reagent(NUTRIMENT, 0.5)
				if (reagents.has_reagent(IRON))	//Hematogen candy anyone?
					B.volume += 1.2
					reagents.remove_reagent(IRON, 0.5)

		// Damaged heart virtually reduces the blood volume, as the blood isn't
		// being pumped properly anymore.
		if(species && species.has_organ["heart"])
			var/datum/organ/internal/heart/heart = internal_organs_by_name["heart"]

			if(!heart)
				blood_volume = 0
			else if(heart.damage > 1 && heart.damage < heart.min_bruised_damage)
				blood_volume *= 0.8
			else if(heart.damage >= heart.min_bruised_damage && heart.damage < heart.min_broken_damage)
				blood_volume *= 0.6
			else if(heart.damage >= heart.min_broken_damage)
				blood_volume *= 0.2 //no heart, no blood

		vessel.update_total()

		//Effects of bloodloss
		switch(blood_volume)
			if(BLOOD_VOLUME_SAFE to 10000)
				if(pale)
					pale = 0
					//update_body()
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(!pale)
					pale = 1
					//update_body()
					var/word = pick("dizzy","woosey","faint")
					to_chat(src, "<span class='danger'>You feel [word].</span>")
				if(blood_volume > BLOOD_VOLUME_WARN)
					if(prob(1))
						var/word = pick("dizzy","woosey","faint")
						to_chat(src, "<span class='danger'>You feel [word].</span>")
				else
					if(prob(3))
						var/word = pick("dizzy","woosey","faint")
						to_chat(src, "<span class='danger'>You feel very [word].</span>")
				if(oxyloss < 20)
					oxyloss += 2
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				if(!pale)
					pale = 1
					//update_body()
				eye_blurry = max(eye_blurry,2)
				if(oxyloss < 40)
					oxyloss += 3
				oxyloss += 3
				if(prob(15))
					Paralyse(1)
					var/word = pick("dizzy","woosey","faint")
					to_chat(src, "<span class='danger'>You feel extremely [word].</span>")
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				if(!pale)
					pale = 1
					//update_body()
				eye_blurry = max(eye_blurry,4)
				if(oxyloss < 60)
					oxyloss += 5
				oxyloss += 5
				toxloss += 1
				if(prob(15))
					Paralyse(rand(1,3))
					var/word = pick("dizzy","woosey","faint")
					to_chat(src, "<span class='danger'>You feel deathly [word].</span>")
			if(0 to BLOOD_VOLUME_SURVIVE)
				// Kill then pretty fast, but don't overdo it
				// I SAID DON'T OVERDO IT
				if(!pale) //Somehow
					pale = 1
					//update_body()
				oxyloss += 8
				toxloss += 2
				//cloneloss += 1
				Paralyse(5) //Keep them on the ground, that'll teach them

		// Without enough blood you slowly go hungry.
		// This is supposed to synergize with nutrients being used up to boost blood regeneration
		// No need to drain it manually, just increase the nutrient drain on regen
		/*
		if(blood_volume < BLOOD_VOLUME_SAFE)
			if(nutrition >= 300)
				burn_calories(5)
			else if(nutrition >= 200)
				burn_calories(2)
		*/

		//Bleeding out
		var/blood_max = 0
		for(var/datum/organ/external/temp in organs)
			if(!(temp.status & ORGAN_BLEEDING) || temp.status & (ORGAN_ROBOT|ORGAN_PEG))
				continue
			for(var/datum/wound/W in temp.wounds) if(W.bleeding())
				blood_max += W.damage / 4
			if(temp.status & ORGAN_DESTROYED && !(temp.status & ORGAN_GAUZED) && !temp.amputated)
				blood_max += 20 //Yer missing a fucking limb.
			if (temp.open)
				blood_max += 2 //Yer stomach is cut open
			blood_max = blood_max * BLOODLOSS_SPEED_MULTIPLIER
			if(lying)
				blood_max = blood_max * 0.7
			/*if(reagents.has_reagent(INAPROVALINE))
				blood_max = blood_max * 0.7*/
		drip(blood_max)

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/human/proc/drip(var/amt as num)


	if(species && species.anatomy_flags & NO_BLOOD) //TODO: Make drips come from the reagents instead.
		return 0

	if(!amt)
		return 0

	vessel.remove_reagent(BLOOD,amt)
	blood_splatter(src,src)
	stat_collection.blood_spilled += amt
	return 1

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to the container, preserving all data in it.
/mob/living/carbon/proc/take_blood(obj/item/weapon/reagent_containers/container, var/amount)
	var/datum/reagent/B = (container ? get_blood(container.reagents) : null)
	if(!B)
		B = new /datum/reagent/blood
	B.holder = (container? container.reagents : null)
	B.volume += amount

	//set reagent data
	B.data["donor"] = src
	if (!B.data["virus2"])
		B.data["virus2"] = list()
	B.data["virus2"] |= virus_copylist(src.virus2)
	B.data["antibodies"] = src.antibodies
	B.data["blood_DNA"] = copytext(src.dna.unique_enzymes,1,0)
	if(src.resistances && src.resistances.len)
		if(B.data["resistances"])
			B.data["resistances"] |= src.resistances.Copy()
		else
			B.data["resistances"] = src.resistances.Copy()
	B.data["blood_type"] = copytext(src.dna.b_type,1,0)

	// Putting this here due to return shenanigans.
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		B.data["blood_colour"] = H.species.blood_color
		B.color = B.data["blood_colour"]

	var/list/temp_chem = list()
	for(var/datum/reagent/R in src.reagents.reagent_list)
		temp_chem += R.id
		temp_chem[R.id] = R.volume
	B.data["trace_chem"] = list2params(temp_chem)

	if(container)
		container.reagents.reagent_list |= B
		container.reagents.update_total()
		container.on_reagent_change()
		container.reagents.handle_reactions()
		container.update_icon()
	return B

//For humans, blood does not appear from blue, it comes from vessels.
/mob/living/carbon/human/take_blood(obj/item/weapon/reagent_containers/container, var/amount)

	if(species && species.anatomy_flags & NO_BLOOD)
		return null

	if(vessel.get_reagent_amount(BLOOD) < amount)
		return null

	. = ..()
	vessel.remove_reagent(BLOOD,amount) // Removes blood if human

/mob/living/carbon/monkey/take_blood(obj/item/weapon/reagent_containers/container, var/amount)
	if(!isDead())
		adjustOxyLoss(amount)
	. = ..()

//Transfers blood from container ot vessels
/mob/living/carbon/proc/inject_blood(obj/item/weapon/reagent_containers/container, var/amount)
	var/datum/reagent/blood/injected = get_blood(container.reagents)
	if (!injected)
		return
	src.virus2 |= virus_copylist(injected.data["virus2"])
	if (injected.data["antibodies"] && prob(5))
		antibodies |= injected.data["antibodies"]
	var/list/chems = list()
	chems = params2list(injected.data["trace_chem"])
	for(var/C in chems)
		src.reagents.add_reagent(C, (text2num(chems[C]) / 560) * amount)//adds trace chemicals to owner's blood
	reagents.update_total()

	container.reagents.remove_reagent(BLOOD, amount)

//Transfers blood from container ot vessels, respecting blood types compatability.
/mob/living/carbon/human/inject_blood(obj/item/weapon/reagent_containers/container, var/amount)

	var/datum/reagent/blood/injected = get_blood(container.reagents)

	if(species && species.anatomy_flags & NO_BLOOD)
		reagents.add_reagent(BLOOD, amount, injected.data)
		reagents.update_total()
		return

	var/datum/reagent/blood/our = get_blood(vessel)

	if (!injected || !our)
		return
	if(blood_incompatible(injected.data["blood_type"],our.data["blood_type"]) )
		reagents.add_reagent(TOXIN,amount * 0.5)
		reagents.update_total()
	else
		vessel.add_reagent(BLOOD, amount, injected.data)
		vessel.update_total()
	..()

//Gets human's own blood.
/mob/living/carbon/proc/get_blood(datum/reagents/container)
	var/datum/reagent/blood/res = locate() in container.reagent_list //Grab some blood
	if(res) // Make sure there's some blood at all
		if(res.data["donor"] != src) //If it's not theirs, then we look for theirs
			for(var/datum/reagent/blood/D in container.reagent_list)
				if(D.data["donor"] == src)
					return D
	return res

proc/blood_incompatible(donor,receiver)
	if(!donor || !receiver)
		return 0
	var
		donor_antigen = copytext(donor,1,lentext(donor))
		receiver_antigen = copytext(receiver,1,lentext(receiver))
		donor_rh = (findtext(donor,"+")>0)
		receiver_rh = (findtext(receiver,"+")>0)
	if(donor_rh && !receiver_rh)
		return 1
	switch(receiver_antigen)
		if("A")
			if(donor_antigen != "A" && donor_antigen != "O")
				return 1
		if("B")
			if(donor_antigen != "B" && donor_antigen != "O")
				return 1
		if("O")
			if(donor_antigen != "O")
				return 1
		//AB is a universal receiver.
	return 0

proc/blood_splatter(var/target,var/datum/reagent/blood/source,var/large)
	var/obj/effect/decal/cleanable/blood/B
	var/decal_type = /obj/effect/decal/cleanable/blood/splatter
	var/turf/T = get_turf(target)
	var/list/drip_icons = list("1","2","3","4","5")

	if(istype(source,/mob/living/carbon/human))
		var/mob/living/carbon/human/M = source
		var/datum/reagent/blood/is_there_blood = M.get_blood(M.vessel)
		if(!is_there_blood)
			return //If there is no blood in the mob's blood vessel, there's no reason to make any sort of splatter.

		source = is_there_blood

	if(istype(source,/mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/donor = source
		if(donor.dna)
			source = new()
			source.data["blood_DNA"] = donor.dna.unique_enzymes
			source.data["blood_type"] = donor.dna.b_type

	// Are we dripping or splattering?
	if(!large)

		// Only a certain number of drips can be on a given turf.
		var/list/drips = list()

		for(var/obj/effect/decal/cleanable/blood/drip/drop in T)
			drips += drop
			drip_icons -= drop.icon_state

		// If we have too many drips, remove them and spawn a proper blood splatter.
		if(drips.len >= 5)
			//TODO: copy all virus data from drips to new splatter?
			for(var/obj/effect/decal/cleanable/blood/drip/drop in drips)
				returnToPool(drop)
		else
			decal_type = /obj/effect/decal/cleanable/blood/drip

	// Find a blood decal or create a new one.
	B = locate(decal_type) in T
	if(!B || (decal_type == /obj/effect/decal/cleanable/blood/drip))
		B = getFromPool(decal_type,T)
		B.New(T)
		if(decal_type == /obj/effect/decal/cleanable/blood/drip)
			B.icon_state = pick(drip_icons)

	// If there's no data to copy, call it quits here.
	if(!source)
		return B

	// Update appearance.
	if(source.data["blood_colour"])
		B.basecolor = source.data["blood_colour"]
		B.update_icon()

	// Update blood information.
	if(source.data["blood_DNA"])
		B.blood_DNA = list()
		if(source.data["blood_type"])
			B.blood_DNA[source.data["blood_DNA"]] = source.data["blood_type"]
		else
			B.blood_DNA[source.data["blood_DNA"]] = "O+"

	// Update virus information. //Looks like this is out of date.
	//for(var/datum/disease/D in source.data["viruses"])
	//	var/datum/disease/new_virus = D.Copy(1)
	//	source.viruses += new_virus
	//	new_virus.holder = B
	if(source.data["virus2"])
		B.virus2 = virus_copylist(source.data["virus2"])

	return B
