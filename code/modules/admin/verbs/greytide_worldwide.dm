/client/proc/greytide_worldwide(var/mob/user)
	if(!ticker)
		alert("The game hasn't started yet!")
		return

	var/list/pickfrom = list("Cancel")
	for(var/datum_type in typesof(/datum/greytide_worldwide))
		var/datum/greytide_worldwide/D = datum_type
		var/name = initial(D.name)
		if(name)
			pickfrom += name
			pickfrom[name] = D

	var/event_type_name = input(user, "Select an event.", "GREYTIDE WORLDWIDE", null) in pickfrom as text|null
	if(!event_type_name)
		return
	var/event_type = pickfrom[event_type_name]
	if(!event_type)
		return

	var/datum/greytide_worldwide/event = new event_type()

	if(!event.event_setup_start())
		message_admins("<span class='notice'>[key_name_admin(usr)] tried to use GREYTIDE WORLDWIDE, but it failed in setup. (Type: [event_type_name])</span>", 1)
		log_admin("[key_name(usr)] tried to use GREYTIDE WORLDWIDE, but it failed in setup. (Type: [event_type_name])")
		return

	message_admins("<span class='notice'>[key_name_admin(usr)] used GREYTIDE WORLDWIDE! (Type: [event_type_name])</span>", 1)
	log_admin("[key_name(usr)] used GREYTIDE WORLDWIDE. (Type: [event_type_name])")

	var/list/mobs_to_convert = list()
	for(var/mob/M in event.eligible_mobs)
		if(event.check_eligibility(M))
			mobs_to_convert += M

	for(var/mob/M in mobs_to_convert)
		event.convert_mob(M)

	event.event_setup_end(mobs_to_convert)

	qdel(event)


/datum/greytide_worldwide
	var/name = ""
	var/list/eligible_mobs

/datum/greytide_worldwide/New()
	eligible_mobs = player_list

/datum/greytide_worldwide/proc/event_setup_start()
	return 1

/datum/greytide_worldwide/proc/check_eligibility(var/mob/M)
	if(M.stat == DEAD)
		return 0
	if(ishuman(M) || issilicon(M))
		return 1

/datum/greytide_worldwide/proc/convert_mob(var/mob/M)
	if(issilicon(M))
		var/mob/living/silicon/S = M
		var/mob/living/carbon/human/new_human = new /mob/living/carbon/human(S.loc, delay_ready_dna=1)
		new_human.setGender(pick(MALE, FEMALE))
		var/datum/preferences/A = new()
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

/datum/greytide_worldwide/proc/event_setup_end(var/list/converted_mobs)


/datum/greytide_worldwide/greytide
	name = "Greytide Worldwide"

/datum/greytide_worldwide/greytide/check_eligibility(var/mob/M)
	if(!..())
		return 0
	if(is_special_character(M))
		return 0
	return 1

/datum/greytide_worldwide/greytide/convert_mob(var/mob/M)
	var/mob/living/carbon/human/H = ..(M)

	ticker.mode.traitors += H.mind
	H.mind.special_role = GREYTIDER

	H.mutations.Add(M_HULK)
	H.set_species("Human", force_organs=TRUE)
	H.a_intent = I_HURT

	H.update_mutations()
	H.update_body()

	var/datum/objective/hijack/hijack_objective = new
	hijack_objective.owner = H.mind
	H.mind.objectives += hijack_objective

	to_chat(H, "<B>You are a greytider!</B>")
	var/obj_count = 1
	for(var/datum/objective/OBJ in H.mind.objectives)
		to_chat(H, "<B>Objective #[obj_count++]</B>: [OBJ.explanation_text]")

	for (var/obj/item/I in H)
		if (istype(I, /obj/item/weapon/implant))
			continue
		if(isplasmaman(H))
			if(!(istype(I, /obj/item/clothing/suit/space/plasmaman) || istype(I, /obj/item/clothing/head/helmet/space/plasmaman) || istype(I, /obj/item/weapon/tank/plasma/plasmaman) || istype(I, /obj/item/clothing/mask/breath)))
				qdel(I)
		else if(isvox(H))
			if(!(istype(I, /obj/item/weapon/tank/nitrogen) || istype(I, /obj/item/clothing/mask/breath/vox)))
				qdel(I)
		else
			qdel(I)

	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset(H), slot_ears)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)

	var/obj/item/weapon/card/id/W = new(H)
	W.name = "[H.real_name]'s ID Card"
	W.icon_state = "centcom"
	W.access = access_maint_tunnels
	W.assignment = "Greytider"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, slot_wear_id)

	return H
