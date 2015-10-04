///SCI TELEPAD///
/obj/machinery/telepad
	name = "telepad"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = 1
	idle_power_usage = 200
	active_power_usage = 5000

	// Bluespace crystal!
	var/obj/item/bluespace_crystal/amplifier=null
	var/opened=0

/obj/machinery/telepad/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(opened)
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class = 'caution'> You secure the access port on \the [src].</span>"
			opened = 0
		else
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class = 'caution'> You open \the [src]'s access port.</span>"
			opened = 1
	if(istype(W, /obj/item/bluespace_crystal) && opened)
		if(amplifier)
			user << "<span class='warning'>There's something in the booster coil already.</span>"
			return
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
		user << "<span class = 'caution'> You jam \the [W] into \the [src]'s booster coil.</span>"
		user.u_equip(W,1)
		W.loc=src
		amplifier=W
		return
	if(istype(W, /obj/item/weapon/crowbar) && opened && amplifier)
		user << "<span class='notice'>You carefully pry \the [amplifier] from \the [src].</span>"
		var/obj/item/bluespace_crystal/C=amplifier
		C.loc=get_turf(src)
		amplifier=null
		return

//CARGO TELEPAD//
/obj/machinery/telepad_cargo
	name = "cargo telepad"
	desc = "A telepad used by the Rapid Crate Sender."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500
	var/stage = 0

/obj/machinery/telepad_cargo/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		anchored = 0
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			anchored = 0
			user << "<span class = 'caution'> The [src] can now be moved.</span>"
		else if(!anchored)
			anchored = 1
			user << "<span class = 'caution'> The [src] is now secured.</span>"
	if(istype(W, /obj/item/weapon/screwdriver))
		if(stage == 0)
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class = 'caution'> You unscrew the telepad's tracking beacon.</span>"
			stage = 1
		else if(stage == 1)
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class = 'caution'> You screw in the telepad's tracking beacon.</span>"
			stage = 0
	if(istype(W, /obj/item/weapon/weldingtool) && stage == 1)
		playsound(src, 'sound/items/Welder.ogg', 50, 1)
		user << "<span class = 'caution'> You disassemble the telepad.</span>"
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
		M.amount = 1
		new /obj/item/stack/sheet/glass/glass(get_turf(src))
		del(src)

///TELEPAD CALLER///
/obj/item/device/telepad_beacon
	name = "telepad beacon"
	desc = "Use to warp in a cargo telepad."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	origin_tech = "bluespace=3"

/obj/item/device/telepad_beacon/attack_self(mob/user as mob)
	if(user)
		user << "<span class = 'caution'> Locked In</span>"
		new /obj/machinery/telepad_cargo(user.loc)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		del(src)
	return

///HANDHELD TELEPAD USER///
/obj/item/weapon/rcs
	name = "rapid-crate-sender (RCS)"
	desc = "Use this to send crates and closets to cargo telepads."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "rcs"
	flags = FPRINT
	siemens_coefficient = 1
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	var/rcharges = 10
	var/obj/machinery/pad = null
	var/last_charge = 30
	var/mode = 0
	var/rand_x = 0
	var/rand_y = 0
	var/emagged = 0
	var/teleporting = 0

/obj/item/weapon/rcs/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/rcs/examine(mob/user)
	..()
	user << "<span class='info'>There are [rcharges] charges left.</span>"

/obj/item/weapon/rcs/Destroy()
	processing_objects.Remove(src)
	..()
/obj/item/weapon/rcs/process()
	if(rcharges > 10)
		rcharges = 10
	if(last_charge == 0)
		rcharges++
		last_charge = 30
	else
		last_charge--

/obj/item/weapon/rcs/attack_self(mob/user)
	if(emagged)
		if(mode == 0)
			mode = 1
			playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
			user << "<span class = 'caution'> The telepad locator has become uncalibrated.</span>"
		else
			mode = 0
			playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
			user << "<span class = 'caution'> You calibrate the telepad locator.</span>"

/obj/item/weapon/rcs/attackby(obj/item/W, mob/user)
	if(istype(W,  /obj/item/weapon/card/emag) && emagged == 0)
		emagged = 1
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		user << "<span class = 'caution'> You emag the RCS. Click on it to toggle between modes.</span>"
		return