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
	..()
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

		equip_nuke_op(synd_mind.current)
		share_syndicate_codephrase(N.antag.current)
		N.antag.current << sound('sound/voice/syndicate_intro.ogg')

		if(!leader_selected)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
			agent_number++
		spawnpos++

		spawn()
			equip_nuke_loadout(synd_mind.current)

	if(uplinklocker)
		new /obj/structure/closet/syndicate/nuclear(uplinklocker.loc)

	if(nuke_spawn && synd_spawn.len > 0)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	update_faction_icons()

/datum/faction/syndicate/nuke_op/proc/nuke_name_assign(var/last_name, var/title = "", var/list/syndicates)
	for(var/datum/role/R in syndicates)
		switch(R.antag.current.gender)
			if(MALE)
				R.antag.current.fully_replace_character_name(R.antag.current.real_name, "[leader == R ? "[title] ":""][pick(first_names_male)] [last_name ? "[last_name]":"[pick(last_names)]"]")
			if(FEMALE)
				R.antag.current.fully_replace_character_name(R.antag.current.real_name, "[leader == R ? "[title] ":""][pick(first_names_female)] [last_name ? "[last_name]":"[pick(last_names)]"]")

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
	synd_mob.equip_to_slot_or_drop(R, slot_ears)

	synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/under/syndicate/holomap(synd_mob), slot_w_uniform)
	synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/shoes/combat(synd_mob), slot_shoes)
	if(!istype(synd_mob.species, /datum/species/plasmaman))
		synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/suit/armor/bulletproof(synd_mob), slot_wear_suit)
	else
		synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/suit/space/plasmaman/nuclear(synd_mob), slot_wear_suit)
		synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/tank/plasma/plasmaman(synd_mob), slot_s_store)
		synd_mob.equip_or_collect(new /obj/item/clothing/mask/breath/(synd_mob), slot_wear_mask)
		synd_mob.internal = synd_mob.get_item_by_slot(slot_s_store)
		if (synd_mob.internals)
			synd_mob.internals.icon_state = "internal1"
	synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/gloves/combat(synd_mob), slot_gloves)
	if(!istype(synd_mob.species, /datum/species/plasmaman))
		synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/head/helmet/tactical/swat(synd_mob), slot_head)
	else
		synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/head/helmet/space/plasmaman/nuclear(synd_mob), slot_head)
	if(istype(synd_mob.species, /datum/species/vox))
		synd_mob.equip_or_collect(new /obj/item/clothing/mask/breath/vox(synd_mob), slot_wear_mask)

		var/obj/item/weapon/tank/nitrogen/TN = new(synd_mob)
		synd_mob.put_in_hands(TN)
		to_chat(synd_mob, "<span class='notice'>You are now running on nitrogen internals from \the [TN] in your hand. Your species finds oxygen toxic, so you must breathe nitrogen (AKA N<sub>2</sub>) only.</span>")
		synd_mob.internal = TN

		if(synd_mob.internals)
			synd_mob.internals.icon_state = "internal1"

	synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/card/id/syndicate(synd_mob), slot_wear_id)
	switch(synd_mob.backbag)
		if(2)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/backpack/security(synd_mob), slot_back)
		if(3, 4)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/backpack/satchel_sec(synd_mob), slot_back)
		if(5)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/backpack/messenger/sec(synd_mob), slot_back)

	synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/box/survival/nuke(synd_mob), slot_in_backpack) //The cyanide pills are in there, for people wondering

	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive/nuclear(synd_mob)
	E.imp_in = synd_mob
	E.implanted = 1
	var/datum/organ/external/affected = synd_mob.get_organ(LIMB_HEAD)
	affected.implants += E
	E.part = affected
	synd_mob.update_icons()
	return 1

//This is separate because the mob will have to make a decision as to what it wants as a loadout. Once this is chosen, the gear will be slapped onto them to not waste time
/datum/faction/syndicate/nuke_op/proc/equip_nuke_loadout(mob/living/carbon/human/synd_mob)

	switch(input(synd_mob, "Your operation is about to begin. What kind of operations would you like to specialize into ?") in list("Ballistics", "Energy", "Demolition", "Melee", "Medical", "Engineering", "Stealth", "Ship and Cameras"))

		if("Ballistics") //Classic Ballistics setup. C20R rifle with ammo, and Beretta handgun also with ammo as a backup
			synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/glasses/sunglasses/prescription(synd_mob), slot_glasses) //Changed to prescription sunglasses for near-sighted players
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/gun/projectile/automatic/c20r(synd_mob), slot_belt)
			synd_mob.equip_to_slot_or_drop(new /obj/item/ammo_storage/magazine/a12mm/ops(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/ammo_storage/magazine/a12mm/ops(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/gun/projectile/beretta(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/ammo_storage/magazine/beretta(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/ammo_storage/magazine/beretta(synd_mob), slot_in_backpack)
		if("Energy") //Classic alternate setup with a twist. Laser Rifle as a primary, but ion carbine as a backup and extra EMP nades for those ENERGY needs. Zap-zap the borgs
			synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/glasses/sunglasses/prescription(synd_mob), slot_glasses) //Changed to prescription sunglasses for near-sighted players
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/gun/energy/laser(synd_mob), slot_belt)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/gun/energy/ionrifle/ioncarbine(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/grenade/empgrenade(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/grenade/empgrenade(synd_mob), slot_in_backpack)
		if("Demolition") //Boom boom, shake the room as the kids say. RPG as primary and grenade launcher as secondary, with C4 and nades reserve. He blows
			synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/glasses/sunglasses/prescription(synd_mob), slot_glasses) //Changed to prescription sunglasses for near-sighted players
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/gun/projectile/rocketlauncher(synd_mob), slot_s_store) //Only place we can store it, it will drop on the ground for plasmamen
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/gun/grenadelauncher/syndicate(synd_mob), slot_belt)
			synd_mob.equip_to_slot_or_drop(new /obj/item/ammo_casing/rocket_rpg(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/ammo_casing/rocket_rpg(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/ammo_casing/rocket_rpg(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/box/syndigrenades(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/box/syndigrenades(synd_mob), slot_in_backpack)
		if("Melee") //Really powerful melee weapons and energy shield, along with random extra goods and eviscerator nades. A dream come true
			synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/glasses/sunglasses/prescription(synd_mob), slot_glasses) //Changed to prescription sunglasses for near-sighted players
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/grenade/spawnergrenade/manhacks(synd_mob), slot_belt) //The non-Syndicate version to have enough manhacks
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/melee/energy/sword/dualsaber(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/melee/energy/hfmachete(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/shield/energy(synd_mob), slot_l_store)
		if("Medical") //The good guy who just wants to help their dumb fucking teammates not die horribly. Has some fancy gear like the mobile surgery table. Main gun is a VERY lethal syringe gun
			synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/glasses/hud/health/prescription(synd_mob), slot_glasses)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/gun/syringe/rapidsyringe(synd_mob), slot_belt)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/box/syndisyringes(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/firstaid/adv(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/reagent_containers/hypospray(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/pill_bottle/hyperzine(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/pill_bottle/inaprovaline(synd_mob), slot_in_backpack)
			synd_mob.put_in_hand(GRASP_RIGHT_HAND, new /obj/item/roller/surgery(synd_mob))
		if("Engineering") //Mister deconstruction, C4 and efficient. Engineers have shotguns because stereotype, and eswords for utility
			synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/glasses/scanner/meson/prescription(synd_mob), slot_glasses)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/gun/projectile/shotgun/pump/combat(synd_mob), slot_s_store) //Only place we can store it, it will drop on the ground for plasmamen
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/belt/utility/complete(synd_mob), slot_belt)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/storage/box/lethalshells(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/melee/energy/sword(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/plastique(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/plastique(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/plastique(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/glasses/welding/superior(synd_mob), slot_l_store)
			synd_mob.put_in_hand(GRASP_RIGHT_HAND, new /obj/item/clothing/shoes/magboots/syndie/elite(synd_mob))
		if("Stealth") //WE STELT. Has an energy crossbow primary and a silenced pistol with magazines, along with a basic kit of infiltration items you could need to not nuke the Ops' credits
			synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/glasses/thermal/syndi(synd_mob), slot_glasses)
			synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/mask/gas/voice(synd_mob), slot_wear_mask)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/gun/projectile/silenced(synd_mob), slot_belt)
			synd_mob.equip_to_slot_or_drop(new /obj/item/ammo_storage/magazine/c45(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/card/emag(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/pen/paralysis(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/gun/energy/crossbow(synd_mob), slot_l_store)
		if("Ship and Cameras") //The guy who stays on the shuttle and goes braindead. This kit is basically useless outside of giving you the coveted teleporter board, saving your team 40 points if you use it
			synd_mob.equip_to_slot_or_drop(new /obj/item/clothing/glasses/thermal/syndi(synd_mob), slot_glasses)
			synd_mob.equip_to_slot_or_drop(new /obj/item/device/encryptionkey/binary(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/device/megaphone/madscientist(synd_mob), slot_in_backpack)
			synd_mob.equip_to_slot_or_drop(new /obj/item/weapon/circuitboard/teleporter(synd_mob), slot_l_store)

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
