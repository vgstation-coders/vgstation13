
//Heater

/obj/machinery/chemheater
	name = "directed laser heater"
	desc = "A platform with an integrated laser that uses high-energy photons to heat a subject through atomic vibrations. In a practical sense, it has no upper limit to how much thermal energy can be induced this way, as it is capable of reaching temperatures which could rapidly destroy any laboratory-approved container."
	icon = 'icons/obj/chemHandC.dmi'
	icon_state = "heater"
	icon_state_open = "heater_open"
	density = 1
	anchored = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL
	use_power = 1
	idle_power_usage = 25
	active_power_usage = 5000

	var/max_temperature = TEMPERATURE_LASER
	var/thermal_energy_transfer = 3000
	var/laser_kind = 0
	var/onstage = null

	var/obj/item/weapon/reagent_containers/held_container
	var/heating = FALSE
	var/had_item = FALSE

/obj/machinery/chemheater/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/chemheater,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/capacitor
	)
	RefreshParts()

/obj/machinery/chemheater/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/L in component_parts)
		T += L.rating
		laser_kind = L.rating //Sets what tier of laser we have
	thermal_energy_transfer = initial(thermal_energy_transfer) * T

	T = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating-1
	idle_power_usage = initial(idle_power_usage) - (T * 10) //T1: 25w, T2: 15w, T3: 5w
	active_power_usage = initial(active_power_usage) - (T * 2000) //T1: 5000w, T2: 3000w, T3: 1000w

	overlays = null
	overlays += image(icon = icon, icon_state = "t[laser_kind]_laser")

/obj/machinery/chemheater/power_change()
	if( powered() )
		stat &= ~NOPOWER
		icon_state = "[initial(icon_state)]"
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			icon_state = "[initial(icon_state)]_off"

/obj/machinery/chemheater/process()
	if(stat & (BROKEN|NOPOWER))
		return
	if(held_container && heating)
		held_container.reagents.heating(thermal_energy_transfer, max_temperature)

/obj/machinery/chemheater/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers) && anchored)
		if(!held_container)
			if(user.drop_item(W, src))
				held_container = W
				to_chat(user, "<span class='notice'>You put \the [held_container] onto \the [src].</span>")
				var/image/I = image("icon"=W, "layer"=FLOAT_LAYER)
				onstage = I
				overlays += I
				return 1
		else
			to_chat(user, "<span class='notice'>\The [src] already has \a [held_container] on it.</span>")
			return 1
	else
		return ..()

/obj/machinery/chemheater/attack_ghost()
	return

/obj/machinery/chemheater/attack_hand(mob/user)
	if(held_container)
		overlays -= onstage
		to_chat(user, "<span class='notice'>You remove \the [held_container] from \the [src].</span>")
		user.put_in_hands(held_container)
		held_container = null
		had_item = TRUE
	toggle()
	had_item = FALSE

/obj/machinery/chemheater/verb/toggle()
	set src in view(1)
	set name = "Toggle heater"
	set category = "Object"

	if(!held_container && heating) //For when you take the beaker off but left the heater on
		heating = !heating
		overlays -= image(icon = icon, icon_state = "t[laser_kind]_beam")
		processing_objects.Remove(src)
		to_chat(usr, "<span class='notice'>You turn off \the [src].</span>")
		return
	else if(held_container)
		heating = !heating
		if(heating)
			overlays += image(icon = icon, icon_state = "t[laser_kind]_beam")
			processing_objects.Add(src)
			to_chat(usr, "<span class='notice'>You turn on \the [src].</span>")
		else
			overlays -= image(icon = icon, icon_state = "t[laser_kind]_beam")
			processing_objects.Remove(src)
			to_chat(usr, "<span class='notice'>You turn off \the [src].</span>")
		return
	else
		if(!had_item)
			to_chat(usr, "<span class='notice'>\The [src] doesn't have anything to heat right now.</span>")

/obj/machinery/chemheater/AltClick(mob/user)
	if(!user.incapacitated() && Adjacent(user) && !(stat & (NOPOWER) && user.dexterity_check()))
		toggle()
		return
	return ..()

/*
//Unused desired temp setting. Maybe useful in the future? Not likely since who doesn't want their coffee as hot as the sun?
/obj/machinery/chemheater/verb/settemp(mob/user as mob)
	set src in view(1)
	set name = "Set temperature"
	set category = "Object"

	var/set_temp = input("Input desired temperature (20 to [TEMPERATURE_LASER] Celsius).", "Set Temperature") as num
	if(set_temp>[TEMPERATURE_LASER] || set_temp<20)
		to_chat(user, "<span class='notice'>Invalid temperature.</span>")
		return
	max_temperature = set_temp+273.15
*/

//Cooler

/obj/machinery/chemcooler
	name = "cryonic wave projector"
	desc = "Ever want to see a microwave work in reverse? Well this machine is basically that. This machine could technically keep removing energy forever until it reaches absolute zero. Breaking physics and physicists since 2314 to current year and counting."
	icon = 'icons/obj/chemHandC.dmi'
	icon_state = "cooler"
	icon_state_open = "cooler_open"
	density = 1
	anchored = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL
	use_power = 1
	idle_power_usage = 25
	active_power_usage = 5000

	var/max_temperature = 0 //You can make stuff REALLY cold
	var/thermal_energy_transfer = -3000
	var/scanner_kind = 0
	var/onstage = null

	var/obj/item/weapon/reagent_containers/held_container
	var/cooling = FALSE
	var/had_item = FALSE

/obj/machinery/chemcooler/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/chemcooler,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/capacitor
	)
	RefreshParts()

/obj/machinery/chemcooler/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/S in component_parts)
		T += S.rating
		scanner_kind = S.rating //Sets what tier of scanner we have
	thermal_energy_transfer = initial(thermal_energy_transfer) * T

	T = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating-1
	idle_power_usage = initial(idle_power_usage) - (T * 10) //T1: 25w, T2: 15w, T3: 5w
	active_power_usage = initial(active_power_usage) - (T * 2000) //T1: 5000w, T2: 2500w, T3: 1250w

	overlays = null
	overlays += image(icon = icon, icon_state = "t[scanner_kind]_scanner")

/obj/machinery/chemcooler/power_change()
	if( powered() )
		stat &= ~NOPOWER
		icon_state = "[initial(icon_state)]"
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			icon_state = "[initial(icon_state)]_off"

/obj/machinery/chemcooler/process()
	if(stat & (BROKEN|NOPOWER))
		return
	if(held_container && cooling)
		held_container.reagents.heating(thermal_energy_transfer, max_temperature)

/obj/machinery/chemcooler/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers) && anchored)
		if(!held_container)
			if(user.drop_item(W, src))
				held_container = W
				to_chat(user, "<span class='notice'>You put \the [held_container] onto \the [src].</span>")
				var/image/I = image("icon"=W, "layer"=FLOAT_LAYER)
				onstage = I
				overlays += I
				return 1
		else
			to_chat(user, "<span class='notice'>\The [src] already has \a [held_container] on it.</span>")
			return 1
	else
		return ..()

/obj/machinery/chemcooler/attack_ghost()
	return

/obj/machinery/chemcooler/attack_hand(mob/user)
	if(held_container)
		overlays -= onstage
		to_chat(user, "<span class='notice'>You remove \the [held_container] from \the [src].</span>")
		user.put_in_hands(held_container)
		held_container = null
		had_item = TRUE
	toggle()
	had_item = FALSE

/obj/machinery/chemcooler/verb/toggle()
	set src in view(1)
	set name = "Toggle cooler"
	set category = "Object"

	if(!held_container && cooling) //For when you take the beaker off but left the heater on
		cooling = !cooling
		overlays -= image(icon = icon, icon_state = "t[scanner_kind]_waveFront")
		underlays -= image(icon = icon, icon_state = "t[scanner_kind]_waveBack")
		processing_objects.Remove(src)
		to_chat(usr, "<span class='notice'>You turn off \the [src].</span>")
		return
	else if(held_container)
		cooling = !cooling
		if(cooling)
			overlays += image(icon = icon, icon_state = "t[scanner_kind]_waveFront")
			underlays += image(icon = icon, icon_state = "t[scanner_kind]_waveBack")
			processing_objects.Add(src)
			to_chat(usr, "<span class='notice'>You turn on \the [src].</span>")
		else
			overlays -= image(icon = icon, icon_state = "t[scanner_kind]_waveFront")
			underlays -= image(icon = icon, icon_state = "t[scanner_kind]_waveBack")
			processing_objects.Remove(src)
			to_chat(usr, "<span class='notice'>You turn off \the [src].</span>")
		return
	else
		if(!had_item)
			to_chat(usr, "<span class='notice'>\The [src] doesn't have anything to cool right now.</span>")

/obj/machinery/chemcooler/AltClick(mob/user)
	if(!user.incapacitated() && Adjacent(user) && !(stat & (NOPOWER) && user.dexterity_check()))
		toggle()
		return
	return ..()

/*
//Unused desired temp setting. Maybe useful in the future? Not likely since who doesn't want their ice to be absolute zero?
/obj/machinery/chemcooler/verb/settemp(mob/user as mob)
	set src in view(1)
	set name = "Set temperature"
	set category = "Object"

	var/set_temp = input("Input desired temperature (20 to -273 Celsius).", "Set Temperature") as num
	if(set_temp>20 || set_temp<-273.15)
		to_chat(user, "<span class='notice'>Invalid temperature.</span>")
		return
	max_temperature = set_temp+273.15
*/
