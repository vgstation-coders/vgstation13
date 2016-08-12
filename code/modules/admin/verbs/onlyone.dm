/client/proc/only_one(var/mob/user)
	if(!ticker)
		alert("The game hasn't started yet!")
		return

	var/list/pickfrom = list("Cancel")
	for(var/datum_type in typesof(/datum/only_one))
		var/datum/only_one/D = datum_type //For the undocumented but super cool initial() behavior
		var/name = initial(D.name)
		if(name)
			pickfrom += name
			pickfrom[name] = D

	var/event_type_name = input(user, "Select an event.", "THERE CAN BE ONLY ONE", null) in pickfrom as text|null
	if(!event_type_name)
		return
	var/event_type = pickfrom[event_type_name]
	if(!event_type)
		return

	var/datum/only_one/event = new event_type()

	if(!event.event_setup_start())
		message_admins("<span class='notice'>[key_name_admin(usr)] tried to use THERE CAN BE ONLY ONE, but it failed in setup. (Type: [event_type_name])</span>", 1)
		log_admin("[key_name(usr)] tried to use there can be only one, but it failed in setup. (Type: [event_type_name])")
		return

	message_admins("<span class='notice'>[key_name_admin(usr)] used THERE CAN BE ONLY ONE! (Type: [event_type_name])</span>", 1)
	log_admin("[key_name(usr)] used there can be only one. (Type: [event_type_name])")

	var/list/mobs_to_convert = list()
	for(var/mob/M in event.eligible_mobs)
		if(event.check_eligibility(M))
			mobs_to_convert += M

	for(var/mob/M in mobs_to_convert)
		event.convert_mob(M)

	event.event_setup_end(mobs_to_convert)

	qdel(event)


/datum/only_one
	var/name = "" //What to show in the list of choices. Does not appear in the list if left blank.
	var/list/eligible_mobs //List of mobs to CHECK for eligibility. Not the final list of mobs to convert. Assigned in New() because BYOND a shit.

//Only used for assigning eligible_mobs at the moment. It doesn't work in the type definition.
/datum/only_one/New()
	eligible_mobs = player_list

//Called at the beginning of the event. Cancels the event if it returns false, so use this to start anything you want to start immediately and/or check if the event can't happen.
/datum/only_one/proc/event_setup_start()
	return 1

//Used to retrieve the list of mobs to convert. Called on each mob in eligible_mobs. Any mob this returns true for is added to the final conversion list.
/datum/only_one/proc/check_eligibility(var/mob/M)
	if(M.stat == DEAD) //I don't use isDead() because that also returns 1 for fakedeath. Don't want to fuck over those in fakedeath when bussing.
		return 0
	if(ishuman(M) || issilicon(M))
		return 1

//Does the actual converting of mobs. Called on each mob in the final conversion list. Returns the converted mob, in case conversion requires spawning a new one.
//The base version of this proc turns just turns silicons into humans, so any events that require that need only call the parent and convert the mob returned.
/datum/only_one/proc/convert_mob(var/mob/M)
	if(issilicon(M))
		var/mob/living/silicon/S = M
		var/mob/living/carbon/human/new_human = new /mob/living/carbon/human(S.loc, delay_ready_dna=1)
		new_human.setGender(pick(MALE, FEMALE)) //The new human's gender will be random
		var/datum/preferences/A = new()	//Randomize appearance for the human
		A.randomize_appearance_for(new_human)
		new_human.generate_name()
		new_human.languages |= S.languages
		if(S.default_language)
			new_human.default_language = S.default_language
		if(S.mind)
			S.mind.transfer_to(new_human)
		else
			new_human.key = S.key
		qdel(S)
		M = new_human
	return M

//Called at the end of the event setup. Provided with the list of converted mobs in case something has to be done with them after everything else is done.
/datum/only_one/proc/event_setup_end(var/list/converted_mobs)


//The classic.
/datum/only_one/highlander
	name = "Highlander"

/datum/only_one/highlander/check_eligibility(var/mob/M)
	if(!..())
		return 0
	if(is_special_character(M))
		return 0
	return 1

/datum/only_one/highlander/convert_mob(var/mob/M)
	var/mob/living/carbon/human/H = ..(M)

	ticker.mode.traitors += H.mind
	H.mind.special_role = HIGHLANDER

	H.mutations.Add(M_HULK) //all highlanders are permahulks
	H.update_mutations()
	H.update_body()

	/* This never worked.
	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = H.mind
	steal_objective.set_target("nuclear authentication disk")
	H.mind.objectives += steal_objective
	*/

	var/datum/objective/hijack/hijack_objective = new
	hijack_objective.owner = H.mind
	H.mind.objectives += hijack_objective

	to_chat(H, "<B>You are a highlander!</B>")
	var/obj_count = 1
	for(var/datum/objective/OBJ in H.mind.objectives)
		to_chat(H, "<B>Objective #[obj_count++]</B>: [OBJ.explanation_text]")

	for (var/obj/item/I in H)
		if (istype(I, /obj/item/weapon/implant))
			continue
		if(isplasmaman(H)) //Plasmamen don't lose their plasma gear since they need it to live.
			if(!(istype(I, /obj/item/clothing/suit/space/plasmaman) || istype(I, /obj/item/clothing/head/helmet/space/plasmaman) || istype(I, /obj/item/weapon/tank/plasma/plasmaman) || istype(I, /obj/item/clothing/mask/breath)))
				qdel(I)
		else if(isvox(H)) //Vox don't lose their N2 gear since they need it to live.
			if(!(istype(I, /obj/item/weapon/tank/nitrogen) || istype(I, /obj/item/clothing/mask/breath/vox)))
				qdel(I)
		else
			qdel(I)

	H.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(H), slot_ears)
	if(!isplasmaman(H)) //Plasmamen don't get a beret since they need their helmet to not burn to death.
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), slot_head)
	H.put_in_hands(new /obj/item/weapon/claymore(H))
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/pinpointer(H.loc), slot_l_store)

	var/obj/item/weapon/card/id/W = new(H)
	W.name = "[H.real_name]'s ID Card"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	W.assignment = "Highlander"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, slot_wear_id)

	return H
	

//MAGIC MISSILE
/datum/only_one/wizardwars
	name = "Wizard Wars"

/datum/only_one/wizardwars/convert_mob(var/mob/M)
	var/mob/living/carbon/human/H = ..(M)

	H.revive() //Fully heal all converted mobs...
	H.status_flags |= (INVULNERABLE | GODMODE) //...and make them invincible. This invincibility is removed in event_setup_end(), after a delay.
	if(H.mind) //Golly gee I sure hope they have a mind or else they might be able to prematurely fuck people up
		H.mind.nospells = 1
	ticker.mode.wizards += H
	H.mind.special_role = "Wizard"

	var/datum/objective/hijack/hijack_objective = new
	hijack_objective.owner = H.mind
	H.mind.objectives += hijack_objective

	to_chat(H, "<span class='danger'>You are a Space Wizard!</span>")
	var/obj_count = 1
	for(var/datum/objective/OBJ in H.mind.objectives)
		to_chat(H, "<B>Objective #[obj_count++]</B>: [OBJ.explanation_text]")

	for(var/obj/item/I in H)
		if(!istype(I, /obj/item/weapon/implant))
			qdel(I)

	if(isplasmaman(H))
		H.set_species("Skellington", 1) //Don't want them just catching fire, and this is the most similar species that doesn't need the suit.
		to_chat(H, "<span class='notice'>Your solid plasma vanishes, leaving behind only bones!</span>")

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset(H), slot_ears)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(H), slot_head)
	switch(H.backbag)
		if(3) //No need to have a case for if they select the normal backpack type, as that's the default in case they haven't selected one.
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		else
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(H), slot_r_store)
	H.equip_to_slot_or_del(new /obj/item/weapon/spellbook(H), slot_in_backpack)
	if(isvox(H))
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/breath/vox(H), slot_wear_mask)
		var/obj/item/weapon/tank/nitrogen/T = new(H)
		H.put_in_hands(T)
		H.internal = T
		if(H.internals)
			H.internals.icon_state = "internal1"

	H.make_all_robot_parts_organic()

	to_chat(H, "<span class='info'>Your spellbook is in your backpack. All wizards are invincible for the next 20 seconds, and no spells can be cast in that time. Take this time to select your spells.</span>")

	return H

/datum/only_one/wizardwars/event_setup_end(var/list/converted_mobs)
	sleep(200) //Twenty seconds.
	for(var/mob/M in converted_mobs)
		M.status_flags &= ~(INVULNERABLE | GODMODE)
		if(M.mind)
			M.mind.nospells = 0
		to_chat(M, "<span class='warning'>Invincibility period over. Let the battle begin!</span>")
