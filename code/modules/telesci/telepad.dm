///SCI TELEPAD///
/obj/machinery/telepad
	name = "telepad"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 200
	active_power_usage = 5000

	machine_flags = MULTITOOL_MENU | SCREWTOGGLE | CROWDESTROY | FIXED2WORK
	mech_flags = MECH_SCAN_FAIL
	id_tag = "telepad"

	var/obj/machinery/computer/telescience/linked

	// Bluespace crystal!
	var/obj/item/bluespace_crystal/amplifier=null
	var/teles_left
	var/infinite_teles //Congratulations, you upgraded the telepad enough!

/obj/machinery/telepad/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/sci_telepad,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser
	)

	RefreshParts()

/obj/machinery/telepad/RefreshParts()
	var/count
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		count += SP.rating
	teles_left = rand(2, 3) * count
	if(count >= 16) //All components are T4
		infinite_teles = 1
	else
		infinite_teles = 0

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

/obj/machinery/telepad/attack_ai(mob/user)
	return

/obj/machinery/telepad/attack_paw(mob/user)
	return

/obj/machinery/telepad/attack_hand(mob/user, ignore_brain_damage)
	if(..())
		return
	if(panel_open && amplifier)
		to_chat(user, "<span class='notice'>You carefully take \the [amplifier] from \the [src].</span>")
		var/obj/item/bluespace_crystal/C=amplifier
		user.put_in_hands(C)
		amplifier=null
		return

/obj/machinery/telepad/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/bluespace_crystal) && panel_open)
		if(amplifier)
			to_chat(user, "<span class='warning'>There's something in the booster coil already.</span>")
			return
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
		to_chat(user, "<span class = 'caution'>You jam \the [W] into \the [src]'s booster coil.</span>")
		user.u_equip(W,1)
		W.forceMove(src)
		amplifier=W
		return
