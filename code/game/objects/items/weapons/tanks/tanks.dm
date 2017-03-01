#define TANK_MAX_RELEASE_PRESSURE (3*ONE_ATMOSPHERE)
#define TANK_DEFAULT_RELEASE_PRESSURE 24

/obj/item/weapon/tank
	name = "tank"
	icon = 'icons/obj/tank.dmi'
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK

	pressure_resistance = ONE_ATMOSPHERE*5

	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4

	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 3
	var/volume = 70
	var/manipulated_by = null		//Used by _onclick/hud/screen_objects.dm internals to determine if someone has messed with our tank or not.
						//If they have and we haven't scanned it with the PDA or gas analyzer then we might just breath whatever they put in it.
/obj/item/weapon/tank/New()
	..()

	src.air_contents = new /datum/gas_mixture()
	src.air_contents.volume = volume //liters
	src.air_contents.temperature = T20C

	processing_objects.Add(src)
	return

/obj/item/weapon/tank/Destroy()
	if(air_contents)
		qdel(air_contents)
		air_contents = null

	if(istype(loc, /obj/machinery/portable_atmospherics))
		var/obj/machinery/portable_atmospherics/holder = loc
		holder.holding = null

	processing_objects.Remove(src)

	..()

/obj/item/weapon/tank/examine(mob/user)
	..()
	var/obj/icon = src
	if (istype(src.loc, /obj/item/assembly))
		icon = src.loc
	if (!in_range(src, user))
		if (icon == src)
			to_chat(user, "<span class='notice'>It's \a [bicon(icon)][src]! If you want any more information you'll need to get closer.</span>")
		return

	var/celsius_temperature = src.air_contents.temperature-T0C
	var/descriptive

	if (celsius_temperature < 20)
		descriptive = "cold"
	else if (celsius_temperature < 40)
		descriptive = "room temperature"
	else if (celsius_temperature < 80)
		descriptive = "lukewarm"
	else if (celsius_temperature < 100)
		descriptive = "warm"
	else if (celsius_temperature < 300)
		descriptive = "hot"
	else
		descriptive = "furiously hot"

	to_chat(user, "<span class='info'>\The [bicon(icon)][src] feels [descriptive]</span>")

	if(air_contents.volume * 10 < volume)
		to_chat(user, "<span class='danger'>The meter on the [src.name] indicates you are almost out of gas!</span>")
		playsound(user, 'sound/effects/alert.ogg', 50, 1)

/obj/item/weapon/tank/blob_act()
	if(prob(50))
		var/turf/location = src.loc
		if (!( istype(location, /turf) ))
			qdel(src)

		if(src.air_contents)
			location.assume_air(air_contents)

		qdel(src)

/obj/item/weapon/tank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	var/obj/icon = src

	if (istype(src.loc, /obj/item/assembly))
		icon = src.loc

	if ((istype(W, /obj/item/device/analyzer)) && get_dist(user, src) <= 1)
		user.visible_message("<span class='attack'>[user] has used [W] on [bicon(icon)] [src]</span>", "<span class='attack'>You use \the [W] on [bicon(icon)] [src]</span>")
		var/obj/item/device/analyzer/analyzer = W
		user.show_message(analyzer.output_gas_scan(src.air_contents, src, 0), 1)
		src.add_fingerprint(user)
	else if (istype(W, /obj/item/clothing/gloves/latex) || (istype(W, /obj/item/toy/balloon) && !istype(W, /obj/item/toy/balloon/inflated)))
		if(air_contents.return_pressure() >= ONE_ATMOSPHERE)
			to_chat(user, "You inflate \the [W] using \the [src].")
			if(istype(W, /obj/item/toy/balloon))
				var/obj/item/toy/balloon/B = W
				B.inflate(user, air_contents)
			else
				user.drop_item(W, force_drop = 1)
				var/obj/item/toy/balloon/glove/B1 = new (get_turf(user))
				B1.inflate(user, air_contents)
				var/obj/item/toy/balloon/glove/B2 = new (get_turf(user))
				B2.inflate(user, air_contents)
				qdel(W)
		else
			to_chat(user, "<span class='warning'>There's no gas in the tank.</span>")


	if(istype(W, /obj/item/device/assembly_holder))
		bomb_assemble(W,user)

/obj/item/weapon/tank/attack_self(mob/user as mob)
	if (!(src.air_contents))
		return

	ui_interact(user)

/obj/item/weapon/tank/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)

	var/using_internal
	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/location = loc
		if(location.internal==src)
			using_internal = 1

	// this is the data which will be sent to the ui
	var/data[0]
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
	data["valveOpen"] = using_internal ? 1 : 0

	data["maskConnected"] = 0
	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/location = loc
		if(location.internal == src || (location.wear_mask && (location.wear_mask.clothing_flags & MASKINTERNALS)))
			data["maskConnected"] = 1

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "tanks.tmpl", "Tank", 500, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/item/weapon/tank/Topic(href, href_list)
	..()
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1
	if (usr.stat|| usr.restrained())
		return 0
	if (src.loc != usr)
		return 0

	if (href_list["dist_p"])
		if (href_list["dist_p"] == "reset")
			src.distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
		else if (href_list["dist_p"] == "max")
			src.distribute_pressure = TANK_MAX_RELEASE_PRESSURE
		else
			var/cp = text2num(href_list["dist_p"])
			src.distribute_pressure += cp
		src.distribute_pressure = min(max(round(src.distribute_pressure), 0), TANK_MAX_RELEASE_PRESSURE)
	if (href_list["stat"])
		if(istype(loc,/mob/living/carbon))
			var/mob/living/carbon/location = loc
			if(location.internal == src)
				location.internal = null
				location.internals.icon_state = "internal0"
				to_chat(usr, "<span class='notice'>You close the tank release valve.</span>")
				if (location.internals)
					location.internals.icon_state = "internal0"
			else
				if(location.wear_mask && (location.wear_mask.clothing_flags & MASKINTERNALS))
					location.internal = src
					to_chat(usr, "<span class='notice'>You open \the [src] valve.</span>")
					if (location.internals)
						location.internals.icon_state = "internal1"
				else
					to_chat(usr, "<span class='notice'>You need something to connect to \the [src].</span>")

	src.add_fingerprint(usr)
	return 1


/obj/item/weapon/tank/remove_air(amount)
	return air_contents.remove(amount)

/obj/item/weapon/tank/return_air()
	return air_contents

/obj/item/weapon/tank/assume_air(datum/gas_mixture/giver)
	air_contents.merge(giver)

	check_status()
	return 1

/obj/item/weapon/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < distribute_pressure)
		distribute_pressure = tank_pressure

	var/moles_needed = distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	return remove_air(moles_needed)

/obj/item/weapon/tank/process()
	//Allow for reactions
	if(air_contents)
		air_contents.react()
	check_status()


/obj/item/weapon/tank/proc/check_status()
	//Handle exploding, leaking, and rupturing of the tank
	if(timestopped)
		return

	var/cap = 0
	var/uncapped = 0
	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()
	if(pressure > TANK_FRAGMENT_PRESSURE)
		if(!istype(src.loc,/obj/item/device/transfer_valve))
			message_admins("Explosive tank rupture! last key to touch the tank was [src.fingerprintslast].")
			log_game("Explosive tank rupture! last key to touch the tank was [src.fingerprintslast].")
//		to_chat(world, "<span class='warning'>[x],[y] tank is exploding: [pressure] kPa</span>")
		//Give the gas a chance to build up more pressure through reacting
		air_contents.react()
		air_contents.react()
		air_contents.react()
		pressure = air_contents.return_pressure()
		var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
		if(range > MAX_EXPLOSION_RANGE)
			cap = 1
			uncapped = range
		range = min(range, MAX_EXPLOSION_RANGE)		// was 8 - - - Changed to a configurable define -- TLE
		var/turf/epicenter = get_turf(loc)

//		to_chat(world, "<span class='notice'>Exploding Pressure: [pressure] kPa, intensity: [range]</span>")

		explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5), 1, cap)
		if(cap)
			for(var/obj/machinery/computer/bhangmeter/bhangmeter in doppler_arrays)
				if(bhangmeter)
					bhangmeter.sense_explosion(epicenter.x,epicenter.y,epicenter.z,round(uncapped*0.25), round(uncapped*0.5), round(uncapped),"???", cap)

		if(istype(src.loc,/obj/item/device/transfer_valve))
			var/obj/item/device/transfer_valve/TV = src.loc
			TV.child_ruptured(src, range)

		qdel(src)

		return

	else if(pressure > TANK_RUPTURE_PRESSURE)
//		to_chat(world, "<span class='warning'>[x],[y] tank is rupturing: [pressure] kPa, integrity [integrity]</span>")
		if(integrity <= 0)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			T.assume_air(air_contents)
			playsound(get_turf(src), 'sound/effects/spray.ogg', 10, 1, -3)

			qdel(src)

			return
		else
			integrity--

	else if(pressure > TANK_LEAK_PRESSURE)
//		to_chat(world, "<span class='warning'>[x],[y] tank is leaking: [pressure] kPa, integrity [integrity]</span>")
		if(integrity <= 0)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
			T.assume_air(leaked_gas)
		else
			integrity--

	else if(integrity < 3)
		integrity++
