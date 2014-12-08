/obj/item/weapon/shield
	name = "shield"

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "riot"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BACK
	force = 5.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	g_amt = 7500
	m_amt = 1000
	melt_temperature = MELTPOINT_GLASS
	origin_tech = "materials=2"
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time

/obj/item/weapon/shield/riot/suicide_act(mob/user)
	viewers(user) << "\red <b>[user] is smashing \his face into the [src.name]! It looks like \he's  trying to commit suicide!</b>"
	return (BRUTELOSS)

/obj/item/weapon/shield/riot/IsShield()
	return 1

/obj/item/weapon/shield/riot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/melee/baton))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()

/obj/item/weapon/shield/riot/roman
	name = "roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"

/obj/item/weapon/shield/riot/roman/IsShield()
	return 1

/obj/item/weapon/shield/riot/roman/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/twohanded/spear))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()



/obj/item/weapon/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = 1
	origin_tech = "materials=4;magnets=3;syndicate=4"
	attack_verb = list("shoved", "bashed")
	var/active = 0

/obj/item/weapon/shield/energy/suicide_act(mob/user)
	viewers(user) << "\red <b>[user] is putting the [src.name] to their head and activating it! It looks like \he's  trying to commit suicide!</b>"
	return (BRUTELOSS)

////////////////PORTAL SHIELD///////////////////
#define INACTIVE_PERIOD 100
/obj/item/weapon/shield/portal_shield
	name = "portal shield"
	desc = "A strange mechanical device, capable of storing and producing a vast armory in the blink of an eye. Armsmasters, beware."
	icon_state = "ps_idle"
	w_class = 3.0

	var/obj/item/weapon/storage/pocket_hole/storage_space

	var/active = 0 //whether its on or not
	var/last_activated

/obj/item/weapon/shield/portal_shield/New()
	..()
	storage_space = new(src)
	storage_space.can_hold = list(	"/obj/item/weapon/melee",
									"/obj/item/weapon/gun",
									"/obj/item/ammo_storage",
									"/obj/item/weapon/plastique",
									"/obj/item/weapon/grenade",
									"/obj/item/device/transfer_valve")

////SPAWNED VERSION - has stuff in it to start with////
/obj/item/weapon/shield/portal_shield/random

/obj/item/weapon/shield/portal_shield/random/New()
	..()
	while(src && storage_space && storage_space.contents.len < 15 && prob(90))
		var/list/spawn_items = pick(40;typesof(/obj/item/weapon/gun),
									40;typesof(/obj/item/weapon/melee) - /obj/item/weapon/melee,
									50;typesof(/obj/item/ammo_storage) - /obj/item/ammo_storage,
									60;list(/obj/item/weapon/plastique),
									60;typesof(/obj/item/weapon/grenade) - list(/obj/item/weapon/grenade, /obj/item/weapon/grenade/flashbang/clusterbang/segment, /obj/item/weapon/grenade/flashbang/clusterbang))
		var/obj/item/spawn_item = pick(spawn_items) //gets an item out of the chosen list
		new spawn_item(storage_space)

////////////////////////////////////////////////////////

/obj/item/weapon/shield/portal_shield/attack_self(mob/user)
	if(!active)
		src.shield_activate()
	else
		src.shield_deactivate()

/obj/item/weapon/shield/portal_shield/proc/hibernate(var/sleep_time = INACTIVE_PERIOD)
	if(!active)
		return
	if(world.time > last_activated + INACTIVE_PERIOD)
		shield_deactivate()
		return
	sleep(sleep_time)
	if(world.time > last_activated + INACTIVE_PERIOD)
		shield_deactivate()
		return

	var/time_difference = world.time - last_activated
	src.hibernate(time_difference)

/obj/item/weapon/shield/portal_shield/proc/shield_activate()
	if(!active)
		active = 1
		flick("ps_activation", src)
		icon_state = "ps_activated"
	last_activated = world.time
	hibernate()

/obj/item/weapon/shield/portal_shield/proc/shield_deactivate()
	if(active)
		flick("ps_deactivation", src)
		icon_state = "ps_idle"
		active = 0

/obj/item/weapon/shield/portal_shield/attackby(var/obj/O, mob/user)
	if(active)
		storage_space.attackby(O, user)
		last_activated = world.time
	return

/obj/item/weapon/shield/portal_shield/attack_hand(mob/user)
	if(active)
		storage_space.attack_hand(user)
		last_activated = world.time
	else
		..()

/obj/item/weapon/shield/portal_shield/dropped(mob/user as mob)
	..()
	shield_deactivate()

/obj/item/weapon/shield/portal_shield/proc/repair_weapon(var/obj/item/I)
	return

///////////////////////////

/obj/item/weapon/cloaking_device
	name = "cloaking device"
	desc = "Use this to become invisible to the human eyesocket."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	var/active = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	throwforce = 10.0
	throw_speed = 2
	throw_range = 10
	w_class = 2.0
	origin_tech = "magnets=3;syndicate=4"


/obj/item/weapon/cloaking_device/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		user << "\blue The cloaking device is now active."
		src.icon_state = "shield1"
	else
		user << "\blue The cloaking device is now inactive."
		src.icon_state = "shield0"
	src.add_fingerprint(user)
	return

/obj/item/weapon/cloaking_device/emp_act(severity)
	active = 0
	icon_state = "shield0"
	if(ismob(loc))
		loc:update_icons()
	..()
