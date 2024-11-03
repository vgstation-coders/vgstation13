/mob/living/New()
	..()

	if(!species_type)
		species_type = src.type
	if(can_butcher && !meat_amount)
		meat_amount = size

	immune_system = new (src)
	oxy_damage_modifier *= (maxHealth / 100) //Scale oxy damage based on the max health of the mob.

/mob/living/create_reagents(const/max_vol)
	..(max_vol)
	addicted_chems = new /datum/reagents(max_vol)
	addicted_chems.my_atom = src
	tolerated_chems = list()

/mob/living/Destroy()
	if(butchering_drops)
		for(var/datum/butchering_product/B in butchering_drops)
			butchering_drops -= B
			QDEL_NULL(B)

	if(immune_system)
		QDEL_NULL(immune_system)

	if(addicted_chems)
		QDEL_NULL(addicted_chems)
	. = ..()

/mob/living/examine(var/mob/user, var/size = "", var/show_name = TRUE, var/show_icon = TRUE) //Show the mob's size and whether it's been butchered
	switch(src.size)
		if(SIZE_TINY)
			size = "tiny"
		if(SIZE_SMALL)
			size = "small"
		if(SIZE_NORMAL)
			size = "average in size"
		if(SIZE_BIG)
			size = "big"
		if(SIZE_HUGE)
			size = "huge"

	var/pronoun = "it is"
	switch(gender)
		if(FEMALE)
			pronoun = "she is"
		if(MALE)
			pronoun = "he is"
		if(PLURAL)
			pronoun = "they are"

	..(user, " [capitalize(pronoun)] [size].", show_name, FALSE)
	if(meat_taken > 0)
		to_chat(user, "<span class='info'>[capitalize(pronoun)] partially butchered.</span>")

	var/butchery = "" //More information about butchering status, check out "code/datums/helper_datums/butchering.dm"

	if(butchering_drops && butchering_drops.len)
		for(var/datum/butchering_product/B in butchering_drops)
			butchery = "[butchery][B.desc_modifier(src)]"
	if(butchery)
		to_chat(user, "<span class='info'>[butchery]</span>")

/mob/living/Life()
	if(timestopped)
		return 0 //under effects of time magick

	..()
	if (flags & INVULNERABLE)
		bodytemperature = initial(bodytemperature)
	if (monkeyizing)
		return 0
	if(!loc)
		return 0	// Fixing a null error that occurs when the mob isn't found in the world -- TLE
	// Why the fuck is this handled here?
	if(reagents && reagents.has_reagent(BUSTANUT))
		if(!(M_HARDCORE in mutations))
			mutations.Add(M_HARDCORE)
			to_chat(src, "<span class='notice'>You feel like you're the best around.  Nothing's going to get you down.</span>")
	else
		if(M_HARDCORE in mutations)
			mutations.Remove(M_HARDCORE)
			to_chat(src, "<span class='notice'>You feel like a pleb.</span>")
	handle_beams()
	if(istype(get_turf(src),/turf/unsimulated/floor/brimstone))
		FireBurn(11, 9001, ONE_ATMOSPHERE) // lag free weird way of doing it
		fire_stacks = 11
		ignite() // ffffFIRE!!!! FIRE!!! FIRE!!
	return 1

// Apply connect damage
/mob/living/beam_connect(var/obj/effect/beam/B)
	..()
	last_beamchecks["\ref[B]"]=world.time

/mob/living/beam_disconnect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)
	last_beamchecks.Remove("\ref[B]") // RIP

/mob/living/handle_beams()
	if(flags & INVULNERABLE)
		return
	// New beam damage code (per-tick)
	for(var/obj/effect/beam/B in beams)
		apply_beam_damage(B)

/mob/living/cultify()
	if(islegacycultist(src) && client)
		var/mob/living/simple_animal/construct/harvester/C = new /mob/living/simple_animal/construct/harvester(get_turf(src))
		mind.transfer_to(C)
		to_chat(C, "<span class='sinister'>The Geometer of Blood is overjoyed to be reunited with its followers, and accepts your body in sacrifice. As reward, you have been gifted with the shell of an Harvester.<br>Your tendrils can use and draw runes without need for a tome, your eyes can see beings through walls, and your mind can open any door. Use these assets to serve Nar-Sie and bring him any remaining living human in the world.<br>You can teleport yourself back to Nar-Sie along with any being under yourself at any time using your \"Harvest\" spell.</span>")
		dust()
	else if(!iscultist(src))
		if(client)
			var/datum/faction/cult/narsie/cult_fact = find_active_faction_by_type(/datum/faction/cult/narsie)
			if (cult_fact)
				cult_fact.harvested++
			var/mob/dead/G = (ghostize())
			G.icon = 'icons/mob/mob.dmi'
			G.icon_state = "ghost-narsie"
			G.overlays = 0
			if(istype(G.mind.current, /mob/living/carbon/human/))
				var/mob/living/carbon/human/H = G.mind.current
				G.overlays += H.overlays_standing[ID_LAYER]
				G.overlays += H.overlays_standing[EARS_LAYER]
				G.overlays += H.overlays_standing[SUIT_LAYER]
				G.overlays += H.overlays_standing[GLASSES_LAYER]
				G.overlays += H.overlays_standing[GLASSES_OVER_HAIR_LAYER]
				G.overlays += H.overlays_standing[BELT_LAYER]
				G.overlays += H.overlays_standing[BACK_LAYER]
				G.overlays += H.overlays_standing[HEAD_LAYER]
				G.overlays += H.overlays_standing[HANDCUFF_LAYER]
			G.invisibility = 0
			to_chat(G, "<span class='sinister'>You feel relieved as what's left of your soul finally escapes its prison of flesh.</span>")
		spawn(1)
			gib()

/mob/living/apply_beam_damage(var/obj/effect/beam/B)
	var/lastcheck=last_beamchecks["\ref[B]"]
	// Figure out how much damage to deal.
	// Formula: (deciseconds_since_connect/10 deciseconds)*B.get_damage()
	var/damage = ((world.time - lastcheck)/10)  * B.get_damage() * beam_defense(B)

	// Actually apply damage
	apply_damage(damage, B.damage_type, B.def_zone)

	// Emitter attack logging. Only when source of emitter beam is /mob/living and there's a ckey in either
	if (B.sources.len >= 1 && (isliving(B.sources[1])))
		var/mob/living/assailant = B.sources[1]
		if (assailant.ckey || src.ckey)
			log_attack("<font color='red'>[assailant.name][assailant.ckey ? "([assailant.ckey])" : "(no key)"] attacked [src.name][src.ckey ? "([src.ckey])" : "(no key)"] with [B.name] ([damage] damage)</font>")

	// Update check time.
	last_beamchecks["\ref[B]"]=world.time

//Return multiplier for damage
/mob/living/proc/beam_defense(var/obj/effect/beam/B)
	return 1

/mob/living/verb/succumb()
	set hidden = 1
	succumb_proc(0)

/mob/living/proc/succumb_proc(var/gibbed = 0, var/from_deathgasp = FALSE)
	if (src.health < 0 && stat != DEAD)
		src.attack_log += "[src] has succumbed to death with [health] points of health!"
		src.apply_damage(maxHealth + src.health, OXY)
		if (!from_deathgasp)
			emote("deathgasp", message = TRUE)
		death(gibbed)
		to_chat(src, "<span class='info'>You have given up life and succumbed to death.</span>")


/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else if(!(flags & INVULNERABLE))
		var/prevhealth = health
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss
		critlog(health,prevhealth)

//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(var/pressure)
	return 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
//		to_chat(world, "DEBUG: burn_skin(), mutations=[mutations]")
		if(M_NO_SHOCK in src.mutations) //shockproof
			return 0
		if (M_RESIST_HEAT in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/extradam = 0	//added to when organ is at max dam
		for(var/datum/organ/external/affecting in H.organs)
			if(!affecting)
				continue
			if(affecting.take_damage(0, divided_damage+extradam))	//TODO: fix the extradam stuff. Or, ebtter yet...rewrite this entire proc ~Carn
				H.UpdateDamageIcon()
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/carbon/monkey))
		if (M_RESIST_HEAT in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.adjustFireLoss(burn_amount)
		M.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		to_chat(world, "[src] ~ [src.bodytemperature] ~ [temperature]")
	return temperature


/mob/living/proc/getBruteLoss(var/ignore_inorganic)
	return bruteloss

/mob/living/proc/adjustBruteLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode

	if(INVOKE_EVENT(src, /event/damaged, "kind" = BRUTE, "amount" = amount))
		return 0

	bruteloss = min(max(bruteloss + (amount * brute_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode

	if(INVOKE_EVENT(src, /event/damaged, "kind" = OXY, "amount" = amount))
		return 0

	oxyloss = min(max(oxyloss + (amount * oxy_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/setOxyLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode
	oxyloss = amount

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode

	if(INVOKE_EVENT(src, /event/damaged, "kind" = TOX, "amount" = amount))
		return 0

	var/mult = 1
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.species.tox_mod)
			mult = H.species.tox_mod
		var/datum/organ/internal/heart/hivelord/HL = H.get_heart()
		if(istype(HL) && amount < 0) // hivelord hearts just heal better
			mult *= 2

	toxloss = min(max(toxloss + (amount * tox_damage_modifier * mult), 0),(maxHealth*2))

/mob/living/proc/setToxLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode
	toxloss = amount

/mob/living/proc/getFireLoss(var/ignore_inorganic)
	return fireloss

/mob/living/proc/adjustFireLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode
	if(mutations.Find(M_RESIST_HEAT))
		return 0
	if(INVOKE_EVENT(src, /event/damaged, "kind" = BURN, "amount" = amount))
		return 0

	fireloss = min(max(fireloss + (amount * burn_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode

	if(INVOKE_EVENT(src, /event/damaged, "kind" = CLONE, "amount" = amount))
		return 0

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(isslimeperson(H))
			amount = min(amount, 0)

	cloneloss = min(max(cloneloss + (amount * clone_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/setCloneLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode
	cloneloss = amount

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode

	if(INVOKE_EVENT(src, /event/damaged, "kind" = BRAIN, "amount" = amount))
		return 0

	brainloss = min(max(brainloss + (amount * brain_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/setBrainLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode
	brainloss = amount

/mob/living/proc/getHalLoss()
	return halloss

/mob/living/proc/adjustHalLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode
	halloss = min(max(halloss + (amount * hal_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/setHalLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode
	halloss = amount

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(var/newMaxHealth)
	maxHealth = newMaxHealth

/mob/living/proc/get_butchering_products()
	return list()

// ++++ROCKDTBEN++++ MOB PROCS //END


/mob/proc/get_contents()



//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/weapon/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/weapon/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/weapon/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/delivery/D in Storage.return_inv()) //Check for package wrapped items
			for(var/atom/movable/wrapped in D) //Basically always only one thing, but could theoretically be more
				L += wrapped
				if(istype(wrapped, /obj/item/weapon/storage)) //this should never happen
					L += get_contents(wrapped)
		return L

	else

		L += src.contents
		for(var/obj/item/weapon/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/clothing/suit/storage/S in src.contents)//Check for labcoats and jackets
			L += get_contents(S.hold)
		for(var/obj/item/clothing/accessory/storage/S in src.contents)//Check for holsters
			L += get_contents(S.hold)
		for(var/obj/item/weapon/gift/G in src.contents) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/delivery/D in src.contents) //Check for package wrapped items
			for(var/atom/movable/wrapped in D) //Basically always only one thing, but could theoretically be more
				L += wrapped
				if(istype(wrapped, /obj/item/weapon/storage)) //this should never happen
					L += get_contents(wrapped)
		return L

/mob/living/proc/electrocute_act(const/shock_damage, const/obj/source, const/siemens_coeff = 1.0)
	if(status_flags & GODMODE || (M_NO_SHOCK in src.mutations))
		return 0

	var/damage = shock_damage * siemens_coeff

	if(damage <= 0)
		damage = 0

	adjustFireLoss(damage)

	return damage

/mob/living/emp_act(severity)
	for(var/obj/item/stickybomb/B in src)
		if(B.stuck_to)
			visible_message("<span class='warning'>\The [B] stuck on \the [src] suddenly deactivates itself and falls to the ground.</span>")
			B.deactivate()
			B.unstick()

	if(flags & INVULNERABLE)
		return

	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/mob/living/proc/get_organ(zone)
	RETURN_TYPE(/datum/organ/external)
	return

//A proc that turns organ strings into a list of organ datums
//The organ strings can be fed in as arguments, or as a list
/mob/living/proc/get_organs(organs)
	return list()

/mob/living/proc/get_organ_target()
	var/t = src.zone_sel.selecting
	if ((t in list( "eyes", "mouth" )))
		t = LIMB_HEAD
	var/datum/organ/external/def_zone = ran_zone(t)
	return def_zone


// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(var/brute, var/burn, var/ignore_inorganics = FALSE)
	if(status_flags & GODMODE)
		return 0	//godmode
	if(flags & INVULNERABLE)
		return 0
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn, var/used_weapon = null)
	if(status_flags & GODMODE)
		return 0	//godmode
	if(flags & INVULNERABLE)
		return 0
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

	return brute + burn


/mob/living/proc/restore_all_organs()
	return

/*
NOTE TO ANYONE MAKING A PROC THAT USES REVIVE/REJUVENATE:
If the proc calling either of these is:
	-meant to be an admin/overpowered revival proc, make sure you set suiciding = 0
	-meant to be something that a player uses to heal/revive themself or others, check if suiciding = 1 and prevent them from reviving if true.
Thanks.
*/

/mob/living/proc/revive(animation = 0)
	rejuvenate(animation)
	/*
	locked_to = initial(src.locked_to)
	*/
	if(iscarbon(src))
		var/mob/living/carbon/C = src

		if(C.handcuffed)
			C.drop_from_inventory(C.handcuffed)

		if (C.mutual_handcuffs)
			C.drop_from_inventory(C.mutual_handcuffs)

		if (C.legcuffed)
			C.drop_from_inventory(C.legcuffed)
	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD

/mob/living/proc/rejuvenate(animation = 0)
	var/turf/T = get_turf(src)
	if(animation)
		T.turf_animation('icons/effects/64x64.dmi',"rejuvenate",-16,0,MOB_LAYER+1,'sound/effects/rejuvenate.ogg',anim_plane = EFFECTS_PLANE)

	// shut down various types of badness
	toxloss = 0
	oxyloss = 0
	cloneloss = 0
	bruteloss = 0
	fireloss = 0
	brainloss = 0
	halloss = 0
	paralysis = 0
	stunned = 0
	knockdown = 0
	remove_jitter()
	dizziness = 0
	confused = 0
	germ_level = 0
	next_pain_time = 0
	radiation = 0
	rad_tick = 0
	nutrition = 400
	bodytemperature = 310
	sdisabilities = 0
	disabilities = 0
	blinded = 0
	eye_blind = 0
	eye_blurry = 0
	ear_deaf = 0
	ear_damage = 0
	say_mute = 0
	said_last_words = 0
	mutations.Remove(M_HUSK)
	if(!reagents)
		create_reagents(1000)
	else
		reagents.clear_reagents()
	heal_overall_damage(1000, 1000)
	extinguish()
	fire_stacks = 0
	/*
	if(locked_to)
		locked_to.unbuckle()
	locked_to = initial(src.locked_to)
	*/
	if(istype(src, /mob/living/carbon))
		var/mob/living/carbon/C = src
		dead_mob_list -= C
		living_mob_list |= list(C)

	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		H.timeofdeath = 0
		H.vessel.reagent_list = list()
		H.vessel.add_reagent(BLOOD,560)
		H.pain_shock_stage = 0
		for(var/organ_name in H.organs_by_name)
			var/datum/organ/external/O = H.organs_by_name[organ_name]
			for(var/obj/item/weapon/shard/shrapnel/s in O.implants)
				if(istype(s))
					O.implants -= s
					H.contents -= s
					QDEL_NULL(s)
			O.amputated = 0
			O.brute_dam = 0
			O.burn_dam = 0
			O.damage_state = "00"
			O.germ_level = 0
			O.hidden = null
			O.number_wounds = 0
			O.open = 0
			O.perma_injury = 0
			O.stage = 0
			O.status = 0
			O.trace_chemicals = list()
			O.wounds = list()
			O.wound_update_accuracy = 1
		for(var/organ_name in H.internal_organs_by_name)
			var/datum/organ/internal/IO = H.internal_organs_by_name[organ_name]
			IO.damage = 0
			IO.trace_chemicals.len = 0
			IO.germ_level = 0
			IO.status = 0
			IO.robotic = 0
		H.updatehealth()
		H.op_stage.butt = SURGERY_HAS_A_BUTT
		H.op_stage.butt_replace = SURGERY_BEGIN_BUTT_REPLACE

	for(var/datum/disease/D in viruses)
		D.cure(0)
	for (var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		V.cure(src)
	if(stat == DEAD)
		resurrect()
		tod = null

	// restore us to conciousness
	stat = CONSCIOUS

	//Snowflake fix for zombiepowder
	status_flags &= ~FAKEDEATH

	// make the icons look correct
	regenerate_icons()
	update_canmove()

	clear_fullscreens()

	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD

/mob/living/proc/UpdateDamageIcon()
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
			to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
		else
			to_chat(usr, "[src] does not have any stored infomation!")
	else
		to_chat(usr, "OOC Metadata is not supported by this server!")

	return

/mob/living/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	if (locked_to && locked_to.loc != NewLoc)
		var/datum/locking_category/category = locked_to.get_lock_cat_for(src)
		if (locked_to.anchored || category.flags & CANT_BE_MOVED_BY_LOCKED_MOBS)
			return 0
		else
			return locked_to.Move(NewLoc, Dir)

	if (restrained())
		stop_pulling()

	var/turf/T = loc

	var/t7 = 1 //What the FUCK is this variable?
	if (restrained())
		for(var/mob/living/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained())))
				t7 = null
	if (t7 && pulling && (Adjacent(pulling) || pulling.loc == loc))
		. = ..()

		if (pulling && pulling.loc)
			if(!isturf(pulling.loc))
				stop_pulling()
				return
			else
				if(Debug)
					diary <<"pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			stop_pulling()
			return

		var/mob/living/M = pulling
		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if(!istype(pulling) || !pulling)
					if (iscarbon(src))
						var/mob/living/carbon/carbon = src
						if (!carbon.mutual_handcuffed_to)
							WARNING("Pulling disappeared! pulling = [pulling] old pulling = [M]")
				else if(isturf(pulling.loc))
					if (isliving(pulling))
						M = pulling
						var/ok = 1
						if (locate(/obj/item/weapon/grab, M.grabbed_by))
							if (prob(75))
								var/obj/item/weapon/grab/G = pick(M.grabbed_by)
								if (istype(G, /obj/item/weapon/grab))
									visible_message("<span class='danger'>[src] has pulled [G.affecting] from [G.assailant]'s grip.</span>",
										drugged_message="<span class='danger'>[src] has pulled [G.affecting] from [G.assailant]'s hug.</span>")
									qdel(G)
							else
								ok = 0
							if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
								ok = 0
						if (ok)
							var/atom/movable/secondarypull = M.pulling
							M.stop_pulling()
							INVOKE_EVENT(src, /event/before_move)
							pulling.Move(T, get_dir(pulling, T), glide_size_override = src.glide_size)
							INVOKE_EVENT(src, /event/after_move)
							if(M && secondarypull)
								M.start_pulling(secondarypull)
					else
						if (pulling)
							pulling.Move(T, get_dir(pulling, T), glide_size_override = src.glide_size)
				else
					stop_pulling()
	else
		stop_pulling()
		. = ..()

	if (s_active && !is_holder_of(src, s_active) && !s_active.Adjacent(src))
		s_active.close(src)

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)

	if(T != loc)
		handle_hookchain(Dir)

	if(.)
		for(var/obj/item/weapon/gun/G in targeted_by) //Handle moving out of the gunner's view.
			var/mob/living/M = G.loc
			if(!(M in view(src)))
				NotTargeted(G)
		for(var/obj/item/weapon/gun/G in src) //Handle the gunner losing sight of their target/s
			if(G.target)
				for(var/mob/living/M in G.target)
					if(M && !(M in view(src)))
						M.NotTargeted(G)

/mob/living/proc/handle_hookchain(var/direct)
	for(var/obj/item/weapon/gun/hookshot/hookshot in src)
		if(hookshot.clockwerk)
			continue

		for(var/i = 1;i<hookshot.maxlength;i++)
			var/obj/effect/overlay/hookchain/HC = hookshot.links["[i]"]
			if(HC.loc != hookshot)
				HC.Move(get_step(HC,direct),direct)

		if(hookshot.hook)
			var/obj/item/projectile/hookshot/hook = hookshot.hook
			hook.Move(get_step(hook,direct),direct)
			if(direct & NORTH)
				hook.override_starting_Y++
				hook.override_target_Y++
			if(direct & SOUTH)
				hook.override_starting_Y--
				hook.override_target_Y--
			if(direct & EAST)
				hook.override_starting_X++
				hook.override_target_X++
			if(direct & WEST)
				hook.override_starting_X--
				hook.override_target_X--

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.special_delayer.blocked())
		return

	var/turf/T = get_turf(src)

	INVOKE_EVENT(src, /event/resist, "user" = src)

	delayNextSpecial(10) // Special delay, a cooldown to prevent spamming too much.

	var/mob/living/L = usr

	//Escaping from within a subspace tunneler.
	var/obj/item/weapon/subspacetunneler/inside_tunneler = get_holder_of_type(L, /obj/item/weapon/subspacetunneler)
	if(inside_tunneler)
		var/breakout_time = 0.5 //30 seconds by default
		L.visible_message("<span class='danger'>\The [inside_tunneler]'s storage bin shudders.</span>","<span class='warning'>You wander through subspace, looking for a way out (this will take about [breakout_time * 60] seconds).</span>")
		spawn(0)
			if(do_after(usr,src,breakout_time * 60 * 10)) //minutes * 60seconds * 10deciseconds
				var/obj/item/weapon/subspacetunneler/still_in = get_holder_of_type(L, /obj/item/weapon/subspacetunneler)
				if(!inside_tunneler || !L || L.stat != CONSCIOUS || !still_in) //tunneler/user destroyed OR user dead/unconcious OR user no longer in tunneler
					return

				//Well then break it!
				inside_tunneler.break_out(L)
		return

	//Getting out of someone's inventory.
	if(istype(src.loc,/obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.loc
		forceMove(T)
		if(istype(H.loc, /mob/living))
			var/mob/living/Location = H.loc
			Location.drop_from_inventory(H)
		QDEL_NULL(H)
		return
	else if(istype(src.loc, /obj/structure/strange_present))
		var/obj/structure/strange_present/present = src.loc
		to_chat(L, "<span class='warning'>You attempt to unwrap yourself, these wraps are tight and will take some time.</span>")
		if(do_after(src, src, 2 MINUTES))
			L.visible_message("<span class='danger'>[L] successfully breaks out of [present]!</span>",\
							  "<span class='notice'>You successfully break out!</span>")
			forceMove(T)
			qdel(present)
			playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
		return
	else if(istype(src.loc, /obj/item/delivery/large)) //Syndie item
		var/obj/item/delivery/large/package = src.loc
		to_chat(L, "<span class='warning'>You attempt to unwrap yourself, this package is tight and will take some time.</span>")
		if(do_after(src, src, 2 MINUTES))
			L.visible_message("<span class='danger'>[L] successfully breaks out of [package]!</span>",\
							  "<span class='notice'>You successfully break out!</span>")
			forceMove(T)
			qdel(package)
			playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
		return
	else if(istype(src.loc, /obj/effect/spider/cocoon))
		var/obj/effect/spider/cocoon/cocoon = src.loc
		to_chat(L, "<span class='warning'>You attempt to untangle yourself, the webs are tight and will take some time.</span>")
		if(do_after(src, src, 2 MINUTES))
			L.visible_message("<span class='danger'>[L] successfully breaks out of [cocoon]!</span>",\
							  "<span class='notice'>You successfully break out!</span>")
			forceMove(T)
			qdel(cocoon)

	//Detaching yourself from a tether
	if(L.tether)
		var/mob/living/carbon/CM = L
		if(!istype(CM) || !CM.handcuffed)
			var/datum/chain/tether_datum = L.tether.chain_datum
			if(tether_datum.extremity_B == src)
				L.visible_message("<span class='danger'>\The [L] quickly grabs and removes \the [L.tether] tethered to his body!</span>",
							  "<span class='warning'>You quickly grab and remove \the [L.tether] tethered to your body.</span>")
				L.tether = null
				tether_datum.extremity_B = null
				tether_datum.rewind_chain()

	//Trying to unstick a stickybomb
	for(var/obj/item/stickybomb/B in L)
		if(B.stuck_to)
			L.visible_message("<span class='danger'>\The [L] is trying to reach and pull off \the [B] stuck on his body!</span>",
						  "<span class='warning'>You reach for \the [B] stuck on your body and start pulling.</span>")
			if(do_after(L, src, 30, 10, FALSE))
				L.visible_message("<span class='danger'>After struggling for an instant, \the [L] manages unstick \the [B] from his body!</span>",
						  "<span class='warning'>It came off!</span>")
				L.put_in_hands(B)
				B.unstick(0)
			else
				to_chat(L, "<span class='warning'>You need to stop moving around while you try to get a hold of \the [B]!</span>")
			return
		else
			continue

	//Resisting control by an alien mind.
	if(istype(src.loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = src.loc
		var/mob/living/captive_brain/H = src

		H.simple_message("<span class='danger'>You begin doggedly resisting the parasite's control (this will take approximately sixty seconds).</span>",\
			"<span class='danger'>You attempt to remember who you are and how the heck did you get here (this will probably take a while).</span>")
		to_chat(B.host, "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>")

		spawn(rand(350,450)+B.host.brainloss)

			if(!B || !B.controlling)
				return

			B.host.adjustBrainLoss(rand(5,10))
			H.simple_message("<span class='danger'>With an immense exertion of will, you regain control of your body!</span>")
			to_chat(B.host, "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>")

			var/mob/living/carbon/C=B.host
			C.do_release_control(0) // Was detach().

			return

	//resisting grabs (as if it helps anyone...)
	if ((!(L.stat) && L.canmove && !(L.restrained())))
		var/resisting = 0
		for(var/obj/O in L.requests)
			L.requests.Remove(O)
			QDEL_NULL(O)
			resisting++
		for(var/obj/item/weapon/grab/G in usr.grabbed_by)
			resisting++
			if (G.state == GRAB_PASSIVE)
				qdel(G)
			else
				if (G.state == GRAB_AGGRESSIVE)
					if (prob(25))
						L.visible_message("<span class='danger'>[L] has broken free of [G.assailant]'s grip!</span>", \
							drugged_message="<span class='danger'>[L] has broken free of [G.assailant]'s hug!</span>")
						qdel(G)
				else
					if (G.state == GRAB_NECK)
						if (prob(5))
							L.visible_message("<span class='danger'>[L] has broken free of [G.assailant]'s headlock!</span>", \
								drugged_message="<span class='danger'>[L] has broken free of [G.assailant]'s passionate hug!</span>")
							qdel(G)
		if(resisting)
			L.visible_message("<span class='danger'>[L] resists!</span>")


	if(L.locked_to && !L.isUnconscious())
		// unbeartrapping yourself
		if (istype(L.locked_to, /obj/item/weapon/beartrap/))
			if (!iscarbon(L))
				L.locked_to.attack_hand(L)
				return
			else
				var/mob/living/carbon/C = L
				if (!C.handcuffed)
					L.locked_to.attack_hand(L)
					return
		//unbuckling yourself
		if(istype(L.locked_to, /obj/structure/bed))
			var/obj/structure/bed/B = L.locked_to
			if(istype(B, /obj/structure/bed/guillotine))
				var/obj/structure/bed/guillotine/G = B
				if(G.open)
					G.manual_unbuckle(L, resisting = TRUE)
				else
					L.visible_message("<span class='warning'>\The [L] attempts to dislodge \the [G]'s stocks!</span>",
									  "<span class='warning'>You attempt to dislodge \the [G]'s stocks (this will take around thirty seconds).</span>",
									  self_drugged_message="<span class='warning'>You attempt to chew through the wooden stocks of \the [G] (this will take a while).</span>")
					spawn(0)
						if(do_after(usr, usr, 30 SECONDS))
							if(!L.locked_to)
								return
							L.visible_message("<span class='danger'>\The [L] dislodges \the [G]'s stocks and climbs out of \the [src]!</span>",\
								"<span class='notice'>You dislodge \the [G]'s stocks and climb out of \the [G].</span>",\
								self_drugged_message="<span class='notice'>You successfully chew through the wooden stocks.</span>")
							G.open = TRUE
							G.manual_unbuckle(L, resisting = TRUE)
							G.update_icon()
							G.verbs -= /obj/structure/bed/guillotine/verb/open_stocks
							G.verbs += /obj/structure/bed/guillotine/verb/close_stocks
						else
							L.simple_message("<span class='warning'>Your escape attempt was interrupted.</span>", \
								"<span class='warning'>Your chewing was interrupted. Damn it!</span>")

			else if(iscarbon(L))
				var/mob/living/carbon/C = L
				if(C.restrained())
					if(isalienadult(C) || (M_HULK in usr.mutations))
						C.visible_message("<span class='warning'>[C] is trying to forcefully unbuckle!</span>",
						                   "<span class='warning'>You attempt to forcefully unbuckle (This will take around five seconds).</span>")
						spawn(0) // I have no idea what this is supposed to actually do but everything else has it so why not
							if(do_after(C, C, 5 SECONDS))
								if(!C.handcuffed || !C.locked_to)
									return
								C.visible_message("<span class='danger'>[C] manages to forcefully unbuckle!</span>",
								                  "<span class='notice'>You successfully forcefully unbuckle.</span>")
								if(!isalien(C))
									C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
								B.manual_unbuckle(C, resisting = TRUE)
							else
								to_chat(C, "<span class='warning'>Your unbuckling attempt was interrupted.</span>")
					else
						C.visible_message("<span class='warning'>[C] attempts to unbuckle themself!</span>",
						                  "<span class='warning'>You attempt to unbuckle yourself (this will take around one minute, and you need to stay still).</span>",
						                   self_drugged_message="<span class='warning'>You attempt to regain control of your legs (this will take a while).</span>")
						spawn(0)
							if(do_after(usr, usr, 1 MINUTES))
								if(!C.locked_to)
									return
								C.visible_message("<span class='danger'>[C] manages to unbuckle themself!</span>",\
								                  "<span class='notice'>You successfully unbuckle yourself.</span>",\
								self_drugged_message="<span class='notice'>You successfully regain control of your legs and stand up.</span>")
								B.manual_unbuckle(C, resisting = TRUE)
							else
								C.simple_message("<span class='warning'>Your unbuckling attempt was interrupted.</span>", \
									"<span class='warning'>Your attempt to regain control of your legs was interrupted. Damn it!</span>")

				else
					B.manual_unbuckle(L)
		//release from kudzu
		/*else if(istype(L.locked_to, /obj/effect/plantsegment))
			var/obj/effect/plantsegment/K = L.locked_to
			K.manual_unbuckle(L)*/

	//Breaking out of a locker?
	if(src.loc && (istype(src.loc, /obj/structure/closet)))
		var/breakout_time = 2 //2 minutes by default

		var/obj/structure/closet/C = L.loc
		if(C.opened)
			return //Door's open... wait, why are you in it's contents then?
		if(istype(C.loc, /obj/structure/rack/crate_shelf) && istype(C,/obj/structure/closet/crate))
			var/obj/structure/closet/crate/R = C
			var/obj/structure/rack/crate_shelf/CS = C.loc
			CS.relay_container_resist_act(src,R)
			return
		if(istype(C.loc, /obj/spacepod/) && istype(C,/obj/structure/closet/crate)) //todo - make this generic for future space pod cargo systems
			var/obj/structure/closet/crate/R = C
			var/obj/spacepod/speesepod = C.loc
			speesepod.attempt_cargo_resist(src,R)
			return
		if(!istype(C.loc, /obj/item/delivery/large)) //Wouldn't want to interrupt escaping being wrapped over the next few trivial checks
			if(istype(C, /obj/structure/closet/secure_closet))
				var/obj/structure/closet/secure_closet/SC = L.loc
				if(!SC.locked && !SC.welded)
					return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'
			else
				if(!C.welded)
					return //closed but not welded...

		//okay, so the closet is either welded or locked... resist!!!
		L.visible_message("<span class='danger'>\The [C] begins to shake violenty!</span>",
						  "<span class='warning'>You lean on the back of [C] and start pushing the door open (this will take about [breakout_time] minutes).</span>")
		spawn(0)
			if(do_after(usr, C, breakout_time * 60 * 10, 30, custom_checks = new /callback(C, /obj/structure/closet/proc/on_do_after))) 	//minutes * 60seconds * 10deciseconds
				if(!C || !L || L.stat != CONSCIOUS || L.loc != C || C.opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
					return

				if(!istype(C.loc, /obj/item/delivery/large)) //Wouldn't want to interrupt escaping being wrapped over the next few trivial checks
					//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
					if(istype(L.loc, /obj/structure/closet/secure_closet))
						var/obj/structure/closet/secure_closet/SC = L.loc
						if(!SC.locked && !SC.welded)
							return
					else
						if(!C.welded)
							return

				//Well then break it!
				if(istype(usr.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					SC.desc = "It appears to be broken."
					SC.icon_state = SC.icon_off
					flick(SC.icon_broken, SC)
					sleep(10)
					flick(SC.icon_broken, SC)
					sleep(10)
					SC.broken = SC.locked // If it's only welded just break the welding, dont break the lock.
					SC.locked = 0
					SC.welded = 0
					L.visible_message("<span class='danger'>[L] successfully breaks out of [SC]!</span>",
									  "<span class='notice'>You successfully break out!</span>")
					if(istype(SC.loc, /obj/item/delivery/large)) //Do this to prevent contents from being opened into nullspace (read: bluespace)
						var/obj/item/delivery/large/BD = SC.loc
						BD.attack_hand(usr)
					SC.open()
				else
					C.welded = 0
					L.visible_message("<span class='danger'>[L] successfully breaks out of [C]!</span>",
									  "<span class='notice'>You successfully break out!</span>")
					if(istype(C.loc, /obj/item/delivery/large)) //nullspace ect.. read the comment above
						var/obj/item/delivery/large/BD = C.loc
						BD.attack_hand(usr)
					C.open()

	//Removing a headcrab
	if(ishuman(L))
		var/on_head = L.get_item_by_slot(slot_head)
		if(istype(on_head, /obj/item/clothing/mask/facehugger/headcrab))
			var/obj/item/clothing/mask/facehugger/headcrab/crab = on_head
			if(crab.is_being_resisted)
				return
			crab.is_being_resisted = 1
			L.visible_message("<span class='danger'>[L.real_name] starts struggling to tear \the [crab] off of their head!</span>")
			if(do_after(L, crab, 3 SECONDS))
				var/rng = 50
				if(crab.stat == DEAD)
					rng = 100
				if(prob(rng))
					if(L.get_item_by_slot(slot_head) == crab)
						L.drop_from_inventory(crab)
						crab.GoIdle(10 SECONDS)
						L.visible_message("<span class='danger'>[L.real_name] successfully tears \the [crab] off of their head!</span>")
						crab.is_being_resisted = 0
						crab.escaping = 1
						crab.GoActive()
				else
					to_chat(L, "\The [crab] is latched on tight! Keep struggling!")
					crab.is_being_resisted = 0
					return
			crab.is_being_resisted = 0 //If the do_after is cancelled.

	// Breaking out of a cage
	if (src.locked_to && istype(src.locked_to, /obj/structure/cage))
		locked_to.attack_hand(src)
		return

	if(src.loc && istype(src.loc, /obj/item/mecha_parts/mecha_equipment/tool/jail))
		var/breakout_time = 30 SECONDS
		var/obj/item/mecha_parts/mecha_equipment/tool/jail/jailcell = src.loc
		L.visible_message("<span class='danger'>One of \the [src.loc]'s cells rattles.</span>","<span class='warning'>You press against the lid of \the [src.loc] and attempt to pop it open (this will take about [breakout_time/10] seconds).</span>")
		spawn(0)
			if(do_after(usr,src,breakout_time)) //minutes * 60seconds * 10deciseconds
				if(src.loc != jailcell || !L || L.stat != CONSCIOUS) //if we're no longer in that mounted cell OR user dead/unconcious
					return

				//Well then break it!
				jailcell.break_out(L)
		return

	if((L.loc && istype(L.loc, /obj/structure/inflatable/shelter)) || (L.loc && istype(L.loc, /obj/structure/reagent_dispensers/cauldron/barrel)))
		var/obj/O = L.loc
		O.container_resist(L)


	else if(iscarbon(L))
		var/mob/living/carbon/CM = L
	//putting out a fire
		if(CM.on_fire && CM.canmove && ((!locate(/obj/effect/fire) in loc) || !CM.handcuffed))	//No point in putting ourselves out if we'd just get set on fire again. Unless there's nothing more pressing to resist out of, in which case go nuts.
			CM.Knockdown(5)
			CM.Stun(5)
			playsound(CM.loc, 'sound/effects/bodyfall.ogg', 50, 1)
			CM.visible_message("<span class='danger'>[CM] rolls on the floor, trying to put themselves out!</span>",
							   "<span class='warning'>You stop, drop, and roll!</span>")

			for(var/i = 1 to CM.fire_stacks + 7)
				CM.dir = turn(CM.dir, pick(-90, 90))
				sleep(1 SECONDS)
			CM.fire_stacks = 0
			CM.visible_message("<span class='danger'>[CM] has successfully extinguished themselves!</span>","<span class='notice'>You extinguish yourself.</span>")
			extinguish()
			return

		CM.resist_restraints()

	//unsticking from a rooting trap, such as a sticky web or a blood nail
	if (istype(L.locked_to, /obj/effect/rooting_trap/))
		var/obj/effect/rooting_trap/RT = L.locked_to
		RT.unstick_attempt(L)

/mob/living/carbon/proc/resist_restraints()
	if(!canmove)
		return
	var/is_hulk = isalienadult(src) || (M_HULK in mutations)
	var/obj/item/cuffs
	var/resist_time = 2 MINUTES
	var/var_to_check // TOOD: Improve this once Lummox releases pointers?
	var/do_after_callback
	if(handcuffed)
		cuffs = handcuffed
		resist_time = cuffs.restraint_resist_time
		var_to_check = "handcuffed"
	else if(legcuffed)
		cuffs = legcuffed
		var/obj/item/weapon/legcuffs/legcuffs = cuffs
		resist_time = legcuffs.breakouttime
		var_to_check = "legcuffed"
	else if(mutual_handcuffs)
		cuffs = mutual_handcuffs
		resist_time = cuffs.restraint_resist_time/2 //it's only one cuff
		var_to_check = "mutual_handcuffs"
	else
		return
	if(is_hulk)
		resist_time = 5 SECONDS
	visible_message("<span class='danger'>[src] attempts to [is_hulk ? "break" : "remove"] \the [cuffs]!</span>",
					"<span class='warning'>You attempt to [is_hulk ? "break" : "remove"] \the [cuffs] (this will take around [resist_time / 10] seconds and you need to stand still).</span>",
					self_drugged_message="<span class='warning'>You attempt to regain control of your hands (this will take a while).</span>")
	spawn(0)
		if(do_after(src, src, resist_time, custom_checks = do_after_callback))
			if(vars[var_to_check] != cuffs || locked_to)
				return
			drop_from_inventory(cuffs)
			if(is_hulk)
				visible_message("<span class='danger'>[src] manages to break \the [cuffs]!</span>",
								"<span class='notice'>You successfully break \the [cuffs].</span>")
				if(!isalien(src))
					say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
				qdel(cuffs)
			else
				visible_message("<span class='danger'>[src] manages to remove \the [cuffs]!</span>",
								"<span class='notice'>You successfully remove \the [cuffs].</span>",
								self_drugged_message="<span class='notice'>You successfully regain control of your hands.</span>")
		else
			simple_message("<span class='warning'>Your attempt at [is_hulk ? "breaking" : "removing"] \the [cuffs] was interrupted.</span>",
							"<span class='warning'>Your attempt to regain control of your hands was interrupted. Damn it!</span>")

/mob/living/verb/lay_down()
	set name = "Rest"
	set category = "IC"

	if(client.move_delayer.blocked())
		return
	if(resting) /* If you're somehow already standing up while inside a crate (shouldn't happen), you can still rest. */
		if(istype(loc, /obj/structure/closet/crate))
			to_chat(src, "<span class='warning'>There isn't enough room to get up. Open the [loc.name] first!</span>")
			return

	rest_action()

/mob/living/proc/rest_action()
	delayNextMove(1)
	resting = !resting
	update_canmove()
	to_chat(src, "<span class='notice'>You are now [resting ? "resting" : "getting up"]</span>")

/mob/living/proc/has_brain()
	return 1

/mob/living/proc/has_attached_brain()
	return 1

/mob/living/proc/has_eyes()
	return 1

/mob/living/singularity_act()
	if(!(src.flags & INVULNERABLE))
		var/gain = 20
		investigation_log(I_SINGULO,"has been consumed by a singularity")
		gib()
		return(gain)

/mob/living/singularity_pull(S, current_size, repel = FALSE)
	if(!(src.flags & INVULNERABLE))
		if(!repel)
			step_towards(src, S)
		else
			step_away(src, S)

//shuttle_act is called when a shuttle collides with the mob
/mob/living/shuttle_act(datum/shuttle/S)
	if(!(src.flags & INVULNERABLE))
		src.attack_log += "\[[time_stamp()]\] was gibbed by a shuttle ([S.name], [S.type])!"
		gib()
	return

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"
	if(AM.Adjacent(src))
		src.start_pulling(AM)
	return

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in tview(src))
	if(src.incapacitated())
		return 0
	if(!..())
		return 0
	var/turf/T = get_turf(src)
	T.visible_message("[pointToMessage(src, A)]")
	return 1

/mob/living/proc/pointToMessage(var/pointer, var/pointed_at)
	return "<b>\The [pointer]</b> points at <b>\the [pointed_at]</b>."

/mob/living/to_bump(atom/movable/AM as mob|obj)
	spawn(0)
		INVOKE_EVENT(src, /event/to_bump, "bumper" = src, "bumped" = AM)
		if (now_pushing || !loc || size <= SIZE_TINY)
			return
		now_pushing = 1
		if (istype(AM, /obj/structure/bed/roller)) //no pushing rollerbeds that have people on them
			var/obj/structure/bed/roller/R = AM
			for(var/mob/living/tmob in range(R, 1))
				if(tmob.pulling == R && !(tmob.restrained()) && tmob.stat == 0 && R.density == 1)
					to_chat(src, "<span class='warning'>[tmob] is pulling [R], you can't push past.</span>")
					now_pushing = 0
					return
		if (istype(AM, /mob/living)) //no pushing people pushing rollerbeds that have people on them
			var/mob/living/tmob = AM
			for(var/obj/structure/bed/roller/R in range(tmob, 1))
				if(tmob.pulling == R && !(tmob.restrained()) && tmob.stat == 0 && R.density == 1)
					to_chat(src, "<span class='warning'>[tmob] is pulling [R], you can't push past.</span>")
					now_pushing = 0
					return
			for(var/mob/living/M in range(tmob, 1)) //no pushing prisoners or people pulling prisoners
				if(tmob.pinned.len ||  ((M.pulling == tmob && (tmob.restrained() && !(M.restrained()) && M.stat == 0)) || locate(/obj/item/weapon/grab, tmob.grabbed_by.len)))
					to_chat(src, "<span class='warning'>[tmob] is restrained, you can't push past.</span>")
					now_pushing = 0
					return
				if(tmob.pulling == M && (M.restrained() && !(tmob.restrained()) && tmob.stat == 0))
					to_chat(src, "<span class='warning'>[tmob] is restraining [M], you can't push past.</span>")
					now_pushing = 0
					return

			//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
			var/dense = 0
			if(loc.density)
				dense = 1
			for(var/atom/movable/A in loc)
				if(A == src)
					continue
				if(A.density)
					if(A.flow_flags&ON_BORDER)
						dense = !A.Cross(src, src.loc)
					else
						dense = 1
				if(dense)
					break
			if((tmob.a_intent == I_HELP || tmob.restrained()) && (a_intent == I_HELP || src.restrained()) && tmob.canmove && canmove && !dense && can_move_mob(tmob, 1, 0)) // mutual brohugs all around!
				var/turf/oldloc = loc
				forceMove(tmob.loc)
				tmob.forceMove(oldloc, glide_size_override = src.glide_size)
				now_pushing = 0
				for(var/mob/living/carbon/slime/slime in view(1,tmob))
					if(slime.Victim == tmob)
						slime.UpdateFeed()
				return

			if(!can_move_mob(tmob, 0, 0))
				now_pushing = 0
				return
			var/mob/living/carbon/human/H = null
			if(ishuman(tmob))
				H = tmob
			if(H && ((M_FAT in H.mutations) || (H && H.species && H.species.anatomy_flags & IS_BULKY)))
				var/mob/living/carbon/human/U = null
				if(ishuman(src))
					U = src
				if(prob(40) && !(U && ((M_FAT in U.mutations) || (U && U.species && U.species.anatomy_flags & IS_BULKY))))
					to_chat(src, "<span class='danger'>You fail to push [tmob]'s fat ass out of the way.</span>")
					now_pushing = 0
					return

			for(var/obj/item/weapon/shield/riot/R in tmob.held_items)
				if(prob(99))
					now_pushing = 0
					return

			if(!(tmob.status_flags & CANPUSH))
				now_pushing = 0
				return

			tmob.assaulted_by(src, TRUE)

		now_pushing = 0
		spawn(0)
			..()
			if (!istype(AM, /atom/movable))
				return
			if (!now_pushing)
				now_pushing = 1

				if (!AM.anchored && AM.can_be_pushed(src))
					var/t = get_dir(src, AM)
					if(AM.flow_flags & ON_BORDER && !t)
						t = AM.dir
					if (istype(AM, /obj/structure/window/full))
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
					AM.set_glide_size(src.glide_size)
					if (ismob(AM))
						var/mob/M = AM
						INVOKE_EVENT(src, /event/before_move)
						step(M, t)
						INVOKE_EVENT(src, /event/after_move)
					else
						step(AM, t)
				now_pushing = 0
			return
	return

/mob/living/proc/scoop_up(mob/M) //M = mob who scoops us up!
	if(!holder_type)
		return 0

	var/obj/item/weapon/holder/D = new holder_type(loc, src)

	if(M.put_in_active_hand(D))
		to_chat(M, "You scoop up [src].")
		to_chat(src, "[M] scoops you up.")
		src.forceMove(D) //Only move the mob into the holder after we're sure he has been picked up!
		return 1
	else
		qdel(D)

	return 0

/mob/living/nuke_act() //Called when caught in a nuclear blast
	return

/mob/living/proc/turn_into_statue(forever = 0, force)
	if(!force)
		if(mob_property_flags & (MOB_UNDEAD|MOB_CONSTRUCT|MOB_ROBOTIC|MOB_HOLOGRAPHIC|MOB_SUPERNATURAL))
			return 0

	spawn()
		//we try to turn into marble mannequins, but if we're not compatible we'll use the old statue type
		if(forever)
			if (!turn_into_mannequin("marble",TRUE))
				new /obj/structure/closet/statue/eternal(get_turf(src), src)
		else
			if (!turn_into_mannequin("marble"))
				new /obj/structure/closet/statue(get_turf(src), src)
		timestopped = 1
	return 1

/*
	How this proc that I took from /tg/ works:
	intensity determines the damage done to humans with eyes
	visual determines whether the proc damages eyes (in the living/carbon/human proc). 1 for no damage
	override_blindness_check = 1 means that it'll display a flash even if the mob is blind
	affect_silicon = 0 means that the flash won't affect silicons at all.

*/
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/abstract/screen/fullscreen/flash)
	if(override_blindness_check || !(disabilities & BLIND))
		// flick("e_flash", flash)
		overlay_fullscreen("flash", type)
		return 1

/mob/living/proc/advanced_mutate()
	color = list(rand(),rand(),rand(),0,
				rand(),rand(),rand(),0,
				rand(),rand(),rand(),0,
				0,0,0,1,
				0,0,0,0)
	if(prob(5))
		eye_blind = rand(0,100)
	if(prob(10))
		eye_blurry = rand(0,100)
	if(prob(5))
		ear_deaf = rand(0,100)
	if(prob(5))
		say_mute = rand(0,100)
	brute_damage_modifier += rand(-5,5)/10
	burn_damage_modifier += rand(-5,5)/10
	tox_damage_modifier += rand(-5,5)/10
	oxy_damage_modifier += rand(-5,5)/10
	clone_damage_modifier += rand(-5,5)/10
	brain_damage_modifier += rand(-5,5)/10
	hal_damage_modifier += rand(-5,5)/10

	movement_speed_modifier += rand(-9,9)/10
	if(prob(1))
		universal_speak = !universal_speak
	if(prob(1))
		universal_understand = !universal_understand

	maxHealth = rand(50,200)
	meat_type = pick(typesof(/obj/item/weapon/reagent_containers/food/snacks/meat))
	if(prob(5))
		cap_calorie_burning_bodytemp = !cap_calorie_burning_bodytemp
	if(prob(10))
		calorie_burning_heat_multiplier += rand(-5,5)/10
	if(prob(10))
		thermal_loss_multiplier += rand(-5,5)/10

//Throwing stuff

/mob/living/proc/toggle_throw_mode()
	if (in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/proc/throw_mode_off()
	in_throw_mode = 0
	if(throw_icon)
		throw_icon.icon_state = "act_throw_off"

/mob/living/proc/throw_mode_on()
	if(gcDestroyed)
		return
	if(!held_items.len)	//need hands to throw
		to_chat(src, "<span class='warning'>You have no hands with which to throw.</span>")
		return
	in_throw_mode = 1
	if(throw_icon)
		throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(var/atom/target,var/atom/movable/what=null)
	return

#define FAILED_THROW 0
#define THREW_SOMETHING 1
#define THREW_NOTHING -1

/mob/living/throw_item(var/atom/target,var/atom/movable/what=null)
	if (src.throw_delayer.blocked())
		return FAILED_THROW
	src.delayNextThrow(3)
	src.throw_mode_off()
	if(src.stat || !target)
		return FAILED_THROW

	if(!istype(loc,/turf))
		to_chat(src, "<span class='warning'>You can't do that now!</span>")
		return FAILED_THROW

	if(runescape_pvp && is_pacified())
		to_chat(src, "<span class='warning'>As such, throwing items is also forbidden outside of maintenance areas.</span>")
		return FAILED_THROW

	if(target.type == /obj/abstract/screen)
		return FAILED_THROW

	var/atom/movable/item = src.get_active_hand()
	if(what)
		item=what

	if(!item)
		return THREW_NOTHING

	if (istype(item, /obj/item/offhand))
		var/obj/item/offhand/offhand = item
		if(offhand.wielding)
			src.throw_item(target, offhand.wielding)
			return FAILED_THROW

	else if (istype(item, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = item
		item = G.toss() //throw the person instead of the grab
		if(ismob(item))
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				var/mob/M = item
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been thrown by [usr.name] ([usr.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")

				log_attack("<font color='red'>[usr.name] ([usr.ckey]) Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				M.assaulted_by(usr)
				qdel(G)
	if(!item)
		return FAILED_THROW	//Grab processing has a chance of returning null
	if(isitem(item))
		var/obj/item/I = item
		if(I.cant_drop > 0)
			to_chat(usr, "<span class='warning'>It's stuck to your hand!</span>")
			return FAILED_THROW

		if(I.pre_throw(target,src))
			return FAILED_THROW

	remove_from_mob(item)

	//actually throw it!
	if (item)
		item.forceMove(get_turf(src))
		if(!(item.flags & NO_THROW_MSG))
			src.visible_message("<span class='warning'>[src] has thrown [item].</span>", \
				drugged_message = "<span class='warning'>[item] escapes from [src]'s grasp and flies away!</span>")

		src.apply_inertia(get_dir(target, src))


/*
		if(istype(src.loc, /turf/space) || (src.flags & NOGRAV)) //they're in space, move em one space in the opposite direction
			src.inertia_dir = get_dir(target, src)
			step(src, inertia_dir)
*/


		var/throw_mult=1
		if(istype(src,/mob/living/carbon/human))
			var/mob/living/carbon/human/H=src
			throw_mult = H.species.throw_mult
			throw_mult += (H.get_strength()-1)/2 //For each level of strength above 1, add 0.5
		item.throw_at(target, item.throw_range*throw_mult, item.throw_speed*throw_mult)
		return THREW_SOMETHING

/mob/living/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"maxHealth",
		"health",
		"bruteloss",
		"oxyloss",
		"toxloss",
		"fireloss",
		"cloneloss",
		"brainloss",
		"halloss",
		"hallucination",
		"meat_taken",
		"on_fire",
		"fire_stacks",
		"specialsauce",
		"silent",
		"is_ventcrawling")

	reset_vars_after_duration(resettable_vars, duration)

/mob/living/proc/handle_dizziness()
	//Dizziness
	if(dizziness || undergoing_hypothermia() == MODERATE_HYPOTHERMIA)
		var/wasdizzy = 1
		if(undergoing_hypothermia() == MODERATE_HYPOTHERMIA && !dizziness && prob(50))
			dizziness = 120
			wasdizzy = 0
		var/client/C = client
		var/pixel_x_diff = 0
		var/pixel_y_diff = 0
		var/temp
		var/saved_dizz = dizziness
		dizziness = max(dizziness - 1, 0)
		if(C)
			var/oldsrc = src
			var/amplitude = dizziness * (sin(dizziness * 0.044 * world.time) + 1) / 70 //This shit is annoying at high strength
			src = null
			spawn(0)
				if(C)
					temp = amplitude * sin(0.008 * saved_dizz * world.time)
					pixel_x_diff += temp
					C.pixel_x += temp * PIXEL_MULTIPLIER
					temp = amplitude * cos(0.008 * saved_dizz * world.time)
					pixel_y_diff += temp
					C.pixel_y += temp * PIXEL_MULTIPLIER
					sleep(3)
					if(C)
						temp = amplitude * sin(0.008 * saved_dizz * world.time)
						pixel_x_diff += temp
						C.pixel_x += temp * PIXEL_MULTIPLIER
						temp = amplitude * cos(0.008 * saved_dizz * world.time)
						pixel_y_diff += temp
						C.pixel_y += temp * PIXEL_MULTIPLIER
					sleep(3)
					if(C)
						C.pixel_x -= pixel_x_diff * PIXEL_MULTIPLIER
						C.pixel_y -= pixel_y_diff * PIXEL_MULTIPLIER
			src = oldsrc
		if(!wasdizzy)
			dizziness = 0


/mob/living/proc/handle_jitteriness()
	if(jitteriness)
		var/amplitude = min(8, (jitteriness/70) + 1)
		var/pixel_x_diff = rand(-amplitude, amplitude) * PIXEL_MULTIPLIER
		var/pixel_y_diff = rand(-amplitude, amplitude) * PIXEL_MULTIPLIER
		spawn()
			animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
			animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)

			pixel_x_diff = rand(-amplitude, amplitude) * PIXEL_MULTIPLIER
			pixel_y_diff = rand(-amplitude, amplitude) * PIXEL_MULTIPLIER
			animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
			animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)

			pixel_x_diff = rand(-amplitude, amplitude) * PIXEL_MULTIPLIER
			pixel_y_diff = rand(-amplitude, amplitude) * PIXEL_MULTIPLIER
			animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
			animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)

/mob/living/proc/Silent(amount)
	silent = max(max(silent,amount),0)

/mob/living/proc/SetSilent(amount)
	silent = max(amount,0)

/mob/living/on_syringe_injection(var/mob/user, var/obj/item/weapon/reagent_containers/syringe/tool)
	if(src == user)
		return ..()
	// Attempting to inject someone else takes time
	if(tool.get_injection_action(src) == INJECTION_SUIT_PORT)
		user.visible_message("<span class='warning'>[user] begins hunting for an injection port for \the [tool] on [src]'s suit!</span>",
							 "<span class='warning'>You begin hunting for an injection port for \the [tool] on [src]'s suit!</span>")
	else
		user.visible_message("<span class='warning'>[user] is trying to inject [src] with \the [tool]!</span>",
							 "<span class='warning'>You try to inject [src] with \the [tool]!</span>")
	if(!do_mob(user, src, tool.get_injection_time(src)))
		return INJECTION_RESULT_FAIL
	user.visible_message("<span class='warning'>[user] injects [src] with the \the [tool]!</span>",
						 "<span class='warning'>You inject [src] with \the [tool]!</span>")
	var/reagent_names = english_list(tool.get_reagent_names())
	add_attacklogs(user, src, "injected", object = tool, addition = "Reagents: [reagent_names]", admin_warn = TRUE)

	// TODO Every reagent reacts with the full volume instead of being scaled accordingly
	// TODO which is pretty irrelevant now but should be fixed
	tool.reagents.reaction(src, INGEST)
	return ..()

/mob/living/proc/ApplySlip(var/obj/effect/overlay/puddle/P)
	return on_foot() // Check if we have legs, gravity, etc. Checked by the children.

/mob/living/proc/Slip(stun_amount, weaken_amount, slip_on_walking = 0, overlay_type, slip_with_magbooties = 0)
	stop_pulling()
	Stun(stun_amount)
	Knockdown(weaken_amount)
	score.slips++
	return 1

///////////////////////DISEASE STUFF///////////////////////////////////////////////////////////////////

//Blocked is whether clothing prevented the spread of contact/blood
/mob/living/proc/assume_contact_diseases(var/list/disease_list,var/atom/source,var/blocked=0,var/bleeding=0)
	if (istype(disease_list) && disease_list.len > 0)
		for(var/ID in disease_list)
			var/datum/disease2/disease/V = disease_list[ID]
			if (!V)
				message_admins("[key_name(src)] is trying to assume contact diseases from touching \a [source], but the disease_list contains an ID ([ID]) that isn't associated to an actual disease datum! Ping Deity about it please.")
				return
			if(!blocked && V.spread & SPREAD_CONTACT)
				infect_disease2(V, notes="(Contact, from [source])")
			else if(suitable_colony() && V.spread & SPREAD_COLONY)
				infect_disease2(V, notes="(Colonized, from [source])")
			else if(!blocked && bleeding && (V.spread & SPREAD_BLOOD))
				infect_disease2(V, notes="(Blood, from [source])")

//Called in Life() by humans (in handle_virus_updates.dm), monkeys and mice
/mob/living/proc/find_nearby_disease()//only tries to find Contact and Blood spread diseases. Airborne ones are handled by breath_airborne_diseases()
	if(locked_to)//Riding a vehicle?
		return
	if(flying)//Flying?
		return

	var/turf/T = get_turf(src)

	//Virus Dishes aren't toys, handle with care, especially when they're open.
	for(var/obj/effect/decal/cleanable/virusdish/dish in T)
		dish.infection_attempt(src)
	for(var/obj/item/weapon/virusdish/dish in T)
		if (dish.open && dish.contained_virus)
			dish.infection_attempt(src,dish.contained_virus)
	var/obj/item/weapon/virusdish/dish = locate() in held_items
	if (dish && dish.open && dish.contained_virus)
		dish.infection_attempt(src,dish.contained_virus)

	//Now to check for stuff that's on the floor
	var/block = 0
	var/bleeding = 0
	if (lying)
		block = check_contact_sterility(FULL_TORSO)
		bleeding = check_bodypart_bleeding(FULL_TORSO)
	else
		block = check_contact_sterility(FEET)
		bleeding = check_bodypart_bleeding(FEET)

	var/static/list/viral_cleanable_types = list(
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/mucus,
		/obj/effect/decal/cleanable/vomit,
		)

	for(var/obj/effect/decal/cleanable/C in T)
		if (is_type_in_list(C,viral_cleanable_types))
			assume_contact_diseases(C.virus2,C,block,bleeding)

	for(var/obj/effect/rune/R in T)
		assume_contact_diseases(R.virus2,R,block,bleeding)
	return 0

//This one is used for one-way infections, such as getting splashed with someone's blood due to clobbering them to death
/mob/living/proc/oneway_contact_diseases(var/mob/living/L,var/block=0,var/bleeding=0)
	assume_contact_diseases(L.virus2,L,block,bleeding)

//This one is used for two-ways infections, such as hand-shakes, hugs, punches, people bumping into each others, etc
/mob/living/proc/share_contact_diseases(var/mob/living/L,var/block=0,var/bleeding=0)
	L.assume_contact_diseases(virus2,src,block,bleeding)
	assume_contact_diseases(L.virus2,L,block,bleeding)

//Called in Life() by humans (in handle_breath.dm), monkeys and mice
/mob/living/proc/breath_airborne_diseases()//only tries to find Airborne spread diseases. Blood and Contact ones are handled by find_nearby_disease()
	if (!check_airborne_sterility() && isturf(loc))//checking for sterile mouth protections
		breath_airborne_diseases_from_clouds()

		var/turf/T = get_turf(src)
		var/list/breathable_cleanable_types = list(
			/obj/effect/decal/cleanable/blood,
			/obj/effect/decal/cleanable/mucus,
			/obj/effect/decal/cleanable/vomit,
			)

		for(var/obj/effect/decal/cleanable/C in T)
			if (is_type_in_list(C,breathable_cleanable_types))
				if(istype(C.virus2,/list) && C.virus2.len > 0)
					for(var/ID in C.virus2)
						var/datum/disease2/disease/V = C.virus2[ID]
						if(V.spread & SPREAD_AIRBORNE)
							infect_disease2(V, notes="(Airborne, from [C])")

		for(var/obj/effect/rune/R in T)
			if(istype(R.virus2,/list) && R.virus2.len > 0)
				for(var/ID in R.virus2)
					var/datum/disease2/disease/V = R.virus2[ID]
					if(V.spread & SPREAD_AIRBORNE)
						infect_disease2(V, notes="(Airborne, from [R])")

		spawn (1)
			//we don't want the rest of the mobs to start breathing clouds before they've settled down
			//otherwise it can produce exponential amounts of lag if many mobs are in an enclosed space
			spread_airborne_diseases()

/mob/living/proc/breath_airborne_diseases_from_clouds()
	for(var/turf/T in range(1, src))
		for(var/obj/effect/pathogen_cloud/cloud in T.contents)
			if (!cloud.sourceIsCarrier || cloud.source != src || cloud.modified)
				if (Adjacent(cloud))
					for (var/ID in cloud.viruses)
						var/datum/disease2/disease/V = cloud.viruses[ID]
						//if (V.spread & SPREAD_AIRBORNE)	//Anima Syndrome allows for clouds of non-airborne viruses
						infect_disease2(V, notes="(Airborne, from a pathogenic cloud[cloud.source ? " created by [key_name(cloud.source)]" : ""])")

/mob/living/proc/spread_airborne_diseases()
	//spreading our own airborne viruses
	if (virus2 && virus2.len > 0)
		var/list/airborne_viruses = filter_disease_by_spread(virus2,required = SPREAD_AIRBORNE)
		if (airborne_viruses && airborne_viruses.len > 0)
			var/strength = 0
			for (var/ID in airborne_viruses)
				var/datum/disease2/disease/V = airborne_viruses[ID]
				strength += V.infectionchance
			strength = round(strength/airborne_viruses.len)
			while (strength > 0)//stronger viruses create more clouds at once
				new /obj/effect/pathogen_cloud/core(get_turf(src), src, virus_copylist(airborne_viruses))
				strength -= 40

/mob/living/proc/handle_virus_updates()
	if(status_flags & GODMODE)
		return 0

	src.find_nearby_disease()//getting diseases from blood/mucus/vomit splatters and open dishes

	activate_diseases()

/mob/living/proc/activate_diseases()
	if (virus2.len)
		var/active_disease = pick(virus2)//only one disease will activate its effects at a time.
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			if(istype(V))
				V.activate(src,active_disease!=ID)

				if (prob(radiation))//radiation turns your body into an inefficient pathogenic incubator.
					V.incubate(src,rad_tick/10)
					//effect mutations won't occur unless the mob also has ingested mutagen
					//and even if they occur, the new effect will have a badness similar to the old one, so helpful pathogen won't instantly become deadly ones.

/mob/living/blob_act(destroy = 0,var/obj/effect/blob/source = null)
	if(flags & INVULNERABLE)
		return
	if(!isDead(src) && source)
		if (!(source.looks in blob_diseases))
			CreateBlobDisease(source.looks)
		var/datum/disease2/disease/D = blob_diseases[source.looks]

		if (!check_contact_sterility(FULL_TORSO))//For simplicity's sake (for once), let's just assume that the blob strikes the torso.
			infect_disease2(D, notes="(Blob, from [source])")

	..()

/mob/living/proc/handle_symptom_on_death()
	if(islist(virus2) && virus2.len > 0)
		for(var/I in virus2)
			var/datum/disease2/disease/D = virus2[I]
			if(D.effects.len)
				for(var/datum/disease2/effect/E in D.effects)
					E.on_death(src)

//Brain slug proc for voluntary removal of control.
/mob/living/proc/release_control()
	set category = "Alien"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	do_release_control(0)

/mob/living/proc/do_release_control(var/rptext=1)
	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.controlling)
		if(rptext)
			to_chat(src, "<span class='danger'>You withdraw your probosci, releasing control of [B.host_brain]</span>")
			to_chat(B.host_brain, "<span class='danger'>Your vision swims as the alien parasite releases control of your body.</span>")
		B.ckey = ckey
		B.controlling = 0
	if(B.host_brain.ckey)
		ckey = B.host_brain.ckey
		B.host_brain.ckey = null
		B.host_brain.name = "host brain"
		B.host_brain.real_name = "host brain"

	//reset name if the borer changed it
	fully_replace_character_name(null, B.host_name)

	verbs -= /mob/living/proc/release_control
	verbs -= /mob/living/proc/punish_host

//Brain slug proc for tormenting the host.
/mob/living/proc/punish_host()
	set category = "Alien"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain.ckey)
		to_chat(src, "<span class='danger'>You send a punishing spike of psychic agony lancing into your host's brain.</span>")
		to_chat(B.host_brain, "<span class='danger'><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></span>")

/mob/living/Stat()
	..()
	if(statpanel("Status"))
		if(mind)
			for(var/role in mind.antag_roles)
				var/datum/role/R = mind.antag_roles[role]
				stat(R.StatPanel())
