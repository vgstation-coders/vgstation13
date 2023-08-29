/datum/role/judge
	name = JUDGE
	id = JUDGE
	required_pref = JUDGE
	special_role = JUDGE
	logo_state = "gun-logo"
	wikiroute = JUDGE
	disallow_job = TRUE
	restricted_jobs = list()

/datum/role/judge/OnPostSetup(laterole = FALSE)
	. =..()
	if(!.)
		return
	if(ishuman(antag.current))
		var/datum/outfit/special/with_id/judge/equipment = new
		equipment.equip(antag.current)
		var/new_name = pick(antag.current.gender == MALE ? judge_male_names : judge_female_names)
		antag.current.fully_replace_character_name(antag.current.real_name, "Judge [new_name]")

/datum/role/judge/ForgeObjectives()
	AppendObjective(/datum/objective/restore_order)

/datum/role/judge/Greet(greeting, custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if(GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>[custom]</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Judge! <br>The station has fallen into chaos and the crew needs your help to restore order.</span>")
			to_chat(antag.current, "<span class='bold'>Uphold the law.</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

/datum/outfit/special/with_id/judge
	outfit_name = "Judge"

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/security,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_wear_mask_str = /obj/item/clothing/mask/gas/swat,
			slot_ears_str = /obj/item/device/radio/headset/ert,
			slot_w_uniform_str = /obj/item/clothing/under/darkred,
			slot_shoes_str = /obj/item/clothing/shoes/combat,
			slot_head_str = /obj/item/clothing/head/helmet/dredd,
			slot_glasses_str = /obj/item/clothing/glasses/hud/security,
			slot_gloves_str = /obj/item/clothing/gloves/combat,
			slot_belt_str = /obj/item/weapon/storage/belt/security,
			slot_wear_suit_str = /obj/item/clothing/suit/armor/dredd,
			slot_l_store_str = /obj/item/weapon/storage/bag/ammo_pouch/judge
		)
	)

	items_to_collect = list(
		/obj/item/weapon/gun/lawgiver/demolition = GRASP_LEFT_HAND,
		/obj/item/binoculars,
		/obj/item/weapon/storage/box/flashbangs,
		/obj/item/weapon/gun/projectile/shotgun/nt12/widowmaker2000,
		/obj/item/weapon/melee/classic_baton/daystick,
		/obj/item/weapon/autocuffer,
	)

	pda_type = /obj/item/device/pda/ert
	pda_slot = slot_r_store
	id_type = /obj/item/weapon/card/id/judge

/datum/outfit/special/with_id/judge/post_equip(mob/living/carbon/human/H)
	equip_accessory(H, /obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical, /obj/item/clothing/shoes, 5)
	return ..()

/obj/item/weapon/storage/bag/ammo_pouch/judge
	desc = "Designed to hold stray magazines and spare bullets. This one has been enlarged significantly."
	storage_slots = 7

/obj/item/weapon/storage/bag/ammo_pouch/judge/New()
	..()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_storage/magazine/a12ga(src)

/datum/faction/justice
	name = "Justice Department"
	ID = JUSTICE_DEPARTMENT
	initial_role = JUDGE
	late_role = JUDGE
	desc = "I AM THE LAW"
	logo_state = "gun-logo"
	initroletype = /datum/role/judge
	roletype = /datum/role/judge
