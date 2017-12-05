/mob/living/New()
	. = ..()
	generate_static_overlay()
	if(istype(static_overlays,/list) && static_overlays.len)
		for(var/mob/living/silicon/robot/mommi/MoMMI in player_list)
			if(MoMMI.can_see_static())
				if(MoMMI.static_choice in static_overlays)
					MoMMI.static_overlays.Add(static_overlays[MoMMI.static_choice])
					MoMMI.client.images.Add(static_overlays[MoMMI.static_choice])
				else
					MoMMI.static_overlays.Add(static_overlays["static"])
					MoMMI.client.images.Add(static_overlays["static"])

	if(!species_type)
		species_type = src.type
	if(can_butcher && !meat_amount)
		meat_amount = size

/mob/living/Destroy()
	for(var/mob/living/silicon/robot/mommi/MoMMI in player_list)
		for(var/image/I in static_overlays)
			MoMMI.static_overlays.Remove(I) //no checks, since it's either there or its not
			MoMMI.client.images.Remove(I)
			qdel(I)
			I = null
	if(static_overlays)
		static_overlays = null

	if(butchering_drops)
		for(var/datum/butchering_product/B in butchering_drops)
			butchering_drops -= B
			qdel(B)
			B = null

	. = ..()

/mob/living/examine(mob/user) //Show the mob's size and whether it's been butchered
	var/size
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
	if(src.gender == FEMALE)
		pronoun = "she is"
	else if(src.gender == MALE)
		pronoun = "he is"
	else if(src.gender == PLURAL)
		pronoun = "they are"

	..(user, " [capitalize(pronoun)] [size].")
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

	//handles "call on life", allowing external life-related things to be processed
	for(var/toCall in src.callOnLife)
		if(locate(toCall) && callOnLife[toCall])
			call(locate(toCall),callOnLife[toCall])()
		else
			callOnLife -= toCall

	if(mind)
		if(mind in ticker.mode.implanted)
			if(implanting)
				return 0
//			to_chat(world, "[src.name]")
			var/datum/mind/head = ticker.mode.implanted[mind]
			//var/list/removal
			if(!(locate(/obj/item/weapon/implant/traitor) in src.contents))
//				to_chat(world, "doesn't have an implant")
				ticker.mode.remove_traitor_mind(mind, head)
				/*
				if((head in ticker.mode.implanters))
					ticker.mode.implanter[head] -= src.mind
				ticker.mode.implanted -= src.mind
				if(src.mind in ticker.mode.traitors)
					ticker.mode.traitors -= src.mind
					special_role = null
					to_chat(current, "<span class='danger'><FONT size = 3>The fog clouding your mind clears. You remember nothing from the moment you were implanted until now..(You don't remember who enslaved you)</FONT></span>")
				*/
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
	if(iscultist(src) && client)
		var/mob/living/simple_animal/construct/harvester/C = new /mob/living/simple_animal/construct/harvester(get_turf(src))
		mind.transfer_to(C)
		to_chat(C, "<span class='sinister'>The Geometer of Blood is overjoyed to be reunited with its followers, and accepts your body in sacrifice. As reward, you have been gifted with the shell of an Harvester.<br>Your tendrils can use and draw runes without need for a tome, your eyes can see beings through walls, and your mind can open any door. Use these assets to serve Nar-Sie and bring him any remaining living human in the world.<br>You can teleport yourself back to Nar-Sie along with any being under yourself at any time using your \"Harvest\" spell.</span>")
		dust()
	else if(client)
		var/mob/dead/G = (ghostize())
		G.icon = 'icons/mob/mob.dmi'
		G.icon_state = "ghost-narsie"
		G.overlays = 0
		if(istype(G.mind.current, /mob/living/carbon/human/))
			var/mob/living/carbon/human/H = G.mind.current
			G.overlays += H.obj_overlays[ID_LAYER]
			G.overlays += H.obj_overlays[EARS_LAYER]
			G.overlays += H.obj_overlays[SUIT_LAYER]
			G.overlays += H.obj_overlays[GLASSES_LAYER]
			G.overlays += H.obj_overlays[GLASSES_OVER_HAIR_LAYER]
			G.overlays += H.obj_overlays[BELT_LAYER]
			G.overlays += H.obj_overlays[BACK_LAYER]
			G.overlays += H.obj_overlays[HEAD_LAYER]
			G.overlays += H.obj_overlays[HANDCUFF_LAYER]
		G.invisibility = 0
		to_chat(G, "<span class='sinister'>You feel relieved as what's left of your soul finally escapes its prison of flesh.</span>")

		if(ticker.mode.name == "cult")
			var/datum/game_mode/cult/mode_ticker = ticker.mode
			mode_ticker.harvested++

	else
		dust()

/mob/living/apply_beam_damage(var/obj/effect/beam/B)
	var/lastcheck=last_beamchecks["\ref[B]"]

	// Figure out how much damage to deal.
	// Formula: (deciseconds_since_connect/10 deciseconds)*B.get_damage()
	var/damage = ((world.time - lastcheck)/10)  * B.get_damage()

	// Actually apply damage
	apply_damage(damage, B.damage_type, B.def_zone)

	// Update check time.
	last_beamchecks["\ref[B]"]=world.time

/mob/living/verb/succumb()
	set hidden = 1
	if (src.health < 0 && stat != DEAD)
		src.attack_log += "[src] has succumbed to death with [health] points of health!"
		src.apply_damage(maxHealth + src.health, OXY)
		death(0)
		to_chat(src, "<span class='info'>You have given up life and succumbed to death.</span>")


/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else if(!(flags & INVULNERABLE))
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss


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


// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn
// I touched them without asking... I'm soooo edgy ~Erro (added nodamage checks)

/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode

	if(INVOKE_EVENT(on_damaged, list("type" = BRUTE, "amount" = amount)))
		return 0

	bruteloss = min(max(bruteloss + (amount * brute_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode

	if(INVOKE_EVENT(on_damaged, list("type" = OXY, "amount" = amount)))
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

	if(INVOKE_EVENT(on_damaged, list("type" = TOX, "amount" = amount)))
		return 0

	var/mult = 1
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.species.tox_mod)
			mult = H.species.tox_mod

	toxloss = min(max(toxloss + (amount * tox_damage_modifier * mult), 0),(maxHealth*2))

/mob/living/proc/setToxLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode
	toxloss = amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode
	if(mutations.Find(M_RESIST_HEAT))
		return 0
	if(INVOKE_EVENT(on_damaged, list("type" = BURN, "amount" = amount)))
		return 0

	fireloss = min(max(fireloss + (amount * burn_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode

	if(INVOKE_EVENT(on_damaged, list("type" = CLONE, "amount" = amount)))
		return 0

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(isslimeperson(H))
			amount = 0

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

	if(INVOKE_EVENT(on_damaged, list("type" = BRAIN, "amount" = amount)))
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
	var/damage = shock_damage * siemens_coeff

	if(damage <= 0)
		damage = 0

	adjustFireLoss(damage)

	return damage

/mob/living/emp_act(severity)
	for(var/obj/item/stickybomb/B in src)
		if(B.stuck_to)
			visible_message("<span class='warning'>\the [B] stuck on \the [src] suddenly deactivates itself and falls to the ground.</span>")
			B.deactivate()
			B.unstick()

	if(flags & INVULNERABLE)
		return

	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/mob/living/proc/get_organ(zone)
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
/mob/living/proc/take_organ_damage(var/brute, var/burn)
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

		if (C.handcuffed && !initial(C.handcuffed))
			C.drop_from_inventory(C.handcuffed)
		C.handcuffed = initial(C.handcuffed)

		if (C.legcuffed && !initial(C.legcuffed))
			C.drop_from_inventory(C.legcuffed)
		C.legcuffed = initial(C.legcuffed)
	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD

/mob/living/proc/rejuvenate(animation = 0)
	var/turf/T = get_turf(src)
	if(animation)
		T.turf_animation('icons/effects/64x64.dmi',"rejuvinate",-16,0,MOB_LAYER+1,'sound/effects/rejuvinate.ogg',anim_plane = EFFECTS_PLANE)

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
	if(!reagents)
		create_reagents(1000)
	else
		reagents.clear_reagents()
	heal_overall_damage(1000, 1000)
	ExtinguishMob()
	fire_stacks = 0
	/*
	if(locked_to)
		locked_to.unbuckle()
	locked_to = initial(src.locked_to)
	*/
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		H.timeofdeath = 0
		H.vessel.reagent_list = list()
		H.vessel.add_reagent(BLOOD,560)
		H.pain_shock_stage = 0
		spawn(1)
			H.fixblood()
		for(var/organ_name in H.organs_by_name)
			var/datum/organ/external/O = H.organs_by_name[organ_name]
			for(var/obj/item/weapon/shard/shrapnel/s in O.implants)
				if(istype(s))
					O.implants -= s
					H.contents -= s
					qdel(s)
					s = null
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
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.handcuffed = initial(C.handcuffed)
	for(var/datum/disease/D in viruses)
		D.cure(0)
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
	..()

	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD
	return

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

/mob/living/Move(atom/newloc, direct)
	if (locked_to && locked_to.loc != newloc)
		var/datum/locking_category/category = locked_to.get_lock_cat_for(src)
		if (locked_to.anchored || category.flags & CANT_BE_MOVED_BY_LOCKED_MOBS)
			return 0
		else
			return locked_to.Move(newloc, direct)

	if (restrained())
		stop_pulling()

	var/turf/T = loc

	var/t7 = 1 //What the FUCK is this variable?
	if (restrained())
		for(var/mob/living/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
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
							pulling.Move(T, get_dir(pulling, T))
							if(M && secondarypull)
								M.start_pulling(secondarypull)

							/* Drag damage is here!*/
							var/mob/living/carbon/human/HM = M
							var/list/damaged_organs = HM.get_broken_organs()
							var/list/bleeding_organs = HM.get_bleeding_organs()
							if (T.has_gravity() && HM.lying)

								if (damaged_organs.len)
									if(!HM.isincrit())
										if(prob(HM.getBruteLoss() / 5)) //Chance for damage based on current damage
											for(var/datum/organ/external/damagedorgan in damaged_organs)
												if((damagedorgan.brute_dam) < damagedorgan.max_damage) //To prevent organs from accruing thousands of damage
													HM.apply_damage(2, BRUTE, damagedorgan)
													HM.visible_message("<span class='warning'>The wounds on \the [HM]'s [damagedorgan.display_name] worsen from being dragged!</span>")
													HM.UpdateDamageIcon()
									else
										if(prob(15))
											for(var/datum/organ/external/damagedorgan in damaged_organs)
												if((damagedorgan.brute_dam) < damagedorgan.max_damage)
													HM.apply_damage(4, BRUTE, damagedorgan)
													HM.visible_message("<span class='warning'>The wounds on \the [HM]'s [damagedorgan.display_name] worsen terribly from being dragged!</span>")
													add_logs(src, HM, "caused drag damage to", admin = (M.ckey))
													HM.UpdateDamageIcon()

								if (bleeding_organs.len && !(HM.species.anatomy_flags & NO_BLOOD))
									var/blood_volume = round(HM:vessel.get_reagent_amount("blood"))
									/*Sometimes species with NO_BLOOD get blood, hence weird check*/
									if(blood_volume > 0)
										if(isturf(HM.loc))
											if(!HM.isincrit())
												if(prob(blood_volume / 89.6)) //Chance to bleed based on blood remaining
													blood_splatter(HM.loc,HM)
													HM.vessel.remove_reagent("blood",4)
													HM.visible_message("<span class='warning'>\The [HM] loses some blood from being dragged!</span>")
											else
												if(prob(blood_volume / 44.8)) //Crit mode means double chance of blood loss
													blood_splatter(HM.loc,HM,1)
													HM.vessel.remove_reagent("blood",8)
													HM.visible_message("<span class='danger'>\The [HM] loses a lot of blood from being dragged!</span>")
													add_logs(src, HM, "caused drag damage bloodloss to", admin = (HM.ckey))
					else
						if (pulling)
							pulling.Move(T, get_dir(pulling, T))
				else
					stop_pulling()
	else
		stop_pulling()
		. = ..()

	if ((s_active && !is_holder_of(src, s_active)))
		s_active.close(src)

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)

	if(T != loc)
		handle_hookchain(direct)

	if(.)
		for(var/obj/item/weapon/gun/G in targeted_by) //Handle moving out of the gunner's view.
			var/mob/living/M = G.loc
			if(!(M in view(src)))
				NotTargeted(G)
		for(var/obj/item/weapon/gun/G in src) //Handle the gunner loosing sight of their target/s
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

/mob/living
    var/event/on_resist

/mob/living/New()
    . = ..()
    on_resist = new(owner = src)

/mob/living/Destroy()
    . = ..()
    qdel(on_resist)
    on_resist = null

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.special_delayer.blocked())
		return

	INVOKE_EVENT(on_resist, list())

	delayNext(DELAY_ALL,20) // Attack, Move, and Special.

	var/mob/living/L = usr

	//Escaping from within a subspace tunneler.
	var/obj/item/weapon/subspacetunneler/inside_tunneler = get_holder_of_type(L, /obj/item/weapon/subspacetunneler)
	if(inside_tunneler)
		var/breakout_time = 0.5 //30 seconds by default
		L.delayNext(DELAY_ALL,100)
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
		forceMove(get_turf(src))
		if(istype(H.loc, /mob/living))
			var/mob/living/Location = H.loc
			Location.drop_from_inventory(H)
		qdel(H)
		H = null
		return
	else if(istype(src.loc, /obj/structure/strange_present))
		var/obj/structure/strange_present/present = src.loc
		forceMove(get_turf(src))
		qdel(present)
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
		return
	else if(istype(src.loc, /obj/item/delivery/large)) //Syndie item
		var/obj/item/delivery/large/package = src.loc
		to_chat(L, "<span class='warning'>You attempt to unwrap yourself, this package is tight and will take some time.</span>")
		if(do_after(src, src, 100))
			L.visible_message("<span class='danger'>[L] successfully breaks out of [package]!</span>",\
							  "<span class='notice'>You successfully break out!</span>")
			forceMove(get_turf(src))
			qdel(package)
			playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
		return

	//Detaching yourself from a tether
	if(L.tether)
		var/mob/living/carbon/CM = L
		if(!istype(CM) || !CM.handcuffed)
			var/datum/chain/tether_datum = L.tether.chain_datum
			if(tether_datum.extremity_B == src)
				L.visible_message("<span class='danger'>\the [L] quickly grabs and removes \the [L.tether] tethered to his body!</span>",
							  "<span class='warning'>You quickly grab and remove \the [L.tether] tethered to your body.</span>")
				L.tether = null
				tether_datum.extremity_B = null
				tether_datum.rewind_chain()

	//Trying to unstick a stickybomb
	for(var/obj/item/stickybomb/B in L)
		if(B.stuck_to)
			L.visible_message("<span class='danger'>\the [L] is trying to reach and pull off \the [B] stuck on his body!</span>",
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
			qdel(O)
			O = null
			resisting++
		for(var/obj/item/weapon/grab/G in usr.grabbed_by)
			resisting++
			if (G.state == GRAB_PASSIVE)
				returnToPool(G)
			else
				if (G.state == GRAB_AGGRESSIVE)
					if (prob(25))
						L.visible_message("<span class='danger'>[L] has broken free of [G.assailant]'s grip!</span>", \
							drugged_message="<span class='danger'>[L] has broken free of [G.assailant]'s hug!</span>")
						returnToPool(G)
				else
					if (G.state == GRAB_NECK)
						if (prob(5))
							L.visible_message("<span class='danger'>[L] has broken free of [G.assailant]'s headlock!</span>", \
								drugged_message="<span class='danger'>[L] has broken free of [G.assailant]'s passionate hug!</span>")
							returnToPool(G)
		if(resisting)
			L.visible_message("<span class='danger'>[L] resists!</span>")


	if(L.locked_to && L.special_delayer.blocked())
		//unbuckling yourself
		if(istype(L.locked_to, /obj/structure/bed))
			var/obj/structure/bed/B = L.locked_to
			if(istype(B, /obj/structure/bed/guillotine))
				var/obj/structure/bed/guillotine/G = B
				if(G.open)
					G.manual_unbuckle(L)
				else
					L.delayNextAttack(100)
					L.delayNextSpecial(100)
					L.visible_message("<span class='warning'>\The [L] attempts to dislodge \the [G]'s stocks!</span>",
									  "<span class='warning'>You attempt to dislodge \the [G]'s stocks (this will take around thirty seconds).</span>",
									  self_drugged_message="<span class='warning'>You attempt to chew through the wooden stocks of \the [G] (this will take a while).</span>")
					spawn(0)
						if(do_after(usr, usr, 300))
							if(!L.locked_to)
								return
							L.visible_message("<span class='danger'>\The [L] dislodges \the [G]'s stocks and climbs out of \the [src]!</span>",\
								"<span class='notice'>You dislodge \the [G]'s stocks and climb out of \the [G].</span>",\
								self_drugged_message="<span class='notice'>You successfully chew through the wooden stocks.</span>")
							G.open = TRUE
							G.manual_unbuckle(L)
							G.update_icon()
							G.verbs -= /obj/structure/bed/guillotine/verb/open_stocks
							G.verbs += /obj/structure/bed/guillotine/verb/close_stocks
						else
							L.simple_message("<span class='warning'>Your escape attempt was interrupted.</span>", \
								"<span class='warning'>Your chewing was interrupted. Damn it!</span>")

			else if(iscarbon(L))
				var/mob/living/carbon/C = L
				if(C.handcuffed)
					C.delayNextAttack(100)
					C.delayNextSpecial(100)
					C.visible_message("<span class='warning'>[C] attempts to unbuckle themself!</span>",
									  "<span class='warning'>You attempt to unbuckle yourself (this will take around two minutes, and you need to stay still).</span>",
									  self_drugged_message="<span class='warning'>You attempt to regain control of your legs (this will take a while).</span>")
					spawn(0)
						if(do_after(usr, usr, 1200))
							if(!C.locked_to)
								return
							C.visible_message("<span class='danger'>[C] manages to unbuckle themself!</span>",\
								"<span class='notice'>You successfully unbuckle yourself.</span>",\
								self_drugged_message="<span class='notice'>You successfully regain control of your legs and stand up.</span>")
							B.manual_unbuckle(C)
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
		if(!istype(C.loc, /obj/item/delivery/large)) //Wouldn't want to interrupt escaping being wrapped over the next few trivial checks
			if(istype(C, /obj/structure/closet/secure_closet))
				var/obj/structure/closet/secure_closet/SC = L.loc
				if(!SC.locked && !SC.welded)
					return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'
			else
				if(!C.welded)
					return //closed but not welded...

		//okay, so the closet is either welded or locked... resist!!!
		L.delayNext(DELAY_ALL,100)
		L.visible_message("<span class='danger'>The [C] begins to shake violenty!</span>",
						  "<span class='warning'>You lean on the back of [C] and start pushing the door open (this will take about [breakout_time] minutes).</span>")
		spawn(0)
			if(do_after(usr,src,breakout_time * 60 * 10)) //minutes * 60seconds * 10deciseconds
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
					L.visible_message("<span class='danger'>[L] successful breaks out of [C]!</span>",
									  "<span class='notice'>You successfully break out!</span>")
					if(istype(C.loc, /obj/item/delivery/large)) //nullspace ect.. read the comment above
						var/obj/item/delivery/large/BD = C.loc
						BD.attack_hand(usr)
					C.open()

	if(src.loc && istype(src.loc, /obj/item/mecha_parts/mecha_equipment/tool/jail))
		var/breakout_time = 30 SECONDS
		var/obj/item/mecha_parts/mecha_equipment/tool/jail/jailcell = src.loc
		L.delayNext(DELAY_ALL,100)
		L.visible_message("<span class='danger'>One of \the [src.loc]'s cells rattles.</span>","<span class='warning'>You press against the lid of \the [src.loc] and attempt to pop it open (this will take about [breakout_time/10] seconds).</span>")
		spawn(0)
			if(do_after(usr,src,breakout_time)) //minutes * 60seconds * 10deciseconds
				if(src.loc != jailcell || !L || L.stat != CONSCIOUS) //if we're no longer in that mounted cell OR user dead/unconcious
					return

				//Well then break it!
				jailcell.break_out(L)
		return


	else if(iscarbon(L))
		var/mob/living/carbon/CM = L
	//putting out a fire
		if(CM.on_fire && CM.canmove)
			CM.fire_stacks -= 5
			CM.SetKnockdown(3)
			playsound(CM.loc, 'sound/effects/bodyfall.ogg', 50, 1)
			CM.visible_message("<span class='danger'>[CM] rolls on the floor, trying to put themselves out!</span>",
							   "<span class='warning'>You stop, drop, and roll!</span>")

			for(var/i = 1 to rand(8,12))
				CM.dir = turn(CM.dir, pick(-90, 90))
				sleep(2)

			if(fire_stacks <= 0)
				CM.visible_message("<span class='danger'>[CM] has successfully extinguished themselves!</span>",
								   "<span class='notice'>You extinguish yourself.</span>")
				ExtinguishMob()
			return

	//breaking out of handcuffs
		if(CM.handcuffed && CM.canmove && CM.special_delayer.blocked())
			CM.delayNext(DELAY_ALL,100)
			if(isalienadult(CM) || (M_HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				CM.visible_message("<span class='danger'>[CM] is trying to break the handcuffs!</span>",
								   "<span class='warning'>You attempt to break your handcuffs. (This will take around five seconds and you will need to stand still).</span>")
				spawn(0)
					if(do_after(CM, CM, 50))
						if(!CM.handcuffed || CM.locked_to)
							return
						CM.visible_message("<span class='danger'>[CM] manages to break \the [CM.handcuffed]!</span>",
										   "<span class='notice'>You successfully break \the [CM.handcuffed].</span>")
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						var/obj/item/cuffs = CM.handcuffed
						CM.drop_from_inventory(cuffs)
						if(!cuffs.gcDestroyed) //If these were not qdel'd already (exploding cuffs, anyone?)
							qdel(cuffs)
					else
						to_chat(CM, "<span class='warning'>Your cuff breaking attempt was interrupted.</span>")


			else
				var/obj/item/HC = CM.handcuffed
				var/resist_time = HC.restraint_resist_time
				if(!(resist_time))
					resist_time = 2 MINUTES //Default
				CM.visible_message("<span class='danger'>[CM] attempts to remove \the [HC]!</span>",
								   "<span class='warning'>You attempt to remove \the [HC] (this will take around [(resist_time)/600] minutes and you need to stand still).</span>",
								   self_drugged_message="<span class='warning'>You attempt to regain control of your hands (this will take a while).</span>")
				spawn(0)
					if(do_after(CM,CM, resist_time))
						if(!CM.handcuffed || CM.locked_to)
							return // time leniency for lag which also might make this whole thing pointless but the server
						CM.visible_message("<span class='danger'>[CM] manages to remove \the [HC]!</span>",
										   "<span class='notice'>You successfully remove \the [HC].</span>",
										   self_drugged_message="<span class='notice'>You successfully regain control of your hands.</span>")
						CM.drop_from_inventory(HC)
					else
						CM.simple_message("<span class='warning'>Your attempt to remove \the [HC] was interrupted.</span>",
							"<span class='warning'>Your attempt to regain control of your hands was interrupted. Damn it!</span>")

		else if(CM.legcuffed && CM.canmove && CM.special_delayer.blocked())
			CM.delayNext(DELAY_ALL,100)
			if(isalienadult(CM) || (M_HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				CM.visible_message("<span class='danger'>[CM] is trying to break the legcuffs!</span>",
								   "<span class='warning'>You attempt to break your legcuffs. (This will take around five seconds and you need to stand still).</span>")
				spawn(0)
					if(do_after(CM, CM, 50))
						if(!CM.legcuffed || CM.locked_to)
							return
						CM.visible_message("<span class='danger'>[CM] manages to break the legcuffs!</span>",
										   "<span class='notice'>You successfully break your legcuffs.</span>")
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						qdel(CM.legcuffed)
						CM.legcuffed = null
						CM.update_inv_legcuffed()
					else
						to_chat(CM, "<span class='warning'>Your legcuffing breaking attempt was interrupted.</span>")
			else
				var/obj/item/weapon/legcuffs/HC = CM.legcuffed
				var/breakouttime = HC.breakouttime
				if(!(breakouttime))
					breakouttime = 1200 //Default
				CM.visible_message("<span class='danger'>[CM] attempts to remove [HC]!</span>",
								   "<span class='warning'>You attempt to remove [HC]. (This will take around [(breakouttime)/600] minutes and you need to stand still).</span>")
				spawn(0)
					if(do_after(CM, CM, breakouttime))
						if(!CM.legcuffed || CM.locked_to)
							return // time leniency for lag which also might make this whole thing pointless but the server
						CM.visible_message("<span class='danger'>[CM] manages to remove [HC]!</span>",
										   "<span class='notice'>You successfully remove [HC].</span>")
						CM.legcuffed.forceMove(usr.loc)
						CM.legcuffed = null
						CM.update_inv_legcuffed()
					else
						to_chat(CM, "<span class='warning'>Your unlegcuffing attempt was interrupted.</span>")

/mob/living/verb/lay_down()
	set name = "Rest"
	set category = "IC"

	if(client.move_delayer.blocked())
		return
	delayNextMove(10)
	resting = !resting
	update_canmove()
	to_chat(src, "<span class='notice'>You are now [resting ? "resting" : "getting up"]</span>")

/mob/living/proc/has_brain()
	return 1

/mob/living/proc/has_eyes()
	return 1

/mob/living/singularity_act()
	if(!(src.flags & INVULNERABLE))
		var/gain = 20
		investigation_log(I_SINGULO,"has been consumed by a singularity")
		gib()
		return(gain)

/mob/living/singularity_pull(S)
	if(!(src.flags & INVULNERABLE))
		step_towards(src, S)

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
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(src.incapacitated())
		return 0
	if(!..())
		return 0
	usr.visible_message("<b>[src]</b> points to [A]")
	return 1


/mob/living/proc/generate_static_overlay()
	if(!istype(static_overlays,/list))
		static_overlays = list()
	static_overlays.Add(list("static", "blank", "letter"))
	var/image/static_overlay = image(getStaticIcon(new/icon(src.icon, src.icon_state)), loc = src)
	static_overlay.override = 1
	static_overlays["static"] = static_overlay

	static_overlay = image(getBlankIcon(new/icon(src.icon, src.icon_state)), loc = src)
	static_overlay.override = 1
	static_overlays["blank"] = static_overlay

	static_overlay = getLetterImage(src)
	static_overlay.override = 1
	static_overlays["letter"] = static_overlay

/mob/living/to_bump(atom/movable/AM as mob|obj)
	spawn(0)
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
					if(A.flags&ON_BORDER)
						dense = !A.Cross(src, src.loc)
					else
						dense = 1
				if(dense)
					break
			if((tmob.a_intent == I_HELP || tmob.restrained()) && (a_intent == I_HELP || src.restrained()) && tmob.canmove && canmove && !dense && can_move_mob(tmob, 1, 0)) // mutual brohugs all around!
				var/turf/oldloc = loc
				forceMove(tmob.loc)
				tmob.forceMove(oldloc)
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

			tmob.LAssailant = src

		now_pushing = 0
		spawn(0)
			..()
			if (!istype(AM, /atom/movable))
				return
			if (!now_pushing)
				now_pushing = 1

				if (!AM.anchored)
					var/t = get_dir(src, AM)
					if(AM.flags & ON_BORDER && !t)
						t = AM.dir
					if (istype(AM, /obj/structure/window/full))
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
					step(AM, t)
				now_pushing = 0
			return
	return

/mob/living/is_open_container()
	return 1

/mob/living/proc/drop_meat(location)
	if(!meat_type)
		return 0

	var/obj/item/weapon/reagent_containers/food/snacks/meat/M
	if(istype(src, /mob/living/carbon/human))
		M = new meat_type(location, src)
	else
		M = new meat_type(location)
	var/obj/item/weapon/reagent_containers/food/snacks/meat/animal/A = M

	if(istype(A))
		var/mob/living/simple_animal/source_animal = src
		if(istype(source_animal) && source_animal.species_type)
			var/mob/living/specimen = source_animal.species_type
			A.name = "[initial(specimen.name)] meat"
			A.animal_name = initial(specimen.name)
		else
			A.name = "[initial(src.name)] meat"
			A.animal_name = initial(src.name)
	return M

/mob/living/proc/butcher()
	set category = "Object"
	set name = "Butcher"
	set src in oview(1)

	var/mob/living/user = usr
	if(!istype(user))
		return

	if(user.isUnconscious() || user.restrained())
		return

	if(being_butchered)
		to_chat(user, "<span class='notice'>[src] is already being butchered.</span>")
		return

	if(!can_butcher)
		if(meat_taken)
			to_chat(user, "<span class='notice'>[src] has already been butchered.</span>")
			return
		else
			to_chat(user, "<span class='notice'>You can't butcher [src]!")
			return
		return

	var/obj/item/tool = null	//The tool that is used for butchering
	var/speed_mod = 1.0			//The higher it is, the faster you butcher
	var/butchering_time = 20 * size //2 seconds for tiny animals, 4 for small ones, 6 for normal sized ones (+ humans), 8 for big guys and 10 for biggest guys
	var/tool_name = null

	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		tool = H.get_active_hand()
		if(tool)
			tool_name = tool.name
		if(tool)
			speed_mod = tool.is_sharp()
			if(!speed_mod)
				to_chat(user, "<span class='notice'>You can't butcher \the [src] with this!</span>")
				return
		else
			speed_mod = 0.0

		if(H.organ_has_mutation(LIMB_HEAD, M_BEAK))
			var/obj/item/mask = H.get_item_by_slot(slot_wear_mask)
			if(!mask || !(mask.body_parts_covered & MOUTH)) //If our mask doesn't cover mouth, we can use our beak to help us while butchering
				speed_mod += 0.25
				if(!tool_name)
					tool_name = "beak"

		if(H.organ_has_mutation(H.get_active_hand_organ(), M_CLAWS))
			if(!istype(H.gloves))
				speed_mod += 0.25
				if(!tool_name)
					tool_name = "claws"

		if(isgrue(H))
			tool_name = "grue"
			speed_mod += 0.5
	else
		speed_mod = 0.5

	if(!speed_mod)
		return

	if(src.butchering_drops && src.butchering_drops.len)
		var/list/actions = list()
		actions += "Butcher"
		for(var/datum/butchering_product/B in src.butchering_drops)
			if(B.amount <= 0)
				continue

			actions |= capitalize(B.verb_name)
			actions[capitalize(B.verb_name)] = B
		actions += "Cancel"

		var/choice = input(user,"What would you like to do with \the [src]?","Butchering") in actions
		if(!Adjacent(user) || !(usr.get_active_hand() == tool))
			return

		if(choice == "Cancel")
			return 0
		else if(choice != "Butcher")
			var/datum/butchering_product/our_product = actions[choice]
			if(!istype(our_product))
				return

			user.visible_message("<span class='notice'>[user] starts [our_product.verb_gerund] \the [src][tool ? "with \the [tool]" : ""].</span>",\
				"<span class='info'>You start [our_product.verb_gerund] \the [src].</span>")
			src.being_butchered = 1
			if(!do_after(user,src,(our_product.butcher_time * size) / speed_mod))
				to_chat(user, "<span class='warning'>Your attempt to [our_product.verb_name] \the [src] has been interrupted.</span>")
				src.being_butchered = 0
			else
				to_chat(user, "<span class='info'>You finish [our_product.verb_gerund] \the [src].</span>")
				src.being_butchered = 0
				our_product.spawn_result(get_turf(src), src)
				src.update_icons()
			return

	user.visible_message("<span class='notice'>[user] starts butchering \the [src][tool ? " with \the [tool]" : ""].</span>",\
		"<span class='info'>You start butchering \the [src].</span>")
	src.being_butchered = 1

	if(!do_after(user,src,butchering_time / speed_mod))
		to_chat(user, "<span class='warning'>Your attempt to butcher \the [src] was interrupted.</span>")
		src.being_butchered = 0
		return

	src.drop_meat(get_turf(src))
	src.meat_taken++
	src.being_butchered = 0
	if(tool_name)
		if(!advanced_butchery)
			advanced_butchery = new()
		advanced_butchery.Add(tool_name)

	if(src.meat_taken < src.meat_amount)
		to_chat(user, "<span class='info'>You cut a chunk of meat out of \the [src].</span>")
		return

	to_chat(user, "<span class='info'>You butcher \the [src].</span>")
	can_butcher = 0

	if(istype(src, /mob/living/simple_animal)) //Animals can be butchered completely, humans - not so
		if(src.size > SIZE_TINY) //Tiny animals don't produce gibs
			gib(meat = 0) //"meat" argument only exists for mob/living/simple_animal/gib()
		else
			qdel(src)

/mob/living/proc/scoop_up(mob/M) //M = mob who scoops us up!
	if(!holder_type)
		return

	var/obj/item/weapon/holder/D = getFromPool(holder_type, loc, src)

	if(M.put_in_active_hand(D))
		to_chat(M, "You scoop up [src].")
		to_chat(src, "[M] scoops you up.")
		src.forceMove(D) //Only move the mob into the holder after we're sure he has been picked up!
	else
		returnToPool(D)

	return

/mob/living/nuke_act() //Called when caught in a nuclear blast
	health = 0
	stat = DEAD

/mob/proc/CheckSlip()
	return 0

/mob/living/proc/turn_into_statue(forever = 0, force)
	if(!force)
		if(mob_property_flags & (MOB_UNDEAD|MOB_CONSTRUCT|MOB_ROBOTIC|MOB_HOLOGRAPHIC|MOB_SUPERNATURAL))
			return 0

	spawn()
		if(forever)
			new /obj/structure/closet/statue/eternal(get_turf(src), src)
		else
			new /obj/structure/closet/statue(get_turf(src), src)

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
	src.throw_mode_off()
	if(usr.stat || !target)
		return FAILED_THROW

	if(!istype(loc,/turf))
		to_chat(src, "<span class='warning'>You can't do that now!</span>")
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
				if(!iscarbon(usr))
					M.LAssailant = null
				else
					M.LAssailant = usr
				returnToPool(G)
	if(!item)
		return FAILED_THROW	//Grab processing has a chance of returning null

	var/obj/item/I = item
	if(istype(I) && I.cant_drop > 0)
		to_chat(usr, "<span class='warning'>It's stuck to your hand!</span>")
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
			if(M_HULK in H.mutations || M_STRONG in H.mutations)
				throw_mult+=0.5
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
		"is_ventcrawling",
		"suiciding")

	reset_vars_after_duration(resettable_vars, duration)
