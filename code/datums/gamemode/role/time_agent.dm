/**
	Time agent

	You've got 5 minutes of playtime to do something weird

	If you succeed, the stations threat level is escalated

	If you fail, something weird happens.

	Are you a bad enough dude to make sure a corgi, a rubber duck, and a bucket are in the same place at the same time?

**/

/datum/role/time_agent
	name = "Time Agent"
	id = TIMEAGENT
	required_pref = ROLE_MADNESS
	logo_state = "time-logo"

/datum/role/time_agent/OnPostSetup()
	.=..()
	if(istype(antag.current, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = antag.current
		H.delete_all_equipped_items()
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/time, slot_head)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/time, slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/death_commando, slot_wear_mask)
		H.equip_to_slot_or_del(new /obj/item/device/chronocapture, slot_l_store)
		H.put_in_hands(new /obj/item/weapon/gun/projectile/automatic/rewind)

/obj/item/device/chronocapture
	name = "chronocapture device"
	desc = "Used to confirm that everything is where it should be."
	icon = 'icons/obj/items.dmi'
	icon_state = "polaroid"
	item_state = "polaroid"
	w_class = W_CLASS_SMALL

/obj/item/weapon/gun/projectile/automatic/rewind
	name = "rewind rifle"
	desc = "Don't need to reload if you just rewind the bullets back into the gun."
	icon_state = "xcomlasergun"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	caliber = list(MM12 = 1)

/obj/item/weapon/gun/projectile/automatic/rewind/special_check(var/mob/M)
	return istimeagent(M)

/obj/item/weapon/gun/projectile/automatic/rewind/process_chambered()
	attempt_past_send(10 SECONDS)
	return ..()

/obj/item/weapon/gun/projectile/automatic/rewind/update_icon()
	icon_state = initial(icon_state)