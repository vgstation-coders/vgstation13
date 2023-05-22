/obj/machinery/media/transmitter/broadcast
	name = "Radio Transmitter"
	desc = "A huge hulk of steel containing high-powered phase-modulating radio transmitting equipment."

	icon = 'icons/obj/machines/broadcast.dmi'
	icon_state = "broadcaster"
	light_color = LIGHT_COLOR_BLUE
	use_power = MACHINE_POWER_USE_NONE // We use power_connection for this.
	density = 1
	anchored = 1 // May need map updates idfk
	idle_power_usage = 50
	active_power_usage = 1000

	var/on=0
	var/integrity=100
	var/list/obj/machinery/media/sources=list()
	var/heating_power=40000
	var/list/autolink = null

	var/datum/wires/transmitter/wires = null
	var/datum/power_connection/consumer/cable/power_connection = null

	var/const/RADS_PER_TICK=75
	var/const/MAX_TEMP=70 // Celsius
	machine_flags = MULTITOOL_MENU | SCREWTOGGLE | WRENCHMOVE | FIXED2WORK

/obj/machinery/media/transmitter/broadcast/New()
	..()
	wires = new(src)
	power_connection = new(src)
	power_connection.idle_usage=idle_power_usage
	power_connection.active_usage=active_power_usage
	power_connection.monitoring_enabled = TRUE

/obj/machinery/media/transmitter/broadcast/Destroy()
	if(wires)
		QDEL_NULL(wires)
	if(power_connection)
		QDEL_NULL(power_connection)
	. = ..()

/obj/machinery/media/transmitter/broadcast/proc/cable_power_change(var/list/args)
	if(power_connection.powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

	update_icon()

/obj/machinery/media/transmitter/broadcast/initialize()
	//testing("[type]/initialize() called!")
	if(autolink && autolink.len)
		for(var/obj/machinery/media/source in orange(20, src))
			if(source.id_tag in autolink)
				sources.Add(source)
				//testing("Autolinked [source] -> [src]")
		hook_media_sources()
	if(on)
		update_on()
	power_connection.connect()
	update_icon()

/obj/machinery/media/transmitter/broadcast/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	if(anchored) // We are now anchored
		power_connection.connect() // Connect to the powernet
	else // We are now NOT anchored
		power_connection.disconnect() // Ditch powernet.
		on=0
		update_on()

/obj/machinery/media/transmitter/broadcast/proc/hook_media_sources()
	if(!sources.len)
		return

	for(var/obj/machinery/media/source in sources)
		// Hook into output
		source.hookMediaOutput(src,exclusive=1) // Don't hook into the room media sources.
		source.update_music() // Request music update

/obj/machinery/media/transmitter/broadcast/proc/unhook_media_sources()
	if(!sources.len)
		return

	for(var/obj/machinery/media/source in sources)
		source.unhookMediaOutput(src)

	broadcast() // Bzzt

/obj/machinery/media/transmitter/broadcast/attackby(var/obj/item/W, mob/user)
	. = ..()
	if(panel_open && iswiretool(W))
		attack_hand(user)
	if(issolder(W))
		if(integrity>=100)
			to_chat(user, "<span class='warning'>[src] doesn't need to be repaired!</span>")
			return
		var/obj/item/tool/solder/S = W
		if(!S.remove_fuel(4,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		if(do_after(user, src,4 SECONDS * S.work_speed))
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
			integrity = 100
			to_chat(user, "<span class='notice'>You repair the blown fuses on [src].</span>")

/obj/machinery/media/transmitter/broadcast/attack_hand(var/mob/user as mob)
	if(panel_open)
		wires.Interact(user)
	. = ..()
	if(.)
		return .

/obj/machinery/media/transmitter/broadcast/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	// You need a multitool to use this, or be silicon
	if(!issilicon(user))
		// istype returns false if the value is null
		if(!istype(user.get_active_hand(), /obj/item/device/multitool))
			return

	if(stat & (FORCEDISABLE|BROKEN|NOPOWER))
		return

	var/screen = {"
	<h2>Settings</h2>
	<ul>
		<li><b>Power:</b> <a href="?src=\ref[src];power=1">[on?"On":"Off"]</a></li>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(media_frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[initial(media_frequency)]">Reset</a>)</li>
	</ul>
	<h2>Media Sources</h2>"}
	if(!sources.len)
		screen += "<em>No media sources have been selected.</em>"
	else
		screen += "<ol>"
		for(var/i=1;i<=sources.len;i++)
			var/obj/machinery/media/source=sources[i]
			screen += "<li>\ref[source] [source.name] ([source.id_tag])  <a href='?src=\ref[src];unlink=[i]'>\[X\]</a></li>"
		screen += "</ol>"
	return screen


/obj/machinery/media/transmitter/broadcast/emp_act(severity)
	if(stat & (FORCEDISABLE|BROKEN|NOPOWER))
		..(severity)
		return
	cable_power_change()
	..(severity)

/obj/machinery/media/transmitter/broadcast/proc/lose_integrity(var/damage)
	integrity = max(0, integrity - damage)
	update_icon()

/obj/machinery/media/transmitter/broadcast/emp_act(severity)
	switch(severity)
		if (1)
			lose_integrity(75)
		if (2)
			lose_integrity(50)
	..()

/obj/machinery/media/transmitter/broadcast/ex_act(severity)
	switch(severity)
		if (1)
			if (prob(75))
				qdel(src)
			else
				lose_integrity(100)
		if (2)
			lose_integrity(80)
		if (3)
			lose_integrity(40)

/obj/machinery/media/transmitter/broadcast/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		lose_integrity(Proj.get_damage())

/obj/machinery/media/transmitter/broadcast/examine(mob/user)
	..()
	if (integrity <= 75)
		to_chat(user,"<span class='warning'>The [src] appears damaged. A solder can be used to repair it.</span>")

/obj/machinery/media/transmitter/broadcast/update_icon()
	overlays = 0
	switch(integrity)
		if (0 to 25)
			icon_state = "broadcaster damaged3"
		if (25 to 50)
			icon_state = "broadcaster damaged2"
		if (50 to 75)
			icon_state = "broadcaster damaged1"
		if (75 to 100)
			icon_state = "broadcaster"
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE) || wires.IsIndexCut(TRANS_POWER))
		return
	if(on)
		overlays += image(icon = icon, icon_state = "broadcaster on")
		set_light(3) // OH FUUUUCK
		power_connection.use_power = MACHINE_POWER_USE_ACTIVE
	else
		set_light(1) // Only the tile we're on.
		power_connection.use_power = MACHINE_POWER_USE_IDLE
	if(sources.len)
		overlays += image(icon = icon, icon_state = "broadcaster linked")

/obj/machinery/media/transmitter/broadcast/proc/update_on()
	if(on)
		visible_message("\The [src] hums as it begins pumping energy into the air!")
		connect_frequency()
		hook_media_sources()
	else
		visible_message("\The [src] falls quiet and makes a soft ticking noise as it cools down.")
		unhook_media_sources()
		disconnect_frequency()
	update_icon()

/obj/machinery/media/transmitter/broadcast/Topic(href,href_list)
	if(..(href, href_list))
		return

	if("power" in href_list)
		if(!power_connection.powernet)
			power_connection.connect()
		if(!power_connection.powered())
			to_chat(usr, "<span class='warning'>This machine needs to be hooked up to a powered cable.</span>")
			return
		on = !on
		update_on()
		return
	if("set_freq" in href_list)
		var/newfreq=media_frequency
		if(href_list["set_freq"]!="-1")
			newfreq = text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Set a new frequency (MHz, 90.0, 200.0).", src, media_frequency) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(newfreq > 900 && newfreq < 2000) // Between (90.0 and 100.0)
				disconnect_frequency()
				media_frequency = newfreq
				connect_frequency()
			else
				to_chat(usr, "<span class='warning'>Invalid FM frequency. (90.0, 200.0)</span>")

/obj/machinery/media/transmitter/broadcast/proc/count_rad_wires()
	return !wires.IsIndexCut(TRANS_RAD_ONE) + !wires.IsIndexCut(TRANS_RAD_TWO)

/obj/machinery/media/transmitter/broadcast/process()
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN) || wires.IsIndexCut(TRANS_POWER))
		return
	if(on && anchored)
		if(integrity<=0 || count_rad_wires()==0 || power_connection.get_satisfaction() < 1.0) //Shut down if too damaged, no rad wires or not properly powered
			on=0
			update_on()

		// Radiation
		emitted_harvestable_radiation(get_turf(src), 50, range = 10)	//Transmitters apply 51 rad doses to nearby humans so we're using that.
		for(var/mob/living/carbon/M in view(src,3))
			var/rads = RADS_PER_TICK * sqrt( 1 / (get_dist(M, src) + 1) ) //Distance/rads: 1 = 27, 2 = 21, 3 = 19
			M.apply_radiation(round(rads*count_rad_wires()/2),RAD_EXTERNAL)

		// Heat output
		var/datum/gas_mixture/env = loc?.return_air()
		if(istype(env) && heating_power)
			if(env.temperature != MAX_TEMP + T0C)
				var/energy_to_add

				if(env.temperature < MAX_TEMP + T0C)
					energy_to_add = min(heating_power, env.get_thermal_energy_change(1000)) //Added min() check to try and avoid wacky superheating issues in low gas scenarios -- TLE
				else
					energy_to_add = -heating_power //add_thermal_energy() automatically prevents the temperature from falling below TCMB, so a similar check here is unnecessary.

				env.add_thermal_energy(energy_to_add)

	// Checks heat from the environment and applies any integrity damage
	var/datum/gas_mixture/environment = loc.return_air()
	if(environment.temperature > (T20C + 20))
		lose_integrity(1)

/obj/machinery/media/transmitter/broadcast/linkWith(var/mob/user, var/obj/O, var/list/context)
	if(istype(O,/obj/machinery/media) && !is_type_in_list(O,list(/obj/machinery/media/transmitter,/obj/machinery/media/receiver)))
		if(sources.len)
			unhook_media_sources()
		sources.Add(O)
		hook_media_sources()
		update_icon()
		return 1
	return 0

/obj/machinery/media/transmitter/broadcast/unlinkFrom(var/mob/user, var/obj/O)
	if(O in sources)
		unhook_media_sources()
		sources.Remove(O)
		if(sources.len)
			hook_media_sources()
		update_icon()
	return 0

/obj/machinery/media/transmitter/broadcast/canLink(var/obj/O, var/list/context)
	return istype(O,/obj/machinery/media) && !is_type_in_list(O,list(/obj/machinery/media/transmitter,/obj/machinery/media/receiver))

/obj/machinery/media/transmitter/broadcast/isLinkedWith(var/obj/O)
	return O in sources

/obj/machinery/media/transmitter/broadcast/npc_tamper_act(mob/living/L)
	if(!panel_open)
		togglePanelOpen(null, L)
	if(wires)
		wires.npc_tamper(L)

/obj/machinery/media/transmitter/broadcast/dj
	id_tag = "dj"
	media_frequency=1015
	autolink = list("DJ Satellite")
	on=1

// Centcomm Shuttle Radio
/obj/machinery/media/transmitter/broadcast/shuttle
	id_tag = "shuttle"
	media_frequency=953
	autolink = list("Shuttle")
	on=1
