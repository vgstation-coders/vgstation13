/datum/species/plasmaman // /vg/
	name = "Plasmaman"
	icobase = 'icons/mob/human_races/r_plasmaman_sb.dmi'
	deform = 'icons/mob/human_races/r_plasmaman_pb.dmi'  // TODO: Need deform.
	language = "Clatter"
	attack_verb = "punch"

	//flags = IS_WHITELISTED /*| HAS_LIPS | HAS_TAIL | NO_EAT | NO_BREATHE | NON_GENDERED*/ | NO_BLOOD
	// These things are just really, really griefy. IS_WHITELISTED removed for now - N3X
	flags = NO_BLOOD|IS_WHITELISTED

	//default_mutations=list(SKELETON) // This screws things up

	breath_type = "plasma"

	heat_level_1 = 350  // Heat damage level 1 above this point.
	heat_level_2 = 400  // Heat damage level 2 above this point.
	heat_level_3 = 500  // Heat damage level 3 above this point.
	burn_mod = 0.5

/datum/species/plasmaman/handle_speech(var/datum/speech/speech, mob/living/carbon/human/H)
	speech.message = replacetext(speech.message, "s", stutter("ss"))
	return ..(speech,H)

/datum/species/plasmaman/equip(var/mob/living/carbon/human/H)
	H.fire_sprite = "Plasmaman"

	// Unequip existing suits and hats.
	H.u_equip(H.wear_suit,1)
	H.u_equip(H.head,1)
	if(H.mind.assigned_role!="Clown")
		H.u_equip(H.wear_mask,1)

	H.equip_or_collect(new /obj/item/clothing/mask/breath(H), slot_wear_mask)
	var/suit=/obj/item/clothing/suit/space/plasmaman
	var/helm=/obj/item/clothing/head/helmet/space/plasmaman
	var/tank_slot = slot_s_store
	var/tank_slot_name = "suit storage"

	switch(H.mind.assigned_role)
		if("Scientist","Geneticist","Roboticist")
			suit=/obj/item/clothing/suit/space/plasmaman/science
			helm=/obj/item/clothing/head/helmet/space/plasmaman/science
		if("Research Director")
			suit=/obj/item/clothing/suit/space/plasmaman/science/rd
			helm=/obj/item/clothing/head/helmet/space/plasmaman/science/rd
		if("Station Engineer", "Mechanic")
			suit=/obj/item/clothing/suit/space/plasmaman/engineer/
			helm=/obj/item/clothing/head/helmet/space/plasmaman/engineer/
		if("Chief Engineer")
			suit=/obj/item/clothing/suit/space/plasmaman/engineer/ce
			helm=/obj/item/clothing/head/helmet/space/plasmaman/engineer/ce
		if("Atmospheric Technician")
			suit=/obj/item/clothing/suit/space/plasmaman/atmostech
			helm=/obj/item/clothing/head/helmet/space/plasmaman/atmostech
		if("Warden","Detective","Security Officer")
			suit=/obj/item/clothing/suit/space/plasmaman/security/
			helm=/obj/item/clothing/head/helmet/space/plasmaman/security/
		if("Head of Security")
			suit=/obj/item/clothing/suit/space/plasmaman/security/hos
			helm=/obj/item/clothing/head/helmet/space/plasmaman/security/hos
		if("Captain")
			suit=/obj/item/clothing/suit/space/plasmaman/security/captain
			helm=/obj/item/clothing/head/helmet/space/plasmaman/security/captain
		if("Head of Personnel")
			suit=/obj/item/clothing/suit/space/plasmaman/security/hop
			helm=/obj/item/clothing/head/helmet/space/plasmaman/security/hop
		if("Medical Doctor")
			suit=/obj/item/clothing/suit/space/plasmaman/medical
			helm=/obj/item/clothing/head/helmet/space/plasmaman/medical
		if("Paramedic")
			suit=/obj/item/clothing/suit/space/plasmaman/medical/paramedic
			helm=/obj/item/clothing/head/helmet/space/plasmaman/medical/paramedic
		if("Chemist")
			suit=/obj/item/clothing/suit/space/plasmaman/medical/chemist
			helm=/obj/item/clothing/head/helmet/space/plasmaman/medical/chemist
		if("Chief Medical Officer")
			suit=/obj/item/clothing/suit/space/plasmaman/medical/cmo
			helm=/obj/item/clothing/head/helmet/space/plasmaman/medical/cmo
		if("Bartender", "Chef")
			suit=/obj/item/clothing/suit/space/plasmaman/service
			helm=/obj/item/clothing/head/helmet/space/plasmaman/service
		if("Cargo Technician", "Quartermaster")
			suit=/obj/item/clothing/suit/space/plasmaman/cargo
			helm=/obj/item/clothing/head/helmet/space/plasmaman/cargo
		if("Shaft Miner")
			suit=/obj/item/clothing/suit/space/plasmaman/miner
			helm=/obj/item/clothing/head/helmet/space/plasmaman/miner
		if("Botanist")
			suit=/obj/item/clothing/suit/space/plasmaman/botanist
			helm=/obj/item/clothing/head/helmet/space/plasmaman/botanist
		if("Chaplain")
			suit=/obj/item/clothing/suit/space/plasmaman/chaplain
			helm=/obj/item/clothing/head/helmet/space/plasmaman/chaplain
		if("Janitor")
			suit=/obj/item/clothing/suit/space/plasmaman/janitor
			helm=/obj/item/clothing/head/helmet/space/plasmaman/janitor
		if("Assistant")
			suit=/obj/item/clothing/suit/space/plasmaman/assistant
			helm=/obj/item/clothing/head/helmet/space/plasmaman/assistant
		if("Clown")
			suit=/obj/item/clothing/suit/space/plasmaman/clown
			helm=/obj/item/clothing/head/helmet/space/plasmaman/clown
		if("Mime")
			suit=/obj/item/clothing/suit/space/plasmaman/mime
			helm=/obj/item/clothing/head/helmet/space/plasmaman/mime
	H.equip_or_collect(new suit(H), slot_wear_suit)
	H.equip_or_collect(new helm(H), slot_head)
	H.equip_or_collect(new/obj/item/weapon/tank/plasma/plasmaman(H), tank_slot) // Bigger plasma tank from Raggy.
	H << "<span class='notice'>You are now running on plasma internals from the [H.s_store] in your [tank_slot_name].  You must breathe plasma in order to survive, and are extremely flammable.</span>"
	H.internal = H.get_item_by_slot(tank_slot)
	if (H.internals)
		H.internals.icon_state = "internal1"

// Plasmamen are so fucking different that they need their own proc.
/datum/species/plasmaman/handle_breath(var/datum/gas_mixture/breath, var/mob/living/carbon/human/H)
	var/safe_plasma_min = 16 // Minimum safe partial pressure of PLASMA, in kPa
	//var/safe_oxygen_max = 140 // Maximum safe partial pressure of PLASMA, in kPa (Not used for now)
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/plasma_used = 0
	var/nitrogen_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	// Partial pressure of plasma
	var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure
	// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
	var/CO2_pp = (breath.carbon_dioxide/breath.total_moles())*breath_pressure // Tweaking to fit the hacky bullshit I've done with atmo -- TLE

	if(Toxins_pp < safe_plasma_min)
		if(prob(20))
			spawn(0)
				H.emote("gasp")
		if(Toxins_pp > 0)
			var/ratio = safe_plasma_min/Toxins_pp
			H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
			H.failed_last_breath = 1
			plasma_used = breath.toxins*ratio/6
		else
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			H.failed_last_breath = 1
		H.oxygen_alert = max(H.oxygen_alert, 1)

	else								// We're in safe limits
		H.failed_last_breath = 0
		H.adjustOxyLoss(-5)
		plasma_used = breath.toxins/6
		H.oxygen_alert = 0

	breath.toxins -= plasma_used
	breath.nitrogen -= nitrogen_used
	breath.carbon_dioxide += plasma_used

	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(CO2_pp > safe_co2_max)
		if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
			H.co2overloadtime = world.time
		else if(world.time - H.co2overloadtime > 120)
			H.Paralyse(3)
			H.adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
			if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
				H.adjustOxyLoss(8)
		if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
			spawn(0)
				H.emote("cough")

	else
		H.co2overloadtime = 0

	if(breath.trace_gases.len)	// If there's some other shit in the air lets deal with it here.
		for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
			var/SA_pp = (SA.moles/breath.total_moles())*breath_pressure
			if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
				H.Paralyse(3) // 3 gives them one second to wake up and run away a bit!
				if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
					H.sleeping = min(H.sleeping+2, 10)
			else if(SA_pp > 0.15)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
				if(prob(20))
					spawn(0)
						H.emote(pick("giggle", "laugh"))
			SA.moles = 0

	if( (abs(310.15 - breath.temperature) > 50) && !(M_RESIST_HEAT in H.mutations)) // Hot air hurts :(
		if(H.status_flags & GODMODE)
			return 1	//godmode
		if(breath.temperature < cold_level_1)
			if(prob(20))
				src << "<span class='warning'>You feel your face freezing and an icicle forming in your lungs!</span>"
		else if(breath.temperature > heat_level_1)
			if(prob(20))
				if(H.dna.mutantrace == "slime")
					src << "<span class='warning'>You feel supercharged by the extreme heat!</span>"
				else
					src << "<span class='warning'>You feel your face burning and a searing heat in your lungs!</span>"
		if(H.dna.mutantrace == "slime")
			if(breath.temperature < cold_level_1)
				H.adjustToxLoss(round(cold_level_1 - breath.temperature))
				H.fire_alert = max(H.fire_alert, 1)
		else
			switch(breath.temperature)
				if(-INFINITY to cold_level_3)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Cold")
					H.fire_alert = max(H.fire_alert, 1)

				if(cold_level_3 to cold_level_2)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Cold")
					H.fire_alert = max(H.fire_alert, 1)

				if(cold_level_2 to cold_level_1)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Cold")
					H.fire_alert = max(H.fire_alert, 1)

				if(heat_level_1 to heat_level_2)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Heat")
					H.fire_alert = max(H.fire_alert, 2)

				if(heat_level_2 to heat_level_3)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Heat")
					H.fire_alert = max(H.fire_alert, 2)

				if(heat_level_3 to INFINITY)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Heat")
					H.fire_alert = max(H.fire_alert, 2)
	return 1