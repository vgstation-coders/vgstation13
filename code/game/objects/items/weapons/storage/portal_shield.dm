/obj/item/weapon/storage/portal_shield
	name = "portal shield"
	desc = "A strange mechanical device, capable of storing and producing a vast armory in the blink of an eye. Armsmasters, beware."
	icon = 'icons/obj/storage.dmi'
	icon_state = "ps_idle"
	w_class = 3.0

	var/active = 0 //whether its on or not
	var/last_activated

	can_hold = list("/obj/item/weapon/melee",
					"/obj/item/weapon/gun",
					"/obj/item/ammo_storage",
					"/obj/item/weapon/plastique",
					"/obj/item/weapon/grenade",
					"/obj/item/device/transfer_valve") //List of objects which this item can store (if set, it can't store anything else)

	max_w_class = 5
	max_combined_w_class = 0
	storage_slots = 0 //Totally overboard

////SPAWNED VERSION - has stuff in it to start with////
/obj/item/weapon/storage/portal_shield/random

/obj/item/weapon/storage/portal_shield/random/New()
	..()
	var/obj/item/spawn_item
	while(prob(50))
		spawn_item = pick(typesof(/obj/item/weapon/gun))
		contents += new spawn_item(src)
	while(prob(40))
		spawn_item = pick(typesof(/obj/item/ammo_storage) - /obj/item/ammo_storage)
		contents += new spawn_item(src)
	while(prob(60))
		spawn_item = pick(typesof(/obj/item/weapon/melee) - /obj/item/weapon/melee)
		contents += new spawn_item(src)
	while(prob(60))
		spawn_item = /obj/item/weapon/plastique
		contents += new spawn_item(src)
	while(prob(70))
		spawn_item = pick(typesof(/obj/item/weapon/grenade) - /obj/item/weapon/grenade)
		contents += new spawn_item(src)

////////////////////////////////////////////////////////

/obj/item/weapon/storage/portal_shield/MouseDrop(over_object, src_location, over_location)
	if (src.active && (over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		var/mob/living/user = usr
		if(!user.stat || !user.lying)
			var/obj/item/chosen_item = input("Remove what?", "Contents", "Cancel") as obj in src.contents
			if(chosen_item && chosen_item in contents)
				user.put_in_active_hand(chosen_item)
				last_activated = world.time
	return

/obj/item/weapon/storage/portal_shield/attack_self(mob/user)
	if(!active)
		src.shield_activate()
	else
		src.shield_deactivate()

/obj/item/weapon/storage/portal_shield/process()
	if(world.time > last_activated + 100)
		shield_deactivate()
		return

/obj/item/weapon/storage/portal_shield/proc/shield_activate()
	if(!active)
		active = 1
		flick("ps_activation", src)
		icon_state = "ps_activated"
		processing_objects.Add(src)
	last_activated = world.time

/obj/item/weapon/storage/portal_shield/proc/shield_deactivate()
	if(active)
		flick("ps_deactivation", src)
		icon_state = "ps_idle"
		active = 0
		processing_objects.Remove(src)

/obj/item/weapon/storage/portal_shield/attackby()
	var/old_items = contents.len
	if(active)
		..()
	if(contents.len != old_items)
		last_activated = world.time
	return

/obj/item/weapon/storage/portal_shield/attack_hand(mob/user)
	if(!active)
		..()
	else
		if(src.drawFrom(user))
			last_activated = world.time

/obj/item/weapon/storage/portal_shield/dropped(mob/user as mob)
	..()
	shield_deactivate()

/obj/item/weapon/storage/portal_shield/proc/drawFrom(mob/user)
	if(!contents.len)
		return
	var/list/weapons_list = list()
	for(var/obj/item/weapon/W in src.contents)
		weapons_list += W
	if(weapons_list.len)
		var/obj/item/weapon/weapon = pick(weapons_list)
		repair_weapon(weapon)
		user.put_in_active_hand(weapon)
		return 1
	else
		var/obj/item/I = pick(src.contents)
		if(I)
			repair_weapon(I)
			user.put_in_active_hand(I)
			return 1

/obj/item/weapon/storage/portal_shield/proc/repair_weapon(var/obj/item/I)
	return