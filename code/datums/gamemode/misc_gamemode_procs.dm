proc/display_roundstart_logout_report()
	var/msg = "<span class='notice'><b>Roundstart logout report\n\n</span>"
	for(var/mob/living/L in mob_list)

		if(L.ckey)
			var/found = 0
			for(var/client/C in clients)
				if(C.ckey == L.ckey)
					found = 1
					break
			if(!found)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))	//Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				continue //AFK client
			if(L.stat)
				if(L.suiciding)	//Suicider
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
					continue //Disconnected client
				if(L.stat == UNCONSCIOUS)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dying)\n"
					continue //Unconscious
				if(L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dead)\n"
					continue //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D in mob_list)
			if(D.mind && (D.mind.original == L || D.mind.current == L))
				if(L.stat == DEAD)
					if(L.suiciding)	//Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>This shouldn't appear.</b></font>)\n"
						continue //Lolwhat
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Ghosted</b></font>)\n"
						continue //Ghosted while alive



	for(var/mob/M in mob_list)
		if(M.client && M.client.holder)
			to_chat(M, msg)


proc/get_nt_opposed()
	var/list/dudes = list()
	for(var/mob/living/carbon/human/man in player_list)
		if(man.client)
			if(man.client.prefs.nanotrasen_relation == "Opposed")
				dudes += man
			else if(man.client.prefs.nanotrasen_relation == "Skeptical" && prob(50))
				dudes += man
	if(dudes.len == 0)
		return null
	return pick(dudes)


proc/equip_wizard(mob/living/carbon/human/wizard_mob)
	if (!istype(wizard_mob))
		return

	//So zards properly get their items when they are admin-made.
	qdel(wizard_mob.wear_suit)
	qdel(wizard_mob.head)
	qdel(wizard_mob.shoes)
	qdel(wizard_mob.r_store)
	qdel(wizard_mob.l_store)

	if(!wizard_mob.find_empty_hand_index())
		wizard_mob.u_equip(wizard_mob.held_items[GRASP_LEFT_HAND])

	wizard_mob.equip_to_slot_or_del(new /obj/item/device/radio/headset(wizard_mob), slot_ears)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(wizard_mob), slot_w_uniform)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(wizard_mob), slot_shoes)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(wizard_mob), slot_wear_suit)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(wizard_mob), slot_head)
	if(wizard_mob.backbag == 2)
		wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(wizard_mob), slot_back)
	if(wizard_mob.backbag == 3)
		wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(wizard_mob), slot_back)
	if(wizard_mob.backbag == 4)
		wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(wizard_mob), slot_back)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(wizard_mob), slot_in_backpack)
//	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/scrying_gem(wizard_mob), slot_l_store) For scrying gem.
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(wizard_mob), slot_r_store)
	wizard_mob.put_in_hands(new /obj/item/weapon/spellbook(wizard_mob))

	wizard_mob.make_all_robot_parts_organic()

	// For Vox and plasmadudes.
	//wizard_mob.species.handle_post_spawn(wizard_mob)

	to_chat(wizard_mob, "You will find a list of available spells in your spell book. Choose your magic arsenal carefully.")
	to_chat(wizard_mob, "In your pockets you will find a teleport scroll. Use it as needed.")
	wizard_mob.mind.store_memory("<B>Remember:</B> do not forget to prepare your spells.")
	wizard_mob.update_icons()
	return 1

proc/name_wizard(mob/living/carbon/human/wizard_mob)
	//Allows the wizard to choose a custom name or go with a random one. Spawn 0 so it does not lag the round starting.
	if(wizard_mob.species && wizard_mob.species.name != "Human")
		wizard_mob.set_species("Human", 1)
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	spawn(0)
		var/newname = copytext(sanitize(input(wizard_mob, "You are a Space Wizard. Would you like to change your name to something else?", "Name change", randomname) as null|text),1,MAX_NAME_LEN)

		if (!newname)
			newname = randomname

		wizard_mob.fully_replace_character_name(wizard_mob.real_name, newname)
	return

/proc/equip_highlander(var/mob/living/carbon/human/highlander_human)
	var/static/list/plasmaman_items = list(
		/obj/item/clothing/suit/space/plasmaman,
		/obj/item/clothing/head/helmet/space/plasmaman,
		/obj/item/weapon/tank/plasma/plasmaman,
		/obj/item/clothing/mask/breath)

	var/static/list/vox_items = list(
		/obj/item/weapon/tank/nitrogen,
		/obj/item/clothing/mask/breath/vox)

	highlander_human.mutations.Add(M_HULK) //all highlanders are permahulks
	highlander_human.set_species("Human", force_organs=TRUE) // No Dionae
	highlander_human.a_intent = I_HURT

	highlander_human.update_mutations()
	highlander_human.update_body()

	for (var/obj/item/I in highlander_human)
		if (istype(I, /obj/item/weapon/implant))
			continue
		if(isplasmaman(highlander_human) && is_type_in_list(I, plasmaman_items)) //Plasmamen don't lose their plasma gear since they need it to live.
			continue
		else if(isvox(highlander_human) && is_type_in_list(I, vox_items)) //Vox don't lose their N2 gear since they need it to live.
			continue
		qdel(I)

	highlander_human.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(highlander_human), slot_w_uniform)
	highlander_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(highlander_human), slot_ears)
	if(!isplasmaman(highlander_human)) //Plasmamen don't get a beret since they need their helmet to not burn to death.
		highlander_human.equip_to_slot_or_del(new /obj/item/clothing/head/beret(highlander_human), slot_head)
	highlander_human.put_in_hands(new /obj/item/weapon/claymore(highlander_human))
	highlander_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(highlander_human), slot_shoes)
	highlander_human.equip_to_slot_or_del(new /obj/item/weapon/pinpointer(highlander_human), slot_l_store)

	var/obj/item/weapon/card/id/new_id = new(highlander_human)
	new_id.name = "[highlander_human.real_name]'s ID Card"
	new_id.icon_state = "centcom"
	new_id.access = get_all_accesses()
	new_id.access += get_all_centcom_access()
	new_id.assignment = "Highlander"
	new_id.registered_name = highlander_human.real_name
	highlander_human.equip_to_slot_or_del(new_id, slot_wear_id)


///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/proc/get_living_heads()
	var/list/heads = list()
	for(var/client/C in clients)
		var/mob/living/carbon/human/player = C.mob
		if(istype(player) && player.stat!=2 && player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/proc/get_all_heads()
	var/list/heads = list()
	for(var/client/C in clients)
		var/mob/living/carbon/human/player = C.mob
		if(istype(player) && player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

/proc/get_assigned_head_roles()
	var/list/roles = list()
	for(var/client/C in clients)
		var/mob/living/carbon/human/player = C.mob
		if(istype(player) && player.mind && (player.mind.assigned_role in command_positions))
			roles += player.mind.assigned_role
	return roles