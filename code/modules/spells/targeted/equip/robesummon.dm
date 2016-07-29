/spell/targeted/equip_item/robesummon
	name = "Summon Robes"
	desc = "A spell which will summon you a new set of robes."

	school = "evocation"
	charge_max = 300

	level_max = list(Sp_TOTAL = 5, Sp_SPEED = 4, Sp_POWER = 1)
	invocation = "I PUT ON MY ROBE AND WIZARD HAT!"
	invocation_type = SpI_SHOUT
	range = -1
	spell_flags = INCLUDEUSER | Z2NOCAST //z2nocast to prevent wizards from summoning the spacesuit and getting a refund

	delete_old = 0 //Players shouldn't lose their hardsuits because they decided to summon some robes.

	cooldown_min = 50

	compatible_mobs = list(/mob/living/carbon/human)

	hud_state = "wiz_robesummon"

	var/list/valid_outfits = list("blue", "red", "marisa")


/spell/targeted/equip_item/robesummon/cast(list/targets, mob/user = usr)
	switch(pick(valid_outfits))

		if ("blue")
			equipped_summons = list("[slot_head]" = /obj/item/clothing/head/wizard,
									"[slot_wear_suit]" = /obj/item/clothing/suit/wizrobe,
									"[slot_shoes]" = /obj/item/clothing/shoes/sandal)

		if ("red")
			equipped_summons = list("[slot_head]" = /obj/item/clothing/head/wizard/red,
									"[slot_wear_suit]" = /obj/item/clothing/suit/wizrobe/red,
									"[slot_shoes]" = /obj/item/clothing/shoes/sandal)

		if("marisa")
			equipped_summons = list("[slot_head]" = /obj/item/clothing/head/wizard/marisa,
									"[slot_wear_suit]" = /obj/item/clothing/suit/wizrobe/marisa,
									"[slot_shoes]" = /obj/item/clothing/shoes/sandal/marisa)

		if("suit")
			equipped_summons = list("[slot_head]" = /obj/item/clothing/head/helmet/space/rig/wizard,
									"[slot_wear_suit]" = /obj/item/clothing/suit/space/rig/wizard,
									"[slot_shoes]" = /obj/item/clothing/shoes/sandal,
									"[slot_wear_mask]" = /obj/item/clothing/mask/breath,
									"[slot_s_store]" = /obj/item/weapon/tank/oxygen/yellow)

	usr.visible_message("<span class='danger'>[user] puts on \his robe and wizard hat!</span>", \
						"<span class='danger'>You put on your robe and wizard hat!</span>")

	..()

/spell/targeted/equip_item/robesummon/empower_spell()
	if(!valid_outfits.Find("suit"))
		valid_outfits = list("suit")
		spell_levels[Sp_POWER]++

	name = "Summon Hardsuit"
	desc = "A spell which will summon you a wizard hardsuit."
	delete_old = 1
	return "You have improved Summon Robes into [name]. It will now summon a gem-encrusted hardsuit with internals."
