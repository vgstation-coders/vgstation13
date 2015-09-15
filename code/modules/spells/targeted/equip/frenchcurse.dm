/spell/targeted/equip_item/frenchcurse
	name = "French Curse"
	desc = "This curse will silence your target for a very long time."

	school = "evocation"
	charge_max = 300
	spell_flags = 0
	invocation = "FU'K Y'U D'NY"
	invocation_type = SpI_SHOUT
	range = 1
	cooldown_min = 50

	sparks_spread = 1
	sparks_amt = 4

	compatible_mobs = list(/mob/living/carbon/human)

	hud_state = "wiz_mime"

/spell/targeted/equip_item/frenchcurse/New()
	..()
	equipped_summons = list("[slot_wear_mask]" = /obj/item/clothing/mask/gas/mime,
							"[slot_w_uniform]" = /obj/item/clothing/under/mime)

/spell/targeted/equip_item/frenchcurse/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/living/carbon/human/target in targets)
		if(target.mind.assigned_role=="Clown")
			usr << "<span-class='warning'>Your magic energy is reflected back into you a thousand fold. Uh oh.</span>
			target << "<span-class='confirm'>The blessing of the honkmother repels the vile assault!</span>
			sleep(5)
			usr.gib()
		else
			flick("e_flash", target.flash)
			target.miming = 1
			target.add_spell(new /spell/aoe_turf/conjure/forcewall/mime)//They can't even acid the mime mask off, if they're going to be permanently muted they may as well get the benefits of the mime.

/spell/targeted/equip_item/frenchcurse/summon_item(var/newtype)
	var/obj/item/new_item = new newtype
	new_item.unacidable = 1
	new_item.canremove = 0
	if(istype(new_item, /obj/item/clothing/mask/gas/mime))
		var/obj/item/clothing/mask/gas/mime/M = new_item
		M.can_flip = 0
		M.muted = 1
	return new_item