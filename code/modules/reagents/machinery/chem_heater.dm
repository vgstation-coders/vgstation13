/obj/machinery/chem_heater
	name = "\improper Chem Heater"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	use_power = 1
	idle_power_usage = 40
	var/obj/item/weapon/reagent_containers/beaker = null
	var/target_temperature = 300
	var/heater_coefficient = 0.10
	var/on = FALSE
	var/useramount

	var/targetMoveKey = null //To prevent borgs from leaving without their beakers.

/obj/machinery/chem_heater/New()
	.=..()

	component_parts = newlist(
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/chem_heater/RefreshParts()
	heater_coefficient = initial(heater_coefficient)
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		heater_coefficient *= M.rating

/obj/machinery/chem_heater/process()
	..()
	if(stat & NOPOWER)
		return
	if(on)
		if(beaker)
			if(beaker.reagents.chem_temp > target_temperature)
				beaker.reagents.chem_temp += min(-1, (target_temperature - beaker.reagents.chem_temp) * heater_coefficient)
			if(beaker.reagents.chem_temp < target_temperature)
				beaker.reagents.chem_temp += max(1, (target_temperature - beaker.reagents.chem_temp) * heater_coefficient)
			if(beaker.reagents.chem_temp == target_temperature)
				playsound(get_turf(src), 'sound/machines/ding.ogg', 50, 1)
				on = !on
			beaker.reagents.chem_temp = round(beaker.reagents.chem_temp)
			beaker.reagents.handle_reactions()

/obj/machinery/chem_heater/attackby(var/obj/item/weapon/B, var/mob/user)
	if(..())
		return 1

	else if(istype(B, /obj/item/weapon/reagent_containers))
		if(beaker)
			to_chat(user, "<span class='warning'>A container is already loaded in \the [src].</span>")
			return
		if(B.w_class > W_CLASS_SMALL)
			to_chat(user, "<span class='warning'>\The [B] is too big to fit.</span>")
			return
		if(!user.drop_item(B, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [B]!</span>")
			return

		beaker = B
		if(user.type == /mob/living/silicon/robot)
			var/mob/living/silicon/robot/R = user
			R.uneq_active()
			targetMoveKey =  R.on_moved.Add(src, "user_moved")

		to_chat(user, "<span class='notice'>You add \the [B] into \the [src]!</span>")

		src.updateUsrDialog()
		update_icon()
		return 1

obj/machinery/chem_heater/proc/user_moved(var/list/args)
	var/event/E = args["event"]
	if(!targetMoveKey)
		E.handlers.Remove("\ref[src]:user_moved")
		return

	var/turf/T = args["loc"]

	if(!Adjacent(T))
		if(E.holder)
			var/atom/movable/holder = E.holder
			holder.on_moved.Remove(targetMoveKey)
		eject_beaker()


/obj/machinery/chem_heater/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	/*Chemical Heater
		If(!beaker)
			No container detected.
			return
		Status: Heating/Standby
			if Heating
				Show beaker temperature/Target Temperature

		[Beaker name]
		[Beaker contents]
		[Eject]
	*/
	if(stat & (BROKEN|NOPOWER))
		return
	if((user.stat && !isobserver(user)) || user.restrained())
		return
	if(!chemical_reagents_list || !chemical_reagents_list.len)
		return
	// this is the data which will be sent to the ui
	var/data = list()
	data["targetTemp"] = target_temperature
	data["isActive"] = on
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerName"] = beaker ? beaker.name : null
	data["currentTemp"] = beaker ? beaker.reagents.chem_temp : null
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null

	var/beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	user.machine = src
	var/dat = ""
	if(!data["isBeakerLoaded"])
		dat = {"Please insert a container.<BR><A href='?src=\ref[src];close=1'>Close</A>"}
	else
		dat += "<B>Status: [data["isActive"] ? "heating" : "standby"]</B><BR>"
		if(data["isActive"])
			dat += "Temperature: [data["currentTemp"]]\\[data["targetTemp"]] K<BR>"
		dat += "<A href='?src=\ref[src];power=1'>Toggle status</A><BR>"
		dat += "<A href='?src=\ref[src];temperature=1'>Toggle target temperature: [data["targetTemp"]]K</A><BR>"
		dat += "<BR><B><HR>Currently loaded container: [data["beakerName"]]</HR></B><BR>"

		dat += "Current Volume: [data["beakerCurrentVolume"]]//[data["beakerMaxVolume"]]<BR>"
		if(beaker.reagents.total_volume && beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				dat += "[R.volume] units of [R.name]<BR>"
		dat += "<A href='?src=\ref[src];eject=1'>Eject [data["beakerName"]]</A><BR>"

	user << browse("<TITLE>Chemical Heater</TITLE>[dat]</ul>", "window=heater;size=575x400")
	onclose(user, "heater")
	return


/obj/machinery/chem_heater/Topic(href, href_list)
	if(..())
		return


	if(stat & (NOPOWER|BROKEN))
		return 0 // don't update UIs attached to this object
	if(href_list["power"])
		on = !on
	if(href_list["temperature"])
		var/num = input("Enter desired output amount", "Amount", useramount) as num|null
		if(num)
			target_temperature = Clamp(num, 0, 1000)
	if(href_list["eject"])
		on = FALSE
		eject_beaker()

	add_fingerprint(usr)
	ui_interact(usr)

/obj/machinery/chem_heater/kick_act(mob/living/H)
	..()
	if(beaker)
		eject_beaker()

/obj/machinery/chem_heater/proc/eject_beaker()
	targetMoveKey=null

	if(beaker)
		var/obj/item/weapon/reagent_containers/B = beaker
		B.forceMove(loc)
		if(istype(beaker, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
			var/obj/item/weapon/reagent_containers/glass/beaker/large/cyborg/borgbeak = beaker
			borgbeak.return_to_modules()
		beaker = null
		return 1


/obj/machinery/chem_heater/attack_ai(mob/user)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/chem_heater/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/chem_heater/attack_hand(mob/user)
	if(stat & BROKEN)
		return

	ui_interact(user)