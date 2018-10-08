/**
	Blacksmithing forge
	Takes chunks of plasma ore, or plasma sheets, to generate high temperatures for molding or melting metal.
**/

/obj/structure/forge
	name = "forge"
	desc = "A fire contained within heat-proof stone. This lets the internal temperature develop enough to make metal malleable or liquid."
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "furnace_off"
	anchored = TRUE
	density = TRUE
	var/status = FALSE //Whether the forge is lit
	var/obj/item/heating //What is contained within the forge, and is being heated
	var/last_check
	var/current_temp
	var/current_thermal_energy

/obj/structure/forge/update_icon()
	if(status)
		icon_state = "furnace_on"
	else
		icon_state = "furnace_off"

/obj/structure/forge/New()
	..()
	processing_objects.Add(src)

/obj/structure/forge/Destroy()
	processing_objects.Remove(src)
	heating.forceMove(get_turf(src))
	heating = null
	for(var/obj/I in contents)
		qdel(I)
	..()


/obj/structure/forge/examine(mob/user)
	..()
	if(heating)
		to_chat(user, "<span class = 'notice'>There is currently \a [heating] in \the [src].</span>")
	var/obj/item/stack/sheet/mineral/plasma/P = locate() in contents
	if(P)
		to_chat(user, "<span class = 'notice'>There is \a [P] fuelling \the [src].</span>")
		P.examine(user)
	if(locate(/obj/item/weapon/ore/plasma) in contents)
		var/count
		for(var/obj/item/weapon/ore/plasma/PP in contents)
			count++
		to_chat(user, "<span class = 'notice'>There is [count] nuggets of plasma ore in \the [src].</span>")

/obj/structure/forge/process()
	if(!has_fuel())
		return
	if(heating)
		heating.attempt_heating(src, null)


//Prefer to burn through sheets over ores
/obj/structure/forge/proc/has_fuel()
	if(last_check+10 SECONDS < world.time)
		return status
	var/obj/fuel = locate(/obj/item/stack/sheet/mineral/plasma) in contents
	if(!fuel)
		fuel = locate(/obj/item/weapon/ore/plasma) in contents
	if(istype(fuel, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/sheet/mineral/plasma/P = fuel
		if(P.use(1))
			current_temp = TEMPERATURE_PLASMA
			last_check = world.time
			status = TRUE
	else if(istype(fuel, /obj/item/weapon/ore/plasma))
		qdel(fuel)
		current_temp = MELTPOINT_STEEL
		last_check = world.time
		status = TRUE
	update_icon()
	return status

/obj/structure/forge/is_hot()
	return current_temp

/obj/structure/forge/thermal_energy_transfer()
	return current_thermal_energy
