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

/mob/living/Destroy()
	for(var/mob/living/silicon/robot/mommi/MoMMI in player_list)
		for(var/image/I in static_overlays)
			MoMMI.static_overlays.Remove(I) //no checks, since it's either there or its not
			MoMMI.client.images.Remove(I)
			del(I)
	if(static_overlays)
		static_overlays = null
	. = ..()

/mob/living/Life()
	..()
	if (flags & INVULNERABLE)
		bodytemperature = initial(bodytemperature)
	if (monkeyizing)	return
	if(!loc)			return	// Fixing a null error that occurs when the mob isn't found in the world -- TLE
	if(reagents && reagents.has_reagent("bustanut"))
		if(!(M_HARDCORE in mutations))
			mutations.Add(M_HARDCORE)
			src << "<span class='notice'>You feel like you're the best around.  Nothing's going to get you down.</span>"
	else
		if(M_HARDCORE in mutations)
			mutations.Remove(M_HARDCORE)
			src << "<span class='notice'>You feel like a pleb.</span>"
	handle_beams()

	//handles "call on life", allowing external life-related things to be processed
	for(var/toCall in src.callOnLife)
		if(locate(toCall) && callOnLife[toCall])
			call(locate(toCall),callOnLife[toCall])()
		else callOnLife -= toCall

	if(mind)
		if(mind in ticker.mode.implanted)
			if(implanting) return
			//world << "[src.name]"
			var/datum/mind/head = ticker.mode.implanted[mind]
			//var/list/removal
			if(!(locate(/obj/item/weapon/implant/traitor) in src.contents))
				//world << "doesn't have an implant"
				ticker.mode.remove_traitor_mind(mind, head)
				/*
				if((head in ticker.mode.implanters))
					ticker.mode.implanter[head] -= src.mind
				ticker.mode.implanted -= src.mind
				if(src.mind in ticker.mode.traitors)
					ticker.mode.traitors -= src.mind
					special_role = null
					current << "<span class='danger'><FONT size = 3>The fog clouding your mind clears. You remember nothing from the moment you were implanted until now..(You don't remember who enslaved you)</FONT></span>"
				*/

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
		C << "<span class='sinister'>The Geometer of Blood is overjoyed to be reunited with its followers, and accepts your body in sacrifice. As reward, you have been gifted with the shell of an Harvester.<br>Your tendrils can use and draw runes without need for a tome, your eyes can see beings through walls, and your mind can open any door. Use these assets to serve Nar-Sie and bring him any remaining living human in the world.<br>You can teleport yourself back to Nar-Sie along with any being under yourself at any time using your \"Harvest\" spell.</span>"
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
		G << "<span class='sinister'>You feel relieved as what's left of your soul finally escapes its prison of flesh.</span>"

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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/mob/living/verb/succumb()  called tick#: [world.time]")
	if ((src.health < 0 && src.health > -95.0))
		src.attack_log += "[src] has succumbed to death with [health] points of health!"
		src.apply_damage(maxHealth + 5 + src.health, OXY) // This will ensure people die when using the command, but don't go into overkill. 15 oxy points over the limit for safety since brute and burn regenerates
		src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss()
		src << "<span class='info'>You have given up life and succumbed to death.</span>"


/mob/living/proc/updatehealth()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/updatehealth() called tick#: [world.time]")
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else if(!(flags & INVULNERABLE))
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(var/pressure)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/calculate_affecting_pressure() called tick#: [world.time]")
	return 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/burn_skin() called tick#: [world.time]")
	if(istype(src, /mob/living/carbon/human))
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
		if(M_NO_SHOCK in src.mutations) //shockproof
			return 0
		if (M_RESIST_HEAT in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/extradam = 0	//added to when organ is at max dam
		for(var/datum/organ/external/affecting in H.organs)
			if(!affecting)	continue
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/adjustBodyTemp() called tick#: [world.time]")
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
//		world << "[src] ~ [src.bodytemperature] ~ [temperature]"
	return temperature


// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn
// I touched them without asking... I'm soooo edgy ~Erro (added nodamage checks)

/mob/living/proc/getBruteLoss()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/getBruteLoss() called tick#: [world.time]")
	return bruteloss

/mob/living/proc/adjustBruteLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/adjustBruteLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	bruteloss = min(max(bruteloss + amount, 0),(maxHealth*2))

/mob/living/proc/getOxyLoss()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/getOxyLoss() called tick#: [world.time]")
	return oxyloss

/mob/living/proc/adjustOxyLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/adjustOxyLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = min(max(oxyloss + amount, 0),(maxHealth*2))

/mob/living/proc/setOxyLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/setOxyLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = amount

/mob/living/proc/getToxLoss()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/getToxLoss() called tick#: [world.time]")
	return toxloss

/mob/living/proc/adjustToxLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/adjustToxLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = min(max(toxloss + amount, 0),(maxHealth*2))

/mob/living/proc/setToxLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/setToxLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = amount

/mob/living/proc/getFireLoss()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/getFireLoss() called tick#: [world.time]")
	return fireloss

/mob/living/proc/adjustFireLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/adjustFireLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	fireloss = min(max(fireloss + amount, 0),(maxHealth*2))

/mob/living/proc/getCloneLoss()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/getCloneLoss() called tick#: [world.time]")
	return cloneloss

/mob/living/proc/adjustCloneLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/adjustCloneLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = min(max(cloneloss + amount, 0),(maxHealth*2))

/mob/living/proc/setCloneLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/setCloneLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = amount

/mob/living/proc/getBrainLoss()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/getBrainLoss() called tick#: [world.time]")
	return brainloss

/mob/living/proc/adjustBrainLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/adjustBrainLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = min(max(brainloss + amount, 0),(maxHealth*2))

/mob/living/proc/setBrainLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/setBrainLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = amount

/mob/living/proc/getHalLoss()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/getHalLoss() called tick#: [world.time]")
	return halloss

/mob/living/proc/adjustHalLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/adjustHalLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = min(max(halloss + amount, 0),(maxHealth*2))

/mob/living/proc/setHalLoss(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/setHalLoss() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = amount

/mob/living/proc/getMaxHealth()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/getMaxHealth() called tick#: [world.time]")
	return maxHealth

/mob/living/proc/setMaxHealth(var/newMaxHealth)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/setMaxHealth() called tick#: [world.time]")
	maxHealth = newMaxHealth

// ++++ROCKDTBEN++++ MOB PROCS //END


/mob/proc/get_contents()

	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/proc/get_contents() called tick#: [world.time]")


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

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += src.contents
		for(var/obj/item/weapon/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/clothing/suit/storage/S in src.contents)//Check for labcoats and jackets
			L += get_contents(S)
		for(var/obj/item/clothing/accessory/storage/S in src.contents)//Check for holsters
			L += get_contents(S)
		for(var/obj/item/weapon/gift/G in src.contents) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in src.contents) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

/mob/living/proc/can_inject()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/can_inject() called tick#: [world.time]")
	return 1

/mob/living/proc/electrocute_act(const/shock_damage, const/obj/source, const/siemens_coeff = 1.0)
	  //writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/electrocute_act() called tick#: [world.time]")
	  return 0 // only carbon liveforms have this proc
				// now with silicons

/mob/living/emp_act(severity)
	if(flags & INVULNERABLE)
		return

	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/mob/living/proc/get_organ_target()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/get_organ_target() called tick#: [world.time]")
	var/t = src.zone_sel.selecting
	if ((t in list( "eyes", "mouth" )))
		t = "head"
	var/datum/organ/external/def_zone = ran_zone(t)
	return def_zone


// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(var/brute, var/burn)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/heal_organ_damage() called tick#: [world.time]")
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(var/brute, var/burn)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/take_organ_damage() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	if(flags & INVULNERABLE)	return 0
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/heal_overall_damage() called tick#: [world.time]")
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn, var/used_weapon = null)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/take_overall_damage() called tick#: [world.time]")
	if(status_flags & GODMODE)	return 0	//godmode
	if(flags & INVULNERABLE)	return 0
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

/mob/living/proc/restore_all_organs()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/restore_all_organs() called tick#: [world.time]")
	return

/*
NOTE TO ANYONE MAKING A PROC THAT USES REVIVE/REJUVENATE:
If the proc calling either of these is:
	-meant to be an admin/overpowered revival proc, make sure you set suiciding = 0
	-meant to be something that a player uses to heal/revive themself or others, check if suiciding = 1 and prevent them from reviving if true.
Thanks.
*/

/mob/living/proc/revive(animation = 0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/revive() called tick#: [world.time]")
	rejuvenate(animation)
	/*
	buckled = initial(src.buckled)
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

	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/rejuvenate() called tick#: [world.time]")

	var/turf/T = get_turf(src)
	if(animation) T.turf_animation('icons/effects/64x64.dmi',"rejuvinate",-16,0,MOB_LAYER+1,'sound/effects/rejuvinate.ogg')

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)
	germ_level = 0
	next_pain_time = 0
	traumatic_shock = 0
	radiation = 0
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
	if(buckled)
		buckled.unbuckle()
	buckled = initial(src.buckled)
	*/
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		H.timeofdeath = 0
		H.vessel.reagent_list = list()
		H.vessel.add_reagent("blood",560)
		H.shock_stage = 0
		spawn(1)
			H.fixblood()
		for(var/organ_name in H.organs_by_name)
			var/datum/organ/external/O = H.organs_by_name[organ_name]
			for(var/obj/item/weapon/shard/shrapnel/s in O.implants)
				if(istype(s))
					O.implants -= s
					H.contents -= s
					del(s)
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
		dead_mob_list -= src
		living_mob_list += src
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/UpdateDamageIcon() called tick#: [world.time]")
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/Examine_OOC() called tick#: [world.time]")

	if(config.allow_Metadata)
		if(client)
			usr << "[src]'s Metainfo:<br>[client.prefs.metadata]"
		else
			usr << "[src] does not have any stored infomation!"
	else
		usr << "OOC Metadata is not supported by this server!"

	return

/mob/living/Move(atom/newloc, direct)
	if (buckled && buckled.loc != newloc)
		if (!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

	if (restrained())
		stop_pulling()


	var/t7 = 1
	if (restrained())
		for(var/mob/living/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if (t7 && pulling && (Adjacent(pulling) || pulling.loc == loc))
		var/turf/T = loc
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
									visible_message("<span class='danger'>[src] has pulled [G.affecting] from [G.assailant]'s grip.</span>")
									qdel(G)
							else
								ok = 0
							if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
								ok = 0
						if (ok)
							var/atom/movable/t = M.pulling
							M.stop_pulling()
							pulling.Move(T, get_dir(pulling, T))
							if(M)
								M.start_pulling(t)
					else
						if (pulling)
							pulling.Move(T, get_dir(pulling, T))
				else
					stop_pulling()
	else
		stop_pulling()
		. = ..()
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)

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
	// Update on_moved listeners.
	INVOKE_EVENT(on_moved,list("loc"=loc))

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/mob/living/verb/resist()  called tick#: [world.time]")

	if(!isliving(usr) || usr.special_delayer.blocked())
		return
	delayNext(DELAY_ALL,20) // Attack, Move, and Special.

	var/mob/living/L = usr

	//Getting out of someone's inventory.
	if(istype(src.loc,/obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.loc
		src.loc = get_turf(src.loc)
		if(istype(H.loc, /mob/living))
			var/mob/living/Location = H.loc
			Location.drop_from_inventory(H)
		del(H)
		return

	//Resisting control by an alien mind.
	if(istype(src.loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = src.loc
		var/mob/living/captive_brain/H = src

		H << "<span class='danger'>You begin doggedly resisting the parasite's control (this will take approximately sixty seconds).</span>"
		B.host << "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>"

		spawn(rand(350,450)+B.host.brainloss)

			if(!B || !B.controlling)
				return

			B.host.adjustBrainLoss(rand(5,10))
			H << "<span class='danger'>With an immense exertion of will, you regain control of your body!</span>"
			B.host << "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>"

			var/mob/living/carbon/C=B.host
			C.do_release_control(0) // Was detach().

			return

	//resisting grabs (as if it helps anyone...)
	if ((!(L.stat) && L.canmove && !(L.restrained())))
		var/resisting = 0
		for(var/obj/O in L.requests)
			L.requests.Remove(O)
			del(O)
			resisting++
		for(var/obj/item/weapon/grab/G in usr.grabbed_by)
			resisting++
			if (G.state == GRAB_PASSIVE)
				returnToPool(G)
			else
				if (G.state == GRAB_AGGRESSIVE)
					if (prob(25))
						L.visible_message("<span class='danger'>[L] has broken free of [G.assailant]'s grip!</span>")
						returnToPool(G)
				else
					if (G.state == GRAB_NECK)
						if (prob(5))
							L.visible_message("<span class='danger'>[L] has broken free of [G.assailant]'s headlock!</span>")
							returnToPool(G)
		if(resisting)
			L.visible_message("<span class='danger'>[L] resists!</span>")


	//unbuckling yourself
	if(L.buckled && L.special_delayer.blocked())
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if(C.handcuffed)
				C.delayNextAttack(100)
				C.delayNextSpecial(100)
				C.visible_message("<span class='warning'>[C] attempts to unbuckle themself!</span>",
								  "<span class='warning'>You attempt to unbuckle yourself. (This will take around two minutes and you need to stand still).</span>")
				spawn(0)
					if(do_after(usr, usr, 1200))
						if(!C.buckled)
							return
						C.visible_message("<span class='danger'>[C] manages to unbuckle themself!</span>",
										  "<span class='notice'>You successfully unbuckle yourself.</span>")
						C.buckled.manual_unbuckle(C)
					else
						C << "<span class='warning'>Your unbuckling attempt was interrupted.</span>"
		else
			L.buckled.manual_unbuckle(L)

	//Breaking out of a locker?
	if(src.loc && (istype(src.loc, /obj/structure/closet)))
		var/breakout_time = 2 //2 minutes by default

		var/obj/structure/closet/C = L.loc
		if(C.opened)
			return //Door's open... wait, why are you in it's contents then?
		if(istype(L.loc, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/SC = L.loc
			if(!SC.locked && !SC.welded)
				return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'
		else
			if(!C.welded)
				return //closed but not welded...
		//	else Meh, lets just keep it at 2 minutes for now
		//		breakout_time++ //Harder to get out of welded lockers than locked lockers

		//okay, so the closet is either welded or locked... resist!!!
		L.delayNext(DELAY_ALL,100)
		L.visible_message("<span class='danger'>The [C] begins to shake violenty!</span>",
						  "<span class='warning'>You lean on the back of [C] and start pushing the door open (this will take about [breakout_time] minutes).</span>")
		spawn(0)
			if(do_after(usr,src,breakout_time * 60 * 10)) //minutes * 60seconds * 10deciseconds
				if(!C || !L || L.stat != CONSCIOUS || L.loc != C || C.opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
					return

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
									  "<span class='notice'>You successful break out!</span>")
					if(istype(SC.loc, /obj/structure/bigDelivery)) //Do this to prevent contents from being opened into nullspace (read: bluespace)
						var/obj/structure/bigDelivery/BD = SC.loc
						BD.attack_hand(usr)
					SC.open()
				else
					C.welded = 0
					L.visible_message("<span class='danger'>[L] successful breaks out of [C]!</span>",
									  "<span class='notice'>You successfully break out!</span>")
					if(istype(C.loc, /obj/structure/bigDelivery)) //nullspace ect.. read the comment above
						var/obj/structure/bigDelivery/BD = C.loc
						BD.attack_hand(usr)
					C.open()

	//breaking out of handcuffs
	else if(iscarbon(L))
		var/mob/living/carbon/CM = L
		if(CM.on_fire && CM.canmove)
			CM.fire_stacks -= 5
			CM.weakened = 5
			CM.visible_message("<span class='danger'>[CM] rolls on the floor, trying to put themselves out!</span>",
							   "<span class='warning'>You stop, drop, and roll!</span>")
			if(fire_stacks <= 0)
				CM.visible_message("<span class='danger'>[CM] has successfully extinguished themselves!</span>",
								   "<span class='notice'>You extinguish yourself.</span>")
				ExtinguishMob()
			return
		if(CM.handcuffed && CM.canmove && CM.special_delayer.blocked())
			CM.delayNext(DELAY_ALL,100)
			if(isalienadult(CM) || (M_HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				CM.visible_message("<span class='danger'>[CM] is trying to break the handcuffs!</span>",
								   "<span class='warning'>You attempt to break your handcuffs. (This will take around five seconds and you will need to stand still).</span>")
				spawn(0)
					if(do_after(CM, CM, 50))
						if(!CM.handcuffed || CM.buckled)
							return
						CM.visible_message("<span class='danger'>[CM] manages to break the handcuffs!</span>",
										   "<span class='notice'>You successful break your handcuffs.</span>")
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						del(CM.handcuffed)
						CM.handcuffed = null
						CM.update_inv_handcuffed()
					else
						CM << "<span class='warning'>Your cuff breaking attempt was interrupted.</span>"


			else
				var/obj/item/weapon/handcuffs/HC = CM.handcuffed
				var/breakouttime = HC.breakouttime
				if(!(breakouttime))
					breakouttime = 1200 //Default
				CM.visible_message("<span class='danger'>[CM] attempts to remove [HC]!</span>",
								   "<span class='warning'>You attempt to remove [HC]. (This will take around [(breakouttime)/600] minutes and you need to stand still).</span>")
				spawn(0)
					if(do_after(CM,CM, breakouttime))
						if(!CM.handcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server
						CM.visible_message("<span class='danger'>[CM] manages to remove [HC]!</span>",
										   "<span class='notice'>You successful remove [HC].</span>")
						CM.handcuffed.loc = usr.loc
						CM.handcuffed = null
						CM.update_inv_handcuffed()
					else
						CM << "<span class='warning'>Your uncuffing attempt was interrupted.</span>"

		else if(CM.legcuffed && CM.canmove && CM.special_delayer.blocked())
			CM.delayNext(DELAY_ALL,100)
			if(isalienadult(CM) || (M_HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				CM.visible_message("<span class='danger'>[CM] is trying to break the legcuffs!</span>",
								   "<span class='warning'>You attempt to break your legcuffs. (This will take around five seconds and you need to stand still).</span>")
				spawn(0)
					if(do_after(CM, CM, 50))
						if(!CM.legcuffed || CM.buckled)
							return
						CM.visible_message("<span class='danger'>[CM] manages to break the legcuffs!</span>",
										   "<span class='notice'>You successfully break your legcuffs.</span>")
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						del(CM.legcuffed)
						CM.legcuffed = null
						CM.update_inv_legcuffed()
					else
						CM << "<span class='warning'>Your legcuffing breaking attempt was interrupted.</span>"
			else
				var/obj/item/weapon/legcuffs/HC = CM.legcuffed
				var/breakouttime = HC.breakouttime
				if(!(breakouttime))
					breakouttime = 1200 //Default
				CM.visible_message("<span class='danger'>[CM] attempts to remove [HC]!</span>",
								   "<span class='warning'>You attempt to remove [HC]. (This will take around [(breakouttime)/600] minutes and you need to stand still).</span>")
				spawn(0)
					if(do_after(CM, CM, breakouttime))
						if(!CM.legcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server
						CM.visible_message("<span class='danger'>[CM] manages to remove [HC]!</span>",
										   "<span class='notice'>You successful remove [HC].</span>")
						CM.legcuffed.loc = usr.loc
						CM.legcuffed = null
						CM.update_inv_legcuffed()
					else
						CM << "<span class='warning'>Your unlegcuffing attempt was interrupted.</span>"
/mob/living/verb/lay_down()
	set name = "Rest"
	set category = "IC"

	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/mob/living/verb/lay_down()  called tick#: [world.time]")
	resting = !resting
	src << "<span class='notice'>You are now [resting ? "resting" : "getting up"]</span>"

/mob/living/proc/has_brain()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/has_brain() called tick#: [world.time]")
	return 1

/mob/living/proc/has_eyes()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/has_eyes() called tick#: [world.time]")
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

/mob/living/proc/InCritical()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/InCritical() called tick#: [world.time]")
	return (src.health < 0 && src.health > -95.0 && stat == UNCONSCIOUS)

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/mob/living/verb/pulled()  called tick#: [world.time]")
	if(AM.Adjacent(src))
		src.start_pulling(AM)
	return

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(src.stat || !src.canmove || src.restrained())
		return 0
	if(src.status_flags & FAKEDEATH)
		return 0
	if(!..())
		return 0
	usr.visible_message("<b>[src]</b> points to [A]")
	return 1


/mob/living/proc/generate_static_overlay()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/generate_static_overlay() called tick#: [world.time]")
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

/*one proc, four uses
swapping: if it's 1, the mobs are trying to switch, if 0, non-passive is pushing passive
default behaviour is:
 - non-passive mob passes the passive version
 - passive mob checks to see if its mob_bump_flag is in the non-passive's mob_bump_flags
 - if si, the proc returns
*/
/mob/living/proc/can_move_mob(var/mob/living/swapped, swapping = 0, passive = 0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/proc/can_move_mob() called tick#: [world.time]")
	if(!swapped)
		return 1
	if(!passive)
		return swapped.can_move_mob(src, swapping, 1)
	else
		var/context_flags = 0
		if(swapping)
			context_flags = swapped.mob_swap_flags
		else
			context_flags = swapped.mob_push_flags
		if(!mob_bump_flag) //nothing defined, go wild
			return 1
		if(mob_bump_flag & context_flags)
			return 1
		return 0

/mob/living/Bump(atom/movable/AM as mob|obj, yes)
	spawn(0)
		if ((!( yes ) || now_pushing) || !loc)
			return
		now_pushing = 1
		if (istype(AM, /mob/living))
			var/mob/living/tmob = AM

			for(var/mob/living/M in range(tmob, 1))
				if(tmob.pinned.len ||  ((M.pulling == tmob && ( tmob.restrained() && !( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, tmob.grabbed_by.len)) )
					if ( !(world.time % 5) )
						src << "<span class='warning'>[tmob] is restrained, you cannot push past</span>"
					now_pushing = 0
					return
				if( tmob.pulling == M && ( M.restrained() && !( tmob.restrained() ) && tmob.stat == 0) )
					if ( !(world.time % 5) )
						src << "<span class='warning'>[tmob] is restraining [M], you cannot push past</span>"
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
						dense = !A.CanPass(src, src.loc)
					else
						dense = 1
				if(dense) break
			if((tmob.a_intent == I_HELP || tmob.restrained()) && (a_intent == I_HELP || src.restrained()) && tmob.canmove && canmove && !dense && can_move_mob(tmob, 1, 0)) // mutual brohugs all around!
				var/turf/oldloc = loc
				loc = tmob.loc
				tmob.loc = oldloc
				now_pushing = 0
				for(var/mob/living/carbon/slime/slime in view(1,tmob))
					if(slime.Victim == tmob)
						slime.UpdateFeed()
				return

			if(!can_move_mob(tmob, 0, 0))
				now_pushing = 0
				return
			if(istype(tmob, /mob/living/carbon/human) && (M_FAT in tmob.mutations))
				if(prob(40) && !(M_FAT in src.mutations))
					src << "<span class='danger'>You fail to push [tmob]'s fat ass out of the way.</span>"
					now_pushing = 0
					return
			if(tmob.r_hand && istype(tmob.r_hand, /obj/item/weapon/shield/riot))
				if(prob(99))
					now_pushing = 0
					return
			if(tmob.l_hand && istype(tmob.l_hand, /obj/item/weapon/shield/riot))
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
