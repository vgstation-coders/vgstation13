#define MONKEY_ANIM_TIME 22

// A standardized proc for turning a mob into a monkey
// ignore_primitive will force the mob to specifically become a monkey and not its primitive type
// returns the monkey mob

/mob/proc/Premorph(var/delete_items = FALSE)
	if(monkeyizing)
		return FALSE
	monkeyizing = TRUE
	canmove = FALSE
	invisibility = 101
	delayNextAttack(5 SECONDS)

	for(var/obj/item/W in src)
		if(istype(W, /obj/item/weapon/implant))
			qdel(W)
			continue
		if(delete_items || issilicon(src)) //Don't drop your non-module crap(holomap, radio, yadda yadda).
			qdel(W)
		else
			drop_from_inventory(W)
	return TRUE

/mob/living/carbon/Premorph(delete_items = FALSE)
	dropBorers()
	return ..()

/mob/proc/Postmorph(var/mob/new_mob = null, var/namepick = FALSE, var/namepick_message = null)
	if(!new_mob)
		return
	if(mind)
		mind.transfer_to(new_mob)
		//namepick
		if(namepick)
			if(!namepick_message)
				namepick_message = "You have been transformed! You can pick a new name, or leave this empty to keep your current one."
			spawn(10)
				var/newname
				for(var/i = 1 to 3)
					newname = reject_bad_name(stripped_input(new_mob, namepick_message, "Name change [4-i] [0-i != 1 ? "tries":"try"] left",""),1,MAX_NAME_LEN)
					if(!newname || newname == "")
						if(alert(new_mob,"Are you sure you want to keep your current name?",,"Yes","No") == "Yes")
							break
					else
						if(alert(new_mob,"Do you really want the name:\n[newname]?",,"Yes","No") == "Yes")
							break
				if(newname)
					new_mob.name = new_mob.real_name = newname
	else
		new_mob.key = key
	new_mob.a_intent = a_intent
	qdel(src)


/mob/proc/monkeyize(var/ignore_primitive = TRUE, var/choose_name = FALSE)
	if(ismonkey(src)) //What's the point
		return
	if(!Premorph())
		return
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
	if(ignore_primitive)
		Mo = new /mob/living/carbon/monkey(loc)
	else
		var/mob/living/carbon/human/H = src
		if(!H.species || !H.species.primitive)
			H.gib()
			return
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
		Mo.virus2 = virus_copylist(L.virus2)
		if (L.immune_system)
			L.immune_system.transfer_to(Mo)
	Mo.delayNextAttack(0)
	Postmorph(Mo, choose_name, "You have been turned into a monkey! Pick a monkey name for your new monkey self.")
	return Mo

/mob/living/carbon/human/monkeyize(ignore_primitive = FALSE)
	.=..()

/mob/proc/Cluwneize()
	if(!Premorph())
		return
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
	if(!Premorph())
		return
	if(client)
		src << sound(null, repeat = FALSE, wait = FALSE, volume = 85, channel = CHANNEL_LOBBY)// stop the jams for AIs
	var/mob/living/silicon/ai/O = new (get_turf(src), base_law_type,,1)//No MMI but safety is in effect.
	O.invisibility = 0
	O.aiRestorePowerRoutine = 0
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
	if(mind)
		mind.transfer_to(O)
		O.mind.original = O
	else
		O.key = key
	O.verbs += /mob/living/silicon/ai/proc/show_laws_verb
	O.verbs += /mob/living/silicon/ai/proc/ai_statuschange
	O.job = "AI"
	O.rename_self("ai",1)
	. = O
	if(del_mob)
		qdel(src)

/mob/proc/Robotize(var/delete_items = FALSE, var/skipnaming=FALSE, var/malfAI=null)
	if(!Premorph(delete_items))
		return
	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(src), malfAI)
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
		message_admins("[key_name(O)] was forcefully transformed into a [job] and had its self-destruct mechanism engaged due \his job ban.")
		log_game("[key_name(O)] was forcefully transformed into a [job] and had its self-destruct mechanism engaged due \his job ban.")
	if(!skipnaming)
		spawn()
			O.Namepick()
	qdel(src)
	return O

/mob/proc/MoMMIfy()
	if(!Premorph())
		return
	var/mob/living/silicon/robot/mommi/O = new /mob/living/silicon/robot/mommi/nt(get_turf(src))
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
	if(jobban_isbanned(O, "Mobile MMI")) //You somehow managed to get MoMMI'd, congrats.
		to_chat(src, "<span class='warning' style=\"font-family:Courier\">WARNING: Illegal operation detected.</span>")
		to_chat(src, "<span class='danger'>Self-destruct mechanism engaged.</span>")
		O.self_destruct()
		message_admins("[key_name(O)] was forcefully transformed into a [job] and had its self-destruct mechanism engaged due \his job ban.")
		log_game("[key_name(O)] was forcefully transformed into a [job] and had its self-destruct mechanism engaged due \his job ban.")
	spawn()
		O.Namepick()
	qdel(src)
	return O

/mob/proc/Alienize(var/alien_caste = null)
	var/list/valid_alien_caste = list("Larva", "Hunter", "Sentinel", "Drone", "Queen", "Empress")
	if(!Premorph())
		return
	if(!alien_caste || !(alien_caste in valid_alien_caste))
		alien_caste = pick("Larva", "Hunter", "Sentinel", "Drone")
	var/mob/living/carbon/alien/new_xeno
	switch(alien_caste)
		if("Larva")
			new_xeno = new /mob/living/carbon/alien/larva(get_turf(src))
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(get_turf(src))
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(get_turf(src))
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(get_turf(src))
		if("Queen")
			new_xeno = new /mob/living/carbon/alien/humanoid/queen(get_turf(src))
		if("Empress")
			new_xeno = new /mob/living/carbon/alien/humanoid/queen/large(get_turf(src))
	Postmorph(new_xeno)
	to_chat(new_xeno, "<B>You are now a Xenomorph [alien_caste].</B>")
	return new_xeno

/mob/proc/slimeize(var/adult = FALSE, var/reproduce = FALSE)
	if(!Premorph())
		return
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
	if(!Premorph())
		return
	var/mob/living/simple_animal/corgi/new_corgi = new /mob/living/simple_animal/corgi(get_turf(src))
	Postmorph(new_corgi)
	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	return new_corgi

/mob/proc/Martianize()
	if(!Premorph())
		return
	var/mob/living/carbon/complex/martian/new_aunt = new /mob/living/carbon/complex/martian(get_turf(src))
	Postmorph(new_aunt)
	return new_aunt

/mob/proc/Humanize(var/new_species = null)
	if(!Premorph())
		return
	var/mob/living/carbon/human/new_human = new /mob/living/carbon/human(loc, delay_ready_dna=TRUE)
	if((gender == MALE) || (gender == FEMALE)) //If the transformed mob is MALE or FEMALE
		new_human.setGender(gender) //The new human will inherit its gender
	else //If its gender is NEUTRAL or PLURAL,
		new_human.setGender(pick(MALE, FEMALE)) //The new human's gender will be random
	var/datum/preferences/A = new()	//Randomize appearance for the human
	A.randomize_appearance_for(new_human)
	if(!new_species || !(new_species in all_species))
		var/list/restricted = list("Krampus", "Horror", "Manifested")
		new_species = pick(all_species - restricted)
	new_human.set_species(new_species)
	if(isliving(src))
		var/mob/living/L = src
		new_human.languages |= L.languages
	new_human.generate_name()
	Postmorph(new_human)
	return new_human

/mob/proc/Frankensteinize()
	if(!Premorph())
		return
	var/mob/living/carbon/human/frankenstein/new_frank = new /mob/living/carbon/human/frankenstein(loc, delay_ready_dna=TRUE)
	if((gender == MALE) || (gender == FEMALE)) //If the transformed mob is MALE or FEMALE
		new_frank.setGender(gender) //The new human will inherit its gender
	else //If its gender is NEUTRAL or PLURAL,
		new_frank.setGender(pick(MALE, FEMALE)) //The new human's gender will be random
	new_frank.generate_name()
	Postmorph(new_frank)
	return new_frank

/mob/proc/Animalize()
	var/list/mobtypes = existing_typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes
	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return
	if(!Premorph())
		return
	var/mob/new_mob = new mobpath(get_turf(src))
	Postmorph(new_mob)
	to_chat(new_mob, "You feel more... animalistic")
	return new_mob

/mob/living/carbon/human/proc/GALize()
	if(ishuman(src))
		var/mob/living/carbon/human/M = src
		if(!M.is_wearing_item(/obj/item/clothing/under/galo))
			var/obj/item/clothing/under/galo/G = new /obj/item/clothing/under/galo(get_turf(M))
			if(M.w_uniform)
				M.u_equip(M.w_uniform, 1)
			M.equip_to_slot(G, slot_w_uniform)
		if(!M.is_wearing_item(/obj/item/clothing/glasses/sunglasses))
			var/obj/item/clothing/glasses/sunglasses/S = new /obj/item/clothing/glasses/sunglasses(get_turf(M))
			if(M.glasses)
				M.u_equip(M.glasses, 1)
			M.equip_to_slot(S, slot_glasses)
	my_appearance.s_tone = -100 //Nichi saro ni itte hada o yaku
	update_body()
	if(gender == MALE && my_appearance.h_style != "Toriyama 2")
		my_appearance.h_style = "Toriyama 2" //Yeah, gyaru otoko sengen
	my_appearance.r_facial = my_appearance.r_hair = 255
	my_appearance.g_facial = my_appearance.g_hair = 255
	my_appearance.b_facial = my_appearance.b_hair = 0
	update_hair()
	playsound(src, 'sound/misc/gal-o-sengen.ogg', 50, 1)// GO GO GO GO GO GO GAL-O-SENGEN

#undef MONKEY_ANIM_TIME
