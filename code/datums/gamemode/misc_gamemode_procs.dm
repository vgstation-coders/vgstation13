/proc/display_roundstart_logout_report()
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
				if(L.mind && L.mind.suiciding)	//Suicider
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<span class='red'><b>Suicide</b></span>)\n"
					continue //Disconnected client
				if(L.stat == UNCONSCIOUS && L.sleeping == 0)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dying)\n"
					continue //Unconscious
				if(L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dead)\n"
					continue //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D in mob_list)
			if(D.mind && D.mind.current == L)
				if(L.stat == DEAD)
					if(L.mind.suiciding)	//Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<span class='red'><b>Suicide</b></span>)\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<span class='red'><b>This shouldn't appear.</b></span>)\n"
						continue //Lolwhat
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<span class='red'><b>Ghosted</b></span>)\n"
						continue //Ghosted while alive



	for(var/mob/M in mob_list)
		if(M.client && M.client.holder)
			to_chat(M, msg)


/proc/get_nt_opposed()
	var/list/dudes = list()
	for(var/mob/living/carbon/human/man in player_list)
		if (!man.client || !man.mind)
			continue

		if (man.mind.assigned_role == "MODE") // Wiz, nukies, ...
			continue

		if(man.client.prefs.nanotrasen_relation == "Opposed")
			dudes += man
		else if(man.client.prefs.nanotrasen_relation == "Skeptical" && prob(50))
			dudes += man

		else if( (man.mind.antag_roles[CULTIST] && prob(40)) || \
				 (man.mind.antag_roles[CHANGELING] && prob(50)) || \
				 (man.mind.antag_roles[TRAITOR] && prob(30)) || \
				 (man.mind.antag_roles[HEADREV] && prob(30)) \
				 )
			dudes += man

		else if(prob(10))
			dudes += man

	return dudes

/datum/gamemode/proc/send_intercept()
	var/intercepttext = {"<FONT size = 3><B>[command_name()] Update</B> Requested status information:</FONT><HR>
<B> In case you have misplaced your copy, attached is a list of personnel whom reliable sources&trade; suspect may be affiliated with the Syndicate:</B><br> <I>Reminder: Acting upon this information without solid evidence will result in termination of your working contract with Nanotrasen.</I></br>"}

	var/list/suspects = get_nt_opposed()

	for(var/mob/M in suspects)
		switch(rand(1, 100))
			if(1 to 50)
				intercepttext += "Someone with the job of <b>[M.mind.assigned_role]</b> <br>"
			else
				intercepttext += "<b>[M.name]</b>, the <b>[M.mind.assigned_role]</b> <br>"

	for (var/obj/machinery/computer/communications/comm in machines)
		if (!(comm.stat & (BROKEN | NOPOWER | FORCEDISABLE)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- '[command_name()] Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("[command_name()] Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert(/datum/command_alert/enemy_comms_interception)

/datum/gamemode/dynamic/send_intercept()
	var/intercepttext = {"<html><style>
						body {color: #000000; background: #EDD6B6;}
						h1 {color: #000000; font-size:30px;}
						</style><FONT size = 3><B>[command_name()] Update</B> Requested status information:</FONT><HR></br>
						<body>
						<center><img src="http://ss13.moe/wiki/images/1/17/NanoTrasen_Logo.png"><BR>"}

	var/list/threat_detected = round(starting_threat)

	switch(threat_detected)
		if(0 to 19)
			update_playercounts()
			if(!living_antags.len)
				intercepttext += "<b>Peaceful Waypoint</b></center><BR>"
				intercepttext += "Your station orbits deep within controlled, core-sector systems and serves as a waypoint for routine traffic through Nanotrasen's trade empire. Due to the combination of high security, interstellar traffic, and low strategic value, it makes any direct threat of violence unlikely. Your primary enemies will be incompetence and bored crewmen: try to organize team-building events to keep staffers interested and productive."
			else
				intercepttext += "<b>Core Territory</b></center><BR>"
				intercepttext += "Your station orbits within reliably mundane, secure space. Although Nanotrasen has a firm grip on security in your region, the valuable resources and strategic position aboard your station make it a potential target for infiltrations. Monitor crew for non-loyal behavior, but expect a relatively tame shift free of large-scale destruction. We expect great things from your station."
		if(20 to 39)
			intercepttext += "<b>Anomalous Exogeology</b></center><BR>"
			intercepttext += "Although your station lies within what is generally considered Nanotrasen-controlled space, the course of its orbit has caused it to cross unusually close to exogeological features with anomalous readings. Although these features offer opportunities for our research department, it is known that these little understood readings are often correlated with increased activity from competing interstellar organizations and individuals, among them the Wizard Federation, Cult of the Geometer of Blood, and the remaining Vampire Lords - all known competitors for Anomaly Type B sites. Exercise elevated caution."
		if(40 to 65)
			intercepttext += "<b>Contested System</b></center><BR>"
			intercepttext += "Your station's orbit passes along the edge of Nanotrasen's sphere of influence. While subversive elements remain the most likely threat against your station, hostile organizations are bolder here, where our grip is weaker. Exercise increased caution against elite Syndicate strike forces, or Executives forbid, some kind of ill-conceived unionizing attempt."
		if(66 to 79)
			intercepttext += "<b>Uncharted Space</b></center><BR>"
			intercepttext += "Congratulations and thank you for participating in the NT 'Frontier' space program! Your station is actively orbiting a high value system far from the nearest support stations. Little is known about your region of space, and the opportunity to encounter the unknown invites greater glory. You are encouraged to elevate security as necessary to protect Nanotrasen assets."
		if(80 to 94)
			intercepttext += "<b>Black Orbit</b></center><BR>"
			intercepttext += "As part of a mandatory security protocol, we are required to inform you that as a result of your orbital pattern directly behind an astrological body (oriented from our nearest observatory), your station will be under decreased monitoring and support. It is anticipated that your extreme location and decreased surveillance could pose security risks. Avoid unnecessary risks and attempt to keep your station in one piece."
		if(95 to 100)
			intercepttext += "<b>Impending Doom</b></center><BR>"
			intercepttext += "Your station is somehow in the middle of hostile territory, in clear view of any enemy of the corporation. Your likelihood to survive is low, and station destruction is expected and almost inevitable. Secure any sensitive material and neutralize any enemy you will come across. It is important that you at least try to maintain the station.<BR>"
			intercepttext += "Good luck."

	intercepttext += "</body></html>"

	for (var/obj/machinery/computer/communications/comm in machines)
		if (!(comm.stat & (BROKEN | NOPOWER | FORCEDISABLE)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- '[command_name()] Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("[command_name()] Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert(/datum/command_alert/enemy_comms_interception)

/proc/disable_suit_sensors(mob/living/carbon/human/H)
	var/obj/item/clothing/under/U = H.get_item_by_slot(slot_w_uniform)
	U.sensor_mode = 0

/proc/equip_wizard(mob/living/carbon/human/wizard_mob, apprentice = FALSE)
	if (!istype(wizard_mob))
		return
	wizard_mob.delete_all_equipped_items()
	var/datum/faction/wizard/civilwar/wpf/WPF = find_active_faction_by_type(/datum/faction/wizard/civilwar/wpf)
	var/datum/faction/wizard/civilwar/wpf/PFW = find_active_faction_by_type(/datum/faction/wizard/civilwar/pfw)
	if(WPF && WPF.get_member_by_mind(wizard_mob.mind))  //WPF get red
		wizard_mob.add_spell(new /spell/targeted/absorb)
		var/datum/outfit/special/wizard/red/W = new
		W.apprentice = apprentice
		W.equip(wizard_mob, strip = TRUE, delete = TRUE)
	else if(PFW && PFW.get_member_by_mind(wizard_mob.mind))  //PFW get blue
		wizard_mob.add_spell(new /spell/targeted/absorb)
		var/datum/outfit/special/wizard/W = new
		W.apprentice = apprentice
		W.equip(wizard_mob, strip = TRUE, delete = TRUE)
	else //Not part of the war? Give them normal robes
		var/datum/outfit/special/wizard/W = new
		W.apprentice = apprentice
		W.equip(wizard_mob, strip = TRUE, delete = TRUE)

	if(!apprentice)
		to_chat(wizard_mob, "You will find a list of available spells in your spell book. Choose your magic arsenal carefully.")
		to_chat(wizard_mob, "In your pockets you will find a teleport scroll. Use it as needed.")
		wizard_mob.mind.store_memory("<B>Remember:</B> do not forget to prepare your spells.")
	return 1

/proc/name_wizard(mob/living/carbon/human/wizard_mob, role_name = "Space Wizard")
	//Allows the wizard to choose a custom name or go with a random one. Spawn 0 so it does not lag the round starting.
	if(wizard_mob.species && wizard_mob.species.name != "Human")
		wizard_mob.set_species("Human", 1)
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	wizard_mob.fully_replace_character_name(wizard_mob.real_name, "[wizard_name_first] [wizard_name_second]")
	mob_rename_self(wizard_mob, role_name)


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

/datum/mind/proc/find_syndicate_uplink(datum/component/uplink/true_uplink)
	for (var/obj/item/I in get_contents_in_object(current, /obj/item))
		var/datum/component/uplink/uplink_comp = I.get_component(/datum/component/uplink)
		if(uplink_comp)
			return uplink_comp

	return true_uplink // returns the uplink they spawned with rather than the one they are currently carrying, or null

/datum/mind/proc/take_uplink()
	var/datum/component/uplink/H = find_syndicate_uplink()
	if(H)
		message_admins("Found and deleted [H] for [src].")
		qdel(H)
	else
		message_admins("The uplink for [src] could not be located for deletion.")

/proc/add_law_zero(mob/living/silicon/killer)
	var/law = "Accomplish your objectives at all costs."
	if(isAI(killer))
		var/mob/living/silicon/ai/KAI = killer
		KAI.set_zeroth_law(law, "Accomplish your AI's objectives at all costs.")
		KAI.notify_slaved()
	else
		var/mob/living/silicon/robot/KR = killer
		KR.set_zeroth_law(law)
	to_chat(killer, "<b>Your laws have been changed!</b>")
	killer.laws.zeroth_lock = TRUE
	to_chat(killer, "New law: 0. [law]")

/proc/equip_time_agent(var/mob/living/carbon/human/H, var/datum/role/time_agent/T, var/is_twin = FALSE)
	H.delete_all_equipped_items()

	var/datum/outfit/special/time_agent/concrete_outfit = new /datum/outfit/special/time_agent
	concrete_outfit.is_twin = is_twin
	concrete_outfit.equip(H)
	if(T)
		T.objects_to_delete = get_contents_in_object(H)
	H.fully_replace_character_name(newname = "John Beckett")
	H.make_all_robot_parts_organic()

/proc/spawn_rand_maintenance(var/mob/living/carbon/human/H)
	var/list/potential_locations = list()
	for(var/area/maintenance/A in areas)
		potential_locations.Add(A)
	var/placed = FALSE
	while(!placed && potential_locations.len)
		var/area/maintenance/A = pick(potential_locations)
		potential_locations.Remove(A)
		for(var/turf/simulated/floor/F in A.contents)
			if(!F.has_dense_content())
				H.forceMove(F)
				placed = TRUE
				return TRUE
	return FALSE

/proc/share_syndicate_codephrase(var/mob/living/agent)
	if(!agent)
		return 0
	if(!agent.mind)
		message_admins("tried to call share_syndicate_codephrase() on [agent] but it had no mind!")
		return 0
	var/words
	if (ischallenger(agent))
		words = "<b>For the Syndicate to validate your assassination, you must take a photo of your target's corpse, severed head, or brain, and publish it publicly via newscaster for all to see.</b><br>"
		words += "As is tradition the Syndicate has provided you and other agents with code words, but be mindful that using them in this context is akin to painting a target on your back:<br>"
	else
		words = "The Syndicate provided you with the following information on how to identify their agents:<br>"
	if (syndicate_code_phrase)
		var/phrases = syndicate_code_phrase.Join(", ")
		words += "<span class='warning'>Code Phrases: </span>[phrases].<br>"
		agent.mind.store_memory("<b>Code Phrases</b>: [phrases].")
	else
		words += "Unfortunately, the Syndicate did not provide you with a code phrase.<br>"
	if (syndicate_code_response)
		var/response = syndicate_code_response.Join(", ")
		words += "<span class='warning'>Code Response: </span>[response].<br>"
		agent.mind.store_memory("<b>Code Response</b>: [response].")
	else
		words += "Unfortunately, the Syndicate did not provide you with a code response.<br>"

	if(!ischallenger(agent) && (syndicate_code_phrase || syndicate_code_response))
		words += "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.<br>"
	else
		words += "Trust nobody.<br>"

	to_chat(agent,words)
	return 1



/proc/equip_raider(var/mob/living/carbon/human/vox, var/index)
	vox.age = rand(12,20)
	if(vox.overeatduration) //We need to do this here and now, otherwise a lot of gear will fail to spawn
		vox.overeatduration = 0 //Fat-B-Gone
		if(vox.nutrition > 400) //We are also overeating nutriment-wise
			vox.nutrition = 400 //Fix that
		vox.mutations.Remove(M_FAT)
		vox.update_mutantrace(0)
		vox.update_mutations(0)
		vox.update_inv_w_uniform(0)
		vox.update_inv_wear_suit()

	vox.my_appearance.s_tone = random_skin_tone("Vox")
	vox.dna.mutantrace = "vox"
	vox.set_species("Vox")
	vox.fully_replace_character_name(vox.real_name, vox.generate_name())
	vox.mind.name = vox.name
	//vox.languages = HUMAN // Removing language from chargen.
	vox.default_language = all_languages[LANGUAGE_VOX]
	vox.flavor_text = ""
	vox.species.default_language = LANGUAGE_VOX
	vox.remove_language(LANGUAGE_GALACTIC_COMMON)
	vox.my_appearance.h_style = "Short Vox Quills"
	vox.my_appearance.f_style = "Shaved"
	for(var/datum/organ/external/limb in vox.organs)
		limb.status &= ~(ORGAN_DESTROYED | ORGAN_ROBOT | ORGAN_PEG)
	vox.regenerate_icons()


/proc/equip_vox_raider(var/mob/living/carbon/human/H)
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/raider
	R.set_frequency(RAID_FREQ) // new fancy vox raiders radios now incapable of hearing station freq
	H.equip_to_slot_or_del(R, slot_ears)

	var/obj/item/clothing/under/vox/vox_robes/uni = new /obj/item/clothing/under/vox/vox_robes
	uni.attach_accessory(new/obj/item/clothing/accessory/holomap_chip/raider)
	H.equip_to_slot_or_del(uni, slot_w_uniform)

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox, slot_shoes) // REPLACE THESE WITH CODED VOX ALTERNATIVES.
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow/vox, slot_gloves) // AS ABOVE.

	H.equip_to_slot_or_del(new /obj/item/clothing/mask/breath/vox, slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen, slot_back)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight, slot_r_store)

	var/obj/item/weapon/card/id/syndicate/C = new
	C.registered_name = H.real_name
	C.assignment = "Trader"
	C.UpdateName()
	C.SetOwnerDNAInfo(H)
	C.icon_state = "trader"
	C.access = list(access_syndicate, access_trade)
	var/obj/item/weapon/storage/wallet/W = new
	W.handle_item_insertion(C)
	W.handle_item_insertion(new /obj/item/weapon/coin/raider)
	H.equip_to_slot_or_del(W, slot_wear_id)
	return 1
