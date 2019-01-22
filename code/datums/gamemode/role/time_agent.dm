/**
	Time agent

	You've got 5 minutes of playtime to do something weird

	If you succeed, the stations threat level is escalated

	If you fail, something weird happens.

	Are you a bad enough dude to make sure a corgi, a rubber duck, and a bucket are in the same place at the same time?

**/

/datum/role/time_agent
	name = "time agent"
	id = TIMEAGENT
	required_pref = ROLE_MADNESS
	logo_state = "time-logo"
	var/list/objects_to_delete = list()

/datum/role/time_agent/ForgeObjectives()
	AppendObjective(/datum/objective/target/locate/random)
	if(prob(30))
		AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/freeform/aid)


/datum/role/time_agent/process()
	if(!objectives.GetObjectives().len || locate(/datum/objective/time_agent_extract) in objectives.GetObjectives())
		return //Not set up yet
	var/finished = TRUE
	for(var/datum/objective/O in objectives.GetObjectives())
		if(!O.IsFulfilled())
			finished = FALSE
			break
	if(finished)
		to_chat(antag.current, "<span class = 'notice'>Objectives complete. Triangulating extraction point.</span>")
		AppendObjective(/datum/objective/time_agent_extract)

/datum/role/time_agent/OnPostSetup()
	.=..()
	if(istype(antag.current, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = antag.current
		spawn()
			showrift(H,1)
		H.delete_all_equipped_items()
		var/under = new /obj/item/clothing/under/rank/scientist(H)
		H.equip_to_slot_or_del(under, slot_w_uniform)
		var/helmet = new /obj/item/clothing/head/helmet/space/time(H)
		H.equip_to_slot_or_del(helmet, slot_head)
		var/suit = new /obj/item/clothing/suit/space/time(H)
		H.equip_to_slot_or_del(suit, slot_wear_suit)
		var/mask = new /obj/item/clothing/mask/gas/death_commando(H)
		H.equip_to_slot_or_del(mask, slot_wear_mask)
		var/camera = new /obj/item/device/chronocapture(H)
		H.equip_to_slot_or_del(camera, slot_l_store)
		var/jump_charge = new /obj/item/device/jump_charge(H)
		H.equip_to_slot_or_del(jump_charge, slot_r_store)
		var/belt = new /obj/item/weapon/storage/belt/grenade/chrono(H)
		H.equip_to_slot_or_del(belt, slot_belt)
		var/gun = new /obj/item/weapon/gun/projectile/automatic/rewind(H)
		H.put_in_hands(gun)
		objects_to_delete = list(under, helmet, suit, mask, camera, jump_charge, belt, gun)
		H.fully_replace_character_name(newname = "John Beckett")
		H.make_all_robot_parts_organic()

/datum/role/time_agent/proc/extract()
	var/mob/living/carbon/human/H = antag.current
	H.drop_all()
	showrift(H,1)
	qdel(H)
	for(var/i in objects_to_delete)
		objects_to_delete.Remove(i)
		qdel(i)

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
					L.check(view(target,2))

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
	if(istimeagent(user) && istype(target, /obj/effect/time_anomaly))
		var/datum/role/time_agent/R = user.mind.GetRole(TIMEAGENT)
		if(R)
			var/datum/objective/time_agent_extract/TAE = locate() in R.objectives.GetObjectives()
			if(TAE && target == TAE.anomaly)
				to_chat(user, "<span class = 'notice'>New anomaly discovered. Welcome back, [user.real_name]. Moving to new co-ordinates.</span>")
				R.extract()
				TAE.anomaly = null
				qdel(target)
		return
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