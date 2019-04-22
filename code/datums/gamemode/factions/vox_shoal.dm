/datum/faction/vox_shoal
	name = "Vox Shoal"
	desc = "In short supply of money, organs, experts, and rubber duckies."
	ID = VOXSHOAL
	required_pref = VOXRAIDER
	initial_role = VOXRAIDER
	late_role = VOXRAIDER
	roletype = /datum/role/vox_raider
	initroletype = /datum/role/vox_raider
	logo_state = "vox-logo"
	hud_icons = list("vox-logo")

/datum/faction/vox_shoal/forgeObjectives()

/datum/faction/vox_shoal/GetScoreboard()

/datum/faction/vox_shoal/AdminPanelEntry()

/datum/faction/vox_shoal/OnPostSetup()
	..()
	var/list/turf/vox_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "voxstart")
			vox_spawn += get_turf(A)
			qdel(A)
			A = null
			continue

	var/spawn_count = 1

	for(var/datum/role/vox_raider/V in members)
		if(spawn_count > vox_spawn.len)
			spawn_count = 1
		var/datum/mind/synd_mind = V.antag
		synd_mind.current.forceMove(vox_spawn[spawn_count])
		spawn_count++
		if (istype(V, /datum/role/vox_raider/chief_vox))
			equip_raider(synd_mind.current)
		equip_raider(synd_mind.current)

/datum/faction/vox_shoal/proc/equip_raider(var/mob/living/carbon/human/vox)
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
	vox.equip_vox_raider()
	vox.regenerate_icons()

/mob/living/carbon/human/proc/equip_vox_raider()
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/raider(src)
	R.set_frequency(RAID_FREQ) // new fancy vox raiders radios now incapable of hearing station freq
	equip_to_slot_or_del(R, slot_ears)

	var/obj/item/clothing/under/vox/vox_robes/uni = new /obj/item/clothing/under/vox/vox_robes(src)
	uni.attach_accessory(new/obj/item/clothing/accessory/holomap_chip/raider(src))
	equip_to_slot_or_del(uni, slot_w_uniform)

	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox(src), slot_shoes) // REPLACE THESE WITH CODED VOX ALTERNATIVES.
	equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow/vox(src), slot_gloves) // AS ABOVE.

	var/index = 1

	switch(index)
		if(1) // Vox raider!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/carapace(src), slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/carapace(src), slot_head)
			equip_to_slot_or_del(new /obj/item/weapon/melee/telebaton(src), slot_belt)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(src), slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/device/chameleon(src), slot_l_store)

			var/obj/item/weapon/crossbow/W = new(src)
			W.cell = new /obj/item/weapon/cell/crap(W)
			W.cell.charge = 500
			put_in_hands(W)

			var/obj/item/stack/rods/A = new(src)
			A.amount = 20
			put_in_hands(A)

		if(2) // Vox engineer!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/pressure(src), slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/pressure(src), slot_head)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(src), slot_belt)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/scanner/meson(src), slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			put_in_hands(new /obj/item/weapon/storage/box/emps(src))
			put_in_hands(new /obj/item/device/multitool(src))


		if(3) // Vox saboteur!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/carapace(src), slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/carapace(src), slot_head)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(src), slot_belt)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(src), slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/weapon/card/emag(src), slot_l_store)
			put_in_hands(new /obj/item/weapon/gun/dartgun/vox/raider(src))
			put_in_hands(new /obj/item/device/multitool(src))

		if(4) // Vox medic!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/pressure(src), slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/pressure(src), slot_head)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(src), slot_belt) // Who needs actual surgical tools?
			equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(src), slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/weapon/circular_saw(src), slot_l_store)
			put_in_hands(new /obj/item/weapon/gun/dartgun/vox/medical)

	equip_to_slot_or_del(new /obj/item/clothing/mask/breath/vox(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen(src), slot_back)
	equip_to_slot_or_del(new /obj/item/device/flashlight(src), slot_r_store)

	var/obj/item/weapon/card/id/syndicate/C = new(src)
	//C.name = "[real_name]'s Legitimate Human ID Card"
	C.registered_name = real_name
	C.assignment = "Trader"
	C.UpdateName()
	C.SetOwnerInfo(src)

	C.icon_state = "trader"
	C.access = list(access_syndicate, access_trade)
	//C.registered_user = src
	var/obj/item/weapon/storage/wallet/W = new(src)
	W.handle_item_insertion(C)
	// NO. /vg/ spawn_money(rand(50,150)*10,W)
	equip_to_slot_or_del(W, slot_wear_id)

	index++
	if (index > 4)
		index = 1

	return 1