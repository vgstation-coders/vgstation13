/datum/faction/syndicate/nuke_op
	name = "Syndicate Nuclear Operatives"
	ID = SYNDIOPS
	required_pref = NUKE_OP
	initial_role = NUKE_OP
	late_role = NUKE_OP
	initroletype = /datum/role/nuclear_operative
	roletype = /datum/role/nuclear_operative
	desc = "The culmination of succesful NT traitors, who have managed to steal a nuclear device.\
	Load up, grab the nuke, don't forget where you've parked, find the nuclear auth disk, and give them hell."
	logo_state = "nuke-logo"
	hud_icons = list("nuke-logo","nuke-logo-leader")
	playlist = "nukesquad"

	var/datum/outfit/striketeam/nukeops/our_outfit = /datum/outfit/striketeam/nukeops

/datum/faction/syndicate/nuke_op/forgeObjectives()
	AppendObjective(/datum/objective/nuclear)
	AnnounceObjectives()

/datum/faction/syndicate/nuke_op/GetScoreboard()
	. = ..()
	if(faction_scoreboard_data)
		. += "<BR>The operatives bought:<BR>"
		for(var/entry in faction_scoreboard_data)
			. += "[entry]<BR>"

/datum/faction/syndicate/nuke_op/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<br><h2>Nuclear disk</h2>"
	if(!nukedisk)
		dat += "There's no nuke disk. Panic?<br>"
	else if(isnull(nukedisk.loc))
		dat += "The nuke disk is in nullspace. Panic."
	else
		dat += "[nukedisk.name]"
		var/atom/disk_loc = nukedisk.loc
		while(!istype(disk_loc, /turf))
			if(istype(disk_loc, /mob))
				var/mob/M = disk_loc
				dat += "carried by <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a> "
			if(istype(disk_loc, /obj))
				var/obj/O = disk_loc
				dat += "in \a [O.name] "
			disk_loc = disk_loc.loc
		dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z]) [formatJumpTo(nukedisk, "Jump")]"
	return dat

/datum/faction/syndicate/nuke_op/OnPostSetup()
	. = ..()
	var/list/turf/synd_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			qdel(A)
			A = null
			continue

	var/obj/effect/landmark/uplinklocker = locate("landmark*Syndicate-Uplink") //I will be rewriting this shortly
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")

	var/nuke_code = "[rand(10000, 99999)]"
	var/leader_selected = 0
	var/agent_number = 1
	var/spawnpos = 1

	for(var/datum/role/nuclear_operative/N in members)
		if(spawnpos > synd_spawn.len)
			spawnpos = 1
		var/datum/mind/synd_mind = N.antag
		synd_mind.current.forceMove(synd_spawn[spawnpos])

		var/datum/outfit/striketeam/nukeops/concrete_outfit = new our_outfit

		concrete_outfit.equip(synd_mind.current)

		share_syndicate_codephrase(N.antag.current)
		N.antag.current << sound('sound/voice/syndicate_intro.ogg')

		if(istype(N, /datum/role/nuclear_operative/leader) && !leader_selected)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
			agent_number++
		spawnpos++

		spawn()
			concrete_outfit.chosen_spec = equip_nuke_loadout(synd_mind.current)
			concrete_outfit.equip_special_items(synd_mind.current)

	if(uplinklocker)
		new /obj/structure/closet/syndicate/nuclear(uplinklocker.loc)

	if(nuke_spawn && synd_spawn.len > 0)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
		the_bomb.r_code = nuke_code
		the_bomb.nt_aligned = 0

	update_faction_icons()

/datum/faction/syndicate/nuke_op/proc/nuke_name_assign(var/last_name, var/title = "", var/list/syndicates)
	for(var/datum/role/R in syndicates)
		switch(R.antag.current.gender)
			if(MALE)
				R.antag.current.fully_replace_character_name(R.antag.current.real_name, "[leader == R ? "[title] ":""][pick(first_names_male)] [last_name ? "[last_name]":"[pick(last_names)]"]")
			if(FEMALE)
				R.antag.current.fully_replace_character_name(R.antag.current.real_name, "[leader == R ? "[title] ":""][pick(first_names_female)] [last_name ? "[last_name]":"[pick(last_names)]"]")

//This is separate because the mob will have to make a decision as to what it wants as a loadout. Once this is chosen, the gear will be slapped onto them to not waste time
/datum/faction/syndicate/nuke_op/proc/equip_nuke_loadout(mob/living/carbon/human/synd_mob)

	var/chosen_loadout = input(synd_mob, "Your operation is about to begin. What kind of operations would you like to specialize into ?") in list("Ballistics", "Energy", "Demolition", "Melee", "Medical", "Engineering", "Stealth", "Ship and Cameras")

	return chosen_loadout

/datum/faction/syndicate/nuke_op/proc/prepare_syndicate_leader(var/datum/mind/synd_mind, var/nuke_code)

	leader = synd_mind.GetRole(NUKE_OP_LEADER)
	spawn()
		var/title = copytext(sanitize(input(synd_mind.current, "Pick a glorious title for yourself. Leave blank to tolerate equality with your teammates and avoid giving yourself away when talking undercover", "Honorifics", "")), 1, MAX_NAME_LEN)
		nuke_name_assign(nuke_last_name(synd_mind.current), title, members) //Allows time for the rest of the syndies to be chosen

	if(nuke_code)
		synd_mind.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [nuke_code]", 0, 0)
		to_chat(synd_mind.current, "The nuclear authorization code is: <B>[nuke_code]</B><br>Make sure to share it with your subordinates.")
		var/obj/item/weapon/paper/P = new
		P.info = "The nuclear authorization code is: <b>[nuke_code]</b>"
		P.name = "nuclear bomb code"
		var/mob/living/carbon/human/H = synd_mind.current
		P.forceMove(H.loc)
		H.equip_to_slot_or_drop(P, slot_r_store)
		H.update_icons()
	else
		nuke_code = "Code will be provided later, complain to Syndicate Command"

/datum/faction/syndicate/nuke_op/proc/nuke_last_name(var/mob/M as mob)

	var/newname = copytext(sanitize(input(M, "Pick a static last name for all the members of your team. Leave blank to preserve everyone's unique last names", "Family Name", "")), 1, MAX_NAME_LEN)

	return newname

/datum/faction/syndicate/nuke_op/process()
	var/livingmembers
	var/mob/living/M
	if(members.len > 0)
		for (var/datum/role/R in members)
			if(R.antag.current)
				M = R.antag.current
				if(M.stat != DEAD)
					livingmembers++
		if(!livingmembers && ticker.IsThematic(playlist))
			ticker.StopThematic()
