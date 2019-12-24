/datum/faction/spider_clan
	name = "Spider Clan"
	desc = "For honor, for revengeance, or just to train by ruining someone's day."
	ID = SPIDERCLAN
	required_pref = NINJA
	initial_role = NINJA
	late_role = NINJA
	roletype = /datum/role/ninja
	initroletype = /datum/role/ninja
	logo_state = "ninja-logo"
	hud_icons = list("ninja-logo")

/datum/faction/spider_clan/New()
	..()
	load_dungeon(/datum/map_element/dungeon/ninja_dojo)


/datum/faction/spider_clan/forgeObjectives()
	if(cyborg_list.len)
		AppendObjective(/datum/objective/target/killsilicons)
	else
		if(prob(70))
			AppendObjective(/datum/objective/target/delayed/assassinate)
		else
			AppendObjective(/datum/objective/target/skulls)

	if(ai_list.len)
		AppendObjective(/datum/objective/killorstealAI)
	else
		AppendObjective(/datum/objective/target/steal)

	var/living = 0
	for(var/mob/living/M in player_list)
		if(!M.client)
			continue
		if(!iscarbon(M) && !issilicon(M))
			continue
		var/turf/T = get_turf(M)
		if(T.z != STATION_Z)
			continue
		if(M.stat != DEAD)
			living++
	if(living<=16 && prob(25))
		AppendObjective(/datum/objective/silence)
	else
		AppendObjective(/datum/objective/survive)
	if(prob(15))
		AppendObjective(/datum/objective/stealsake)


// -- Ninja procs --

/proc/equip_ninja(var/mob/living/carbon/human/spaceninja)
	if(!istype(spaceninja))
		return 0
	if(!isjusthuman(spaceninja))
		spaceninja = spaceninja.Humanize("Human")
	spaceninja.delete_all_equipped_items()
	if(spaceninja.gender == FEMALE)
		spaceninja.equip_to_slot_or_del(new /obj/item/clothing/under/color/blackf, slot_w_uniform)
	else
		spaceninja.equip_to_slot_or_del(new /obj/item/clothing/under/color/black, slot_w_uniform)
	disable_suit_sensors(spaceninja)
	spaceninja.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/ninja/apprentice, slot_head)
	spaceninja.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/voice/ninja, slot_wear_mask)
	spaceninja.equip_to_slot_or_del(new /obj/item/clothing/suit/space/ninja/apprentice, slot_wear_suit)
	spaceninja.equip_to_slot_or_del(new /obj/item/clothing/shoes/ninja/apprentice, slot_shoes)
	spaceninja.equip_to_slot_or_del(new /obj/item/clothing/gloves/ninja, slot_gloves)
	spaceninja.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/ninja(), slot_s_store)
	spaceninja.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/silicon, slot_belt)
	spaceninja.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/messenger/black, slot_back)
	spaceninja.equip_to_slot_or_del(new /obj/item/weapon/storage/box/syndie_kit/smokebombs, slot_in_backpack)
	spaceninja.equip_to_slot_or_del(new /obj/item/weapon/substitutionhologram, slot_in_backpack)
	spaceninja.equip_to_slot_or_del(new /obj/item/weapon/substitutionhologram, slot_in_backpack)
	spaceninja.equip_to_slot_or_del(new /obj/item/weapon/substitutionhologram, slot_in_backpack)
	spaceninja.equip_to_slot_or_del(new /obj/item/mounted/poster/stealth, slot_in_backpack)
	spaceninja.equip_to_slot_or_del(new /obj/item/stack/shuriken(spaceninja,10), slot_l_store)
	spaceninja.equip_to_slot_or_del(new /obj/item/device/radio/headset, slot_ears)
	spaceninja.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double(spaceninja), slot_r_store)
	spaceninja.internal = spaceninja.get_item_by_slot(slot_r_store)
	if (spaceninja.internals)
		spaceninja.internals.icon_state = "internal1"

	spaceninja.see_in_dark_override = 8

#define GREET_WEEB "weebgreet"
/proc/equip_weeaboo(var/mob/living/carbon/human/H)
	if(!istype(H))
		return 0
	H.delete_all_equipped_items()
	H.put_in_hands(new /obj/item/weapon/katana/hesfast)

	H.equip_to_slot_or_del(new /obj/item/clothing/head/rice_hat, slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/balaclava, slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/kimono/ronin, slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/black, slot_w_uniform)
	disable_suit_sensors(H)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/silicon, slot_belt)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal, slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/ninja/nentendiepower, slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/messenger/black, slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/syndie_kit/smokebombs, slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/weapon/substitutionhologram/dakimakura, slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/weapon/substitutionhologram/dakimakura, slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/weapon/substitutionhologram/dakimakura, slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/mounted/poster/stealth/anime, slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/stack/shuriken/pizza(H,10), slot_l_store)

	H.see_in_dark_override = 8

	var/datum/role/R = H.mind.GetRole(NINJA)
	if(R)
		R.Greet(GREET_WEEB)

/proc/name_ninja(var/mob/living/carbon/human/H)
	if(!isjusthuman(H))
		H.set_species("Human", 1)
	var/ninja_title = pick(ninja_titles)
	var/ninja_name = pick(ninja_names)
	H.fully_replace_character_name(H.real_name, "[ninja_title] [ninja_name]")
	mob_rename_self(H, "ninja")

/datum/map_element/dungeon/ninja_dojo //small room for the ninja to get oriented
	file_path = "maps/misc/dojo.dmm"
	unique = TRUE

/obj/structure/button/ninja
	activate_id = "0"
	global_search = 0
	reset_name = 0
	
/obj/structure/button/ninja/attack_hand(mob/user)

	visible_message("<span class='info'>[user] presses \the [src].</span>")
	activate(user)
	
/obj/structure/button/ninja/launcher
	name = "Launch button"
	desc = "Pressing this button will activate your space protection and launch you to the target station from a random direction."
	
/obj/structure/button/ninja/launcher/activate(mob/user)
	var/mob/living/carbon/human/spaceninja = user
	if(spaceninja.get_item_by_slot(slot_wear_suit))
		spaceninja.get_item_by_slot(slot_wear_suit).pressurize()
	if(spaceninja.get_item_by_slot(slot_shoes))
		spaceninja.get_item_by_slot(slot_shoes).activateMagnets()
	spaceninja.ThrowAtStation()

/obj/structure/button/ninja/teleporter
	name = "Teleport button"
	desc = "Pressing this button will teleport you into a dark secluded place on the target station."

/obj/structure/button/ninja/teleporter/activate(mob/user)
	usr.spawn_rand_maintenance()
	
/obj/effect/decal/ninjaporter
	name = "ninja teleporter"
	desc = "Teleports you at the press of a button!"
	icon = 'icons/mecha/mecha_equipment.dmi' //placeholder until someone sprites something better
	icon_state = "mecha_teleport"  // much like the acoustic floors instead of tatami mats