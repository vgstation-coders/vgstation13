
/obj/machinery/bunsen_burner
	name = "bunsen burner"
	desc = "A flat, self-heating device designed for bringing chemical mixtures to boil."
	icon = 'icons/obj/device.dmi'
	icon_state = "bunsen0"
	var/heating = 0		//whether the bunsen is turned on
	var/obj/item/weapon/reagent_containers/held_container
	var/list/possible_fuels = list(
		PLASMA = list(
				"max_temperature" = TEMPERATURE_PLASMA,
				"thermal_energy_transfer" = 6000,
				"consumption_rate" = 0.1,
				"o2_cons" = 0.01,
				"co2_cons" = 0,
				"unsafety" = 0),
		GLYCEROL = list(
				"max_temperature" = 1833.15,
				"thermal_energy_transfer" = 4000,
				"consumption_rate" = 0.25,
				"o2_cons" = 0.05,
				"co2_cons" = -0.025,
				"unsafety" = 5),
		FUEL = list(
				"max_temperature" = TEMPERATURE_WELDER,
				"thermal_energy_transfer" = 3600,
				"consumption_rate" = 0.5,
				"o2_cons" = 0.2,
				"co2_cons" = -0.2,
				"unsafety" = 25),
		ETHANOL = list(
				"max_temperature" = 1833.15,
				"thermal_energy_transfer" = 2600,
				"consumption_rate" = 0.5,
				"o2_cons" = 0.08,
				"co2_cons" = -0.04,
				"unsafety" = 10))
	pixel_y = 15 * PIXEL_MULTIPLIER
	ghost_read = 0

/obj/machinery/bunsen_burner/New()
	..()
	processing_objects.Remove(src)
	create_reagents(50)

/obj/machinery/bunsen_burner/Destroy()
	if(held_container)
		held_container.forceMove(get_turf(src))
		held_container = null
	..()

/obj/machinery/bunsen_burner/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/R = W
		if(held_container)
			for(var/possible_fuel in possible_fuels)
				if(R.reagents.has_reagent(possible_fuel) && (reagents.has_reagent(possible_fuel) || !reagents.reagent_list.len))
					var/reagent_transfer = R.reagents.trans_id_to(src, possible_fuel, 10)
					if(reagent_transfer)
						to_chat(user, "<span class='notice'>You transfer [reagent_transfer]u of [possible_fuel] from \the [R] to \the [src]</span>")
						return
			to_chat(user, "<span class='warning'>You must remove the [held_container] first.</span>")
			return
		else
			if(user.drop_item(W, src))
				held_container = W
				to_chat(user, "<span class='notice'>You put the [held_container] onto the [src].</span>")
				var/image/I = image("icon"=W, "layer"=FLOAT_LAYER)
				underlays += I
				return 1 // avoid afterattack() being called
	if(iswrench(W))
		user.visible_message("<span class = 'warning'>[user] starts to deconstruct \the [src]!</span>","<span class = 'notice'>You start to deconstruct \the [src].</span>")
		if(do_after(user, src, 5 SECONDS))
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
			drop_stack(/obj/item/stack/sheet/metal, loc, rand(3,4), user)
			qdel(src)
	else
		..()

/obj/machinery/bunsen_burner/process()
	if(held_container && heating)
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/G = T.return_air()
		if(!G || G.oxygen < 0.1)
			visible_message("<span class = 'warning'>\The [src] splutters out from lack of oxygen.</span>","<span class = 'warning'>You hear something cough.</span>")
			toggle()
			return

		var/max_temperature
		var/thermal_energy_transfer
		var/consumption_rate
		var/unsafety = 0 //Possibility it lights things on its turf
		var/o2_consumption
		var/co2_consumption

		for(var/possible_fuel in possible_fuels)
			if(reagents.has_reagent(possible_fuel))
				var/list/fuel_stats = possible_fuels[possible_fuel]
				max_temperature = fuel_stats["max_temperature"]
				thermal_energy_transfer = fuel_stats["thermal_energy_transfer"]
				consumption_rate = fuel_stats["consumption_rate"]
				unsafety = fuel_stats["unsafety"]
				o2_consumption = fuel_stats["o2_cons"]
				co2_consumption = fuel_stats["co2_cons"]

				reagents.remove_reagent(possible_fuel, consumption_rate)
				held_container.reagents.heating(thermal_energy_transfer, max_temperature)
				G.adjust(o2 = -o2_consumption, co2 = -co2_consumption)
				if(prob(unsafety) && T)
					T.hotspot_expose(max_temperature, 5)
				break

		if(!max_temperature)
			visible_message("<span class = 'warning'>\The [src] splutters out from lack of fuel.</span>","<span class = 'warning'>You hear something cough.</span>")
			toggle()

/obj/machinery/bunsen_burner/update_icon()
	icon_state = "bunsen[heating]"


/obj/machinery/bunsen_burner/attack_hand(mob/user)
	if(held_container)
		underlays = null
		to_chat(user, "<span class='notice'>You remove the [held_container] from the [src].</span>")
		held_container.forceMove(src.loc)
		held_container.attack_hand(user)
		held_container = null
	else
		toggle()

/obj/machinery/bunsen_burner/verb/toggle()
	set src in view(1)
	set name = "Toggle bunsen burner"
	set category = "Object"

	heating = !heating
	update_icon()
	if(heating)
		processing_objects.Add(src)
	else
		processing_objects.Remove(src)
