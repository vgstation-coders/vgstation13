// the SMES
// stores power

#define SMESMAXCHARGELEVEL 200000
#define SMESMAXOUTPUT 200000
#define SMESRATE 0.05 				// rate of internal charge to external power

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = 1
	anchored = 1
	use_power = 0
	var/output = 50000
	var/lastout = 0
	var/loaddemand = 0
	var/capacity = 5e6
	var/charge = 1e6
	var/charging = 0
	var/chargemode = 0
	var/chargecount = 0
	var/chargelevel = 50000
	var/online = 1
	var/name_tag = null
	var/obj/machinery/power/terminal/terminal = null
	//Holders for powerout event.
	var/last_output = 0
	var/last_charge = 0
	var/last_online = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY

/obj/machinery/power/smes/New()
	. = ..()
	spawn(5)
		dir_loop:
			for(var/d in cardinal)
				var/turf/T = get_step(src, d)
				for(var/obj/machinery/power/terminal/term in T)
					if(term && term.dir == turn(d, 180))
						terminal = term
						break dir_loop
		if(!terminal)
			stat |= BROKEN
			return
		terminal.master = src
		updateicon()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/smes,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/power/smes/proc/make_terminal(const/mob/user)
	if (user.loc == loc)
		user << "<span class='warning'>You must not be on the same tile with SMES.</span>"
		return 1

	var/userdir = get_dir(user, src)

	for(var/dirs in cardinal)	//there shouldn't be any diagonal terminals
		if(userdir == dirs)
			var/turf/T = get_turf(user)
			if(T.intact)
				user << "<span class='warning'>The floor plating must be removed first.</span>"
				return 1

			user << "<span class='notice'>You start adding cable to the SMES.</span>"
			playsound(get_turf(src), 'sound/items/zip.ogg', 100, 1)
			if (do_after(user, 100) && panel_open && !terminal && !T.intact)
				terminal = new /obj/machinery/power/terminal(get_turf(user))
				terminal.dir = dirs
				terminal.master = src
				return 0
			else
				return 1

	user << "<span class='warning'>You can't wire the SMES like that!</span>"
	return 1

/obj/machinery/power/smes/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob) //these can only be moved by being reconstructed, solves having to remake the powernet.
	if(..())
		return 1
	if(panel_open)
		if(istype(W, /obj/item/stack/cable_coil) && !terminal)
			var/obj/item/stack/cable_coil/CC = W

			if (CC.amount < 10)
				user << "<span class=\"warning\">You need 10 length cable coil to make a terminal.</span>"
				return

			if (make_terminal(user))
				return

			CC.use(10)
			user.visible_message(\
				"<span class='warning'>[user.name] has added cables to the SMES!</span>",\
				"You added cables the SMES.")
			terminal.connect_to_network()
			src.stat = 0
		else if(istype(W, /obj/item/weapon/wirecutters) && terminal)
			var/turf/T = get_turf(terminal)
			if(T.intact)
				user << "<span class='warning'>You must remove the floor plating in front of the SMES first.</span>"
				return
			user << "You begin to cut the cables..."
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			if (do_after(user, 50) && panel_open && terminal && !T.intact)
				if (prob(50) && electrocute_mob(usr, terminal.get_powernet(), terminal))
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(5, 1, src)
					s.start()
					return
				getFromPool(/obj/item/stack/cable_coil, get_turf(src), 10)
				user.visible_message(\
					"<span class='warning'>[user.name] cut the cables and dismantled the power terminal.</span>",\
					"You cut the cables and dismantle the power terminal.")
				del(terminal)
		else
			user.set_machine(src)
			interact(user)
			return 1
	return

/obj/machinery/power/smes/proc/updateicon()
	overlays.len = 0
	if(stat & BROKEN)	return

	overlays += image('icons/obj/power.dmi', "smes-op[online]")

	if(charging)
		overlays += image('icons/obj/power.dmi', "smes-oc1")
	else
		if(chargemode)
			overlays += image('icons/obj/power.dmi', "smes-oc0")

	var/clevel = chargedisplay()
	if(clevel>0)
		overlays += image('icons/obj/power.dmi', "smes-og[clevel]")
	return


/obj/machinery/power/smes/proc/chargedisplay()
	return round(5.5*charge/(capacity ? capacity : 5e6))

/obj/machinery/power/smes/process()
	if (stat & BROKEN)
		return

	var/_charging = charging
	var/_online = online

	// Input
	if (terminal)
		var/excess = terminal.surplus()

		if (charging)
			if (excess >= 0) // If there's power available, try to charge
				var/load = min((capacity - charge) / SMESRATE, chargelevel) // Charge at set rate, limited to spare capacity

				charge += load * SMESRATE // Increase the charge

				add_load(load) // Add the load to the terminal side network
			else
				charging = FALSE
				chargecount = 0
		else
			if (chargemode)
				if (chargecount > rand(3, 6))
					charging = TRUE
					chargecount = 0

				if (excess > chargelevel)
					chargecount++
				else
					chargecount = 0
			else
				chargecount = 0
	else
		charging = FALSE
		chargecount = 0

	// Output
	if (online)
		lastout = min(charge / SMESRATE, output) // Limit output to that stored

		charge -= lastout * SMESRATE // Reduce the storage (may be recovered in /restore() if excessive)

		add_avail(lastout) // Add output to powernet (smes side)

		if (charge < 0.0001)
			online = FALSE

	// Only update icon if state changed
	if(_charging != charging || _online != online)
		updateicon()

/*
 * Called after all power processes are finished
 * Restores charge level to smes if there was excess this ptick
 */
/obj/machinery/power/smes/proc/restore()
	if (stat & BROKEN)
		return

	var/excess = powernet.netexcess // This was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(lastout, excess) // Clamp it to how much was actually output by this SMES last ptick

	excess = min((capacity - charge) / SMESRATE, excess) // For safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// Now recharge this amount

	var/_chargedisplay = chargedisplay()

	charge += excess * SMESRATE // Restore unused power

	powernet.netexcess -= excess // Remove the excess from the powernet, so later SMESes don't try to use it

	loaddemand = lastout - excess

	if(_chargedisplay != chargedisplay()) // If needed updates the icons overlay
		updateicon()

/obj/machinery/power/smes/add_load(var/amount)
	if(terminal && terminal.get_powernet())
		terminal.powernet.load += amount

/obj/machinery/power/smes/attack_ai(mob/user)
	src.add_hiddenprint(user)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/power/smes/attack_hand(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/power/smes/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)

	if(stat & BROKEN)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["nameTag"] = name_tag
	data["storedCapacity"] = round(100.0*charge/capacity, 0.1)
	data["charging"] = charging
	data["chargeMode"] = chargemode
	data["chargeLevel"] = chargelevel
	data["chargeMax"] = SMESMAXCHARGELEVEL
	data["outputOnline"] = online
	data["outputLevel"] = output
	data["outputMax"] = SMESMAXOUTPUT
	data["outputLoad"] = round(loaddemand)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "smes.tmpl", "SMES Power Storage Unit", 540, 380)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/smes/Topic(href, href_list)
	if(!isAI(usr) && usr.z != z) return 1
	..()
	if(href_list["close"])
		if(usr.machine == src) usr.unset_machine()
		return 1
	if (usr.stat || usr.restrained() )
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		if(!istype(usr, /mob/living/silicon/ai))
			usr << "<span class='warning'>You don't have the dexterity to do this!</span>"
			return

//world << "[href] ; [href_list[href]]"

	if (!isturf(src.loc) && !istype(usr, /mob/living/silicon/))
		return 0 // Do not update ui

	if( href_list["cmode"] )
		chargemode = !chargemode
		if(!chargemode)
			charging = 0
		updateicon()

	else if( href_list["online"] )
		online = !online
		updateicon()
	else if( href_list["input"] )
		switch( href_list["input"] )
			if("min")
				chargelevel = 0
			if("max")
				chargelevel = SMESMAXCHARGELEVEL		//30000
			if("set")
				chargelevel = input(usr, "Enter new input level (0-[SMESMAXCHARGELEVEL])", "SMES Input Power Control", chargelevel) as num
		chargelevel = max(0, min(SMESMAXCHARGELEVEL, chargelevel))	// clamp to range

	else if( href_list["output"] )
		switch( href_list["output"] )
			if("min")
				output = 0
			if("max")
				output = SMESMAXOUTPUT		//30000
			if("set")
				output = input(usr, "Enter new output level (0-[SMESMAXOUTPUT])", "SMES Output Power Control", output) as num
		output = max(0, min(SMESMAXOUTPUT, output))	// clamp to range

	investigation_log(I_SINGULO,"input/output; [chargelevel>output?"<font color='green'>":"<font color='red'>"][chargelevel]/[output]</font> | Output-mode: [online?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [chargemode?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [usr.key]")

	return 1

/obj/machinery/power/smes/proc/ion_act()
	if(src.z == 1)
		if(prob(1)) //explosion
			world << "<span class='warning'>SMES explosion in [src.loc.loc]</span>"
			for(var/mob/M in viewers(src))
				M.show_message("<span class='warning'>The [src.name] is making strange noises!</span>", 3, "<span class='warning'>You hear sizzling electronics.</span>", 2)
			sleep(10*pick(4,5,6,7,10,14))
			var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()
			explosion(src.loc, -1, 0, 1, 3, 0)
			del(src)
			return
		if(prob(15)) //Power drain
			world << "<span class='warning'>SMES power drain in [src.loc.loc]</span>"
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			if(prob(50))
				emp_act(1)
			else
				emp_act(2)
		if(prob(5)) //smoke only
			world << "<span class='warning'>SMES smoke in [src.loc.loc]</span>"
			var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()


/obj/machinery/power/smes/emp_act(severity)
	online = 0
	charging = 0
	output = 0
	charge -= 1e6/severity
	if (charge < 0)
		charge = 0
	spawn(100)
		output = initial(output)
		charging = initial(charging)
		online = initial(online)
	..()



/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."

	mech_flags = MECH_SCAN_FAIL

/obj/machinery/power/smes/magical/process()
	// Is this really needed?
	capacity = INFINITY
	charge = INFINITY
	..()

/proc/rate_control(var/S, var/V, var/C, var/Min=1, var/Max=5, var/Limit=null)
	var/href = "<A href='?src=\ref[S];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C?C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if(Limit) return "[href]=-[Limit]'>-</A>"+rate+"[href]=[Limit]'>+</A>"
	return rate

/obj/machinery/power/smes/Destroy()
	if (terminal)
		terminal.master = null
		terminal = null

	..()

#undef SMESRATE
