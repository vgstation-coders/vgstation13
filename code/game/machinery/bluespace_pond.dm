// Calls update_icon() on the surrounding bluespace ponds
// center: source turf to update around
/proc/update_surrounding_bsp(var/turf/centre)
	for(var/direction in cardinal)
		var/turf/T = get_step(centre, direction)
		for(var/obj/machinery/bluespace_pond/machine in T)
			machine.update_icon()

/obj/machinery/bluespace_pond
	name = "bluespace pond"
	desc = "A bluespace pond full of wonderful sea life. Goes well with a fishing rod, beer and friends."
	icon = 'icons/obj/machines/new_ame.dmi'
	icon_state = "shield"
	anchored = 1
	density = 0
	dir = 1
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0

/obj/machinery/bluespace_pond/New(loc)
	..(loc)
	update_icon()
	update_surrounding_bsp(get_turf(src))

/obj/machinery/bluespace_pond/update_icon()
	var/pond_dirs = 0
	for(var/direction in cardinal)
		var/turf/T = get_step(loc, direction)
		for(var/obj/machinery/bluespace_pond/machine in T)
		pond_dirs |= direction
	icon_state = "shield_[pond_dirs]"

/obj/machinery/bluespace_pond/attackby(obj/item/weapon/W, mob/user)
	..()
	if(iswrench(W))
		if(do_after(user, src, 30))
			new /obj/item/device/bluespace_pond_container(loc)
			var/turf/upd_turf = get_turf(src)
			qdel(src)
			update_surrounding_bsp(upd_turf)
			to_chat(user, "<span class='notice'>You pack the [name] away.</span>")

/obj/item/device/bluespace_pond_container
	name = "packaged bluespace pond section"
	desc = "Thanks to advances in bluespace technology, you too can now have your own portable pond in space! Use a multitool to activate this package."
	icon = 'icons/obj/machines/antimatter.dmi' // placeholder
	icon_state = "box"
	item_state = "electronic"
	w_class = W_CLASS_LARGE
	flags = FPRINT
	siemens_coefficient = 1
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL*2)
	w_type = RECYK_METAL

/obj/item/device/bluespace_pond_container/attackby(var/obj/item/I, var/mob/user)
	if(ismultitool(I) && isturf(loc))
		for(var/obj/machinery/bluespace_pond/BSP in loc.contents)
			to_chat(user, "<span class='warning'>You cannot unpack a bluespace pond on top of another.</span>")
			return
		new/obj/machinery/bluespace_pond(src.loc)
		to_chat(user, "<span class='notice'>You unpack the [name].</span>")
		qdel(src)
		return
	..()
