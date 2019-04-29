#define NEEDED_CHARGE_TO_RESTOCK_MAG 30

//Robot racks.
/obj/item/robot_rack
	name = "generic robot rack"
	desc = "A rack for carrying objects as a robot."
	var/obj/object_type = null //The types of object the rack holds (subtypes are allowed).
	var/obj/initial_type = null //What type we start with. Useful if we start with a subtype of the type we can held.
	var/starting_objects = 0 //How many things we start with.
	var/capacity = 1 //How many things can be held.
	var/list/obj/held = list() //What is being held.

/obj/item/robot_rack/examine(mob/user)
	. = ..()
	if(length(held) > 0)
		var/obj/held_thing = held[length(held)]
		to_chat(user, "It is holding [length(held)] [held_thing.name][length(held) == 1 ? "" : "s"].")
	to_chat(user, "It can hold up to [capacity] item[capacity == 1 ? "" : "s"].")

/obj/item/robot_rack/New()
	. = ..()
	var/obj/starting_type = initial_type? initial_type : object_type
	if(starting_type && starting_objects)
		for(var/i = 1, i <= min(starting_objects, capacity), i++)
			held += new starting_type(src)
			update_icon()

/obj/item/robot_rack/Destroy()
	held = null
	..()

/obj/item/robot_rack/attack_self(mob/user)
	if(!length(held))
		to_chat(user, "<span class='notice'>\The [name] is empty.</span>")
		return
	var/obj/R = held[length(held)]
	R.forceMove(get_turf(src))
	held -= R
	to_chat(user, "<span class='notice'>You deploy [R].</span>")
	update_icon()

/obj/item/robot_rack/preattack(obj/O, mob/user, proximity, params)
	if(istype(O, object_type))
		if(length(held) < capacity)
			to_chat(user, "<span class='notice'>You collect [O].</span>")
			O.forceMove(src)
			held += O
			update_icon()
			return
		to_chat(user, "<span class='notice'>\The [name] is full and can't store any more items.</span>")
		return
	. = ..()

//Mediborg's bed rack
/obj/item/robot_rack/bed
	name = "bed rack"
	desc = "A rack for carrying a collapsed bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "borgbed_"
	object_type = /obj/structure/bed/roller
	initial_type = /obj/structure/bed/roller/borg
	var/obj/interact_type = /obj/structure/bed //Unbuckle dudes.
	starting_objects = 1

/obj/item/robot_rack/bed/preattack(obj/O, mob/user, proximity, params)
	if(istype(O, interact_type)) //Move this to rack level if in the future anything else needs this.
		O.attack_hand(user)
	if(istype(O, /obj/item/roller))
		var/obj/item/roller/folded = O
		folded.attack_self(user) //If it is folded, unfold it.
	. = ..()

/obj/item/robot_rack/bed/update_icon()
	icon_state = "[initial(icon_state)][length(held) > 0 ? "stored" : "deployed"]"

/obj/item/robot_rack/bed/syndie
	icon_state = "syndie_borgbed_"
	initial_type = /obj/structure/bed/roller/borg/syndie

//Ammo racks, they hold/make mags and borgs can attack it with projectile guns to load them.
/obj/item/robot_rack/ammo
	name = "default magazine carrier"
	desc = "ADMINS STOP SPAWNING ME"
	initial_type = /obj/item/ammo_storage/magazine
	object_type = /obj/item/ammo_storage/magazine
	var/reload_type = /obj/item/weapon/gun/projectile/automatic
	starting_objects = 0
	capacity = 1
	var/charge = 0

/obj/item/robot_rack/ammo/restock()
	charge++
	if((charge >= NEEDED_CHARGE_TO_RESTOCK_MAG) && (length(held) < capacity)) //takes about 60 seconds.
		var/obj/item/ammo_storage/magazine/ammo = new initial_type(src)
		playsound(src, 'sound/machines/info.ogg',20)
		held += ammo
		charge = initial(charge)
		update_icon()

/obj/item/robot_rack/ammo/attackby(obj/O, mob/user)
	if(istype(O, reload_type))
		if(held && (length(held) > 0))
			var/obj/item/weapon/gun/projectile/automatic/G = O
			var/obj/item/ammo_storage/magazine/M = held[length(held)]
			if(!G.stored_magazine)
				playsound(src, 'sound/weapons/magdrop_1.ogg',20)
				M.forceMove(G)
				held -= M
				G.LoadMag(M)
				update_icon()
				return TRUE
		else
			to_chat(user, "\The [name] is empty!")

//Syndicate Blitzkrieg's ammo rack/loader
/obj/item/robot_rack/ammo/a12mm
	name = "blitzkrieg a12mm carrier"
	desc = "A special magazine carrier complete with gun-reloading mechanism and portable ammolathe. It needs to be directly connected to a recharging station to make more magazines."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "ammopack_0"
	initial_type = /obj/item/ammo_storage/magazine/a12mm/ops
	object_type = /obj/item/ammo_storage/magazine/a12mm
	reload_type = /obj/item/weapon/gun/projectile/automatic/c20r
	starting_objects = 4
	capacity = 4

/obj/item/robot_rack/ammo/a12mm/update_icon()
	icon_state = "ammopack_[length(held)]"

#undef NEEDED_CHARGE_TO_RESTOCK_MAG