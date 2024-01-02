#define OVERLAY_HOLDING 1
#define OVERLAY_CONNECTED 2
#define OVERLAY_NO_PRESSURE 4
#define OVERLAY_LOW_PRESSURE 8
#define OVERLAY_MEDIUM_PRESSURE 16
#define OVERLAY_HIGH_PRESSURE 32

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A container for gases. Can be used with atmospherics machinery through interaction with a port, and can also fill man-portable tanks."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "yellow"
	density = 1
	health = 100.0
	flags = FPRINT
	siemens_coefficient = 1

	var/valve_open = 0
	var/release_pressure = ONE_ATMOSPHERE

	var/canister_color = "yellow"
	var/old_color = 0
	var/can_label = 1
	var/filled = 0.5 // Mapping var: Set to 0 for empty, 1 to full, anywhere between.
	pressure_resistance = 7*ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = MACHINE_POWER_USE_NONE
	var/release_log = ""
	var/busy = 0
	starting_materials = list(MAT_IRON = 10*CC_PER_SHEET_METAL)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL

	//Icon Update Code
	var/overlay_status = 0
	var/log="" // Bad boys, bad boys.

/obj/machinery/portable_atmospherics/canister/New()
	..()
	old_color = canister_color

/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "redws"
	canister_color = "redws"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red"
	canister_color = "red"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
	canister_color = "blue"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/plasma
	name = "Canister \[Plasma\]"
	icon_state = "orange"
	canister_color = "orange"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/plasma/broken
	icon_state = "orange-1"
	destroyed = 1

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black"
	canister_color = "black"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "grey"
	canister_color = "grey"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/update_icon()
	if(destroyed)
		icon_state = "[canister_color]-1"
		overlays.len = 0
		return

	if (canister_color != old_color)
		icon_state = "[canister_color]"
		old_color = canister_color

	var/tank_pressure = air_contents.return_pressure()
	if(check_updates(tank_pressure))
		if(overlays.len)
			overlays = 0

		overlay_status = 0

		if (holding)
			overlays += other_overlays(1)
			overlay_status |= OVERLAY_HOLDING

		if (connected_port)
			overlays += other_overlays(2)
			overlay_status |= OVERLAY_CONNECTED

		switch(tank_pressure)
			if(15 * ONE_ATMOSPHERE to INFINITY)
				overlays += pressure_overlays(4)
				overlay_status |= OVERLAY_HIGH_PRESSURE
			if(ONE_ATMOSPHERE to 15 * ONE_ATMOSPHERE)
				overlays += pressure_overlays(3)
				overlay_status |= OVERLAY_MEDIUM_PRESSURE
			if(10 to ONE_ATMOSPHERE)
				overlays += pressure_overlays(2)
				overlay_status |= OVERLAY_LOW_PRESSURE
			else
				overlays += pressure_overlays(1)
				overlay_status |= OVERLAY_NO_PRESSURE
	return

/obj/machinery/portable_atmospherics/canister/proc/pressure_overlays(var/state)
	var/static/list/status_overlays_pressure = list(
		image('icons/obj/atmos.dmi', "can-o0"), //Should be able to use icon as an arg here, but BYOND (as of v514) makes it null for some reason. null actually works fine here though because it uses src.icon by default. But for the sake of clarity we'll keep the explicit path here for now. Same situation with the vintage canisters in randomvaults/objects.dm.
		image('icons/obj/atmos.dmi', "can-o1"),
		image('icons/obj/atmos.dmi', "can-o2"),
		image('icons/obj/atmos.dmi', "can-o3")
	)

	return status_overlays_pressure[state]

/obj/machinery/portable_atmospherics/canister/proc/other_overlays(var/state)
	var/static/list/status_overlays_other = list(
		image('icons/obj/atmos.dmi', "can-open"),
		image('icons/obj/atmos.dmi', "can-connector")
	)

	return status_overlays_other[state]

/obj/machinery/portable_atmospherics/canister/proc/check_updates(tank_pressure = 0)
	if((overlay_status & OVERLAY_HOLDING) != holding)
		return 1
	if((overlay_status & OVERLAY_CONNECTED) != connected_port)
		return 1
	if((overlay_status & OVERLAY_HIGH_PRESSURE) && tank_pressure < 15*ONE_ATMOSPHERE)
		return 1
	if((overlay_status & OVERLAY_MEDIUM_PRESSURE) && (tank_pressure < ONE_ATMOSPHERE || tank_pressure > 15*ONE_ATMOSPHERE))
		return 1
	if((overlay_status & OVERLAY_LOW_PRESSURE) && (tank_pressure < 10 || tank_pressure > ONE_ATMOSPHERE))
		return 1
	if((overlay_status & OVERLAY_NO_PRESSURE) && tank_pressure > 10)
		return 1
	return 0


/obj/machinery/portable_atmospherics/canister/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(destroyed)
		return 1

	if (src.health <= 10)
		var/atom/location = src.loc
		location.assume_air(air_contents)

		src.destroyed = 1
		playsound(src, 'sound/effects/spray.ogg', 10, 1, -3)
		setDensity(FALSE)
		update_icon()
		investigation_log(I_ATMOS, "was destoyed by excessive damage.")

		if (src.holding)
			src.holding.forceMove(src.loc)
			src.holding = null
		nanomanager.update_uis(src)
		return 1
	else
		return 1

/obj/machinery/portable_atmospherics/canister/process()
	if (destroyed)
		return

	..()

	handle_beams() //emitter beams

	if(valve_open)
		var/datum/gas_mixture/environment
		var/transfer_vol //A band-aid fix for the fact the equation used below doesn't work as intended
		if(holding && !arcanetampered)
			environment = holding.air_contents
			transfer_vol = holding.volume
		else
			environment = loc.return_air()
			transfer_vol = CELL_VOLUME

		var/env_pressure = environment.return_pressure()
		var/pressure_delta = min(release_pressure - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta * transfer_vol / (air_contents.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			if(holding && !arcanetampered)
				environment.merge(removed)
			else
				loc.assume_air(removed)
			src.update_icon()
		nanomanager.update_uis(src)

	if(air_contents.return_pressure() < 1)
		can_label = 1
	else
		can_label = 0

	if(air_contents.temperature > PLASMA_FLASHPOINT)
		air_contents.zburn()
		nanomanager.update_uis(src)

	return

/obj/machinery/portable_atmospherics/canister/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/canister/proc/return_temperature()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume>0)
		return GM.temperature
	return 0

/obj/machinery/portable_atmospherics/canister/proc/return_pressure()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume>0)
		return GM.return_pressure()
	return 0

/obj/machinery/portable_atmospherics/canister/blob_act()
	src.health -= 200
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		src.health -= round(Proj.damage / 2)
		healthcheck()
	return ..()

/obj/machinery/portable_atmospherics/canister/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(iswelder(W) && src.destroyed)
		if(weld(W, user))
			to_chat(user, "<span class='notice'>You salvage what's left of \the [src].</span>")
			var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(get_turf(src))//new /obj/item/stack/sheet/metal(src.loc)
			M.amount = 3
			qdel (src)
		return

	if(!W.is_wrench(user) && !istype(W, /obj/item/weapon/tank) && !istype(W, /obj/item/device/analyzer) && !istype(W, /obj/item/device/pda))
		visible_message("<span class='warning'>[user] hits the [src] with a [W]!</span>")
		investigation_log(I_ATMOS, "<span class='danger'>was smacked with \a [W] by [key_name(user)]</span>")
		src.health -= W.force
		src.add_fingerprint(user)
		healthcheck()

	if(istype(user, /mob/living/silicon/robot) && istype(W, /obj/item/weapon/tank/jetpack))
		var/datum/gas_mixture/thejetpack = W:air_contents
		var/env_pressure = thejetpack.return_pressure()
		var/pressure_delta = min(10*ONE_ATMOSPHERE - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure
		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*thejetpack.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			thejetpack.merge(removed)
			to_chat(user, "You pulse-pressurize your jetpack from the tank.")
		return

	..()

	nanomanager.update_uis(src) // Update all NanoUIs attached to src


/obj/machinery/portable_atmospherics/canister/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(var/mob/user as mob)
	return src.ui_interact(user)

/obj/machinery/portable_atmospherics/canister/attack_alien(var/mob/living/carbon/alien/user as mob)
	src.add_hiddenprint(user)
	health -= rand(15, 30)
	user.visible_message("<span class='danger'>\The [user] slashes away at \the [src]!</span>", \
						 "<span class='danger'>You slash away at \the [src]!</span>")
	user.delayNextAttack(10) //Hold on there amigo
	investigation_log(I_ATMOS, "<span style='danger'>was slashed at by alien [key_name(user)]</span>")
	playsound(src, 'sound/weapons/slice.ogg', 25, 1, -1)
	healthcheck()

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if (src.destroyed || gcDestroyed || !get_turf(src))
		if(!ui)
			ui = nanomanager.get_open_ui(user, src, ui_key)
		if(ui)
			ui.close()
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["name"] = name
	data["canLabel"] = can_label ? 1 : 0
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() > 0 ? air_contents.return_pressure() : 0)//This used to be redundant, made it into a fix for -1 kPA showing up in the UI
	data["releasePressure"] = round(release_pressure)
	data["minReleasePressure"] = round(ONE_ATMOSPHERE/10)
	data["maxReleasePressure"] = round(10*ONE_ATMOSPHERE)
	data["valveOpen"] = valve_open ? 1 : 0

	data["hasHoldingTank"] = holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure() > 0 ? holding.air_contents.return_pressure() : 0))

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "canister.tmpl", "Canister", 480, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		//ui.set_auto_update(1)

/obj/machinery/portable_atmospherics/canister/Topic(href, href_list)
	. = ..()//Sanity
	if(.)
		return .

	if(href_list["toggle"])
		if (valve_open && !arcanetampered)
			if (holding)
				investigation_log(I_ATMOS, "had its valve <b>closed</b> by [key_name(usr)], stopping transfer into \the [holding].")
			else
				investigation_log(I_ATMOS, "had its valve <b>closed</b> by [key_name(usr)], stopping transfer into the <font color='red'><b>air</b></font>")
		else
			if (holding && !arcanetampered)
				investigation_log(I_ATMOS, "had its valve <b>OPENED</b> by [key_name(usr)], starting transfer into \the [holding]")
			else
				var/naughty_stuff = air_contents.loggable_contents()
				investigation_log(I_ATMOS, "had its valve <b>OPENED</b> by [key_name(usr)], starting transfer into the <font color='red'><b>air</b></font> ([naughty_stuff])")
				if(naughty_stuff)
					message_admins("[usr.real_name] ([formatPlayerPanel(usr,usr.ckey)]) opened a[arcanetampered ? "n arcane tampered" : ""] canister that contains [naughty_stuff] at [formatJumpTo(loc)]!")
					log_admin("[usr]([ckey(usr.key)]) opened a[arcanetampered ? "n arcane tampered" : ""] canister that contains [naughty_stuff] at [loc.x], [loc.y], [loc.z]")

		valve_open = !valve_open

	if (href_list["remove_tank"])
		if(holding)
			if(valve_open || arcanetampered)
				var/naughty_stuff = air_contents.loggable_contents()
				if(naughty_stuff)
					message_admins("[usr.real_name] ([formatPlayerPanel(usr,usr.ckey)]) opened a[arcanetampered ? "n arcane tampered" : ""] canister that contains [naughty_stuff] at [formatJumpTo(loc)]!")
					log_admin("[usr]([ckey(usr.key)]) opened a[arcanetampered ? "n arcane tampered" : ""] canister that contains [naughty_stuff] at [loc.x], [loc.y], [loc.z]")

			if(istype(holding, /obj/item/weapon/tank))
				holding.manipulated_by = usr.real_name
			usr.put_in_hands(holding)
			holding = null

	if (href_list["pressure_adj"])
		var/diff = text2num(href_list["pressure_adj"])
		if(diff > 0)
			release_pressure = min(10*ONE_ATMOSPHERE, release_pressure+diff)
		else
			release_pressure = max(ONE_ATMOSPHERE/10, release_pressure+diff)

	if (href_list["relabel"])
		if (can_label)
			var/list/colors = list(\
				"\[N2O\]" = "redws", \
				"\[N2\]" = "red", \
				"\[O2\]" = "blue", \
				"\[Plasma\]" = "orange", \
				"\[CO2\]" = "black", \
				"\[Air\]" = "grey", \
				"\[CAUTION\]" = "yellow", \
			)
			var/label = input("Choose canister label", "Gas canister") as null|anything in colors
			if (label)
				src.canister_color = colors[label]
				src.icon_state = colors[label]
				src.name = "Canister: [label]"

	src.add_fingerprint(usr)
	src.add_hiddenprint(usr)
	update_icon()

	return 1

/obj/machinery/portable_atmospherics/canister/plasma/New(loc)
	..(loc)
	air_contents.adjust_gas(GAS_PLASMA, (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
	update_icon()

/obj/machinery/portable_atmospherics/canister/oxygen/New(loc)
	..(loc)
	air_contents.adjust_gas(GAS_OXYGEN, (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
	update_icon()

/obj/machinery/portable_atmospherics/canister/sleeping_agent/New(loc)
	..(loc)
	air_contents.adjust_gas(GAS_SLEEPING, (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
	update_icon()

/obj/machinery/portable_atmospherics/canister/nitrogen/New(loc)
	..(loc)
	air_contents.adjust_gas(GAS_NITROGEN, (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
	update_icon()

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New(loc)
	..(loc)
	air_contents.adjust_gas(GAS_CARBON, (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
	update_icon()

/obj/machinery/portable_atmospherics/canister/air/New(loc)
	..(loc)

	air_contents.adjust_multi(
		GAS_OXYGEN, (O2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature),
		GAS_NITROGEN, (N2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))

	update_icon()

/obj/machinery/portable_atmospherics/canister/proc/weld(var/obj/item/tool/weldingtool/WT, var/mob/user)


	if(busy)
		return 0

	// Do after stuff here
	to_chat(user, "<span class='notice'>You start to slice away at \the [src]...</span>")
	busy = 1
	if(WT.do_weld(user, src, 50,0))
		busy = 0
		return 1
	busy = 0
	return 0

/obj/machinery/portable_atmospherics/canister/apply_beam_damage(var/obj/effect/beam/B)
	var/lastcheck=last_beamchecks["\ref[B]"]

	var/damage = ((world.time - lastcheck)/10)  * (B.get_damage()/2)

	// Actually apply damage
	health -= damage

	// Update check time.
	last_beamchecks["\ref[B]"]=world.time

// Apply connect damage
/obj/machinery/portable_atmospherics/canister/beam_connect(var/obj/effect/beam/B)
	..()
	last_beamchecks["\ref[B]"]=world.time

/obj/machinery/portable_atmospherics/canister/beam_disconnect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)
	last_beamchecks.Remove("\ref[B]") // RIP

/obj/machinery/portable_atmospherics/canister/handle_beams()
	// New beam damage code (per-tick)
	for(var/obj/effect/beam/B in beams)
		apply_beam_damage(B)
	healthcheck()

#undef OVERLAY_HOLDING
#undef OVERLAY_CONNECTED
#undef OVERLAY_NO_PRESSURE
#undef OVERLAY_LOW_PRESSURE
#undef OVERLAY_MEDIUM_PRESSURE
#undef OVERLAY_HIGH_PRESSURE
