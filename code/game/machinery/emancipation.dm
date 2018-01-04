/obj/machinery/emancipation_grill
	name = "emancipation grill"
	desc = "Liberator of luggage. Larcenist of belongings."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "emancipation_grill"
	density = 0
	anchored = 1
	use_power = 1
	idle_power_usage = 75
	active_power_usage = 750
	flow_flags = IMPASSIBLE
	var/list/obj_whitelist = list() //Things that are okay to go through. Frazzle everything else.
	var/list/obj_blacklist = list() //Things that aren't okay to go through. Don't frazzle everything else.

/obj/machinery/emancipation_grill/New()
	..()
	update_icon()

/obj/machinery/emancipation_grill/power_change()
	. = ..()
	update_icon()

/obj/machinery/emancipation_grill/update_icon()
	if(stat & (BROKEN|NOPOWER))
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_on"

/obj/machinery/emancipation_grill/proc/emancipate(atom/movable/user)
	if(!user)
		return
	if(stat & (BROKEN|NOPOWER))
		return
	use_power = 2
	var/delete = FALSE

	if(isobserver(user)) //Fucking ghosts.
		return

	if(issilicon(user) && !is_type_in_list(/mob/living/silicon,obj_whitelist)) //YOU FOOL, YOU ARE AN ITEM.
		to_chat(user, "<span class = 'warning'>You feel your sensors overcharge and dissipate, as you are torn apart at the molecular level.</span>")
		delete = TRUE

	if(isobj(user)) //Let's only vaporize objects
		if(obj_blacklist.len)
			if(is_type_in_list(user, obj_blacklist))
				delete = TRUE
		else if(obj_whitelist.len)
			if(!is_type_in_list(user, obj_whitelist))
				delete = TRUE

	if(delete == TRUE)
		qdel(user)
		return

	for(var/atom/movable/I in get_contents_in_object(user)) //If it does, see if its contents can get past
		emancipate(I)

/obj/machinery/emancipation_grill/Crossed(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	..()
	emancipate(mover)



/obj/machinery/emancipation_grill/pro_duck
	obj_whitelist = list(/obj/item/weapon/bikehorn/rubberducky)

/obj/machinery/emancipation_grill/anti_duck
	obj_blacklist = list(/obj/item/weapon/bikehorn/rubberducky)