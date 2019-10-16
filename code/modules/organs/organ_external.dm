/****************************************************
				EXTERNAL ORGANS
****************************************************/
/datum/organ/external
	name = "external"

	var/datum/species/species
	var/icon_name = null
	var/body_part = null
	var/icon_position = 0

	var/obj/item/organ_item = null //The actual item used to make the organ
	var/list/slots_to_drop

	var/damage_state = "00"
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/max_size = 0
	var/last_dam = -1

	var/display_name
	var/list/wounds = list()
	var/number_wounds = 0 //Cache the number of wounds, which is NOT wounds.len!

	var/tmp/perma_injury = 0
	var/tmp/destspawn = 0 //Has it spawned the broken limb?
	var/tmp/amputated = 0 //Whether this has been cleanly amputated, thus causing no pain
	var/min_broken_damage = 30

	var/datum/organ/external/parent
	var/list/datum/organ/external/children

	//Internal organs of this body part
	var/list/datum/organ/internal/internal_organs

	var/damage_msg = "<span class='warning'>You feel an intense pain</span>"
	var/broken_description

	var/open = 0
	var/stage = 0
	var/cavity = 0
	var/sabotaged = 0 //If a prosthetic limb is emagged, it will detonate when it fails.
	var/encased       //Needs to be opened with a saw to access the organs.

	var/obj/item/hidden = null
	var/list/implants = list()

	//How often wounds should be updated, a higher number means less often
	var/wound_update_accuracy = 1

	var/has_fat = 0 //Has a _fat variant

	var/grasp_id = 0 //Does this organ affect other grasping organs?
	var/can_grasp = 0 //Can this organ actually grasp something?

	var/w_class = W_CLASS_LARGE


/datum/organ/external/New(var/datum/organ/external/P)
	if(P)
		parent = P
		if(!parent.children)
			parent.children = list()
		parent.children.Add(src)
	return ..()

/datum/organ/external/Destroy()
	if(parent?.children)
		parent.children -= src
		parent = null

	if(children)
		for(var/datum/organ/external/O in children)
			qdel(O)
		children = null

	if(internal_organs)
		for(var/datum/organ/internal/O in internal_organs)
			qdel(O)
		internal_organs = null

	if(implants)
		for(var/obj/O in implants)
			qdel(O)
		implants = null

	if(wounds)
		for(var/datum/wound/W in wounds)
			qdel(W)
		wounds = null

	if(owner)
		owner.organs -= src
		if(grasp_id)
			owner.grasp_organs -= src
		for(var/organ_name in owner.organs_by_name) //I hate that this is the only way
			if(owner.organs_by_name[organ_name] == src)
				owner.organs_by_name -= src
				break //Assume there's only one because if not we have much bigger problems than a hard del
		owner = null

	organ_item = null //I honestly cannot tell if anything else should be done with this
	..()

/****************************************************
			   DAMAGE PROCS
****************************************************/

/datum/organ/external/proc/emp_act(severity)
	if(!is_robotic()) //Meatbags do not care about EMP
		return
	var/probability = 30
	var/damage = 15
	if(severity == 2)
		probability = 1
		damage = 3
	if(prob(probability))
		if(is_malfunctioning())
			explode()
		else
			status |= ORGAN_MALFUNCTIONING
			to_chat(owner, "<span class = 'warning'>Your [display_name] malfunctions!</span>")
	take_damage(damage, 0, 1, used_weapon = "EMP")

/datum/organ/external/proc/get_health()
	return (burn_dam + brute_dam)

/datum/organ/external/proc/explode()
	if(is_peg())
		return droplimb(1)

	var/gib_type = /obj/effect/decal/cleanable/blood/gibs/core

	if(is_robotic())
		gib_type = /obj/effect/decal/cleanable/blood/gibs/robot

	var/turf/T = get_turf(owner)
	if(T)
		var/obj/effect/decal/gib

		//Create two gibs
		for(var/i = 1 to 2)
			gib = new gib_type(get_turf(owner))
			gib.name = "mangled [src.display_name]"
			gib.desc = "Completely useless now."

		spawn(3)
			step(gib, pick(alldirs)) //move the last spawned gib in a random direction

		if(is_robotic())
			T.hotspot_expose(1000,1000,surfaces=1)
		else
			playsound(T, 'sound/effects/gib3.ogg', 50, 1)

	var/msg = pick(
	"\The [owner]'s [display_name] is mangled to bits!",\
	"\The [owner]'s [display_name] [is_robotic() ? "is completely wrecked" : "explodes into gory red paste"]!",\
	"\The [owner]'s [display_name] [is_robotic() ? "is ripped into loose shreds" : "collapses into a lump of gore"]!")

	owner.visible_message("<span class='danger'>[msg]</span>")
	droplimb(1, spawn_limb = 0, display_message = FALSE)

/datum/organ/external/proc/dust()
	if(is_peg())
		return droplimb(1)
	var/obj/O = generate_dropped_organ()
	var/obj/I = O.ashtype()
	qdel(O)
	new I(owner.loc)
	droplimb(1, spawn_limb = 0, display_message = FALSE)

/datum/organ/external/proc/take_damage(brute, burn, sharp, edge, used_weapon = null, list/forbidden_limbs = list())
	if((brute <= 0) && (burn <= 0))
		return 0

	if(!is_existing()) //No limb there
		return 0

	if(!is_organic())
		brute *= 0.66 //~2/3 damage for ROBOLIMBS
		burn *= (status & (ORGAN_PEG) ? 2 : 0.66) //~2/3 damage for ROBOLIMBS 2x for peg
	else
		var/datum/species/species = src.species || owner.species
		if(species)
			if(species.brute_mod)
				brute *= species.brute_mod
			if(species.burn_mod)
				burn *= species.burn_mod

	//If limb took enough damage, try to cut or tear it off
	if(body_part != UPPER_TORSO && body_part != LOWER_TORSO) //As hilarious as it is, getting hit on the chest too much shouldn't effectively gib you.
		var/threshold_multiplier = 1
		if(isslimeperson(owner))
			threshold_multiplier = 0
		if(config.limbs_can_break && get_health() >= max_damage * config.organ_health_multiplier * threshold_multiplier)
			if(isslimeperson(owner))
				var/chance_multiplier = 1
				if(istype(src, /datum/organ/external/head))
					chance_multiplier = 0
				if(prob(brute * sharp * chance_multiplier))
					droplimb(1)
					return
			else
				if(sharp || is_peg())
					if(prob((5 * brute) * sharp)) //sharp things have a greater chance to sever based on how sharp they are
						droplimb(1)
						return
				else if(!sharp && brute > 15) //Massive blunt damage can result in limb explosion
					if(prob((brute/7.5)**3)) //15 dmg - 8% chance, 22 dmg - 27%, 30 dmg - 64%, anything higher than ~35 is a guaranteed limbgib
						explode()
						return
				else if(brute > 20 && prob(2 * brute)) //non-sharp hits with force greater than 20 can cause limbs to sever, too (smaller chance)
					droplimb(1)
					return

		else if((config.limbs_can_break && sharp == 100) || ((sharp >= 2) && (config.limbs_can_break && brute_dam + burn_dam >= (max_damage * config.organ_health_multiplier)/sharp))) //items of exceptional sharpness are capable of severing the limb below its damage threshold, the necessary threshold scaling inversely with sharpness
			if(prob((5 * (brute * sharp)) * (sharp - 1))) //the same chance multiplier based on sharpness applies here as well
				droplimb(1)
				return

	//High brute damage or sharp objects may damage internal organs
	if(internal_organs != null)
		if((sharp && brute >= 5) || brute >= 10)
			if(prob(5))
				//Damage an internal organ
				var/datum/organ/internal/I = pick(internal_organs)
				I.take_damage(brute / 2)
				brute -= brute / 2

	if(is_broken() && prob(40) && brute)
		owner.audible_scream() //Getting hit on broken and unsplinted limbs hurts

	if(used_weapon)
		add_autopsy_data("[used_weapon]", brute + burn)

	var/can_cut = (prob(brute * 2) || sharp) && is_organic()
	//If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
	if((brute_dam + burn_dam + brute + burn) < max_damage || !config.limbs_can_break)
		if(brute)
			if(can_cut)
				createwound(CUT, brute)
			else
				createwound(BRUISE, brute)
		if(burn)
			createwound(BURN, burn)
	else
		//If we can't inflict the full amount of damage, spread the damage in other ways
		//How much damage can we actually cause?
		var/can_inflict = max_damage * config.organ_health_multiplier - (brute_dam + burn_dam)
		if(can_inflict)
			if(brute > 0)
				//Inflict all burte damage we can
				if(can_cut)
					createwound(CUT, min(brute,can_inflict))
				else
					createwound(BRUISE, min(brute,can_inflict))
				var/temp = can_inflict
				//How much mroe damage can we inflict
				can_inflict = max(0, can_inflict - brute)
				//How much brute damage is left to inflict
				brute = max(0, brute - temp)

			if(burn > 0 && can_inflict)
				//Inflict all burn damage we can
				createwound(BURN, min(burn,can_inflict))
				//How much burn damage is left to inflict
				burn = max(0, burn - can_inflict)
		//If there are still hurties to dispense
		if(burn || brute)
			if(!is_organic())
				droplimb(1) //Non-organic limbs just drop off with no further complications
			else
				//List organs we can pass it to
				var/list/datum/organ/external/possible_points = list()
				if(parent)
					possible_points += parent
				if(children)
					possible_points += children
				if(forbidden_limbs.len)
					possible_points -= forbidden_limbs
				if(possible_points.len)
					//And pass the pain around
					var/datum/organ/external/target = pick(possible_points)
					target.take_damage(brute, burn, sharp, edge, used_weapon, forbidden_limbs + src)

	//Sync the organ's damage with its wounds
	src.update_damages()
	owner.updatehealth()

	var/result = update_icon()
	return result

/datum/organ/external/proc/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	if(is_robotic() && !robo_repair) //This item can't fix robotic limbs
		return

	if(is_peg()) //We can't fix peg legs at all
		return

	//Heal damage on the individual wounds
	for(var/datum/wound/W in wounds)
		if(brute == 0 && burn == 0)
			break

		//Heal brute damage
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			brute = W.heal_damage(brute)
		else if(W.damage_type == BURN)
			burn = W.heal_damage(burn)

	if(internal)
		status &= ~ORGAN_BROKEN
		perma_injury = 0

	//Sync the organ's damage with its wounds
	src.update_damages()
	owner.updatehealth()

	var/result = update_icon()
	return result

//This function completely restores a damaged organ to perfect condition
/datum/organ/external/proc/rejuvenate()
	damage_state = "00"
	//Robotic organs stay robotic.  Fix because right click rejuvinate makes IPC's organs organic.
	//N3X: Use bitmask to exclude shit we don't want.
	status = status & (ORGAN_ROBOT|ORGAN_PEG)
	perma_injury = 0
	brute_dam = 0
	burn_dam = 0
	cancer_stage = 0
	germ_level = 0

	//Handle internal organs
	for(var/datum/organ/internal/current_organ in internal_organs)
		current_organ.rejuvenate()

	//Remove embedded objects and drop them on the floor
	for(var/obj/implanted_object in implants)
		if(!istype(implanted_object,/obj/item/weapon/implant))	//We don't want to remove REAL implants. Just shrapnel etc.
			implanted_object.forceMove(owner.loc)
			implants -= implanted_object

	owner.updatehealth()

/datum/organ/external/proc/createwound(var/type = CUT, var/damage)
	if(!damage || damage < 0) //We weren't passed a damage value, or it's negative for some reason
		return

	var/datum/species/species = src.species || owner.species

	//First check whether we can widen an existing wound
	if(wounds.len > 0 && prob(50 + owner.number_wounds * 10))
		if((type == CUT || type == BRUISE) && damage >= 5)
			var/datum/wound/W = pick(wounds)
			if(W.amount == 1 && W.started_healing())
				W.open_wound(damage)
				if(prob(25))
					owner.visible_message("<span class='warning'>The wound on [owner.name]'s [display_name] widens with a nasty ripping sound.</span>", \
					"<span class='warning'>The wound on your [display_name] widens with a nasty ripping sound.</span>", \
					"You hear a nasty ripping noise, as if flesh is being torn apart.")
				return

	//Creating wound
	var/datum/wound/W
	var/size = min(max(1, damage/10), 6)
	//Possible types of wound
	var/list/size_names = list()
	switch(type)
		if(CUT)
			size_names = typesof(/datum/wound/cut/) - /datum/wound/cut/
		if(BRUISE)
			size_names = typesof(/datum/wound/bruise/) - /datum/wound/bruise/
		if(BURN)
			size_names = typesof(/datum/wound/burn/) - /datum/wound/burn/

	size = min(size,size_names.len)
	var/wound_type = size_names[size]
	W = new wound_type(damage)

	//Possibly trigger an internal wound, too.
	var/local_damage = brute_dam + burn_dam + damage
	if(damage > 10 && type != BURN && local_damage > 20 && prob(damage) && is_organic() && !(species && species.anatomy_flags & NO_BLOOD))
		var/internal_bleeding = 0
		for(var/datum/wound/Wound in wounds)
			if(Wound.internal)
				internal_bleeding = 1
				break
		if(!internal_bleeding)
			var/datum/wound/internal_bleeding/I = new (15)
			wounds += I
			owner.custom_pain("You feel something rip in your [display_name]!", 1)

	//Check whether we can add the wound to an existing wound
	for(var/datum/wound/other in wounds)
		if(other.desc == W.desc)
			//Okay, add it!
			other.damage += W.damage
			other.amount += 1
			W = null //To signify that the wound was added
			break
	if(W)
		wounds += W

/****************************************************
			   PROCESSING & UPDATING
****************************************************/

//Determines if we even need to process this organ.

/datum/organ/external/proc/need_process()
	if(status && !is_organic()) //If it's non-organic, that's fine it will have a status.
		return 1
	if(brute_dam || burn_dam)
		return 1
	if(last_dam != brute_dam + burn_dam) //Process when we are fully healed up.
		last_dam = brute_dam + burn_dam
		return 1
	last_dam = brute_dam + burn_dam
	return 0

/datum/organ/external/process()

	//Process wounds, doing healing etc. Only do this every few ticks to save processing power
	if(owner.life_tick % wound_update_accuracy == 0)
		update_wounds()

	//Chem traces slowly vanish
	if(owner.life_tick % 10 == 0)
		for(var/chemID in trace_chemicals)
			trace_chemicals[chemID] = trace_chemicals[chemID] - 1
			if(trace_chemicals[chemID] <= 0)
				trace_chemicals.Remove(chemID)

	//Dismemberment
	if(status & ORGAN_DESTROYED)
		if(!destspawn && config.limbs_can_break)
			droplimb()
		return

	if(parent)
		if(parent.status & ORGAN_DESTROYED)
			status |= ORGAN_DESTROYED
			owner.update_body(1)
			return

	//Bone fracurtes
	var/datum/species/species = src.species || owner.species
	if(config.bones_can_break && brute_dam > min_broken_damage * config.organ_health_multiplier && is_organic() && !(species.anatomy_flags & NO_BONES))
		src.fracture()
	if(!is_broken())
		perma_injury = 0

	update_germs()

	if(grasp_id)
		process_grasp(owner.held_items[grasp_id], owner.get_index_limb_name(grasp_id))

//Cancer growth for external organs is simple, it grows, hurts, damages, and suddenly grows out of control
//Limb cancer is relatively benign until it grows large, then it cripples you and metastases
/datum/organ/external/handle_cancer()

	if(..())
		return 1

	if(!is_existing()) //Limb has been destroyed or amputated, cancer's over as far as we are concerned since there is no limb to grow on anymore
		cancer_stage = 0
		return 1

	switch(cancer_stage)
		if(CANCER_STAGE_SMALL_TUMOR to CANCER_STAGE_LARGE_TUMOR) //Small tumors will not damage your limb, but might flash pain
			if(prob(1))
				owner.custom_pain("You feel a stabbing pain in your [display_name]!", 1)
		if(CANCER_STAGE_LARGE_TUMOR to CANCER_STAGE_METASTASIS) //Large tumors will start damaging your limb and give the owner DNA damage (bodywide, can't go per limb)
			if(prob(20))
				take_damage(0.5, 0, 0, used_weapon = "tumor growth")
				owner.custom_pain("You feel a stabbing pain in your [display_name]!", 1)
			if(prob(1))
				owner.apply_damage(0.5, CLONE, src)
		if(CANCER_STAGE_METASTASIS to INFINITY) //Metastasis achieved, limb will start breaking down very rapidly, and cancer will spread to all other limbs in short order through bloodstream
			if(prob(50))
				take_damage(0.5, 0, 0, used_weapon = "tumor metastasis")
			if(prob(20))
				owner.apply_damage(0.5, CLONE, src)
			if(prob(1))
				owner.add_cancer() //Add a new cancerous growth

	//Cancer has a single universal sign. Coughing. Has a chance to happen every tick
	//Most likely not medically accurate, but whocares.ru
	if(prob(1))
		owner.audible_cough()

//Updating germ levels. Handles organ germ levels and necrosis.
/*
The INFECTION_LEVEL values defined in setup.dm control the time it takes to reach the different
infection levels. Since infection growth is exponential, you can adjust the time it takes to get
from one germ_level to another using the rough formula:

desired_germ_level = initial_germ_level*e^(desired_time_in_seconds/1000)

So if I wanted it to take an average of 15 minutes to get from level one (100) to level two
I would set INFECTION_LEVEL_TWO to 100*e^(15*60/1000) = 245. Note that this is the average time,
the actual time is dependent on RNG.

INFECTION_LEVEL_ONE		below this germ level nothing happens, and the infection doesn't grow
INFECTION_LEVEL_TWO		above this germ level the infection will start to spread to internal and adjacent organs
INFECTION_LEVEL_THREE	above this germ level the player will take additional toxin damage per second, and will die in minutes without
						antitox. also, above this germ level you will need to overdose on spaceacillin to reduce the germ_level.

Note that amputating the affected organ does in fact remove the infection from the player's body.
*/

/datum/organ/external/proc/update_germs()
	if(!is_existing() || !is_organic()) //Needs to be organic and existing
		germ_level = 0
		return

	if(owner.bodytemperature >= 170) //Cryo stops germs from moving and doing their bad stuffs
		//Syncing germ levels with external wounds
		handle_germ_sync()

		//Handle antibiotics and curing infections
		handle_antibiotics()

		//Handle the effects of infections
		handle_germ_effects()

/datum/organ/external/proc/handle_germ_sync()
	var/antibiotics = owner.reagents.get_reagent_amount(SPACEACILLIN)
	for(var/datum/wound/W in wounds)
		//Open wounds can become infected
		if(owner.germ_level > W.germ_level && W.infection_check())
			W.germ_level++

	if(antibiotics < 5)
		for(var/datum/wound/W in wounds)
			//Infected wounds raise the organ's germ level
			if(W.germ_level > germ_level)
				germ_level++
				break //Limit increase to a maximum of one per second

/datum/organ/external/proc/handle_germ_effects()
	var/antibiotics = owner.reagents.get_reagent_amount(SPACEACILLIN)

	if(germ_level > 0 && germ_level < INFECTION_LEVEL_ONE && prob(60))	//This could be an else clause, but it looks cleaner this way
		germ_level-- //Since germ_level increases at a rate of 1 per second with dirty wounds, prob(60) should give us about 5 minutes before level one.

	if(germ_level >= INFECTION_LEVEL_ONE)
		//Having an infection raises your body temperature
		var/fever_temperature = (owner.species.heat_level_1 - owner.species.body_temperature - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + owner.species.body_temperature
		//Need to make sure we raise temperature fast enough to get around environmental cooling preventing us from reaching fever_temperature
		owner.bodytemperature += Clamp((fever_temperature - T20C) / BODYTEMP_COLD_DIVISOR + 1, 0, fever_temperature - owner.bodytemperature)

		if(prob(round(germ_level/10)))
			if(antibiotics < 5)
				germ_level++

			if(prob(10)) //Adjust this to tweak how fast people take toxin damage from infections
				owner.adjustToxLoss(1)

	if(germ_level >= INFECTION_LEVEL_TWO && antibiotics < 5)
		//Spread the infection to internal organs
		var/datum/organ/internal/target_organ = null //Make internal organs become infected one at a time instead of all at once
		for(var/datum/organ/internal/I in internal_organs)
			if(I.germ_level > 0 && I.germ_level < min(germ_level, INFECTION_LEVEL_TWO)) //Once the organ reaches whatever we can give it, or level two, switch to a different one
				if(!target_organ || I.germ_level > target_organ.germ_level)	//Choose the organ with the highest germ_level
					target_organ = I

		if(!target_organ)
			//Figure out which organs we can spread germs to and pick one at random
			var/list/candidate_organs = list()
			for(var/datum/organ/internal/I in internal_organs)
				if(I.germ_level < germ_level)
					candidate_organs += I
			if(candidate_organs.len)
				target_organ = pick(candidate_organs)

		if(target_organ)
			target_organ.germ_level++

		//Spread the infection to child and parent organs
		if(children)
			for(var/datum/organ/external/child in children)
				if(child.germ_level < germ_level && child.is_organic())
					if(child.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30))
						child.germ_level++

		if(parent)
			if(parent.germ_level < germ_level && parent.is_organic())
				if(parent.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30))
					parent.germ_level++

	if(germ_level >= INFECTION_LEVEL_THREE && antibiotics < 30)	//Overdosing is necessary to stop severe infections
		if(!(status & ORGAN_DEAD))
			status |= ORGAN_DEAD
			to_chat(owner, "<span class='notice'>You can't feel your [display_name] anymore.</span>")
			owner.update_body(1)

		germ_level++
		owner.adjustToxLoss(1)

//Updating wounds. Handles wound natural healing, internal bleedings and infections
/datum/organ/external/proc/update_wounds()

	if(!is_organic()) //Non-organic limbs don't heal or get worse
		return

	var/datum/species/species = src.species || owner.species

	for(var/datum/wound/W in wounds)
		//Internal wounds get worse over time. Low temperatures (cryo) stop them.
		if(W.internal && !W.is_treated() && owner.bodytemperature >= 170 && !(species && species.anatomy_flags & NO_BLOOD))
			if(!owner.reagents.has_any_reagents(list(BICARIDINE,INAPROVALINE,CLOTTING_AGENT,BIOFOAM)))	//Bicard, inaprovaline, clotting agent, and biofoam stop internal wounds from growing bigger with time, and also slow bleeding
				W.open_wound(0.1 * wound_update_accuracy)
				owner.vessel.remove_reagent(BLOOD, 0.05 * W.damage * wound_update_accuracy)

			if(!owner.reagents.has_reagent(CLOTTING_AGENT) && !owner.reagents.has_reagent(BIOFOAM))	//Clotting agent and biofoam stop bleeding entirely.
				owner.vessel.remove_reagent(BLOOD, 0.02 * W.damage * wound_update_accuracy)
			if(prob(1 * wound_update_accuracy))
				owner.custom_pain("You feel a stabbing pain in your [display_name]!", 1)

		// slow healing
		var/heal_amt = 0

		if(W.damage < 15 || (M_REGEN in owner.mutations && W.damage <= 50)) //This thing's edges are not in day's travel of each other, what healing?
			heal_amt += 0.2

		if(W.is_treated() && W.damage < 50) //Whoa, not even magical band aid can hold it together
			heal_amt += 0.3

		//We only update wounds once in [wound_update_accuracy] ticks so have to emulate realtime
		heal_amt = heal_amt * wound_update_accuracy
		//Configurable regen speed woo, no-regen hardcore or instaheal hugbox, choose your destiny
		heal_amt = heal_amt * config.organ_regeneration_multiplier
		if(M_REGEN in owner.mutations)
			heal_amt = heal_amt * 2 // The heal rate is twice as much if you have regeneration
		//Amount of healing is spread over all the wounds
		heal_amt = heal_amt / (wounds.len + 1)
		//Making it look prettier on scanners
		heal_amt = round(heal_amt,0.1)
		W.heal_damage(heal_amt)

		//Salving also helps against infection
		if(W.germ_level > 0 && W.salved && prob(2))
			W.germ_level = 0
			W.disinfected = 1

		if(W.damage <= 0)
			//Since we're a HIGH ARRPEE codebase and we want LOTS OF FLAVORR we like to keep all the completely healed wounds sticking around for 10 minutes minimum, so they show up as bruises and scars in examine.
			if(W.internal || W.created + 10 MINUTES <= world.time) //The exception to this is internal wounds, which are more of a special status and not really a wound at all in practice.
				wounds -= W
				continue //Let the GC handle the deletion of the wound

	//Sync the organ's damage with its wounds
	src.update_damages()
	if(update_icon())
		owner.UpdateDamageIcon()

//Updates brute_damn and burn_damn from wound damages. Updates BLEEDING status.
/datum/organ/external/proc/update_damages()
	number_wounds = 0
	brute_dam = 0
	burn_dam = 0
	status &= ~ORGAN_BLEEDING
	var/clamped = 0
	var/datum/species/species = src.species || owner.species

	for(var/datum/wound/W in wounds)
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			brute_dam += W.damage
		else if(W.damage_type == BURN)
			burn_dam += W.damage

		if(is_organic() && W.bleeding() && !(species.anatomy_flags & NO_BLOOD))
			W.bleed_timer--
			if(!owner.reagents.has_reagent(CLOTTING_AGENT))
				status |= ORGAN_BLEEDING

		clamped |= W.clamped
		number_wounds += W.amount

	if(open && !clamped && is_organic() && !(species.anatomy_flags & NO_BLOOD)) //Things tend to bleed if they are CUT OPEN
		if(!owner.reagents.has_reagent(CLOTTING_AGENT))
			status |= ORGAN_BLEEDING


// new damage icon system
// adjusted to set damage_state to brute/burn code only (without r_name0 as before)
/datum/organ/external/proc/update_icon()
	var/n_is = damage_state_text()
	if(n_is != damage_state)
		damage_state = n_is
		//owner.update_body(1)
		return 1
	return 0

//New damage icon system
//Returns just the brute/burn damage code
/datum/organ/external/proc/damage_state_text()
	if(!is_existing())
		return "--"

	var/tburn = 0
	var/tbrute = 0

	if(burn_dam == 0)
		tburn = 0
	else if(burn_dam < (max_damage * 0.25 / 2))
		tburn = 1
	else if(burn_dam < (max_damage * 0.75 / 2))
		tburn = 2
	else
		tburn = 3

	if(brute_dam == 0)
		tbrute = 0
	else if(brute_dam < (max_damage * 0.25 / 2))
		tbrute = 1
	else if(brute_dam < (max_damage * 0.75 / 2))
		tbrute = 2
	else
		tbrute = 3
	return "[tbrute][tburn]"

/datum/organ/external/proc/rejuvenate_limb()
	for(var/obj/item/weapon/shard/shrapnel/s in implants)
		if(istype(s))
			implants -= s
			owner.contents -= s
			qdel(s)
			s = null
	amputated = 0
	brute_dam = 0
	burn_dam = 0
	damage_state = "00"
	germ_level = 0
	hidden = null
	number_wounds = 0
	open = 0
	perma_injury = 0
	stage = 0
	status = 0
	trace_chemicals = list()
	wounds = list()
	wound_update_accuracy = 1

/****************************************************
			   DISMEMBERMENT
****************************************************/

//Recursive setting of all child organs to amputated
/datum/organ/external/proc/setAmputatedTree()
	for(var/datum/organ/external/O in children)
		O.amputated = 1
		O.setAmputatedTree()

//Handles dismemberment
//Returns the organ item
/datum/organ/external/proc/droplimb(var/override = 0, var/no_explode = 0, var/spawn_limb = 1, var/display_message = TRUE)
	if(destspawn)
		return
	if(body_part == (UPPER_TORSO || LOWER_TORSO)) //We can't lose either, those cannot be amputated and will cause extremely serious problems
		return

	var/datum/species/species = src.species || owner.species
	var/obj/item/organ/external/organ //Dropped limb object

	if(override)
		status |= ORGAN_DESTROYED
	if(status & ORGAN_DESTROYED)
		destspawn = 1
		//If your whole leg is missing, then yes, your foot is considered as "cleanly amputated".
		setAmputatedTree()

		if(spawn_limb)
			organ = get_organ_item()

			//If any organs are attached to this, attach them to the dropped organ item
			for(var/datum/organ/external/O in children)
				var/obj/item/organ/external/child_organ = O.droplimb(1, display_message = FALSE)

				if(istype(child_organ) && istype(organ))
					organ.add_child(child_organ)
		else
			//If any organs are attached to this, destroy them
			for(var/datum/organ/external/O in children)
				O.droplimb(1, no_explode, spawn_limb, display_message)

		for(var/implant in implants)
			qdel(implant)

		src.status &= ~ORGAN_BROKEN
		src.status &= ~ORGAN_BLEEDING
		src.status &= ~ORGAN_SPLINTED
		src.status &= ~ORGAN_DEAD

		//No limb, no damage
		brute_dam = 0
		burn_dam = 0
		perma_injury = 0
		for(var/datum/wound/W in wounds)
			wounds -= W
			number_wounds -= W.amount
			//Don't delete the wounds because they're transferred to the organ item. If they aren't, garbage collecting will take care of it

		src.species = null

		if(body_part == LOWER_TORSO)
			to_chat(owner, "<span class='danger'>You are now sterile.</span>")

		if(slots_to_drop && slots_to_drop.len)
			for(var/slot_id in slots_to_drop)
				owner.u_equip(owner.get_item_by_slot(slot_id), 1)
		if(grasp_id && can_grasp)
			if(owner.held_items[grasp_id])
				owner.u_equip(owner.held_items[grasp_id], 1)

		//Robotic limbs explode if sabotaged.
		if(status & ORGAN_ROBOT && !no_explode && sabotaged)
			owner.visible_message("<span class='danger'>\The [owner]'s [display_name] explodes violently!</span>", \
			"<span class='danger'>Your [display_name] explodes violently!</span>", \
			"<span class='danger'>You hear an explosion followed by a scream!</span>")
			explosion(get_turf(owner), -1, -1, 2, 3)
			spark(src, 5, FALSE)

		if(organ)
			if(display_message)
				owner.visible_message("<span class='danger'>[owner.name]'s [display_name] flies off in an arc.</span>", \
				"<span class='danger'>Your [display_name] goes flying off!</span>", \
				"<span class='danger'>You hear a terrible sound of ripping tendons and flesh.</span>")

			//Throw organs around
			var/randomdir = pick(cardinal)
			step(organ, randomdir)

		owner.update_body(1)
		owner.handle_organs(1)

		//OK so maybe your limb just flew off, but if it was attached to a pair of cuffs then hooray! Freedom!
		release_restraints()

		if(vital)
			owner.death()

		if(species.anatomy_flags & NO_STRUCTURE)
			status |= ORGAN_ATTACHABLE
			amputated = 1
			setAmputatedTree()
			open = 0

		if(isslimeperson(owner) && organ)
			spawn(1)
			if(organ.borer)
				organ.borer.detach()
			if(name != LIMB_HEAD)
				qdel(organ)
			else
				var/headloc = organ.loc
				rejuvenate_limb()
				var/datum/organ/internal/I = organ.organ_data
				var/obj/item/organ/internal/O = I.remove(owner)
				if(O && istype(O))
					O.organ_data.rejecting = null
					owner.internal_organs_by_name["brain"] = null
					owner.internal_organs_by_name -= "brain"
					owner.internal_organs -= O.organ_data
					internal_organs -= O.organ_data
					O.removed(owner,owner)
					O.loc = headloc
				qdel(organ)
				organ = null

	return organ

/datum/organ/external/proc/get_organ_item()
	var/organ_item = generate_dropped_organ(src.organ_item)


	if(istype(organ_item, /obj/item/robot_parts))
		var/obj/item/robot_parts/O = organ_item

		O.burn_dam = src.burn_dam
		O.brute_dam = src.brute_dam

	return organ_item

//Don't use this proc, use get_organ_item
/datum/organ/external/proc/generate_dropped_organ(var/obj/item/current_organ)
	return current_organ

/****************************************************
			   HELPERS
****************************************************/

//Returns true if this organ's species has a specific mutation
/datum/organ/external/proc/has_mutation(mutation)
	if(!species)
		return FALSE

	return (species.default_mutations.Find(mutation))


/datum/organ/external/proc/release_restraints(var/uncuff = UNCUFF_BOTH)
	if(uncuff >= UNCUFF_BOTH)
		if(owner.handcuffed && body_part in list(ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT))
			owner.visible_message(\
				"\The [owner.handcuffed.name] falls off of [owner.name].",\
				"\The [owner.handcuffed.name] falls off you.")

			owner.drop_from_inventory(owner.handcuffed)

	if(uncuff <= UNCUFF_BOTH)
		if(owner.legcuffed && body_part in list(FOOT_LEFT, FOOT_RIGHT, LEG_LEFT, LEG_RIGHT))
			owner.visible_message("\The [owner.legcuffed.name] falls off of [owner].", \
			"\The [owner.legcuffed.name] falls off you.")

			owner.drop_from_inventory(owner.legcuffed)

/datum/organ/external/proc/bandage()
	var/rval = 0
	src.status &= ~ORGAN_BLEEDING
	for(var/datum/wound/W in wounds)
		if(W.internal)
			continue
		rval |= !W.bandaged
		W.bandaged = 1
	return rval

/datum/organ/external/proc/disinfect()
	var/rval = 0
	for(var/datum/wound/W in wounds)
		if(W.internal)
			continue
		rval |= !W.disinfected
		W.disinfected = 1
		W.germ_level = 0
	return rval

/datum/organ/external/proc/clamp()
	var/rval = 0
	src.status &= ~ORGAN_BLEEDING
	for(var/datum/wound/W in wounds)
		if(W.internal)
			continue
		rval |= !W.clamped
		W.clamped = 1
	return rval

/datum/organ/external/proc/salve()
	var/rval = 0
	for(var/datum/wound/W in wounds)
		rval |= !W.salved
		W.salved = 1
	return rval

/datum/organ/external/proc/fracture()
	var/datum/species/species = src.species || owner.species
	if(species.anatomy_flags & NO_BONES)
		return
	if(status & ORGAN_BROKEN)
		return
	owner.visible_message("<span class='danger'>You hear a loud cracking sound coming from \the [owner].</span>", \
	"<span class='danger'>Something feels like it shattered in your [display_name]!</span>", \
	"<span class='danger'>You hear a sickening crack.</span>")

	if(owner.feels_pain())
		owner.audible_scream()

	playsound(owner.loc, "fracture", 100, 1, -2)
	status |= ORGAN_BROKEN
	broken_description = pick("broken", "fracture", "hairline fracture")
	perma_injury = brute_dam

	//Fractures have a chance of getting you out of restraints. All spacemen are all trained to be Houdini.
	if(owner.handcuffed && body_part in list(HAND_LEFT, HAND_RIGHT))
		if(prob(25))
			release_restraints(UNCUFF_HANDS)//Handcuffs only.
	if(owner.legcuffed && body_part in list(FOOT_LEFT, FOOT_RIGHT))
		if(prob(25))
			release_restraints(UNCUFF_LEGS)//Legcuffs only.


	if(isgolem(owner))
		droplimb(1)

	return

/datum/organ/external/proc/robotize()
	src.status &= ~ORGAN_BROKEN
	src.status &= ~ORGAN_BLEEDING
	src.status &= ~ORGAN_SPLINTED
	src.status &= ~ORGAN_CUT_AWAY
	src.status &= ~ORGAN_ATTACHABLE
	src.status &= ~ORGAN_DESTROYED
	src.status &= ~ORGAN_PEG
	src.status |= ORGAN_ROBOT
	src.species = null
	src.destspawn = 0
	for (var/datum/organ/external/T in children)
		if(T)
			T.robotize()

/datum/organ/external/proc/peggify()
	src.status &= ~ORGAN_BROKEN
	src.status &= ~ORGAN_BLEEDING
	src.status &= ~ORGAN_CUT_AWAY
	src.status &= ~ORGAN_SPLINTED
	src.status &= ~ORGAN_ATTACHABLE
	src.status &= ~ORGAN_DESTROYED
	src.status &= ~ORGAN_ROBOT
	src.status |= ORGAN_PEG
	src.species = null
	src.wounds.len = 0

	for (var/datum/organ/external/T in children)
		if(T)
			if(body_part == ARM_LEFT || body_part == ARM_RIGHT || body_part == LEG_RIGHT || body_part == LEG_LEFT)
				T.peggify()
				src.destspawn = 0
			else
				T.droplimb(1, 1)
				T.status &= ~ORGAN_BROKEN
				T.status &= ~ORGAN_BLEEDING
				T.status &= ~ORGAN_CUT_AWAY
				T.status &= ~ORGAN_SPLINTED
				T.status &= ~ORGAN_ATTACHABLE
				T.status &= ~ORGAN_DESTROYED
				T.status &= ~ORGAN_ROBOT
				T.wounds.len = 0


/datum/organ/external/proc/fleshify()
	src.status &= ~ORGAN_BROKEN
	src.status &= ~ORGAN_BLEEDING
	src.status &= ~ORGAN_SPLINTED
	src.status &= ~ORGAN_CUT_AWAY
	src.status &= ~ORGAN_ATTACHABLE
	src.status &= ~ORGAN_DESTROYED
	src.status &= ~ORGAN_PEG
	src.status &= ~ORGAN_ROBOT
	src.destspawn = 0

/datum/organ/external/proc/attach(obj/item/I)
	if(istype(I, /obj/item/organ/external)) //Attaching an organic limb
		var/obj/item/organ/external/organ = I

		src.fleshify()

		//Transfer properties (species, damage, ...)
		src.species = organ.species
		src.cancer_stage = organ.cancer_stage
		src.wounds = organ.wounds
		src.status = organ.status
		src.brute_dam = organ.brute_dam
		src.burn_dam = organ.burn_dam

		//Process attached parts (i.e. if attaching an arm with a hand, this will process the hand)
		for(var/obj/item/organ/external/attached in organ.children)
			organ.remove_child(attached)

			//Get the organ datum of the attached organ
			var/datum/organ/external/OE = owner.get_organ(attached.part)

			OE.attach(attached)

		if(organ.organ_data && !owner.internal_organs_by_name[organ.organ_data.organ_type])
			owner.internal_organs_by_name[organ.organ_data.organ_type] = organ.organ_data.Copy()
			owner.internal_organs += owner.internal_organs_by_name[organ.organ_data.organ_type]
			internal_organs += owner.internal_organs_by_name[organ.organ_data.organ_type]
			owner.internal_organs_by_name[organ.organ_data.organ_type].owner = owner


	else if(istype(I, /obj/item/weapon/peglimb)) //Attaching a peg limb
		src.peggify()

	else if(istype(I, /obj/item/robot_parts)) //Robotic limb
		var/obj/item/robot_parts/R = I

		src.robotize()

		src.sabotaged = R.sabotaged
		src.brute_dam = R.brute_dam
		src.burn_dam = R.burn_dam

	else
		throw EXCEPTION("Bad item passed to attach(): '[I]'")

	qdel(I)

	owner.handle_organs(1)
	owner.update_body()
	owner.updatehealth()
	owner.UpdateDamageIcon()

/datum/organ/external/proc/mutate()
	src.status |= ORGAN_MUTATED
	owner.update_body()
	owner.handle_organs(1)

/datum/organ/external/proc/unmutate()
	src.status &= ~ORGAN_MUTATED
	owner.update_body()
	owner.handle_organs(1)

/datum/organ/external/proc/get_damage()	//returns total damage
	return max(brute_dam + burn_dam - perma_injury, perma_injury)	//could use health?

/datum/organ/external/proc/has_infected_wound()
	for(var/datum/wound/W in wounds)
		if(W.germ_level > INFECTION_LEVEL_ONE)
			return 1
	return 0

/datum/organ/external/get_icon(gender = "", isFat = 0)
	//stand_icon = new /icon(icobase, "torso_[g][fat?"_fat":""]")
	if(gender)
		gender="_[gender]"
	var/fat = ""
	if(isFat && has_fat)
		fat = "_fat"
	var/icon_state = "[icon_name][gender][fat]"
	var/baseicon = (species ? species.icobase : owner.race_icon)
	if(status & ORGAN_MUTATED)
		baseicon = (species ? species.deform : owner.deform_icon)
	else if(is_peg())
		baseicon = 'icons/mob/human_races/o_peg.dmi'
	else if(is_robotic())
		baseicon = 'icons/mob/human_races/o_robot.dmi'
	return new /icon(baseicon, icon_state)

//Our external limb is a peg
/datum/organ/external/proc/is_peg()
	return (status & ORGAN_PEG)

//Our external limb is robotic
/datum/organ/external/proc/is_robotic()
	return (status & ORGAN_ROBOT)

//Our external limb is organic, 100 % bio
/datum/organ/external/proc/is_organic()
	return !(status & (ORGAN_ROBOT|ORGAN_PEG))

//Is the limb physically present ?
/datum/organ/external/proc/is_existing()
	return !(status & (ORGAN_DESTROYED|ORGAN_CUT_AWAY))

//Can we use the limb at all in any manner
/datum/organ/external/proc/is_usable()
	return !(status & (ORGAN_DESTROYED|ORGAN_MUTATED|ORGAN_DEAD|ORGAN_CUT_AWAY|ORGAN_MALFUNCTIONING))

//Is the limb broken and not splinted
/datum/organ/external/proc/is_broken()
	return ((status & ORGAN_BROKEN) && !(status & ORGAN_SPLINTED))

/datum/organ/external/proc/is_healthy()
	return (is_usable() && !is_broken())

//Is the limb robotic and malfunctioning
/datum/organ/external/proc/is_malfunctioning()
	return (is_robotic() && (status & (ORGAN_MALFUNCTIONING) || (brute_dam + burn_dam > min_broken_damage/2 && prob(brute_dam + burn_dam))))

//Can we use advanced tools (no pegs or hook-hands)
/datum/organ/external/proc/can_use_advanced_tools()
	return !(status & (ORGAN_DESTROYED|ORGAN_MUTATED|ORGAN_DEAD|ORGAN_PEG|ORGAN_CUT_AWAY))

/datum/organ/external/proc/can_stand()
	return 0

/datum/organ/external/proc/can_grasp()
	return (can_grasp && grasp_id)

/datum/organ/external/proc/process_grasp(var/obj/item/c_hand, var/hand_name)
	if(!c_hand)
		return
	if(c_hand.cant_drop)
		return

	if(is_organic() && is_broken() && !istype(c_hand,/obj/item/tk_grab))
		owner.drop_item(c_hand)
		var/emote_scream = pick("screams in pain and", "lets out a sharp cry and", "cries out and")
		owner.emote("me", 1, "[owner.feels_pain() ? emote_scream : ""] drops what they were holding in their [hand_name]!")
	if(is_malfunctioning())
		// owner.u_equip(c_hand, 1)
		owner.emote("me", 1, "drops what they were holding, their [hand_name] malfunctioning!")
		spark(src, 5, FALSE)
		owner.drop_item(c_hand)

/datum/organ/external/proc/embed(var/obj/item/weapon/W, var/silent = 0)
	if(!silent)
		owner.visible_message("<span class='danger'>\The [W] sticks in the wound!</span>")
	implants += W
	owner.embedded_flag = 1
	owner.verbs += /mob/proc/yank_out_object
	W.add_blood(owner)
	if(ismob(W.loc))
		var/mob/living/H = W.loc
		H.drop_item(W, force_drop = 1)
	W.forceMove(owner)

/datum/organ/external/proc/skeletify()
	if(istype(species, /datum/species/skellington))
		return
	owner.visible_message("<span class = 'warning'>The flesh falls off of \the [owner]'s [display_name]!</span>","<span class = 'warning'>The flesh is falling off of your [display_name]!</span>")
	var/new_species_name
	if(isvox(owner))
		new_species_name = "Skeletal Vox"
	else
		new_species_name = "Skellington"
	var/datum/species/S = all_species[new_species_name]
	species = new S.type
	owner.update_body()

/****************************************************
			   ORGAN DEFINES
****************************************************/

/datum/organ/external/chest
	name = LIMB_CHEST
	icon_name = "torso"
	display_name = "chest"
	max_damage = 150
	min_broken_damage = 75
	body_part = UPPER_TORSO
	has_fat = 1
	vital = 1
	encased = "ribcage"
	w_class = W_CLASS_MEDIUM

/datum/organ/external/groin
	name = LIMB_GROIN
	icon_name = "groin"
	display_name = "groin"
	max_damage = 115
	min_broken_damage = 70
	body_part = LOWER_TORSO
	vital = 1
	w_class = W_CLASS_MEDIUM

//=====Legs======

/datum/organ/external/l_leg
	name = LIMB_LEFT_LEG
	display_name = "left leg"
	icon_name = "l_leg"
	max_damage = 75
	min_broken_damage = 30
	body_part = LEG_LEFT
	icon_position = LEFT
	w_class = W_CLASS_SMALL

/datum/organ/external/l_leg/can_stand()
	//Peg legs don't require an attached foot
	if(is_peg())
		return 1

	//For normal legs, check if the feet are broken or missing.
	var/feet_usable = FALSE
	for(var/datum/organ/external/child in children)
		if(child.is_usable())
			feet_usable = TRUE
	if(!feet_usable)
		return 0

	//If the feet are OK, return 1 if this leg is usable
	return is_usable()

/datum/organ/external/l_leg/generate_dropped_organ(current_organ)
	if(is_peg())
		current_organ = new /obj/item/weapon/peglimb(owner.loc)
	if(!current_organ)
		if(is_robotic())
			current_organ = new /obj/item/robot_parts/l_leg(owner.loc)
		else
			current_organ = new /obj/item/organ/external/l_leg(owner.loc, owner, src)
	return current_organ

/datum/organ/external/r_leg
	name = LIMB_RIGHT_LEG
	display_name = "right leg"
	icon_name = "r_leg"
	max_damage = 75
	min_broken_damage = 30
	body_part = LEG_RIGHT
	icon_position = RIGHT

	w_class = W_CLASS_SMALL

//This proc is same as l_leg/can_stand()
/datum/organ/external/r_leg/can_stand()
	//Peg legs don't require an attached foot
	if(is_peg())
		return 1

	//For normal legs, check if the feet are broken or missing.
	var/feet_usable = FALSE
	for(var/datum/organ/external/child in children)
		if(child.is_usable())
			feet_usable = TRUE
	if(!feet_usable)
		return 0

	//If the feet are OK, return 1 if this leg is usable
	return is_usable()

/datum/organ/external/r_leg/generate_dropped_organ(current_organ)
	if(is_peg())
		current_organ = new /obj/item/weapon/peglimb(owner.loc)
	if(!current_organ)
		if(is_robotic())
			current_organ = new /obj/item/robot_parts/r_leg(owner.loc)
		else
			current_organ = new /obj/item/organ/external/r_leg(owner.loc, owner, src)
	return current_organ

//======Arms=======

/datum/organ/external/l_arm
	name = LIMB_LEFT_ARM
	display_name = "left arm"
	icon_name = "l_arm"
	max_damage = 75
	min_broken_damage = 30
	w_class = W_CLASS_SMALL
	body_part = ARM_LEFT

	grasp_id = GRASP_LEFT_HAND

/datum/organ/external/l_arm/generate_dropped_organ(current_organ)
	if(status & ORGAN_PEG)
		current_organ = new /obj/item/weapon/peglimb(owner.loc)
	if(!current_organ)
		if(status & ORGAN_ROBOT)
			current_organ= new /obj/item/robot_parts/l_arm(owner.loc)
		else
			current_organ= new /obj/item/organ/external/l_arm(owner.loc, owner, src)
	return current_organ

/datum/organ/external/r_arm
	name = LIMB_RIGHT_ARM
	display_name = "right arm"
	icon_name = "r_arm"
	max_damage = 75
	min_broken_damage = 30
	w_class = W_CLASS_SMALL
	body_part = ARM_RIGHT

	grasp_id = GRASP_RIGHT_HAND

/datum/organ/external/r_arm/generate_dropped_organ(current_organ)
	if(is_peg())
		current_organ = new /obj/item/weapon/peglimb(owner.loc)
	if(!current_organ)
		if(is_robotic())
			current_organ = new /obj/item/robot_parts/r_arm(owner.loc)
		else
			current_organ = new /obj/item/organ/external/r_arm(owner.loc, owner, src)
	return current_organ

/datum/organ/external/l_foot
	name = LIMB_LEFT_FOOT
	display_name = "left foot"
	icon_name = "l_foot"
	max_damage = 40
	min_broken_damage = 15
	body_part = FOOT_LEFT
	icon_position = LEFT

	w_class = W_CLASS_TINY
	slots_to_drop = list(slot_shoes, slot_legcuffed)

/datum/organ/external/l_foot/generate_dropped_organ(current_organ)
	if(is_peg())
		current_organ = new /obj/item/weapon/peglimb(owner.loc)
	if(!current_organ)
		if(!is_robotic())
			current_organ = new /obj/item/organ/external/l_foot(owner.loc, owner, src)
	return current_organ

/datum/organ/external/r_foot
	name = LIMB_RIGHT_FOOT
	display_name = "right foot"
	icon_name = "r_foot"
	max_damage = 40
	min_broken_damage = 15
	body_part = FOOT_RIGHT
	icon_position = RIGHT

	w_class = W_CLASS_TINY
	slots_to_drop = list(slot_shoes, slot_legcuffed)

/datum/organ/external/r_foot/generate_dropped_organ(current_organ)
	if(is_peg())
		current_organ = new /obj/item/weapon/peglimb(owner.loc)
	if(!current_organ)
		if(!is_robotic())
			current_organ = new /obj/item/organ/external/r_foot(owner.loc, owner, src)
	return current_organ

/datum/organ/external/r_hand
	name = LIMB_RIGHT_HAND
	display_name = "right hand"
	icon_name = "r_hand"
	max_damage = 40
	min_broken_damage = 15
	body_part = HAND_RIGHT
	grasp_id = GRASP_RIGHT_HAND
	can_grasp = 1

	w_class = W_CLASS_TINY
	slots_to_drop = list(slot_gloves, slot_handcuffed)

/datum/organ/external/r_hand/generate_dropped_organ(current_organ)
	if(is_peg())
		current_organ = new /obj/item/weapon/peglimb(owner.loc)
	if(!current_organ)
		if(!is_robotic())
			current_organ = new /obj/item/organ/external/r_hand(owner.loc, owner, src)
	return current_organ

/datum/organ/external/l_hand
	name = LIMB_LEFT_HAND
	display_name = "left hand"
	icon_name = "l_hand"
	max_damage = 40
	min_broken_damage = 15
	body_part = HAND_LEFT
	grasp_id = GRASP_LEFT_HAND
	can_grasp = 1

	w_class = W_CLASS_TINY
	slots_to_drop = list(slot_gloves, slot_handcuffed)

/datum/organ/external/l_hand/generate_dropped_organ(current_organ)
	if(is_peg())
		current_organ = new /obj/item/weapon/peglimb(owner.loc)
	if(!current_organ)
		if(!is_robotic())
			current_organ = new /obj/item/organ/external/l_hand(owner.loc, owner, src)
	return current_organ

/datum/organ/external/head
	icon_name = "head"
	display_name = "head"
	name = LIMB_HEAD
	max_damage = 130
	min_broken_damage = 40
	body_part = HEAD
	var/disfigured = FALSE
	vital = 1
	encased = "skull"

	w_class = W_CLASS_SMALL
	slots_to_drop = list(slot_glasses, slot_wear_mask, slot_head, slot_ears)

/datum/organ/external/head/generate_dropped_organ(current_organ)
	if(!current_organ)
		current_organ = new /obj/item/organ/external/head(owner.loc, owner, src)
		owner.decapitated = current_organ
	var/datum/organ/internal/brain/B = eject_brain()
	var/obj/item/organ/external/head/H = current_organ
	if(B)
		H.organ_data = B
		B.organ_holder = current_organ
		B.owner_dna = H.owner_dna

	return current_organ

/datum/organ/external/head/proc/eject_brain()
	var/datum/organ/internal/brain/B = owner.internal_organs_by_name["brain"]

	if(B)
		owner.internal_organs_by_name.Remove("brain")
		owner.internal_organs.Remove(B)
		src.internal_organs.Remove(B)

	return B

/datum/organ/external/head/explode()
	owner.remove_internal_organ(owner, owner.internal_organs_by_name["brain"], src)
	.=..()
	owner.update_hair()

/datum/organ/external/head/get_icon(gender = "", isFat = 0)
	if(!owner)
		return ..()

	var/baseicon = (species ? species.icobase : owner.race_icon)
	if(status & ORGAN_MUTATED)
		baseicon = (species ? species.deform : owner.deform_icon)

	if(is_peg())
		baseicon = 'icons/mob/human_races/o_peg.dmi'
	if(is_robotic())
		baseicon = 'icons/mob/human_races/o_robot.dmi'
	return new /icon(baseicon, "[icon_name]_[gender]")

/datum/organ/external/head/take_damage(brute, burn, sharp, edge, used_weapon = null, list/forbidden_limbs = list())
	..(brute, burn, sharp, edge, used_weapon, forbidden_limbs)
	if(!disfigured)
		if(brute_dam > 40)
			if(prob(50))
				disfigure("brute")
		if(burn_dam > 40)
			disfigure((used_weapon != WPN_LOW_BODY_TEMP) ? "burn" : "frostbite")

/datum/organ/external/head/proc/disfigure(var/type = "brute")
	if(disfigured)
		return

	if(type == "brute")
		owner.visible_message("<span class='warning'>You hear a sickening cracking sound coming from \the [owner]'s face.</span>",
		                      "<span class='danger'>Your face becomes an unrecognizable, mangled mess!</span>",
		                      "<span class='warning'>You hear a sickening crack.</span>")
	else if (type == "burn")
		owner.visible_message("<span class='warning'>[owner]'s face melts away, turning into a mangled mess!</span>",
		                      "<span class='danger'>Your face melts away into an unrecognizable, mangled mess!</span>",
		                      "<span class='warning'>You hear a sickening sizzle.</span>")
	else if (type == "frostbite")
		owner.visible_message("<span class='warning'>[owner]'s frozen face blisters and cracks.</span>",
		                      "<span class='danger'>Your face blisters and numbs away!</span>",
							  "<span class='warning'>You hear a sickening crackling.</span>")
	else // Generic message, shouldn't happen
		owner.visible_message("<span class='warning'>[owner]'s face disfigures.</span>",
		                      "<span class='danger'>Your face becomes an unrecognizable, mangled mess!</span>")

	disfigured = TRUE

/****************************************************
			   EXTERNAL ORGAN ITEMS
****************************************************/

obj/item/organ/external
	icon = 'icons/mob/human_races/r_human.dmi'
	var/datum/organ/internal/organ_data
	var/datum/dna/owner_dna
	var/part = "organ"

	//This variable stores "butchering products" - objects of type "/datum/butchering_product" (see  code/datums/helper_datums/butchering.dm)
	//They are transferred from the mob from which the organ was removed.
	//Currently the only "butchering drops" which are going to be stored here are teeth
	var/list/butchering_drops = list()
	var/mob/living/simple_animal/borer/borer

	var/datum/species/species

	//Store health facts. Right now limited exclusively to cancer, but should likely include all limb stats eventually
	var/cancer_stage = 0
	var/list/wounds = list()
	var/brute_dam
	var/burn_dam
	var/status

	//List of attached organs
	//It doesn't contain the whole tree, only the organs attached to this one
	var/list/obj/item/organ/external/children = list()


obj/item/organ/external/New(loc, mob/living/carbon/human/H, datum/organ/external/source)
	..(loc)
	if(!istype(H))
		return
	if(H.dna)
		owner_dna = H.dna.Clone()
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[H.dna.unique_enzymes] = H.dna.b_type

	src.species = source.species || H.species
	w_class = source.w_class
	cancer_stage = source.cancer_stage
	wounds = source.wounds.Copy()
	burn_dam = source.burn_dam
	brute_dam = source.brute_dam

	//Copy status flags except for ORGAN_CUT_AWAY and ORGAN_DESTROYED
	status = source.status & ~(ORGAN_CUT_AWAY | ORGAN_DESTROYED)

	//Forming icon for the limb
	//Setting base icon for this mob's race
	update_icon(H)

	for(var/datum/butchering_product/B in H.butchering_drops) //Go through all butchering products (like teeth) in the parent
		if(B.stored_in_organ == src.part) //If they're stored in our organ,

			var/datum/butchering_product/new_bp = new B.type() //Create a new butchering_product datum to go into the head!
			new_bp.amount = B.amount
			B.amount = 0 //Transfer the found product's amount to the new datum

			src.butchering_drops += new_bp

			//The reason why B isn't just transferred from H.butchering_drops to src.butchering_drops is:
			//on examine(), each butchering drop's "desc_modifier()" is added to the description. This adds stuff like "he HAS NO TEETH AT ALL!!!" to the resulting description.

/obj/item/organ/external/examine(mob/user)
	..()

	//TODO: wound datums should be handling this (they aren't because they're awful)

	//Brute damage can be either cuts or bruises
	if(brute_dam)
		if(locate(/datum/wound/cut) in wounds)
			to_chat(user, "<span class='warning'>It has some cuts on it.</span>")
		if(locate(/datum/wound/bruise) in wounds)
			to_chat(user, "<span class='warning'>It has some bruises on it.</span>")

	//Burn damage is straightforward
	switch(burn_dam)
		if(1 to 10)
			to_chat(user, "<span class='warning'>It has some minor burns on it.</span>")
		if(10 to 50)
			to_chat(user, "<span class='warning'>It is covered in major burns.</span>")
		if(50 to INFINITY)
			to_chat(user, "<span class='warning'>It is covered in large carbonised areas.</span>")

	for(var/obj/item/organ/external/E in children)
		to_chat(user, "<span class='info'>There's \a [E] attached to it.</span>")

	//Add information about teeth and the such

	var/butchery
	if(butchering_drops.len)
		for(var/datum/butchering_product/B in butchering_drops)
			butchery = "[butchery][B.desc_modifier(src, user)]"
	if(butchery)
		to_chat(user, "<span class='warning'>[butchery]</span>")

/obj/item/organ/external/update_icon(mob/living/carbon/human/H)
	..()

	if(!H && !species)
		return

	var/icon/base
	if(H)
		base = H.get_organ(part).get_icon(H.gender == FEMALE? "f":"m", (M_FAT in H.mutations) && (H.species && H.species.anatomy_flags & CAN_BE_FAT))
	else if(species)
		base = icon(species.icobase)

	//Display organs attached to this one
	if(children.len)
		for(var/obj/item/organ/external/attached in children)
			attached.update_icon(H) //This works recursively, ensuring all children are drawn
			attached.transform = matrix() //Remove any rotation

			base.Blend(attached.icon, ICON_OVERLAY)

	if(base)
		//Changing limb's skin tone to match owner
		if(H)
			if(!H.species || H.species.anatomy_flags & HAS_SKIN_TONE)
				if(H.my_appearance.s_tone >= 0)
					base.Blend(rgb(H.my_appearance.s_tone, H.my_appearance.s_tone, H.my_appearance.s_tone), ICON_ADD)
				else
					base.Blend(rgb(-H.my_appearance.s_tone,  -H.my_appearance.s_tone,  -H.my_appearance.s_tone), ICON_SUBTRACT)

		icon = base
		dir = SOUTH

		src.transform = turn(src.transform, rand(70, 130))

/obj/item/organ/external/proc/add_child(obj/item/organ/external/O, upd_icon = TRUE)
	children.Add(O)
	O.forceMove(src)

	if(upd_icon)
		update_icon()

/obj/item/organ/external/proc/remove_child(obj/item/organ/external/O)
	children.Remove(O)

/obj/item/organ/external/attackby(obj/item/W, mob/user)
	if(W.is_sharp()) //Allow cutting attached parts off
		for(var/obj/item/organ/external/O in children)
			children.Remove(O)
			O.forceMove(get_turf(src))

			update_icon()

	..()

/****************************************************
			   EXTERNAL ORGAN ITEMS DEFINES
****************************************************/

obj/item/organ/external/l_arm
	name = "left arm"
	icon_state = LIMB_LEFT_ARM
	part = LIMB_LEFT_ARM
obj/item/organ/external/l_arm/New(loc, mob/living/carbon/human/H)
	..()
	if(H && istype(H))
		var/mob/living/simple_animal/borer/B = H.has_brain_worms(LIMB_LEFT_ARM)
		if(B)
			B.infest_limb(src)

obj/item/organ/external/l_foot
	name = "left foot"
	icon_state = LIMB_LEFT_FOOT
	part = LIMB_LEFT_FOOT

obj/item/organ/external/l_hand
	name = "left hand"
	icon_state = LIMB_LEFT_HAND
	part = LIMB_LEFT_HAND

obj/item/organ/external/l_leg
	name = "left leg"
	icon_state = LIMB_LEFT_LEG
	part = LIMB_LEFT_LEG
obj/item/organ/external/l_leg/New(loc, mob/living/carbon/human/H)
	..()
	if(H && istype(H))
		var/mob/living/simple_animal/borer/B = H.has_brain_worms(LIMB_LEFT_LEG)
		if(B)
			B.infest_limb(src)

obj/item/organ/external/r_arm
	name = "right arm"
	icon_state = LIMB_RIGHT_ARM
	part = LIMB_RIGHT_ARM
obj/item/organ/external/r_arm/New(loc, mob/living/carbon/human/H)
	..()
	if(H && istype(H))
		var/mob/living/simple_animal/borer/B = H.has_brain_worms(LIMB_RIGHT_ARM)
		if(B)
			B.infest_limb(src)

obj/item/organ/external/r_foot
	name = "right foot"
	icon_state = LIMB_RIGHT_FOOT
	part = LIMB_RIGHT_FOOT

obj/item/organ/external/r_hand
	name = "right hand"
	icon_state = LIMB_RIGHT_HAND
	part = LIMB_RIGHT_HAND

obj/item/organ/external/r_leg
	name = "right leg"
	icon_state = LIMB_RIGHT_LEG
	part = LIMB_RIGHT_LEG
obj/item/organ/external/r_leg/New(loc, mob/living/carbon/human/H)
	..()
	if(H && istype(H))
		var/mob/living/simple_animal/borer/B = H.has_brain_worms(LIMB_RIGHT_LEG)
		if(B)
			B.infest_limb(src)

/obj/item/organ/external/head
	dir = NORTH
	name = LIMB_HEAD
	icon_state = "head_m"
	part = LIMB_HEAD
	var/mob/living/carbon/brain/brainmob
	var/brain_op_stage = 0
	var/mob/living/carbon/human/origin_body = null

/obj/item/organ/external/head/ashtype()
	return /obj/item/weapon/skull

obj/item/organ/external/head/Destroy()
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	..()

//obj/item/organ/external/head/with_teeth starts with 32 human teeth!
/obj/item/organ/external/head/with_teeth/New()
	.=..()
	butchering_drops += new /datum/butchering_product/teeth/human()

/obj/item/organ/external/head/posi
	name = "robotic head"

obj/item/organ/external/head/New(loc, mob/living/carbon/human/H)
	origin_body = H

	if(istype(H))
		src.icon_state = H.gender == MALE? "head_m" : "head_f"
	..()
	if(isgolem(H)) //Golems don't inhabit their severed heads, they turn to dust when they die.
		var/mob/living/simple_animal/borer/B = H.has_brain_worms()
		if(B)
			B.detach()
		qdel(src)
		return
	//Add (facial) hair.
	if(H && H.my_appearance.f_style &&  !H.check_hidden_head_flags(HIDEBEARDHAIR))
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[H.my_appearance.f_style]
		if(facial_hair_style && species.name in facial_hair_style.species_allowed)
			var/icon/facial = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial.Blend(rgb(H.my_appearance.r_facial, H.my_appearance.g_facial, H.my_appearance.b_facial), ICON_ADD)

			overlays.Add(facial) // icon.Blend(facial, ICON_OVERLAY)

	if(H && H.my_appearance.h_style && !H.check_hidden_head_flags(HIDEHEADHAIR))
		var/datum/sprite_accessory/hair_style = hair_styles_list[H.my_appearance.h_style]
		if(hair_style && species.name in hair_style.species_allowed)
			var/icon/hair = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				hair.Blend(rgb(H.my_appearance.r_hair, H.my_appearance.g_hair, H.my_appearance.b_hair), ICON_ADD)
			if(hair_style.additional_accessories)
				hair.Blend(icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_acc"), ICON_OVERLAY)

			overlays.Add(hair) //icon.Blend(hair, ICON_OVERLAY)
	spawn(5)
	if(brainmob && brainmob.client)
		brainmob.client.screen.len = null //clear the hud

	if(H && istype(H))
		var/mob/living/simple_animal/borer/B = H.has_brain_worms()
		if(B)
			B.infest_limb(src)

	//if(ishuman(H))
	//	if(H.gender == FEMALE)
	//		H.icon_state = "head_f"
	//	H.overlays += H.generate_head_icon()
	if(H)
		transfer_identity(H)

		name = "[H.real_name]'s head"

		H.regenerate_icons()

	if(brainmob)
		brainmob.stat = 2
		brainmob.death()

		if(brainmob.mind && brainmob.mind.special_role == HIGHLANDER)
			if(H.lastattacker && istype(H.lastattacker, /mob/living/carbon/human))
				var/mob/living/carbon/human/L = H.lastattacker
				if(L.mind && L.mind.special_role == HIGHLANDER)
					L.revive(0)
					to_chat(L, "<span class='notice'>You absorb \the [brainmob]'s power!</span>")
					var/turf/T1 = get_turf(H)
					make_tracker_effects(T1, L)

obj/item/organ/external/head/proc/transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->head
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob.languages = H.languages
	brainmob.default_language = H.default_language
	brainmob.container = src

obj/item/organ/external/head/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/scalpel) || istype(W,/obj/item/weapon/shard) || (istype(W,/obj/item/weapon/kitchen/utensil/knife/large) && !istype(W,/obj/item/weapon/kitchen/utensil/knife/large/butch)))
		if(organ_data)
			switch(brain_op_stage)
				if(0)
					user.visible_message("<span class='warning'>[user] cuts [brainmob]'s head open with \the [W].</span>", \
					"<span class='notice'>You cut [brainmob]'s open with \the [W]!</span>")

					brain_op_stage = 1

				if(2)
					user.visible_message("<span class='warning'>[user] severs [brainmob]'s brain connections delicately with \the [W].</span>", \
					"<span class='notice'>You sever [brainmob]'s brain connections delicately with \the [W]!</span>")

					brain_op_stage = 3.0

				else
					..()
		else
			to_chat(user, "<span class='warning'>That head has no brain to remove!</span>")

	else if(istype(W,/obj/item/weapon/circular_saw) || istype(W,/obj/item/weapon/kitchen/utensil/knife/large/butch) || istype(W,/obj/item/weapon/hatchet))
		if(organ_data)
			switch(brain_op_stage)
				if(1)
					user.visible_message("<span class='warning'>[user] saws [brainmob]'s head open with \the [W].</span>", \
					"<span class='notice'>You saw [brainmob]'s head open with \the [W].</span>")

					brain_op_stage = 2
				if(3)
					user.visible_message("<span class='warning'>[user] severs [brainmob]'s spine connections delicately with \the [W].</span>", \
					"<span class='notice'>You sever [brainmob]'s spine connections delicately with \the [W]!</span>")

					user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [brainmob.name] ([brainmob.ckey]) with [W.name] (INTENT: [uppertext(user.a_intent)])</font>"
					brainmob.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [W.name] (INTENT: [uppertext(user.a_intent)])</font>"
					msg_admin_attack("[user] ([user.ckey]) debrained [brainmob] ([brainmob.ckey]) (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

					//TODO: ORGAN REMOVAL UPDATE.
					var/turf/T = get_turf(src)
					if(isatom(organ_data.removed_type))
						var/obj/I = organ_data.removed_type
						if(istype(organ_data.removed_type, /obj/item/device/mmi/posibrain))
							var/obj/item/device/mmi/posibrain/B = organ_data.removed_type
							B.transfer_identity(brainmob)
						else if(istype(organ_data.removed_type, /obj/item/organ/internal/brain))
							var/obj/item/organ/internal/brain/B = organ_data.removed_type
							B.transfer_identity(brainmob)
						I.forceMove(T)
					else
						var/obj/item/organ/internal/brain/B = new organ_data.removed_type(T)
						B.transfer_identity(brainmob)

					if(borer)
						borer.detach()

					brain_op_stage = 4.0
					organ_data = null
				else
					..()
		else
			to_chat(user, "<span class='warning'>That head has no brain to remove!</span>")
	else if(istype(W,/obj/item/device/soulstone))
		W.capture_soul_head(src,user)
		return
	else if(istype(W,/obj/item/device/healthanalyzer))
		to_chat(user, "<span class='notice'>You use \the [W] to induce a small electric shock into \the [src].</span>")
		playsound(src,'sound/weapons/electriczap.ogg',50,1)
		animate(src, pixel_x = pixel_x + rand(-2,2), pixel_y = pixel_y + rand(-2,2) , time = 0.5 SECONDS, easing = BOUNCE_EASING) //Give it a little shake
		animate(src, pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 0.5 SECONDS, easing = LINEAR_EASING) //Then calm it down
		if(!organ_data)
			to_chat(user, "<span class='warning'>\The [src] has no brain!</span>")
			return
		if(brainmob)
			var/mind_found = 0
			if(brainmob.client)
				mind_found = 1
				to_chat(user, "<span class='notice'>[pick("The eyes","The jaw","The ears")] of \the [src] twitch ever so slightly.</span>")
			else
				var/mob/dead/observer/ghost = mind_can_reenter(brainmob.mind)
				if(ghost)
					var/mob/ghostmob = ghost.get_top_transmogrification()
					if(ghostmob)//Lights are on but no-one's home
						mind_found = 1
						to_chat(user, "<span class='notice'>\The [src] stares blankly forward. The pupils dilate but otherwise it does not react to stimuli.</span>")
						ghostmob << 'sound/effects/adminhelp.ogg'
						to_chat(ghostmob, "<span class='interface big'><span class='bold'>Someone has found your head. Return to it if you want to be resurrected!</span> \
							(Verbs -> Ghost -> Re-enter corpse, or <a href='?src=\ref[ghost];reentercorpse=1'>click here!</a>)</span>")
			if(!mind_found)
				to_chat(user, "<span class='danger'>\The [src] seems unresponsive to shock stimuli.</span>")
		else
			to_chat(user, "<span class='danger'>\The [src] seems unresponsive to shock stimuli.</span>")
		return
	else
		..()

obj/item/organ/external/head/Destroy()
	if(brainmob)
		brainmob.ghostize()
	if(origin_body)
		origin_body.decapitated = null
		origin_body = null
	..()

/mob/living/carbon/human/find_organ_by_grasp_index(index)
	for(var/datum/organ/external/OE in grasp_organs)
		if(OE.grasp_id == index && OE.can_grasp)
			return OE
	return null

/mob/living/carbon/human/has_hand_check()
	for(var/datum/organ/external/OE in grasp_organs)
		if(OE.can_grasp())
			return TRUE
	return FALSE

/datum/organ/external/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"damage_state",
		"brute_dam",
		"burn_dam",
		"last_dam",
		"wounds",
		"number_wounds",
		"perma_injury",
		"parent",
		"children",
		"internal_organs",
		"open",
		"stage",
		"cavity",
		"sabotaged",
		"encased",
		"implants")

	reset_vars_after_duration(resettable_vars, duration)
	for(var/datum/wound/W in wounds)
		W.send_to_past(duration)
