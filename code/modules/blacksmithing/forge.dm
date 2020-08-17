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
	var/fuel_time //How long is left, in deciseconds
	var/current_temp
	var/current_thermal_energy

/obj/structure/forge/update_icon()
	if(status)
		icon_state = "furnace_on"
	else
		icon_state = "furnace_off"

/obj/structure/forge/Destroy()
	processing_objects.Remove(src)
	if(heating)
		heating.forceMove(get_turf(src))
		heating = null
	for(var/obj/I in contents)
		I.forceMove(get_turf(src))
	..()

/obj/structure/forge/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/sheet/mineral/plasma/P = I
		if(P.use(1))
			to_chat(user, "<span class = 'notice'>You toss a sheet of \the [I] into \the [src].</span>")
			if(current_temp < TEMPERATURE_PLASMA)
				current_temp = TEMPERATURE_PLASMA
			fuel_time+= 10
			return 1
	else if(istype(I, /obj/item/stack/ore/plasma))
		to_chat(user, "<span class = 'notice'>You toss \the [I] into \the [src].</span>")
		var/obj/item/stack/ore/plasma/P = I
		if(P.use(1))
			if(current_temp < MELTPOINT_STEEL)
				current_temp = MELTPOINT_STEEL
			fuel_time += 15
			return 1
	else if(istype(I, /obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/W = I
		if(W.use(1))
			to_chat(user, "<span class = 'notice'>You toss a sheet of \the [I] into \the [src].</span>")
			if(current_temp < MELTPOINT_GOLD)
				current_temp = MELTPOINT_GOLD
			fuel_time += 10
			return 1
	else if(istype(I, /obj/item/weapon/grown/log))
		to_chat(user, "<span class = 'notice'>You toss \the [I] into \the [src].</span>")
		user.drop_item(I)
		qdel(I)
		if(current_temp < MELTPOINT_STEEL)
			current_temp = MELTPOINT_STEEL
		fuel_time += 5
		return 1
	else if(I.is_hot() && status == FALSE)
		to_chat(user, "<span class = 'notice'>You attempt to light \the [src] with \the [I].</span>")
		if(do_after(user, I, 3 SECONDS))
			if(!has_fuel())
				to_chat(user, "<span class = 'warning'>\The [src] does not light.</span>")
				return 0
			toggle_lit()
			return 1
	else if(iscrowbar(I))
		to_chat(user, "<span class = 'notice'>You begin to disassemble \the [src].</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(do_after(user, src, 5 SECONDS))
			drop_stack(/obj/item/stack/sheet/mineral/sandstone, get_turf(src), rand(5, 20))
			qdel(src)
			return 1
	else if(!heating)
		if(user.drop_item(I, src))
			to_chat(user, "<span class = 'notice'>You place \the [I] into \the [src].</span>")
			heating = I
			return 1
	return ..()

/obj/structure/forge/proc/toggle_lit()
	switch(status)
		if(TRUE) //turning it off
			status = FALSE
			current_temp = 0
			processing_objects.Remove(src)
		if(FALSE)//turning it on
			status = TRUE
			processing_objects.Add(src)
	on_fire = status
	update_icon()
	return status

/obj/structure/forge/attack_hand(mob/user)
	if(heating)
		to_chat(user, "<span class = 'notice'>You retrieve \the [heating] from \the [src].</span>")
		user.put_in_hands(heating)
		heating = null

/obj/structure/forge/attack_robot(var/mob/user as mob)
	if(isMoMMI(user) && Adjacent(user))
		return attack_hand(user)
	else
		return attack_ai(user)

/obj/structure/forge/examine(mob/user)
	..()
	if(heating)
		to_chat(user, "<span class = 'notice'>There is currently \a [heating] in \the [src].</span>")
	if(status)
		to_chat(user, "<span class = 'notice'>\The [src] is lit</span>")
		switch(current_temp)
			if(MELTPOINT_GOLD)
				to_chat(user, "<span class = 'notice'>It looks hot enough to make gold malleable.</span>")
			if(MELTPOINT_STEEL)
				to_chat(user, "<span class = 'notice'>It looks hot enough to make most basic metals malleable.</span>")
			if(TEMPERATURE_PLASMA to INFINITY)
				to_chat(user, "<span class = 'notice'>It looks hot enough to make most metals malleable.</span>")
	else
		to_chat(user, "<span class = 'notice'>\The [src] is currently not lit.</span>")
	if(fuel_time)
		to_chat(user, "<span class = 'notice'> It looks like it has enough fuel for another [fuel_time * 2] seconds.</span>")

/obj/structure/forge/process()
	if(!has_fuel())
		return
	if(heating)
		heating.attempt_heating(src, null)


//Prefer to burn through sheets over ores
/obj/structure/forge/proc/has_fuel()
	fuel_time = max(0, fuel_time-1)
	if(fuel_time <= 0 && status)
		toggle_lit()
	return fuel_time

/obj/structure/forge/is_hot()
	if(status)
		return current_temp
	return FALSE

/obj/structure/forge/thermal_energy_transfer()
	return current_thermal_energy

/obj/structure/forge/extinguish()
	if(status)
		toggle_lit()