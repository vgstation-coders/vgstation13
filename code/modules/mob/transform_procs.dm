#define MONKEY_ANIM_TIME 22

// A standardized proc for turning a mob into a monkey
// ignore_primitive will force the mob to specifically become a monkey and not its primitive type
// returns the monkey mob

/mob/proc/Premorph(var/delete_items = FALSE)
	if(monkeyizing)
		return FALSE
	regenerate_icons()
	monkeyizing = TRUE
	canmove = FALSE
	icon = null
	overlays.Cut()
	invisibility = 101
	delayNextAttack(50)

	if(isrobot(src)) //Don't leave your brain behind.
		var/mob/living/silicon/robot/sillycone = src
		if(sillycone.mmi)
			qdel(sillycone.mmi)
	else
		if(iscarbon(src))
			var/mob/living/carbon/carbo = src
			carbo.dropBorers()

		if(ishuman(src))
			var/mob/living/carbon/human/humie = src
			for(var/t in humie.organs)//this really should not be necessary
				qdel(t)

	for(var/obj/item/W in src)
		if(istype(W, /obj/item/weapon/implant))
			qdel(W)
			continue
		if(delete_items || issilicon(src)) //Don't drop your non-module crap(holomap, radio, yadda yadda).
			qdel(W)
		else
			drop_from_inventory(W)

/mob/proc/Postmorph(var/mob/new_mob = null)
	if(!new_mob)
		return

	if(mind)
		mind.transfer_to(new_mob)
	else
		new_mob.key = key

	new_mob.a_intent = a_intent

	qdel(src)


/mob/proc/monkeyize(var/ignore_primitive = FALSE)
	if(ismonkey(src))
		return FALSE

	Premorph()

	if(isturf(loc)) // no need to do animations if we're inside something
		var/atom/movable/overlay/animation = new(loc)
		animation.icon_state = "blank"
		animation.icon = 'icons/mob/mob.dmi'
		animation.master = src
		flick("h2monkey", animation)
		sleep(MONKEY_ANIM_TIME)
		animation.master = null
		qdel(animation)

	var/mob/living/carbon/monkey/Mo

	if(ignore_primitive || !ishuman(src))
		Mo = new /mob/living/carbon/monkey(loc)
	else
		var/mob/living/carbon/human/H = src
		if(!H.species.primitive)
			H.gib()
			return FALSE
		Mo = new H.species.primitive(loc)
		Mo.dna = H.dna.Clone()
		if(!Mo.dna.GetSEState(MONKEYBLOCK)) // make sure our copied dna has the right monkey blocks
			Mo.dna.SetSEState(MONKEYBLOCK,TRUE)
			Mo.dna.SetSEValueRange(MONKEYBLOCK, 0xDAC, 0xFFF)
	if(isliving(src))
		var/mob/living/L = src
		Mo.suiciding = L.suiciding
		Mo.take_overall_damage(L.getBruteLoss(), L.getFireLoss())
		Mo.setToxLoss(L.getToxLoss())
		Mo.setOxyLoss(L.getOxyLoss())
		Mo.stat = L.stat
		for(var/datum/disease/D in L.viruses)
			Mo.viruses += D
			D.affected_mob = Mo
			L.viruses -= D //But why?
	Mo.delayNextAttack(0)

	Postmorph(Mo)

	return Mo

/mob/proc/Cluwneize()
	Premorph()

	var/mob/living/simple_animal/hostile/retaliate/cluwne/new_mob = new (get_turf(src))
	new_mob.setGender(gender)
	new_mob.name = pick(clown_names)
	new_mob.real_name = new_mob.name
	new_mob.mutations += M_CLUMSY
	new_mob.mutations += M_FAT
	new_mob.setBrainLoss(100)

	Postmorph(new_mob)

	to_chat(new_mob, "<span class='sinister'>Instantly, what was your clothes fall off, and are replaced with a mockery of all that is clowning; Disgusting-looking garb that the foulest of creatures would be afraid of wearing. Your very face begins to shape, mold, into something truely disgusting. A mask made of flesh. Your body is feeling the worst pain it has ever felt. As you think it cannot get any worse, one of your arms turns into a horrific meld of flesh and plastic, making a limb made entirely of bike horns.</span>")
	to_chat(new_mob, "<span class='sinister'>Your very soul is being torn apart. What was organs, blood, flesh, is now darkness. And inside the infernal void that was once a living being, something sinister takes root. As what you were goes away, you try to let out a frantic plea of 'Help me! Please god help me!' but your god has abandoned you, and all that leaves your horrible mouth is a strangled 'HONK!'.</span>")
	new_mob.say("HONK!")

	return new_mob

/mob/new_player/AIize(var/spawn_here = FALSE, var/del_mob = TRUE)
	spawning = TRUE
	return ..()

/mob/proc/AIize(var/spawn_here = FALSE, var/del_mob = TRUE)
	Premorph()

	if(client)
		src << sound(null, repeat = FALSE, wait = FALSE, volume = 85, channel = CHANNEL_LOBBY)// stop the jams for AIs

	var/mob/living/silicon/ai/O = new (get_turf(src), base_law_type,,1)//No MMI but safety is in effect.
	O.invisibility = 0
	O.aiRestorePowerRoutine = 0

	if(mind)
		mind.transfer_to(O)
		O.mind.original = O
	else
		O.key = key

	var/obj/loc_landmark

	if(!spawn_here)
		for(var/obj/effect/landmark/start/sloc in landmarks_list)
			if (sloc.name != "AI")
				continue
			if (locate(/mob/living) in sloc.loc)
				continue
			loc_landmark = sloc
		if (!loc_landmark)
			for(var/obj/effect/landmark/tripai in landmarks_list)
				if (tripai.name == "tripai")
					if(locate(/mob/living) in tripai.loc)
						continue
					loc_landmark = tripai
		if (!loc_landmark)
			to_chat(O, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.")
			for(var/obj/effect/landmark/start/sloc in landmarks_list)
				if (sloc.name == "AI")
					loc_landmark = sloc

		O.forceMove(loc_landmark.loc)
		for (var/obj/item/device/radio/intercom/comm in O.loc)
			comm.ai += O

	to_chat(O, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
	to_chat(O, "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>")
	to_chat(O, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
	to_chat(O, "To use something, simply click on it.")
	to_chat(O, {"Use say ":b to speak to your cyborgs through binary."})
	if (!(ticker && ticker.mode && (O.mind in ticker.mode.malf_ai)))
		O.show_laws()
		to_chat(O, "<b>These laws may be changed by other players, or by you being the traitor.</b>")

	O.verbs += /mob/living/silicon/ai/proc/show_laws_verb
	O.verbs += /mob/living/silicon/ai/proc/ai_statuschange

	O.job = "AI"

	O.rename_self("ai",1)
	. = O
	if(del_mob)
		qdel(src)


//human -> robot
/mob/proc/Robotize(var/delete_items = FALSE, var/skipnaming=FALSE)
	Premorph(delete_items)

	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(src))
	. = O

	if(mind)		//TODO
		mind.transfer_to(O)
		if(O.mind.assigned_role == "Cyborg")
			O.mind.original = O
		else if(mind && mind.special_role)
			O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		O.key = key

	O.forceMove(loc)
	O.mmi = new /obj/item/device/mmi(O)
	O.mmi.transfer_identity(src)//Does not transfer key/client.

	if(jobban_isbanned(O, "Cyborg")) //You somehow managed to get borged, congrats.
		to_chat(src, "<span class='warning' style=\"font-family:Courier\">WARNING: Illegal operation detected.</span>")
		to_chat(src, "<span class='danger'>Self-destruct mechanism engaged.</span>")
		O.self_destruct()
		message_admins("[key_name(O)] was forcefully transformed into a [job] and had its self-destruct mechanism engaged.")
		log_game("[key_name(O)] was forcefully transformed into a [job] and had its self-destruct mechanism engaged.")

	if(!skipnaming)
		O.Namepick()

	qdel(src)

	return O


//human -> mommi
/mob/proc/MoMMIfy(round_start = FALSE)
	Premorph()

	var/mob/living/silicon/robot/mommi/O = new /mob/living/silicon/robot/mommi/nt(get_turf(src))
	. = O

	if(!O.cell) // MoMMIs' New() is suposed to give them a battery but JUST TO BE SURE.
		O.cell = new(O)
	O.cell.maxcharge = (round_start ? 10000 : 15000)
	O.cell.charge = (round_start ? 10000 : 15000)

	if(mind)		//TODO
		mind.transfer_to(O)
		if(O.mind.assigned_role == "Cyborg")
			O.mind.original = O
		else if(mind && mind.special_role)
			O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		O.key = key

	O.forceMove(loc)
	O.mmi = new /obj/item/device/mmi(O)
	O.mmi.transfer_identity(src)//Does not transfer key/client.

	if(jobban_isbanned(O, "Mobile MMI")) //You somehow managed to get MoMMI'd, congrats.
		to_chat(src, "<span class='warning' style=\"font-family:Courier\">WARNING: Illegal operation detected.</span>")
		to_chat(src, "<span class='danger'>Self-destruct mechanism engaged.</span>")
		O.self_destruct()
		message_admins("[key_name(O)] was forcefully transformed into a [job] and had its self-destruct mechanism engaged.")
		log_game("[key_name(O)] was forcefully transformed into a [job] and had its self-destruct mechanism engaged.")

	O.Namepick()

	qdel(src)

	return O

//human -> alien
/mob/proc/Alienize()
	Premorph()

	var/alien_caste = pick("Hunter","Sentinel","Drone")
	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(get_turf(src))
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(get_turf(src))
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(get_turf(src))

	Postmorph(new_xeno)

	to_chat(new_xeno, "<B>You are now an alien.</B>")

	return new_xeno

/mob/proc/slimeize(adult as num, reproduce as num)
	Premorph()

	var/mob/living/carbon/slime/new_slime

	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i=1,i<=number,i++)
			var/mob/living/carbon/slime/M = new/mob/living/carbon/slime(get_turf(src))
			M.nutrition = round(nutrition/number)
			step_away(M,src)
			babies += M
		new_slime = pick(babies)
	else
		if(adult)
			new_slime = new /mob/living/carbon/slime/adult(get_turf(src))
		else
			new_slime = new /mob/living/carbon/slime(get_turf(src))

	Postmorph(new_slime)

	to_chat(new_slime, "<B>You are now a slime.</B>")

	return new_slime

/mob/proc/corgize()
	Premorph()

	var/mob/living/simple_animal/corgi/new_corgi = new /mob/living/simple_animal/corgi (get_turf(src))

	Postmorph(new_corgi)

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")

	return new_corgi

/mob/proc/Humanize(var/new_species = "null")
	Premorph()
	var/mob/living/carbon/human/new_human = new /mob/living/carbon/human(loc, delay_ready_dna=TRUE)

	if((gender == MALE) || (gender == FEMALE)) //If the transformed mob is MALE or FEMALE
		new_human.setGender(gender) //The new human will inherit its gender
	else //If its gender is NEUTRAL or PLURAL,
		new_human.setGender(pick(MALE, FEMALE)) //The new human's gender will be random

	var/datum/preferences/A = new()	//Randomize appearance for the human
	A.randomize_appearance_for(new_human)

	if(!new_species)
		new_species = pick(all_species-"Krampus")
	new_human.set_species(new_species)
	new_human.languages |= languages
	if(isliving(src))
		var/mob/living/L = src
		new_human.default_language = L.default_language
	new_human.generate_name()

	Postmorph(new_human)

	return new_human

/mob/proc/Frankensteinize()
	Premorph()

	var/mob/living/carbon/human/frankenstein/new_frank = new /mob/living/carbon/human/frankenstein(loc, delay_ready_dna=TRUE)

	if((gender == MALE) || (gender == FEMALE)) //If the transformed mob is MALE or FEMALE
		new_frank.setGender(gender) //The new human will inherit its gender
	else //If its gender is NEUTRAL or PLURAL,
		new_frank.setGender(pick(MALE, FEMALE)) //The new human's gender will be random
	new_frank.generate_name()

	Postmorph(new_frank)

	return new_frank

/mob/proc/Animalize()
	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return

	Premorph()

	var/mob/new_mob = new mobpath(get_turf(src))

	Postmorph(new_mob)

	to_chat(new_mob, "You feel more... animalistic")

	return new_mob

/* Certain mob types have problems and should not be allowed to be controlled by players.
 *
 * This proc is here to force coders to manually place their mob in this list, hopefully tested.
 * This also gives a place to explain -why- players shouldnt be turn into certain mobs and hopefully someone can fix them.
 */
/mob/proc/safe_animal(var/MP)

//Bad mobs! - Remember to add a comment explaining what's wrong with the mob
	if(!MP)
		return FALSE	//Sanity, this should never happen.

	if(ispath(MP, /mob/living/simple_animal/space_worm))
		return FALSE //Unfinished. Very buggy, they seem to just spawn additional space worms everywhere and eating your own tail results in new worms spawning.

	if(ispath(MP, /mob/living/simple_animal/construct/behemoth))
		return FALSE //I think this may have been an unfinished WiP or something. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/armoured))
		return FALSE //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/wraith))
		return FALSE //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/builder))
		return FALSE //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

//Good mobs!
	if(ispath(MP, /mob/living/simple_animal/cat))
		return TRUE
	if(ispath(MP, /mob/living/simple_animal/corgi))
		return TRUE
	if(ispath(MP, /mob/living/simple_animal/crab))
		return TRUE
	if(ispath(MP, /mob/living/simple_animal/hostile/carp))
		return TRUE
	if(ispath(MP, /mob/living/simple_animal/hostile/mushroom))
		return TRUE
	if(ispath(MP, /mob/living/simple_animal/shade))
		return TRUE
	if(ispath(MP, /mob/living/simple_animal/tomato))
		return TRUE
	if(ispath(MP, /mob/living/simple_animal/mouse))
		return TRUE
	if(ispath(MP, /mob/living/simple_animal/hostile/bear))
		return TRUE
	if(ispath(MP, /mob/living/simple_animal/parrot))
		return TRUE

	//Not in here? Must be untested!
	return FALSE

#undef MONKEY_ANIM_TIME
