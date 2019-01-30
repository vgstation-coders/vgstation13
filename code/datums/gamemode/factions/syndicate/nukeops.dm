/datum/faction/syndicate/nuke_op
	name = "Syndicate Nuclear Operatives"
	ID = SYNDIOPS
	required_pref = ROLE_OPERATIVE
	initial_role = NUKE_OP
	late_role = NUKE_OP
	initroletype = /datum/role/nuclear_operative
	roletype = /datum/role/nuclear_operative
	desc = "The culmination of succesful NT traitors, who have managed to steal a nuclear device.\
	Load up, grab the nuke, don't forget where you've parked, find the nuclear auth disk, and give them hell."
	logo_state = "nuke-logo"
	hud_icons = list("nuke-logo","nuke-logo-leader")

/datum/faction/syndicate/nuke_op/forgeObjectives()
	AppendObjective(/datum/objective/nuclear)
	for(var/datum/role/nuclear_operative/N in members)
		N.AnnounceObjectives()

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
	..()
	var/list/turf/synd_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			qdel(A)
			A = null
			continue

	var/obj/effect/landmark/uplinklocker = locate("landmark*Syndicate-Uplink")	//i will be rewriting this shortly
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

		equip_nuke_op(synd_mind.current)
		share_syndicate_codephrase(N.antag.current)

		if(!leader_selected)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
			agent_number++
		spawnpos++

	if(uplinklocker)
		new /obj/structure/closet/syndicate/nuclear(uplinklocker.loc)

	if(nuke_spawn && synd_spawn.len > 0)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	update_faction_icons()

/datum/faction/syndicate/nuke_op/proc/nukelastname(var/mob/M as mob) //--All praise goes to NEO|Phyte, all blame goes to DH, and it was Cindi-Kate's idea. Also praise Urist for copypasta ho.
	var/randomname = pick(last_names)
	var/newname = copytext(sanitize(input(M,"You are the nuke operative Leader. Please choose a last name for your family.", "Name change",randomname)),1,MAX_NAME_LEN)

	if (!newname)
		newname = randomname

	else
		if (newname == "Unknown" || newname == "floor" || newname == "wall" || newname == "rwall" || newname == "_")
			to_chat(M, "That name is reserved.")
			return nukelastname(M)

	return newname

/datum/faction/syndicate/nuke_op/proc/NukeNameAssign(var/lastname,var/list/syndicates)
	for(var/datum/role/R in syndicates)
		var/title = ""
		if(leader == R)
			title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")+" "
		switch(R.antag.current.gender)
			if(MALE)
				R.antag.current.fully_replace_character_name(R.antag.current.real_name, "[title][pick(first_names_male)] [lastname]")
			if(FEMALE)
				R.antag.current.fully_replace_character_name(R.antag.current.real_name, "[title][pick(first_names_female)] [lastname]")
	return

/datum/faction/syndicate/nuke_op/proc/equip_nuke_op(mob/living/carbon/human/synd_mob)
	var/radio_freq = SYND_FREQ

	if(synd_mob.overeatduration) //We need to do this here and now, otherwise a lot of gear will fail to spawn
		to_chat(synd_mob, "<span class='notice'>Your intensive physical training to become a Nuclear Operative has paid off and made you fit again!</span>")
		synd_mob.overeatduration = 0 //Fat-B-Gone
		if(synd_mob.nutrition > 400) //We are also overeating nutriment-wise
			synd_mob.nutrition = 400 //Fix that
		synd_mob.mutations.Remove(M_FAT)
		synd_mob.update_mutantrace(0)
		synd_mob.update_mutations(0)
		synd_mob.update_inv_w_uniform(0)
		synd_mob.update_inv_wear_suit()

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(synd_mob)
	R.set_frequency(radio_freq)
	synd_mob.equip_to_slot_or_del(R, slot_ears)

	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate/holomap(synd_mob), slot_w_uniform)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(synd_mob), slot_shoes)
	if(!istype(synd_mob.species, /datum/species/plasmaman))
		synd_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/bulletproof(synd_mob), slot_wear_suit)
	else
		synd_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/space/plasmaman/nuclear(synd_mob), slot_wear_suit)
		synd_mob.equip_to_slot_or_del(new /obj/item/weapon/tank/plasma/plasmaman(synd_mob), slot_s_store)
		synd_mob.equip_or_collect(new /obj/item/clothing/mask/breath/(synd_mob), slot_wear_mask)
		synd_mob.internal = synd_mob.get_item_by_slot(slot_s_store)
		if (synd_mob.internals)
			synd_mob.internals.icon_state = "internal1"
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(synd_mob), slot_gloves)
	if(!istype(synd_mob.species, /datum/species/plasmaman))
		synd_mob.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/swat(synd_mob), slot_head)
	else
		synd_mob.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/plasmaman/nuclear(synd_mob), slot_head)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/prescription(synd_mob), slot_glasses)//changed to prescription sunglasses so near-sighted players aren't screwed if there aren't any admins online
	if(istype(synd_mob.species, /datum/species/vox))
		synd_mob.equip_or_collect(new /obj/item/clothing/mask/breath/vox(synd_mob), slot_wear_mask)

		var/obj/item/weapon/tank/nitrogen/TN = new(synd_mob)
		synd_mob.put_in_hands(TN)
		to_chat(synd_mob, "<span class='notice'>You are now running on nitrogen internals from the [TN] in your hand. Your species finds oxygen toxic, so you must breathe nitrogen (AKA N<sub>2</sub>) only.</span>")
		synd_mob.internal = TN

		if (synd_mob.internals)
			synd_mob.internals.icon_state = "internal1"

	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/card/id/syndicate(synd_mob), slot_wear_id)
	switch(synd_mob.backbag)
		if(2)
			synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(synd_mob), slot_back)
		if(3,4)
			synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_sec(synd_mob), slot_back)
		if(5)
			synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/messenger/sec(synd_mob), slot_back)
	synd_mob.equip_to_slot_or_del(new /obj/item/ammo_storage/magazine/a12mm/ops(synd_mob), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/ammo_storage/magazine/a12mm/ops(synd_mob), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/pill/cyanide(synd_mob), slot_in_backpack) // For those who hate fun
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/pill/laststand(synd_mob), slot_in_backpack) // HOOOOOO HOOHOHOHOHOHO - N3X
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/c20r(synd_mob), slot_belt)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival/engineer(synd_mob.back), slot_in_backpack)
	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive/nuclear(synd_mob)
	E.imp_in = synd_mob
	E.implanted = 1
	var/datum/organ/external/affected = synd_mob.get_organ(LIMB_HEAD)
	affected.implants += E
	E.part = affected
	synd_mob.update_icons()
	return 1

/datum/faction/syndicate/nuke_op/proc/prepare_syndicate_leader(var/datum/mind/synd_mind, var/nuke_code)
	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	spawn(1)
		NukeNameAssign(nukelastname(synd_mind.current),members) //allows time for the rest of the syndies to be chosen
	synd_mind.current.real_name = "[syndicate_name()] [leader_title]"
	leader = synd_mind
	if (nuke_code)
		synd_mind.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [nuke_code]", 0, 0)
		to_chat(synd_mind.current, "The nuclear authorization code is: <B>[nuke_code]</B>")
		var/obj/item/weapon/paper/P = new
		P.info = "The nuclear authorization code is: <b>[nuke_code]</b>"
		P.name = "nuclear bomb code"
		var/mob/living/carbon/human/H = synd_mind.current
		P.forceMove(H.loc)
		H.equip_to_slot_or_drop(P, slot_r_store)
		H.update_icons()

	else
		nuke_code = "code will be provided later"
	return