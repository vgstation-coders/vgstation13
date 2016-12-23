// -----------------------------
//       Bluespace Ponds
// -----------------------------

/obj/machinery/bluespace_pond
	name = "bluespace pond"
	desc = "A bluespace pond full of wonderful sea life. Goes well with a fishing rod, beer and friends."
	icon = 'icons/obj/machines/bluespace_pond.dmi'
	var/base_state = "pond" // used for icon selection in update_icon
	icon_state = "pond0"
	anchored = 1
	density = 1
	dir = 1
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0

/obj/machinery/bluespace_pond/New()
	..()
	update_nearby_icons()
	update_icon()

// Calls update_icon() on the surrounding bluespace ponds
// T:				source turf to update around
// ignore_T:	set to TRUE to ignore T.  Used when deleting/packing up pond pieces
/obj/machinery/bluespace_pond/proc/update_nearby_icons(var/turf/T, var/ignore_T = FALSE)
	if(!T)
		T = get_turf(src)
	for(var/direction in cardinal)
		for(var/obj/machinery/bluespace_pond/bsp in get_step(T, direction))
			if(ignore_T)
				bsp.update_icon(T)
			else
				bsp.update_icon()

/obj/machinery/bluespace_pond/update_icon(var/turf/ignore_turf)
	spawn()
		var/junction = 0 // bitflag for directions of surrounding ponds
		for(var/obj/machinery/bluespace_pond/bsp in orange(src, 1))
			if(get_turf(bsp) == null)
				continue
			if(abs(x-bsp.x)-abs(y-bsp.y)) // only cardinal directions matter
				junction |= get_dir(src, bsp)
		icon_state = "[base_state][junction]"

/obj/machinery/bluespace_pond/attackby(obj/item/weapon/W, mob/user)
	..()
	if(iswrench(W))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, src, 30))
			new /obj/item/device/bluespace_pond_container(loc)
			qdel(src)
			to_chat(user, "<span class='notice'>You pack \the [name] away.</span>")
	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/fish))
		to_chat(user, "<span class='notice'>You throw \the [W] back into the water.</span>")
		qdel(W)

/obj/machinery/bluespace_pond/Destroy()
	var/turf/T = get_turf(src)
	..()
	update_nearby_icons(T, TRUE)

// -----------------------------
//   Bluespace Pond Containers
// -----------------------------

/obj/item/device/bluespace_pond_container
	name = "packaged bluespace pond section"
	desc = "Thanks to advances in bluespace technology, you too can now have your own portable pond in space! Use a multitool to activate this package."
	icon = 'icons/obj/machines/bluespace_pond.dmi'
	icon_state = "box"
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
		to_chat(user, "<span class='notice'>You unpack \the [name].</span>")
		qdel(src)
		return
	..()
