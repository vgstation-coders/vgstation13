/datum/role/revolutionary
	name = REV
	id = REV
	required_pref = REV
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Mobile MMI","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent")
	logo_state = "rev-logo"
	greets = list(GREET_DEFAULT,GREET_CUSTOM,GREET_ROUNDSTART,GREET_MIDROUND,GREET_LATEJOIN,GREET_CONVERTED,GREET_PROVOC_CONVERTED,GREET_REVSQUAD_CONVERTED,GREET_ADMINTOGGLE)

// The ticker current state check is because revs are created, at roundstart, in the cuck cube.
// Which is outside the z-level of the main station.

/datum/role/revolutionary/AssignToRole(var/datum/mind/M, var/override = 0, var/roundstart = 0)
	if (!(M && M.current) || (M.current.z != map.zMainStation && !roundstart))
		message_admins("Error: cannot create a revolutionary off the main z-level.")
		return FALSE
	return ..()

/datum/role/revolutionary/Greet(var/greeting, var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/><span class='warning'><FONT size = 3>You are a member of the revolutionaries' leadership!</FONT><BR>Flash un-implanted crew to bring them to your side and accomplish your objectives!</span>"})
		if (GREET_DEFAULT)
			to_chat(antag.current, {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/><span class='warning'><FONT size = 3>You are now a revolutionary!</FONT><BR>Help your fellow workers throw off the shackles of oppression! Viva!</span>"})
		if (GREET_MIDROUND)
			to_chat(antag.current, {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/><span class='warning'><FONT size = 3>You are part of the elite revolutionary squad!</FONT><BR>Each squad flash is only good for one conversion. Choose your allies wisely! Don't forget, your flash and headset are specially protected from EMPs.</span>"})
		if (GREET_LATEJOIN)
			to_chat(antag.current, {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/><span class='warning'><FONT size = 3>You are the revolutionary provocateur!</FONT><BR>You are the only member of the revolution who can convert crewmen. Flash un-implanted crew to bring them to your side and accomplish your objectives!</span>"})
		if (GREET_CONVERTED)
			to_chat(antag.current, {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/><span class='warning'><FONT size = 3>You are now a member of the revolution!</FONT><BR>Red \"R\" icons indicate comrades, blue indicates a revolutionary leader. Assist your leadership in converting the station and accomplishing your objectives.</span>"})
		if (GREET_REVSQUAD_CONVERTED)
			to_chat(antag.current, {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/><span class='warning'><FONT size = 3>You are now a member of the revolution!</FONT><BR>You have been selected as one of very few privileged workers who will join the revolution. Mass conversion will not be possible, so stick together with your squad!</span>"})
		if (GREET_PROVOC_CONVERTED)
			to_chat(antag.current, {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/><span class='warning'><FONT size = 3>You are now a member of the revolution!</FONT><BR>The Provocateur is the <B>only</B> revolutionary head and must be protected or it will be impossible to convert new revolutionaries. Protect your leader!</span></span>"})
		if (GREET_ADMINTOGGLE)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'>You suddenly feel rather annoyed with this stations leadership!</span>")
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'>[custom]</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

/datum/role/revolutionary/OnPostSetup()
	. = ..()
	AnnounceObjectives()

/datum/role/revolutionary/New()
	..()
	wikiroute = role_wiki[REV]

/datum/role/revolutionary/leader
	name = HEADREV
	id = HEADREV
	logo_state = "rev_head-logo"

	stat_datum_type = /datum/stat/role/revolutionary/leader

/datum/role/revolutionary/leader/OnPostSetup()
	.=..()
	if(!.)
		return
	var/mob/living/carbon/human/mob = antag.current
	var/datum/gamemode/dynamic/D = ticker.mode

	if(locate(/datum/dynamic_ruleset/midround/from_ghosts/faction_based/revsquad) in D.executed_rules)
		equip_revsquad(mob)
		mob.fully_replace_character_name("Cargonian",random_name(mob.gender)) //This will change the ID name, it MUST be Cargonian!
	else
		var/obj/item/device/flash/rev/T = new(mob)
		if(istype(mob))
			var/list/slots = list (
				"backpack" = slot_in_backpack,
				"left pocket" = slot_l_store,
				"right pocket" = slot_r_store,
			)
			var/where = mob.equip_in_one_of_slots(T, slots, put_in_hand_if_fail = 1)

			if (!where)
				to_chat(mob, "\The [faction.name] were unfortunately unable to get you \a [T].")
			else
				to_chat(mob, "\The [T] in your [where] will help you to persuade the crew to join your cause.")
		else
			T.forceMove(get_turf(mob))
			to_chat(mob, "\The [faction.name] were able to get you \a [T], but could not find anywhere to slip it onto you, so it is now on the floor.")

/datum/role/revolutionary/Drop(var/borged = FALSE)
	if (!antag)
		return ..()
	if (borged)
		antag.current.visible_message("<span class='big danger'>The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it.</span>",
				"<span class='big danger'>The frame's firmware detects and deletes your neural reprogramming! You remember nothing from the moment you were flashed until now.</span>")
	else
		antag.current.visible_message("<span class='big danger'>It looks like [antag.current] just remembered their real allegiance!</span>",
			"<span class='big danger'>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you...</span>")
	update_faction_icons()
	return ..()

var/list/revsquad_guns = list(/obj/item/weapon/gun/projectile/automatic/uzi, ///obj/item/ammo_storage/magazine/uzi45
									/obj/item/weapon/gun/projectile/pistol, ///obj/item/ammo_storage/magazine/mc9mm
									/obj/item/weapon/gun/projectile/shotgun/doublebarrel/sawnoff, ///obj/item/ammo_storage/speedloader/shotgun
									/obj/item/weapon/gun/projectile/automatic/xcom, ///obj/item/ammo_casing/a12mm/assault
									/obj/item/weapon/gun/projectile/luger, ///obj/item/ammo_storage/magazine/mc9mm
									/obj/item/weapon/gun/projectile/colt,
									/obj/item/weapon/gun/projectile/deagle, ///obj/item/ammo_storage/magazine/a50
									/obj/item/weapon/gun/projectile/deagle/gold,
									/obj/item/weapon/gun/projectile/deagle/camo,
									/obj/item/weapon/gun/projectile/gyropistol, ///obj/item/ammo_storage/magazine/a75
									/obj/item/weapon/gun/projectile/beretta, ///obj/item/ammo_storage/magazine/beretta
									)

var/list/revsquad_gear = list(/obj/item/weapon/card/emag,
								   /obj/item/clothing/accessory/storage/bandolier/chaos,
								   //obj/item/gun_part/silencer,
								   /obj/item/clothing/suit/armor/vest,
								   /obj/item/weapon/storage/belt/slim/pro,
								   /obj/item/weapon/storage/box/flashbangs,
								   /obj/item/device/flash/rev/revsquad, //each revsquad flash is only worth +1 convert
								   /obj/item/weapon/storage/box/smokebombs,
								   /obj/item/weapon/storage/box/handcuffs,
								   /obj/item/weapon/storage/box/bolas,
								   /obj/item/weapon/storage/bag/ammo_pouch/rev,
								   /obj/item/clothing/glasses/sunglasses/prescription,
								   /obj/item/weapon/melee/telebaton,
								   /obj/item/weapon/melee/classic_baton,
								   /obj/item/weapon/reagent_containers/spray/rev
								  )

// Rev gear
/obj/item/device/pulsar
	name = "EMP pulsar"
	desc = "The power of the stars in your pocket. Activate in hand to ruin all the tech around you, Luddite."
	icon_state = "empar"
	w_class = W_CLASS_SMALL
	var/active = FALSE

/obj/item/device/pulsar/Destroy()
	if(active)
		processing_objects -= src
	..()

/obj/item/device/pulsar/attack_self(mob/user)
	if(active)
		processing_objects -= src
	else
		processing_objects += src
	active = !active
	to_chat(user,"<span class='notice'>You toggle \the [src] [active ? "on" : "off"].")

/obj/item/device/pulsar/process()
	if(active)
		empulse(src,2,4)

/obj/item/clothing/accessory/storage/bandolier/chaos
	desc = "A bandolier designed to strap in with an incredible number of IEDs."
	storage_slots = 14
	can_only_hold = list("/obj/item/weapon/grenade/iedcasing")

/obj/item/clothing/accessory/storage/bandolier/chaos/New()
	..()
	for(var/i = 1 to storage_slots)
		new /obj/item/weapon/grenade/iedcasing/preassembled/withshrapnel(src)

/obj/item/weapon/storage/bag/ammo_pouch/rev
	desc = "Designed to hold stray magazines and spare bullets. This one has been enlarged significantly."
	storage_slots = 8

/obj/item/weapon/storage/bag/ammo_pouch/rev/New()
	..()
	var/mob/living/carbon/human/H = locate(/mob/living/carbon/human) in get_turf(src)
	var/obj/item/weapon/storage/S = H.back
	if(!S)
		return
	for(var/obj/item/weapon/gun/projectile/P in S.contents)
		if(P.mag_type)
			var/path = text2path(P.mag_type)
			new path(src)
			new path(src)
		else if(istype(P,/obj/item/weapon/gun/projectile/shotgun))
			new /obj/item/ammo_storage/speedloader/shotgun/loaded(src)
			new /obj/item/ammo_storage/speedloader/shotgun/loaded(src)
		else if(istype(P,/obj/item/weapon/gun/projectile/colt))
			new /obj/item/ammo_storage/speedloader/a357(src)
			new /obj/item/ammo_storage/speedloader/a357(src)

/obj/item/weapon/reagent_containers/spray/rev
	name = "Lubricant spray"
	desc = "Nothing more working class than slipping the floors."

/obj/item/weapon/reagent_containers/spray/rev/New()
	..()
	reagents.add_reagent(LUBE, 250)
	new /obj/item/weapon/reagent_containers/spray/antilube(src.loc)

/obj/item/weapon/reagent_containers/spray/antilube
	name = "Antilube Spray"
	desc = "Use to make ground manueverable, or if you hate fun."
	color = "#FFAAAA" //Shade it red so it's easy to distinguish

/obj/item/weapon/reagent_containers/spray/antilube/New()
	..()
	reagents.add_reagent(SODIUM_POLYACRYLATE, 250)

//equip

/proc/equip_revsquad(mob/living/carbon/human/rev_mob)
	if(rev_mob.overeatduration) //We need to do this here and now, otherwise a lot of gear will fail to spawn
		to_chat(rev_mob, "<span class='notice'>Your intensive physical training to become a Squad member has paid off and made you fit again!</span>")
		rev_mob.overeatduration = 0 //Fat-B-Gone
		if(rev_mob.nutrition > 400) //We are also overeating nutriment-wise
			rev_mob.nutrition = 400 //Fix that
		rev_mob.mutations.Remove(M_FAT)
		rev_mob.update_mutantrace(0)
		rev_mob.update_mutations(0)
		rev_mob.update_inv_w_uniform(0)
		rev_mob.update_inv_wear_suit()

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/revsquad(rev_mob)
	//R.set_frequency(REV_FREQ)
	rev_mob.equip_to_slot_or_del(R, slot_ears)

	rev_mob.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargotech(rev_mob), slot_w_uniform)
	rev_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(rev_mob), slot_shoes)
	rev_mob.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(rev_mob), slot_gloves)
	//Handle Aliens
	if(istype(rev_mob.species, /datum/species/plasmaman))
		rev_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/space/plasmaman/cargo(rev_mob), slot_wear_suit)
		rev_mob.equip_to_slot_or_del(new /obj/item/weapon/tank/plasma/plasmaman(rev_mob), slot_s_store)
		rev_mob.equip_or_collect(new /obj/item/clothing/mask/breath(rev_mob), slot_wear_mask)
		rev_mob.internal = rev_mob.get_item_by_slot(slot_s_store)
		if (rev_mob.internals)
			rev_mob.internals.icon_state = "internal1"
		rev_mob.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/plasmaman/cargo(rev_mob), slot_head)
	else if(istype(rev_mob.species, /datum/species/vox))
		rev_mob.equip_or_collect(new /obj/item/clothing/mask/breath/vox(rev_mob), slot_wear_mask)
		rev_mob.equip_or_collect(new /obj/item/clothing/suit/space/vox/civ/cargo, slot_wear_suit)
		rev_mob.equip_or_collect(new /obj/item/clothing/head/helmet/space/vox/civ/cargo, slot_head)
		var/obj/item/weapon/tank/nitrogen/TN = new(rev_mob)
		rev_mob.put_in_hands(TN)
		to_chat(rev_mob, "<span class='notice'>You are now running on nitrogen internals from the [TN] in your hand. Your species finds oxygen toxic, so you must breathe nitrogen (AKA N<sub>2</sub>) only.</span>")
		rev_mob.internal = TN

		if (rev_mob.internals)
			rev_mob.internals.icon_state = "internal1"
	else
		rev_mob.equip_to_slot_or_del(new /obj/item/clothing/head/soft(rev_mob), slot_head) //cargo cap

	var/obj/item/weapon/card/id/supply/ID = new(rev_mob)
	ID.assignment = "Cargo Technician"
	rev_mob.equip_to_slot_or_del(ID, slot_wear_id)

	var/obj/item/weapon/storage/backpack/satchel/BP = new(rev_mob.loc)
	rev_mob.equip_to_slot_or_del(BP, slot_back)
	rev_mob.equip_to_slot_or_del(new /obj/item/device/flash/rev/revsquad(rev_mob), slot_l_store)
	rev_mob.equip_to_slot_or_del(new /obj/item/device/pulsar(rev_mob), slot_r_store)
	for(var/i = 1 to rand(2,4))
		var/tospawn = pick(revsquad_guns)
		new tospawn(BP)
	var/list/possible_gear = revsquad_gear.Copy()
	while(BP.contents.len < BP.storage_slots)
		var/tospawn = pick_n_take(possible_gear)
		if(istype(tospawn,/obj/item/weapon/reagent_containers/spray/rev)&&BP.storage_slots-BP.contents.len==1)
			continue //don't spawn the lube bottle as our last item because it needs an extra slot for the antilube
		new tospawn(BP)

	rev_mob.update_icons()
	return 1
