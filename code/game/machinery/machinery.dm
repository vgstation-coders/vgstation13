//multitool programming whitelist
var/global/list/multitool_var_whitelist = list(	"id_tag",
													"master_tag",
													"command",
													"input_tag",
													"output_tag",
													"tag_airpump",
													"tag_exterior_door",
													"tag_interior_door",
													"tag_chamber_sensor",
													"tag_interior_sensor",
													"tag_exterior_sensor",
													"smelter_tag",
													"stacker_tag"
													)

/*
Overview:
   Used to create objects that need a per step proc call.  Default definition of 'New()'
   stores a reference to src machine in global 'machines list'.  Default definition
   of 'Del' removes reference to src machine in global 'machines list'.

Class Variables:
   use_power (num)
      current state of auto power use.
      Possible Values:
         0 -- no auto power use
         1 -- machine is using power at its idle power level
         2 -- machine is using power at its active power level

   active_power_usage (num)
      Value for the amount of power to use when in active power mode

   idle_power_usage (num)
      Value for the amount of power to use when in idle power mode

   power_channel (num)
      What channel to draw from when drawing power for power mode
      Possible Values:
         EQUIP:0 -- Equipment Channel
         LIGHT:2 -- Lighting Channel
         ENVIRON:3 -- Environment Channel

   component_parts (list)
      A list of component parts of machine used by frame based machines.

   uid (num)
      Unique id of machine across all machines.

   gl_uid (global num)
      Next uid value in sequence

   stat (bitflag)
      Machine status bit flags.
      Possible bit flags:
         BROKEN:1 -- Machine is broken
         NOPOWER:2 -- No power is being supplied to machine.
         POWEROFF:4 -- tbd
         MAINT:8 -- machine is currently under going maintenance.
         EMPED:16 -- temporary broken by EMP pulse

   manual (num)
      Currently unused.

Class Procs:
   New()                     'game/machinery/machine.dm'

   Destroy()                     'game/machinery/machine.dm'

   auto_use_power()            'game/machinery/machine.dm'
      This proc determines how power mode power is deducted by the machine.
      'auto_use_power()' is called by the 'master_controller' game_controller every
      tick.

      Return Value:
         return:1 -- if object is powered
         return:0 -- if object is not powered.

      Default definition uses 'use_power', 'power_channel', 'active_power_usage',
      'idle_power_usage', 'powered()', and 'use_power()' implement behavior.

   powered(chan = EQUIP)         'modules/power/power.dm'
      Checks to see if area that contains the object has power available for power
      channel given in 'chan'.

   use_power(amount, chan=EQUIP)   'modules/power/power.dm'
      Deducts 'amount' from the power channel 'chan' of the area that contains the object.

   power_change()               'modules/power/power.dm'
      Called by the area that contains the object when ever that area under goes a
      power state change (area runs out of power, or area channel is turned off).

   RefreshParts()               'game/machinery/machine.dm'
      Called to refresh the variables in the machine that are contributed to by parts
      contained in the component_parts list. (example: glass and material amounts for
      the autolathe)

      Default definition does nothing.

   assign_uid()               'game/machinery/machine.dm'
      Called by machine to assign a value to the uid variable.

   process()                  'game/machinery/machine.dm'
      Called by the 'master_controller' once per game tick for each machine that is listed in the 'machines' list.


	Compiled by Aygar
*/

//The machine flags can be found in setup.dm

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	var/icon_state_open = ""

	w_type = NOT_RECYCLABLE

	penetration_dampening = 5

	var/stat = 0
	var/emagged = 0
	var/use_power = 1
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = EQUIP // EQUIP, ENVIRON or LIGHT.
	var/list/component_parts // List of all the parts used to build it, if made from certain kinds of frames.
	var/uid
	var/manual = 0
	var/global/gl_uid = 1
	var/custom_aghost_alerts=0
	var/panel_open = 0
	var/state = 0 //0 is unanchored, 1 is anchored and unwelded, 2 is anchored and welded for most things

	//These are some values to automatically set the light power/range on machines if they have power
	var/light_range_on = 0
	var/light_power_on = 0
	var/use_auto_lights = 0//Incase you want to use it, set this to 0, defaulting to 1 so machinery with no lights doesn't call set_light()

	/**
	 * Machine construction/destruction/emag flags.
	 */
	var/machine_flags = 0

	/**
	 * Emag energy cost (in MJ).
	 */
	var/emag_cost = 1

	var/inMachineList = 1 // For debugging.
	var/obj/item/weapon/card/id/scan = null	//ID inserted for identification, if applicable

/obj/machinery/cultify()
	var/list/random_structure = list(
		/obj/structure/cult/talisman,
		/obj/structure/cult/forge,
		/obj/structure/cult/tome
		)
	var/I = pick(random_structure)
	new I(loc)
	..()

/obj/machinery/New()
	machines += src
	//if(ticker) initialize()
	return ..()

/obj/machinery/initialize()
	if(machine_flags & PURCHASER)
		reconnect_database()
		linked_account = vendor_account

/obj/machinery/examine(mob/user)
	..()
	if(panel_open)
		to_chat(user, "<span class='info'>Its maintenance panel is open.</span>")

/obj/machinery/Destroy()

	machines.Remove(src)

	power_machines.Remove(src)

	atmos_machines.Remove(src)

	fast_machines.Remove(src)
/*
	if(component_parts)
		for(var/atom/movable/AM in component_parts)
			AM.forceMove(loc)
			component_parts -= AM
*/
	component_parts = null

	..()

/obj/machinery/projectile_check()
	return PROJREACT_OBJS

/obj/machinery/process() // If you dont use process or power why are you here
	set waitfor = FALSE
	return PROCESS_KILL

/obj/machinery/emp_act(severity)
	if(use_power && stat == 0)
		use_power(7500/severity)

		var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( src.loc )
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)

		spawn(10)
			qdel(pulse2)
	..()

/obj/machinery/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				qdel(src)
				return
		else
	return

/obj/machinery/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		return 0

	switch (use_power)
		if (1)
			use_power(idle_power_usage, power_channel)
		if (2)
			use_power(active_power_usage, power_channel)

	return 1

/obj/machinery/proc/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	if("set_id" in href_list)
		if(!("id_tag" in vars))
			warning("set_id: [type] has no id_tag var.")
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, src:id_tag) as null|text),1,MAX_MESSAGE_LEN)
		if(newid)
			src:id_tag = newid
			return MT_UPDATE|MT_REINIT
	if("set_freq" in href_list)
		if(!("frequency" in vars))
			warning("set_freq: [type] has no frequency var.")
			return 0
		var/newfreq=src:frequency
		if(href_list["set_freq"]!="-1")
			newfreq=text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Specify a new frequency (GHz). Decimals assigned automatically.", src, src:frequency) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(newfreq < 10000)
				src:frequency = newfreq
				return MT_UPDATE|MT_REINIT
	return 0

/obj/machinery/proc/handle_multitool_topic(var/href, var/list/href_list, var/mob/user)
	var/obj/item/device/multitool/P = get_multitool(usr)
	if(P && istype(P))
		var/update_mt_menu=0
		var/re_init=0
		if("set_tag" in href_list)
			if(!(href_list["set_tag"] in multitool_var_whitelist))
				var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag", src) as null|text),1,MAX_MESSAGE_LEN)
				log_admin("[usr] ([formatPlayerPanel(usr,usr.ckey)]) attempted to modify variable(var = [href_list["set_tag"]], value = [newid]) using multitool - [formatJumpTo(usr)]")
				message_admins("[usr] ([formatPlayerPanel(usr,usr.ckey)]) attempted to modify variable(var = [href_list["set_tag"]], value = [newid]) using multitool - [formatJumpTo(usr)]")
				return
			if(!(href_list["set_tag"] in vars))
				to_chat(usr, "<span class='warning'>Something went wrong: Unable to find [href_list["set_tag"]] in vars!</span>")
				return 1
			var/current_tag = src.vars[href_list["set_tag"]]
			var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag", src, current_tag) as null|text),1,MAX_MESSAGE_LEN)
			if(newid)
				vars[href_list["set_tag"]] = newid
				re_init=1
			update_mt_menu = 1

		if("unlink" in href_list)
			var/idx = text2num(href_list["unlink"])
			if (!idx)
				return 1

			var/obj/O = getLink(idx)
			if(!O)
				return 1

			if(unlinkFrom(usr, O))
				to_chat(usr, "<span class='confirm'>A green light flashes on \the [P], confirming the link was removed.</span>")
			else
				to_chat(usr, "<span class='attack'>A red light flashes on \the [P].  It appears something went wrong when unlinking the two devices.</span>")
			update_mt_menu=1

		if("link" in href_list)
			var/obj/O = P.buffer
			if(!O)
				return 1
			if(!canLink(O,href_list))
				to_chat(usr, "<span class='warning'>You can't link with that device.</span>")
				return 1
			if (isLinkedWith(O))
				to_chat(usr, "<span class='attack'>A red light flashes on \the [P]. The two devices are already linked.</span>")
				return 1

			if(linkWith(usr, O, href_list))
				to_chat(usr, "<span class='confirm'>A green light flashes on \the [P], confirming the link has been created.</span>")
			else
				to_chat(usr, "<span class='attack'>A red light flashes on \the [P].  It appears something went wrong when linking the two devices.</span>")
			update_mt_menu=1

		if("buffer" in href_list)
			if(istype(src, /obj/machinery/telecomms))
				if(!hasvar(src, "id"))
					to_chat(usr, "<span class='danger'>A red light flashes and nothing changes.</span>")
					return
			else if(!hasvar(src, "id_tag"))
				to_chat(usr, "<span class='danger'>A red light flashes and nothing changes.</span>")
				return
			P.buffer = src
			to_chat(usr, "<span class='confirm'>A green light flashes, and the device appears in the multitool buffer.</span>")
			update_mt_menu=1

		if("flush" in href_list)
			to_chat(usr, "<span class='confirm'>A green light flashes, and the device disappears from the multitool buffer.</span>")
			P.buffer = null
			update_mt_menu=1

		var/ret = multitool_topic(usr,href_list,P.buffer)
		if(ret == MT_ERROR)
			return 1
		if(ret & MT_UPDATE)
			update_mt_menu=1
		if(ret & MT_REINIT)
			re_init=1

		if(re_init)
			initialize()
		if(update_mt_menu)
			//usr.set_machine(src)
			update_multitool_menu(usr)
			return 1

/obj/machinery/Topic(href, href_list)
	..()
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(href_list["close"])
		return
	var/ghost_flags=0
	if(ghost_write)
		ghost_flags |= PERMIT_ALL
	if(!canGhostWrite(usr,src,"",ghost_flags))
		if(usr.restrained() || usr.lying || usr.stat)
			return 1
		if (!usr.dexterity_check())
			to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return 1
		var/turf/T = get_turf(usr)
		if(!isAI(usr) && T.z != z)
			if(usr.z != map.zCentcomm)
				to_chat(usr, "<span class='warning'>WARNING: Unable to interface with \the [src.name].</span>")
				return 1
		if ((!in_range(src, usr) || !istype(src.loc, /turf)) && !istype(usr, /mob/living/silicon))
			return 1
	else if(!custom_aghost_alerts)
		log_adminghost("[key_name(usr)] screwed with [src] ([href])!")

	src.add_fingerprint(usr)
	src.add_hiddenprint(usr)

	return handle_multitool_topic(href,href_list,usr)

/obj/machinery/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	if(isrobot(user))
		// For some reason attack_robot doesn't work
		// This is to stop robots from using cameras to remotely control machines.
		if(user.client && user.client.eye == user)
			return src.attack_hand(user)
	else
		return src.attack_hand(user)

/obj/machinery/attack_ghost(mob/user as mob)
	src.add_hiddenprint(user)
	var/ghost_flags=0
	if(ghost_read)
		ghost_flags |= PERMIT_ALL
	if(canGhostRead(usr,src,ghost_flags))
		return src.attack_ai(user)

/obj/machinery/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/attack_hand(mob/user as mob, var/ignore_brain_damage = 0)
	if(stat & (NOPOWER|BROKEN|MAINT))
		return 1

	if(user.lying || (user.stat && !canGhostRead(user))) // Ghost read-only
		return 1

	if(istype(user,/mob/dead/observer))
		return 0

	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1
/*
	//distance checks are made by atom/proc/DblClick
	if ((get_dist(src, user) > 1 || !istype(src.loc, /turf)) && !istype(user, /mob/living/silicon))
		return 1
*/
	if (ishuman(user) && !ignore_brain_damage)
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			visible_message("<span class='warning'>[H] stares cluelessly at [src] and drools.</span>")
			return 1
		else if(prob(H.getBrainLoss()) || (H.undergoing_hypothermia() == MODERATE_HYPOTHERMIA && prob(25)))
			to_chat(user, "<span class='warning'>You momentarily forget how to use [src].</span>")
			return 1

	src.add_fingerprint(user)
	return 0

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/proc/dropFrame()
	var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
	M.set_build_state(2)
	M.state = 1

/obj/machinery/proc/spillContents(var/destroy_chance = 0)
	for(var/obj/I in component_parts)
		if(prob(destroy_chance))
			qdel(I)
		else
			if(istype(I, /obj/item/weapon/reagent_containers/glass/beaker) && src:reagents && src:reagents.total_volume)
				reagents.trans_to(I, reagents.total_volume)
			if(I.reliability != 100 && crit_fail)
				I.crit_fail = 1
			I.forceMove(src.loc)
	for(var/atom/movable/I in src) //remove any stuff loaded, like for fridges
		if(!prob(destroy_chance) && machine_flags &EJECTNOTDEL)
			I.forceMove(src.loc)
		else
			qdel(I)

/obj/machinery/proc/crowbarDestroy(mob/user)
	user.visible_message(	"[user] begins to pry out the circuitboard from \the [src].",
							"You begin to pry out the circuitboard from \the [src]...")
	if(do_after(user, src, 40))
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
		dropFrame()
		spillContents()
		user.visible_message(	"<span class='notice'>[user] successfully pries out the circuitboard from \the [src]!</span>",
								"<span class='notice'>[bicon(src)] You successfully pry out the circuitboard from \the [src]!</span>")
		return 1
	return -1

//just something silly to delete the machine while still leaving something behind
/obj/machinery/proc/smashDestroy(var/destroy_chance = 50)
	getFromPool(/obj/item/stack/sheet/metal, get_turf(src), 2)
	spillContents(destroy_chance)
	qdel(src)

/obj/machinery/proc/togglePanelOpen(var/obj/toggleitem, var/mob/user)
	panel_open = !panel_open
	if(!icon_state_open)
		icon_state_open = icon_state
	if(panel_open)
		icon_state = icon_state_open
	else
		icon_state = initial(icon_state)
	to_chat(user, "<span class='notice'>[bicon(src)] You [panel_open ? "open" : "close"] the maintenance hatch of \the [src].</span>")
	if(isscrewdriver(toggleitem))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
	update_icon()
	return 1

/obj/machinery/proc/toggleSecuredPanelOpen(var/obj/toggleitem, var/mob/user)
	if(!linked_account || panel_open)
		togglePanelOpen(toggleitem, user)
		return 1
	if(!user.Adjacent(src))
		return 0
	var/account_try = input(user,"Please enter the already connected account number to unlock the panel","Security measure") as null|num
	if(!user.Adjacent(src))
		return 0
	if(account_try != linked_account.account_number)
		to_chat(user, "[bicon(src)]<span class='warning'>Access denied. Your input doesn't match the vending machine's connected account. This incident will be reported.</span>")
		return 0
	togglePanelOpen(toggleitem, user)
	return 1

/obj/machinery/proc/weldToFloor(var/obj/item/weapon/weldingtool/WT, mob/user)
	if(!anchored)
		state = 0 //since this might be wrong, we go sanity
		to_chat(user, "You need to secure \the [src] before it can be welded.")
		return -1
	if (WT.remove_fuel(0,user))
		playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
		user.visible_message("[user.name] starts to [state - 1 ? "unweld": "weld" ] the [src] [state - 1 ? "from" : "to"] the floor.", \
				"You start to [state - 1 ? "unweld": "weld" ] the [src] [state - 1 ? "from" : "to"] the floor.", \
				"You hear welding.")
		if (do_after(user, src,20))
			if(!src || !WT.isOn())
				return -1
			switch(state)
				if(0)
					to_chat(user, "You have to keep \the [src] secure before it can be welded down.")
					return -1
				if(1)
					state = 2
				if(2)
					state = 1
			user.visible_message(	"[user.name] [state - 1 ? "weld" : "unweld"]s \the [src] [state - 1 ? "to" : "from"] the floor.",
									"[bicon(src)] You [state - 1 ? "weld" : "unweld"] \the [src] [state - 1 ? "to" : "from"] the floor."
								)
			return 1
	else
		to_chat(user, "<span class='rose'>You need more welding fuel to complete this task.</span>")
		return -1

/**
 * Handle emags.
 * @param user /mob The mob that used the emag.
 */
/obj/machinery/proc/emag(mob/user as mob)
	// Disable emaggability. Note that some machines such as the Communications Computer might be emaggable multiple times.
	machine_flags &= ~EMAGGABLE
	new/obj/effect/effect/sparks(get_turf(src))
	playsound(loc,"sparks",50,1)


/**
 * Returns the cost of emagging this machine (emag_cost by default)
 * @param user /mob The mob that used the emag.
 * @param emag /obj/item/weapon/card/emag The emag used on this device.
 * @return number Cost to emag.
 */
/obj/machinery/proc/getEmagCost(var/mob/user, var/obj/item/weapon/card/emag/emag)
	return emag_cost

/obj/machinery/attackby(var/obj/O, var/mob/user)
	..()
	if(istype(O, /obj/item/weapon/card/emag) && machine_flags & EMAGGABLE)
		var/obj/item/weapon/card/emag/E = O
		if(E.canUse(user,src))
			emag(user)
			return

	if(iswrench(O) && wrenchable()) //make sure this is BEFORE the fixed2work check
		if(!panel_open)
			if(state == 2 && src.machine_flags & WELD_FIXED) //prevent unanchoring welded machinery
				to_chat(user, "\The [src] has to be unwelded from the floor first.")
				return -1 //state set to 2, can't do it
			else
				// wrenchAnchor returns -1 on check failures, for some reason.
				if(wrenchAnchor(user) == 1 && machine_flags & FIXED2WORK) //wrenches/unwrenches into place if possible, then updates the power and state if necessary
					state = anchored
					power_change() //updates us to turn on or off as necessary
					return 1
		else
			to_chat(user, "<span class='warning'>\The [src]'s maintenance panel must be closed first!</span>")
			return -1 //we return -1 rather than 0 for the if(..()) checks

	if(isscrewdriver(O) && machine_flags & SCREWTOGGLE)
		if(machine_flags & SECUREDPANEL)
			return toggleSecuredPanelOpen(O, user)
		return togglePanelOpen(O, user)

	if(iswelder(O) && machine_flags & WELD_FIXED && canAffixHere(user))
		return weldToFloor(O, user)

	if(iscrowbar(O) && machine_flags & CROWDESTROY)
		if(panel_open)
			if(crowbarDestroy(user) == 1)
				qdel(src)
				return 1
			else
				return -1

	if(ismultitool(O) && machine_flags & MULTITOOL_MENU)
		update_multitool_menu(user)
		return 1

	if(!anchored && machine_flags & FIXED2WORK)
		return to_chat(user, "<span class='warning'>\The [src] must be anchored first!</span>")

	if(istype(O, /obj/item/device/paicard) && machine_flags & WIREJACK)
		for(var/mob/M in O)
			wirejack(M)
		return 1

	if(istype(O, /obj/item/weapon/storage/bag/gadgets/part_replacer))
		return exchange_parts(user, O)

/obj/machinery/proc/wirejack(var/mob/living/silicon/pai/P)
	if(!(machine_flags & WIREJACK))
		return 0
	if(!P.hackloop(src))
		return 0
	return 1

/obj/machinery/proc/can_overload(mob/user) //used for AI machine overload
	return(src in machines)

/obj/machinery/proc/shock(mob/user, prb, var/siemenspassed = -1)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!istype(user) || !user.Adjacent(src))
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(siemenspassed == -1) //this means it hasn't been set by proc arguments, so we can set it ourselves safely
		siemenspassed = 0.7
	if (electrocute_mob(user, get_area(src), src, siemenspassed))
		return 1
	else
		return 0

// Hook for html_interface module to prevent updates to clients who don't have this as their active machine.
/obj/machinery/proc/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	if (hclient.client.mob && (hclient.client.mob.stat == 0 || isobserver(hclient.client.mob)))
		if(isAI(hclient.client.mob))
			return 1
		if(hclient.client.mob.machine == src)
			return hclient.client.mob.html_mob_check(src.type)
	return FALSE

// Hook for html_interface module to unset the active machine when the window is closed by the player.
/obj/machinery/proc/hiOnHide(datum/html_interface_client/hclient)
	if (hclient.client.mob && hclient.client.mob.machine == src)
		hclient.client.mob.unset_machine()

/obj/machinery/proc/alert_noise(var/notice_state = "ping")
	switch(notice_state)
		if("ping")
			src.visible_message("<span class='notice'>[bicon(src)] \The [src] pings.</span>")
			playsound(get_turf(src), 'sound/machines/notify.ogg', 50, 0)
		if("beep")
			src.visible_message("<span class='notice'>[bicon(src)] \The [src] beeps.</span>")
			playsound(get_turf(src), 'sound/machines/twobeep.ogg', 50, 0)
		if("buzz")
			src.visible_message("<span class='notice'>[bicon(src)] \The [src] buzzes.</span>")
			playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 50, 0)

/obj/machinery/proc/check_rebuild()
	return

/obj/machinery/wrenchable()
	return (machine_flags & WRENCHMOVE)

/obj/machinery/can_wrench_shuttle()
	return (machine_flags & SHUTTLEWRENCH)

/obj/machinery/proc/exchange_parts(mob/user, obj/item/weapon/storage/bag/gadgets/part_replacer/W)
	var/shouldplaysound = 0
	if(component_parts)
		if(panel_open)
			var/obj/item/weapon/circuitboard/CB = locate(/obj/item/weapon/circuitboard) in component_parts
			var/P
			for(var/obj/item/A in component_parts)
				for(var/D in CB.req_components)
					D = text2path(D) //For some stupid reason these are strings by default.
					if(ispath(A.type, D))
						P = D
						break
				for(var/obj/item/B in W.contents)
					if(istype(B, P) && istype(A, P))
						if(B.get_rating() > A.get_rating())
							W.remove_from_storage(B, src)
							W.handle_item_insertion(A, 1)
							component_parts -= A
							component_parts += B
							B.forceMove(null)
							to_chat(user, "<span class='notice'>[A.name] replaced with [B.name].</span>")
							shouldplaysound = 1 //Only play the sound when parts are actually replaced!
							break
			RefreshParts()
		else
			to_chat(user, "<span class='notice'>Following parts detected in the machine:</span>")
			for(var/var/obj/item/C in component_parts)
				to_chat(user, "<span class='notice'>    [C.name]</span>")
		if(shouldplaysound)
			W.play_rped_sound()
		return 1
	return 0


/obj/machinery/kick_act(mob/living/carbon/human/H)
	playsound(get_turf(src), 'sound/effects/grillehit.ogg', 50, 1) //Zth: I couldn't find a proper sound, please replace it

	H.visible_message("<span class='danger'>[H] kicks \the [src].</span>", "<span class='danger'>You kick \the [src].</span>")
	if(prob(70))
		H.apply_damage(rand(2,4), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))

	if(!anchored && !locked_to) //What could go wrong
		var/strength = H.get_strength()
		var/kick_dir = get_dir(H, src)

		if(!Move(get_step(loc, kick_dir))) //The structure that we kicked is up against a wall - this hurts our foot
			H.apply_damage(rand(2,4), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))

		if(strength > 1) //Strong - kick further
			spawn()
				sleep(3)
				for(var/i = 2 to strength)
					if(!Move(get_step(loc, kick_dir)))
						break
					sleep(3)
	else
		src.shake(1, 3) //1 means x movement, 3 means intensity

	if(scan)
		if(prob(50))
			scan.forceMove(get_turf(src))
			visible_message("<span class='notice'>\A [scan] pops out of \the [src]!</span>")
			scan = null
