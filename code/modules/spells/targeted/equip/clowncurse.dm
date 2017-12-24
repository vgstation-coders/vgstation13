/spell/targeted/equip_item/clowncurse
	name = "The Clown Curse"
	desc = "A curse that will turn its victim into a miserable clown."
	abbreviation = "CC"
	user_type = USER_TYPE_WIZARD

	school = "evocation"
	charge_max = 300
	invocation = "L' C'MMEDIA E F'NITA!"
	invocation_type = SpI_SHOUT
	range = 1
	spell_flags = WAIT_FOR_CLICK //SELECTABLE hinders you here, since the spell has a range of 1 and only works on adjacent guys. Having the TARGETTED flag here makes it easy for your target to run away from you!

	cooldown_min = 50

	sparks_spread = 1
	sparks_amt = 4

	compatible_mobs = list(/mob/living/carbon/human)

	hud_state = "wiz_clown"

/spell/targeted/equip_item/clowncurse/New()
	..()
	equipped_summons = list("[slot_wear_mask]" = /obj/item/clothing/mask/gas/clown_hat/stickymagic,
							"[slot_w_uniform]" = /obj/item/clothing/under/rank/clown,
							"[slot_shoes]" = /obj/item/clothing/shoes/clown_shoes/stickymagic)

/spell/targeted/equip_item/clowncurse/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/living/carbon/human/target in targets)
		target.flash_eyes(visual = 1)
		target.dna.SetSEState(CLUMSYBLOCK,1)
		genemutcheck(target,CLUMSYBLOCK,null,MUTCHK_FORCED)
		target.update_mutations()

/spell/targeted/equip_item/clowncurse/summon_item(var/newtype)
	var/obj/item/new_item = new newtype
	new_item.canremove = 0
	if(istype(new_item, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/M = new_item
		M.can_flip = 0
	if(istype(new_item, /obj/item/clothing/shoes/clown_shoes))
		var/obj/item/clothing/shoes/clown_shoes/M = new_item
		M.wizard_garb = 1  // This means that wizards who are clown cursed can still cast robed spells.
	return new_item


/spell/targeted/equip_item/clowncurse/christmas //elves for santa's workshop
	name = "The Elf Curse"
	desc = "A curse that will turn its victim into a miserable christmas elf."
	abbreviation = "EC"
	holiday_required = list("Christmas")

	hud_state = "wiz_elf"

	invocation = "MAK'N T'YS!"

/spell/targeted/equip_item/clowncurse/christmas/New()
	..()
	equipped_summons = list("[slot_head]" = /obj/item/clothing/head/elfhat/stickymagic,
							"[slot_w_uniform]" = /obj/item/clothing/under/elf/stickymagic,
							"[slot_shoes]" = /obj/item/clothing/shoes/clown_shoes/elf/stickymagic)