var/global/list/obj/item/beacon/beacons = list()

/obj/item/beacon
	name = "Tracking Beacon"
	desc = "A beacon used by a teleporter."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	var/code = "electronic"
	var/frequency = 1459
	var/emagged = 0
	origin_tech = Tc_BLUESPACE + "=1"
	flags = FPRINT
	autoignition_temperature = AUTOIGNITION_PLASTIC

/obj/item/beacon/New()
	..()
	frequency = format_frequency(sanitize_frequency(frequency))
	beacons += src

/obj/item/beacon/Destroy()
	..()
	beacons -= src

/obj/item/beacon/examine(mob/user)
	..()
	to_chat(user,"<span class='notice'>The frequency of the [src] is set to [frequency].</span>")

/obj/item/beacon/attack_self(mob/user as mob)
	..()
	var/newfreq = input(user, "Input a new frequency for the beacon", "Frequency", null) as null|num
	if(!src.Adjacent(user))
		return
	if(usr.restrained() || usr.lying || usr.stat)
		return 0
	if(!newfreq)
		return
	frequency = format_frequency(sanitize_frequency(newfreq))

/obj/item/beacon/emag_act(mob/user)
	if(!emagged)
		spark(src)
		emagged = 1
		to_chat(user,"<span class='warning'>Teleportation collision safety protocols disabled.</span>")

/obj/item/beacon/verb/alter_signal(t as text)
	set name = "Alter Beacon's Signal"
	set category = "Object"
	set src in usr

	if ((usr.canmove && !( usr.restrained() )))
		src.code = t
	if (!( src.code ))
		src.code = "beacon"
	src.add_fingerprint(usr)
	return

// SINGULO BEACON SPAWNER

/obj/item/beacon/syndicate
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to have a singularity beacon teleported to your location</i>."
	origin_tech = Tc_BLUESPACE + "=1;" + Tc_SYNDICATE + "=7"
	emagged = 1

/obj/item/beacon/syndicate/attack_self(mob/user as mob)
	if(user)
		to_chat(user, "<span class='notice'>Locked In</span>")
		new /obj/machinery/singularity_beacon/syndicate( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)

/obj/item/beacon/bluespace_beacon
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	name = "Bluespace Gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	level = 1		// underfloor
	layer = BELOW_OBJ_LAYER
	anchored = 1

/obj/item/beacon/bluespace_beacon/New()
	..()
	var/turf/T = loc
	hide(T.intact)

// update the invisibility and icon
/obj/item/beacon/bluespace_beacon/hide(var/intact)
	invisibility = intact ? 101 : 0
	update_icon()

	// update the icon_state
/obj/item/beacon/bluespace_beacon/update_icon()
	icon_state = "floor_beacon" + "[invisibility? "f" : ""]"

/obj/item/beacon/bluespace_beacon/attack_hand(mob/user as mob) //Let's not pick up the anchored item
	return

/obj/item/beacon/bluespace_beacon/ex_act() //It has to have SOME advantage over a normal beacon
	return

/obj/item/beacon/bluespace_beacon/singularity_pull()
	return

var/global/list/emergency_beacons = list()

/obj/item/beacon/bluespace_beacon/emergency/New()
	..()
	emergency_beacons += src

/obj/item/beacon/bluespace_beacon/emergency/Destroy()
	emergency_beacons -= src
	..()
