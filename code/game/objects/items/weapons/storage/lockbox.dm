//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = 4
	max_w_class = 3
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_access = list(access_armory)
	var/locked = 1
	var/broken = 0
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/card/id))
			if(src.broken)
				user << "<span class=\"rose\">It appears to be broken.</span>"
				return
			if(src.allowed(user))
				src.locked = !( src.locked )
				if(src.locked)
					src.icon_state = src.icon_locked
					user << "<span class=\"rose\">You lock the [src.name]!</span>"
					return
				else
					src.icon_state = src.icon_closed
					user << "<span class=\"rose\">You unlock the [src.name]!</span>"
					return
			else
				user << "<span class=\"rose\">Access Denied</span>"
		else if((istype(W, /obj/item/weapon/card/emag)||istype(W, /obj/item/weapon/melee/energy/blade)) && !src.broken)
			broken = 1
			locked = 0
			desc = "It appears to be broken."
			icon_state = src.icon_broken
			if(istype(W, /obj/item/weapon/melee/energy/blade))
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, src.loc)
				spark_system.start()
				playsound(get_turf(src), 'sound/weapons/blade1.ogg', 50, 1)
				playsound(get_turf(src), "sparks", 50, 1)
				for(var/mob/O in viewers(user, 3))
					O.show_message(text("<span class=\"notice\">The locker has been sliced open by [] with an energy blade!</span>", user), 1, text("<span class=\"rose\">You hear metal being sliced and sparks flying.</span>"), 2)
			else
				for(var/mob/O in viewers(user, 3))
					O.show_message(text("<span class=\"notice\">The locker has been broken by [] with an electromagnetic card!</span>", user), 1, text("You hear a faint electrical spark."), 2)

		if(!locked)
			..()
		else
			user << "<span class=\"rose\">Its locked!</span>"
		return


	show_to(mob/user as mob)
		if(locked)
			user << "<span class=\"rose\">Its locked!</span>"
		else
			..()
		return


/obj/item/weapon/storage/lockbox/loyalty
	name = "Lockbox (Loyalty Implants)"
	req_access = list(access_security)

	New()
		..()
		new /obj/item/weapon/implantcase/loyalty(src)
		new /obj/item/weapon/implantcase/loyalty(src)
		new /obj/item/weapon/implantcase/loyalty(src)
		new /obj/item/weapon/implanter/loyalty(src)


/obj/item/weapon/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "You have a bad feeling about opening this."
	req_access = list(access_security)

	New()
		..()
		new /obj/item/weapon/grenade/flashbang/clusterbang(src)
