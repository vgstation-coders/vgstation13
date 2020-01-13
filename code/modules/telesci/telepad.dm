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
	machine_flags = MULTITOOL_MENU
	var/id_tag = "telepad"

	var/obj/machinery/computer/telescience/linked

	// Bluespace crystal!
	var/obj/item/bluespace_crystal/amplifier=null
	var/opened=0

/obj/machinery/telepad/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return ""

/obj/machinery/telepad/canLink(var/obj/T)
	return (istype(T,/obj/machinery/computer/telescience) && get_dist(src,T) < 7)

/obj/machinery/telepad/isLinkedWith(var/obj/T)
	return (linked == T)

/obj/machinery/telepad/linkWith(var/mob/user, var/obj/T, var/list/context)
	if(istype(T, /obj/machinery/computer/telescience))
		linked = T
		linked.telepad = src
		return 1

/obj/machinery/telepad/unlinkFrom(mob/user, obj/buffer)
	if(linked.telepad)
		linked.telepad = null
	if(linked)
		linked = null
	return 1

/obj/machinery/telepad/canClone(var/obj/machinery/T)
	return (istype(T, /obj/machinery/computer/telescience) && get_dist(src, T) < 7)

/obj/machinery/telepad/clone(var/obj/machinery/T)
	if(istype(T, /obj/machinery/computer/telescience))
		linked = T
		linked.telepad = src
		return 1

/obj/machinery/telepad/Destroy()
	if (linked)
		linked.telepad = null
		linked = null
	..()

/obj/machinery/telepad/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(W.is_screwdriver(user))
		if(opened)
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			to_chat(user, "<span class = 'caution'>You secure the access port on \the [src].</span>")
			opened = 0
		else
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			to_chat(user, "<span class = 'caution'>You open \the [src]'s access port.</span>")
			opened = 1
	if(istype(W, /obj/item/bluespace_crystal) && opened)
		if(amplifier)
			to_chat(user, "<span class='warning'>There's something in the booster coil already.</span>")
			return
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
		to_chat(user, "<span class = 'caution'>You jam \the [W] into \the [src]'s booster coil.</span>")
		user.u_equip(W,1)
		W.forceMove(src)
		amplifier=W
		return
	if(iscrowbar(W) && opened && amplifier)
		to_chat(user, "<span class='notice'>You carefully pry \the [amplifier] from \the [src].</span>")
		var/obj/item/bluespace_crystal/C=amplifier
		C.forceMove(get_turf(src))
		amplifier=null
		return
