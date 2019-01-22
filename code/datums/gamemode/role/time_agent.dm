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

/datum/role/time_agent/ForgeObjectives()
	AppendObjective(/datum/objective/target/locate/random)
	AppendObjective(/datum/objective/survive)

/datum/role/time_agent/OnPostSetup()
	.=..()
	if(istype(antag.current, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = antag.current
		spawn()
			showrift(H,1)
		H.delete_all_equipped_items()
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/time, slot_head)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/time, slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/death_commando, slot_wear_mask)
		H.equip_to_slot_or_del(new /obj/item/device/chronocapture, slot_l_store)
		H.equip_to_slot_or_del(new /obj/item/device/jump_charge, slot_r_store)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/grenade/chrono, slot_belt)
		H.put_in_hands(new /obj/item/weapon/gun/projectile/automatic/rewind)
		H.fully_replace_character_name(newname = "John Beckett")

/obj/item/device/chronocapture
	name = "chronocapture device"
	desc = "Used to confirm that everything is where it should be."
	icon = 'icons/obj/items.dmi'
	icon_state = "polaroid"
	item_state = "polaroid"
	w_class = W_CLASS_SMALL
	var/triggered = FALSE

/obj/item/device/chronocapture/afterattack(atom/target, mob/user)
	if(!triggered)
		triggered = TRUE
		playsound(loc, "polaroid", 75, 1, -3)
		spawn(3 SECONDS)
			triggered = FALSE
		if(istimeagent(user))
			var/datum/role/R = user.mind.GetRole(TIMEAGENT)
			if(R)
				var/datum/objective/target/locate/L = locate() in R.objectives.GetObjectives()
				if(L)
					L.check(range(target,3))

/obj/item/weapon/gun/projectile/automatic/rewind
	name = "rewind rifle"
	desc = "Don't need to reload if you just rewind the bullets back into the gun."
	icon_state = "xcomlasergun"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	caliber = list(MM12 = 1)

/obj/item/weapon/gun/projectile/automatic/rewind/send_to_past(var/duration)
	var/mob/owner = loc
	..()
	spawn(duration)
		owner.put_in_hands(src)

/obj/item/weapon/gun/projectile/automatic/rewind/special_check(var/mob/M)
	return istimeagent(M)

/obj/item/weapon/gun/projectile/automatic/rewind/process_chambered()
	attempt_past_send(rand(10,15) SECONDS)
	return ..()

/obj/item/weapon/gun/projectile/automatic/rewind/update_icon()
	icon_state = initial(icon_state)

/obj/item/device/jump_charge
	name = "jump charge"
	desc = "A strange button."
	icon_state = "jump_charge"
	w_class = W_CLASS_SMALL
	var/triggered = FALSE

/obj/item/device/jump_charge/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag && !triggered)
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		icon_state = "jump_charge_firing"
		to_chat(user, "<span class = 'notice'>Jump charge armed. Firing in 3 seconds.</span>")
		triggered = TRUE
		spawn(3 SECONDS)
			icon_state = "jump_no_charge"
			future_rift(target, 10 SECONDS, 1)
			spawn(10 SECONDS)
				icon_state = initial(icon_state)
				triggered = FALSE

/obj/item/weapon/storage/belt/grenade
	storage_slots = 6
	can_only_hold = list("/obj/item/weapon/grenade")

/obj/item/weapon/storage/belt/grenade/chrono/New()
	..()
	new /obj/item/weapon/grenade/chronogrenade(src)
	new /obj/item/weapon/grenade/chronogrenade(src)
	new /obj/item/weapon/grenade/chronogrenade/future(src)
	new /obj/item/weapon/grenade/chronogrenade/future(src)
	new /obj/item/weapon/grenade/smokebomb(src)
	new /obj/item/weapon/grenade/empgrenade(src)