/turf/open/floor/mech_bay_recharge_floor               //        Whos idea it was
	name = "mech bay recharge station"                      //        Recharging turfs
	icon = 'icons/turf/floors.dmi'                          //		  That are set in stone to check the west turf for recharge port
	icon_state = "recharge_floor"                           //        Some people just want to watch the world burn i guess

/turf/open/floor/mech_bay_recharge_floor/break_tile()
	ScrapeAway()

/turf/open/floor/mech_bay_recharge_floor/airless
	icon_state = "recharge_floor_asteroid"
	initial_gas_mix = "TEMP=2.7"

/obj/machinery/mech_bay_recharge_port
	name = "mech bay power port"
	density = TRUE
	anchored = TRUE
	dir = EAST
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_port"
	circuit = /obj/item/circuitboard/machine/mech_recharger
	var/obj/mecha/recharging_mech
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	var/max_charge = 50
	var/on = FALSE
	var/repairability = 0
	var/turf/recharging_turf = null

/obj/machinery/mech_bay_recharge_port/Initialize()
	. = ..()
	recharging_turf = get_step(loc, dir)

/obj/machinery/mech_bay_recharge_port/RefreshParts()
	var/MC
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		MC += C.rating
	max_charge = MC * 25

/obj/machinery/mech_bay_recharge_port/process()
	if(stat & NOPOWER || !recharge_console)
		return
	if(!recharging_mech)
		recharging_mech = locate(/obj/mecha) in recharging_turf
		if(recharging_mech)
			recharge_console.update_icon()
	if(recharging_mech && recharging_mech.cell)
		if(recharging_mech.cell.charge < recharging_mech.cell.maxcharge)
			var/delta = min(max_charge, recharging_mech.cell.maxcharge - recharging_mech.cell.charge)
			recharging_mech.give_power(delta)
			use_power(delta*150)
		else
			recharge_console.update_icon()
		if(recharging_mech.loc != recharging_turf)
			recharging_mech = null
			recharge_console.update_icon()


/obj/machinery/mech_bay_recharge_port/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "recharge_port-o", "recharge_port", I))
		return

	if(default_change_direction_wrench(user, I))
		recharging_turf = get_step(loc, dir)
		return

	if(exchange_parts(user, I))
		return

	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/computer/mech_bay_power_console
	name = "mech bay power control console"
	desc = "Used to control mechbay power ports."
	icon_screen = "recharge_comp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/mech_bay_power_console
	var/obj/machinery/mech_bay_recharge_port/recharge_port
	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/mech_bay_power_console/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mech_bay_power_console", "Mech Bay Power Control Console", 400, 170, master_ui, state)
		ui.open()

/obj/machinery/computer/mech_bay_power_console/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("reconnect")
			reconnect()
			. = TRUE
			update_icon()

/obj/machinery/computer/mech_bay_power_console/ui_data(mob/user)
	var/list/data = list()
	if(recharge_port && !QDELETED(recharge_port))
		data["recharge_port"] = list("mech" = null)
		if(recharge_port.recharging_mech && !QDELETED(recharge_port.recharging_mech))
			data["recharge_port"]["mech"] = list("health" = recharge_port.recharging_mech.obj_integrity, "maxhealth" = recharge_port.recharging_mech.max_integrity, "cell" = null)
			if(recharge_port.recharging_mech.cell && !QDELETED(recharge_port.recharging_mech.cell))
				data["recharge_port"]["mech"]["cell"] = list(
				"critfail" = recharge_port.recharging_mech.cell.crit_fail,
				"charge" = recharge_port.recharging_mech.cell.charge,
				"maxcharge" = recharge_port.recharging_mech.cell.maxcharge
				)
	return data


/obj/machinery/computer/mech_bay_power_console/proc/reconnect()
	if(recharge_port)
		return
	recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in range(1)
	if(!recharge_port )
		for(var/D in GLOB.cardinals)
			var/turf/A = get_step(src, D)
			A = get_step(A, D)
			recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in A
			if(recharge_port)
				break
	if(recharge_port)
		if(!recharge_port.recharge_console)
			recharge_port.recharge_console = src
		else
			recharge_port = null

/obj/machinery/computer/mech_bay_power_console/update_icon()
	..()
	if(!recharge_port || !recharge_port.recharging_mech || !recharge_port.recharging_mech.cell || !(recharge_port.recharging_mech.cell.charge < recharge_port.recharging_mech.cell.maxcharge) || stat & (NOPOWER|BROKEN))
		return
	add_overlay("recharge_comp_on")

/obj/machinery/computer/mech_bay_power_console/Initialize()
	. = ..()
	reconnect()
