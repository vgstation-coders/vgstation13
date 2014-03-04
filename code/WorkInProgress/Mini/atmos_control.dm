/obj/item/weapon/circuitboard/atmoscontrol
	name = "\improper Central Atmospherics Computer Circuitboard"
	build_path = /obj/machinery/computer/atmoscontrol

/datum/design/atmoscontrol
	name = "Circuit Design (Central Atmosherics Computer)"
	desc = "Allows for the construction of circuit boards used to build an Atmos Control Console."
	id = "atmoscontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/atmoscontrol

/obj/machinery/computer/atmoscontrol
	name = "\improper Central Atmospherics Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "tank"
	density = 1
	anchored = 1.0
	circuit = "/obj/item/weapon/circuitboard/atmoscontrol"
	var/obj/machinery/alarm/current
	var/list/filter=null
	var/overridden = 0 //not set yet, can't think of a good way to do it
	req_one_access = list(access_ce)


/obj/machinery/computer/atmoscontrol/xeno
	name = "\improper Xenobiology Atmospherics Computer"
	filter=list(
		/area/toxins/xenobiology/specimen_1,
		/area/toxins/xenobiology/specimen_2,
		/area/toxins/xenobiology/specimen_3,
		/area/toxins/xenobiology/specimen_4,
		/area/toxins/xenobiology/specimen_5,
		/area/toxins/xenobiology/specimen_6
	)
	req_one_access = list(access_xenobiology,access_ce)


/obj/machinery/computer/atmoscontrol/gas_chamber
	name = "\improper Gas Chamber Atmospherics Computer"
	filter=list(
		/area/security/gas_chamber
	)
	req_one_access = list(access_ce,access_hos)


/obj/machinery/computer/atmoscontrol/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return interact(user)

/obj/machinery/computer/atmoscontrol/attack_paw(var/mob/user as mob)
	return interact(user)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	return interact(user)

/obj/machinery/computer/atmoscontrol/interact(mob/user)
	user.set_machine(src)
	if(allowed(user))
		overridden = 1
	else if(!emagged)
		overridden = 0

	return ui_interact(user)


/obj/machinery/computer/atmoscontrol/attackby(var/obj/item/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		user.visible_message("<span class=\"rose\">\The [user] swipes \a [I] through \the [src], causing the screen to flash!</span>",\
			"<span class=\"rose\">You swipe your [I] through \the [src], the screen flashing as you gain full control.</span>",\
			"You hear the swipe of a card through a reader, and an electronic warble.")
		emagged = 1
		overridden = 1
		return
	return ..()

/obj/machinery/computer/atmoscontrol/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(user.stat && !isobserver(user))
		return

	var/list/data[0]
	data["alarm"]=null
	if(current)
		data += current.get_nano_data(user,TRUE)
		data["alarm"] = "\ref[current]"

	var/list/alarms=list()
	for(var/obj/machinery/alarm/alarm in sortAtom(machines))
		if(!is_in_filter(alarm.alarm_area.type))
			continue // NO ACCESS 4 U

		var/list/alarm_data=list()
		alarm_data["ID"]="\ref[alarm]"
		alarm_data["danger"] = max(alarm.local_danger_level, alarm.alarm_area.atmosalm-1)
		alarm_data["name"] = "[alarm]"
		alarms+=list(alarm_data)
	data["alarms"]=alarms

	if (!ui) // no ui has been passed, so we'll search for one
		ui = nanomanager.get_open_ui(user, src, ui_key)

	if (!ui)
		// the ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "atmos_control.tmpl", name, 550, 410)
		// When the UI is first opened this is the data it will use
		ui.set_initial_data(data)
		ui.open()
		// Auto update every Master Controller tick
		if(current)
			ui.set_auto_update(1)
	else
		// The UI is already open so push the new data to it
		ui.push_data(data)
		return


/obj/machinery/computer/atmoscontrol/proc/is_in_filter(var/typepath)
	if(!filter) return 1 // YEP.  TOTALLY.
	return typepath in filter

//a bunch of this is copied from atmos alarms
/obj/machinery/computer/atmoscontrol/Topic(href, href_list)
	if(..())
		return
	if(href_list["reset"])
		current = null

	if(href_list["alarm"])
		current = locate(href_list["alarm"])
		updateUsrDialog()
		return

	if(current)
		if(href_list["command"])
			var/device_id = href_list["id_tag"]
			switch(href_list["command"])
				if(
					"power",
					"adjust_external_pressure",
					"checks",
					"co2_scrub",
					"tox_scrub",
					"n2o_scrub",
					"o2_scrub",
					"n2_scrub",
					"panic_siphon",
					"scrubbing"
				)
					var/val
					if(href_list["val"])
						val=text2num(href_list["val"])
					else
						var/newval = input("Enter new value") as num|null
						if(isnull(newval))
							return
						val = newval
					current.send_signal(device_id, list (href_list["command"] = val))
					spawn(3)
						src.updateUsrDialog()
				//if("adjust_threshold") //was a good idea but required very wide window
				if("set_threshold")
					var/env = href_list["env"]
					var/threshold = text2num(href_list["var"])
					var/list/selected = current.TLV[env]
					var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
					var/newval = input("Enter [thresholds[threshold]] for [env]", "Alarm triggers", selected[threshold]) as num|null
					if (isnull(newval) || ..() || (current.locked && issilicon(usr)))
						return
					if (newval<0)
						selected[threshold] = -1.0
					else if (env=="temperature" && newval>5000)
						selected[threshold] = 5000
					else if (env=="pressure" && newval>50*ONE_ATMOSPHERE)
						selected[threshold] = 50*ONE_ATMOSPHERE
					else if (env!="temperature" && env!="pressure" && newval>200)
						selected[threshold] = 200
					else
						newval = round(newval,0.01)
						selected[threshold] = newval
					if(threshold == 1)
						if(selected[1] > selected[2])
							selected[2] = selected[1]
						if(selected[1] > selected[3])
							selected[3] = selected[1]
						if(selected[1] > selected[4])
							selected[4] = selected[1]
					if(threshold == 2)
						if(selected[1] > selected[2])
							selected[1] = selected[2]
						if(selected[2] > selected[3])
							selected[3] = selected[2]
						if(selected[2] > selected[4])
							selected[4] = selected[2]
					if(threshold == 3)
						if(selected[1] > selected[3])
							selected[1] = selected[3]
						if(selected[2] > selected[3])
							selected[2] = selected[3]
						if(selected[3] > selected[4])
							selected[4] = selected[3]
					if(threshold == 4)
						if(selected[1] > selected[4])
							selected[1] = selected[4]
						if(selected[2] > selected[4])
							selected[2] = selected[4]
						if(selected[3] > selected[4])
							selected[3] = selected[4]

					//Sets the temperature the built-in heater/cooler tries to maintain.
					if(env == "temperature")
						if(current.target_temperature < selected[2])
							current.target_temperature = selected[2]
						if(current.target_temperature > selected[3])
							current.target_temperature = selected[3]

					spawn(1)
						updateUsrDialog()
			return

		if(href_list["screen"])
			current.screen = text2num(href_list["screen"])
			spawn(1)
				src.updateUsrDialog()
			return

		if(href_list["atmos_unlock"])
			switch(href_list["atmos_unlock"])
				if("0")
					current.air_doors_close(1)
				if("1")
					current.air_doors_open(1)

		if(href_list["atmos_alarm"])
			current.alarmActivated=1
			current.alarm_area.updateDangerLevel()
			spawn(1)
				src.updateUsrDialog()
			current.update_icon()
			return
		if(href_list["atmos_reset"])
			current.alarmActivated=0
			current.alarm_area.updateDangerLevel()
			spawn(1)
				src.updateUsrDialog()
			current.update_icon()
			return

		if(href_list["mode"])
			current.mode = text2num(href_list["mode"])
			current.apply_mode()
			spawn(5)
				src.updateUsrDialog()
			return

		if(href_list["preset"])
			current.preset = text2num(href_list["preset"])
			current.apply_preset()
			spawn(5)
				src.updateUsrDialog()
			return

		if(href_list["temperature"])
			var/list/selected = current.TLV["temperature"]
			var/max_temperature = min(selected[3] - T0C, MAX_TEMPERATURE)
			var/min_temperature = max(selected[2] - T0C, MIN_TEMPERATURE)
			var/input_temperature = input("What temperature would you like the system to maintain? (Capped between [min_temperature]C and [max_temperature]C)", "Thermostat Controls") as num|null
			if(input_temperature==null)
				return
			if(input_temperature > max_temperature || input_temperature < min_temperature)
				usr << "Temperature must be between [min_temperature]C and [max_temperature]C"
			else
				current.target_temperature = input_temperature + T0C
			return
	updateUsrDialog()