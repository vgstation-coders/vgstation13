#define NOTBUSY 0
#define BUSY 1
#define KEYDONE 2

/obj/machinery/keyfab
	name = "key fabricator"
	desc = "A machine that can print keys."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "old_recharger"
	density = 0
	anchored = 1
	var/busy = NOTBUSY
	var/obj/item/key/storedkey
	var/build_time = 20 SECONDS

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE

/obj/machinery/keyfab/New()
	..()
	component_parts = newlist(
							/obj/item/weapon/circuitboard/keyfab,
							/obj/item/weapon/stock_parts/micro_laser
							)
	RefreshParts()
	update_icon()

/obj/machinery/keyfab/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/ML in component_parts)
		T = ML.rating
	build_time = 20 SECONDS - ((T - 1) * 5 SECONDS)

/obj/machinery/keyfab/update_icon()
	..()
	//_ is off, 0 is powered but not running, 1 is running, 2 is ready, 3 is error.
	if(stat & (FORCEDISABLE|NOPOWER))
		icon_state = initial(icon_state)
		return
	icon_state = "[initial(icon_state)][busy]"

/obj/machinery/keyfab/attackby(obj/item/K, mob/user)
	..()
	if(ishigherbeing(user))
		src.add_fingerprint(user)
		if((stat & (FORCEDISABLE|BROKEN|NOPOWER)))
			to_chat(user, "<span class='notice'>\The [src] is unresponsive.</span>")
			return
		if(istype(K, /obj/item/key/snowmobile/universal)) //FUTURE FEATURE? Change this to /obj/item/key and play with line 90 to allow all kinds of keys to be created. Would require redoing keys slightly to use VIN as a unique ID and having keys match that VIN.
			if(storedkey)
				to_chat(user, "<span class='notice'>\The [src] has a key inside of it already. You need to remove it before you can create another key.</span>")
				return
			switch(busy)
				if(NOTBUSY)
					to_chat(user, "<span class='notice'>You scan \the [K] and \the [src] begins to copy it.</span>")
					make_key(K)
				if(BUSY)
					to_chat(user, "<span class='notice'>\The [src] is busy right now.</span>")

/obj/machinery/keyfab/attack_hand(mob/user)
	..()
	if(ishigherbeing(user))
		src.add_fingerprint(user)
		if((stat & (BROKEN|NOPOWER|FORCEDISABLE)))
			to_chat(user, "<span class='notice'>\The [src] is unresponsive.</span>")
			return
		switch(busy)
			if(NOTBUSY)
				to_chat(user, "<span class='notice'>You start \the [src].</span>")
				make_key()
			if(BUSY)
				to_chat(user, "<span class='notice'>\The [src] is busy right now.</span>")
			if(KEYDONE)
				to_chat(user, "<span class='notice'>You remove the finished key from \the [src].</span>")
				storedkey.forceMove(loc)
				user.put_in_hands(storedkey)
				storedkey = null
				busy = NOTBUSY
				update_icon()

/obj/machinery/keyfab/proc/make_key(var/obj/item/key/K)
	busy = BUSY
	update_icon()
	sleep(build_time)
	if((stat & (BROKEN|NOPOWER|FORCEDISABLE)))
		update_icon()
		busy = NOTBUSY
		return
	if(K)
		storedkey = new K.type(src)
		storedkey.paired_to = K.paired_to //Doesn't work properly due to how vehicles currently work with direct refs to their key. See line 48.
	else
		storedkey = new /obj/item/key/snowmobile/universal(src)
	busy = KEYDONE
	update_icon()

#undef NOTBUSY
#undef BUSY
#undef KEYDONE
