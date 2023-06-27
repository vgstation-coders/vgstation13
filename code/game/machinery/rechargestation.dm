/obj/machinery/recharge_station
	name = "cyborg recharging station"
	desc = "A large metallic machine for charging cyborgs."
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 1
	anchored = 1.0
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 5
	active_power_usage = 1000
	var/mob/living/occupant = null
	var/list/acceptable_upgradeables = list(/obj/item/weapon/cell) // battery for now
	var/list/upgrade_holder = list()
	var/obj/upgrading = 0 // are we upgrading a nigga?
	var/upgrade_finished = -1 // time the upgrade should finish
	var/manipulator_coeff = 1 // better manipulator swaps parts faster
	var/transfer_rate_coeff = 1 // transfer rate bonuses
	var/capacitor_stored = 0 //power stored in capacitors, to be instantly transferred to robots when they enter the charger
	var/capacitor_max = 0 //combined max power the capacitors can hold
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | EJECTNOTDEL

	hack_abilities = list(
		/datum/malfhack_ability/oneuse/make_autoborger,
		/datum/malfhack_ability/oneuse/overload_quiet,
	)

	var/autoborger = FALSE
	var/make_mommis = FALSE
	var/is_borging = FALSE
	var/mob/living/silicon/ai/aiowner

/obj/machinery/recharge_station/New()
	. = ..()
	build_icon()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/recharge_station,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin
	)

	RefreshParts()

/obj/machinery/recharge_station/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating-1
	manipulator_coeff = initial(manipulator_coeff)+(T)
	T = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating-1
	transfer_rate_coeff = initial(transfer_rate_coeff)+(T * 0.2)
	capacitor_max = initial(capacitor_max)+(T * 750)
	active_power_usage = 1000 * transfer_rate_coeff

/obj/machinery/recharge_station/Destroy()
	src.go_out()
	..()

/obj/machinery/recharge_station/is_airtight()
	return occupant

/obj/machinery/recharge_station/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				new /obj/item/weapon/circuitboard/recharge_station(src.loc)
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				src.anchored = 0
				src.build_icon()
		else
	return

/obj/machinery/recharge_station/process()
	process_upgrade()
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE) || !anchored)
		return

	if(src.occupant)
		process_occupant()
	else
		process_capacitors()
	if(upgrade_holder.len)
		var/obj/item/weapon/cell/C = locate() in upgrade_holder
		charge_cell(C)
	return 1

/obj/machinery/recharge_station/proc/process_upgrade()
	if(!upgrading)
		return
	if(!occupant || !isrobot(occupant)) // Something happened so stop the upgrade.
		upgrading = 0
		upgrade_finished = -1
		return
	var/mob/living/silicon/robot/R = occupant
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE) || !anchored)
		to_chat(R, "<span class='warning'>Upgrade interrupted due to power failure, movement lock is released.</span>")
		upgrading = 0
		upgrade_finished = -1
		return
	if(world.timeofday >= upgrade_finished && upgrade_finished != -1)
		if(istype(upgrading, /obj/item/weapon/cell))
			if(R.cell)
				R.cell.updateicon()
				R.cell.forceMove(get_turf(src))
			upgrade_holder -= upgrading
			upgrading.forceMove(R)
			R.cell = upgrading
			upgrading = 0
			upgrade_finished = -1
			to_chat(R, "<span class='notice'>Upgrade completed.</span>")
			playsound(src, 'sound/machines/ping.ogg', 50, 0)

/obj/machinery/recharge_station/attackby(var/obj/item/W, var/mob/living/user)
	if(is_type_in_list(W, acceptable_upgradeables))
		if(!(locate(W.type) in upgrade_holder))
			if(user.drop_item(W, src))
				upgrade_holder.Add(W)
				to_chat(user, "<span class='notice'>You add \the [W] to \the [src].</span>")
				return
		else
			to_chat(user, "<span class='notice'>\The [src] already contains something resembling a [W.name].</span>")
			return
	else
		..()
		return
	return

/obj/machinery/recharge_station/attack_ghost(var/mob/user) //why would they
	return 0

/obj/machinery/recharge_station/attack_hand(var/mob/user)
	if(occupant == user)
		apply_cell_upgrade()
		return
	if(upgrade_holder.len && !upgrading)
		var/obj/removed = input(user, "Choose an item to remove.",upgrade_holder[1]) as null|anything in upgrade_holder
		if(!removed || upgrading)
			return
		var/obj/item/weapon/cell/rcell = removed
		if(istype(rcell))
			rcell.updateicon()
		user.put_in_hands(removed)
		if(removed.loc == src)
			removed.forceMove(get_turf(src))
		upgrade_holder -= removed

/obj/machinery/recharge_station/verb/apply_cell_upgrade()
	set category = "Object"
	set name = "Apply Cell Upgrade"
	set src in range(0)

	var/mob/user = usr
	if(!issilicon(user))
		to_chat(user, "<span class='warning'>You can't seem to find any cell to upgrade on your person, maybe because you're not a silicon you dummy.</span>")
		return
	if(user != occupant)
		to_chat(user, "<span class='warning'>You must be inside \the [src] to do this.</span>")
		return
	if(upgrading)
		to_chat(user, "<span class='notice'>You interrupt the upgrade process.</span>")
		upgrading = 0
		upgrade_finished = -1
		return
	else if(upgrade_holder.len)
		upgrading = input(user, "Choose an item to swap out.","Upgradeables") as null|anything in upgrade_holder
		if(!upgrading)
			upgrading = 0
			return
		if(alert(user, "You have chosen [upgrading], is this correct?", , "Yes", "No") == "Yes")
			upgrade_finished = world.timeofday + (600/manipulator_coeff)
			to_chat(user, "The upgrade should complete in approximately [60/manipulator_coeff] seconds, you will be unable to exit \the [src] during this unless you cancel the process.")
			spawn() do_after(user,src,600/manipulator_coeff,needhand = FALSE)
			return
		else
			upgrading = 0
			to_chat(user, "You decide not to apply the upgrade")
			return
	else
		to_chat(user, "<span class='warning'>There are no cell upgrades available at this time.</span>")

/obj/machinery/recharge_station/allow_drop()
	return 0

/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if(user.stat)
		return
	src.go_out()
	return

/obj/machinery/recharge_station/emp_act(severity)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		..(severity)
		return
	if(occupant)
		occupant.emp_act(severity)
		go_out()
	..(severity)

/obj/machinery/recharge_station/proc/build_icon()
	overlays = 0
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE) || !anchored)
		icon_state = "borgcharger"
	else
		if(src.occupant)
			if(isrobot(occupant) || !autoborger)
				icon_state = "borgcharger1"
			else
				icon_state = "borgchargerfuck"
		else
			icon_state = "borgcharger0"
/obj/machinery/recharge_station/proc/process_occupant()
	if(src.occupant)
		if(isrobot(occupant))
			var/mob/living/silicon/robot/R = occupant
			if((R.stat) || (!R.client))//no more borgs suiciding in recharge stations to ruin them.
				go_out()
				return
			restock_modules()
		else if(ishuman(occupant) && autoborger && !is_borging)
			do_autoborg()
			return
		charge_cell(occupant.get_cell())

/obj/machinery/recharge_station/proc/charge_cell(var/obj/item/weapon/cell/C)
	if(!istype(C))
		return
	if (capacitor_stored > 0)
		capacitor_stored -= C.give(capacitor_stored)
	use_power(200*transfer_rate_coeff)
	C.give(200 * transfer_rate_coeff + (isMoMMI(occupant) ? 100 * transfer_rate_coeff : 0))

/obj/machinery/recharge_station/proc/process_capacitors()
	if (capacitor_stored >= capacitor_max)
		if (idle_power_usage != initial(idle_power_usage)) //probably better to not re-assign the variable each process()?
			idle_power_usage = initial(idle_power_usage)
		return 0
	idle_power_usage = initial(idle_power_usage) + (100 * transfer_rate_coeff)
	capacitor_stored = min(capacitor_stored + (20 * transfer_rate_coeff), capacitor_max)
	return 1

/obj/machinery/recharge_station/Exited(var/atom/movable/O) // Used for teleportation from within the recharge station.
	if (O == occupant)
		occupant = null
		build_icon()
	..()

/obj/machinery/recharge_station/proc/go_out(var/turf/T)
	if(!T)
		T = get_turf(src)
	if(!( src.occupant ))
		return
	if(ishuman(occupant) && is_borging) // No escaping!
		return
	if(upgrading)
		to_chat(occupant, "<span class='notice'>The upgrade hasn't completed yet, interface with \the [src] again to halt the process.</span>")
		return
	//for(var/obj/O in src)
	//	O.loc = src.loc
	if(!occupant.gcDestroyed)
		if (occupant.client)
			occupant.client.eye = occupant.client.mob
			occupant.client.perspective = MOB_PERSPECTIVE
		occupant.forceMove(T)
	occupant = null
	build_icon()
	src.use_power = MACHINE_POWER_USE_IDLE
	// Removes dropped items/magically appearing mobs from the charger too
	for (var/atom/movable/x in src.contents)
		if(!(x in upgrade_holder | component_parts))
			x.forceMove(src.loc)
	return

/obj/machinery/recharge_station/proc/restock_modules()
	if(isrobot(occupant))
		var/mob/living/silicon/robot/R = occupant
		if(R.module && R.module.modules)
			var/list/um = R.contents|R.module.modules
			// ^ makes single list of active (R.contents) and inactive modules (R.module.modules)
			for(var/obj/item/I in um)
				I.restock()
			R.module.respawn_consumable(R)
			R.module.fix_modules()

/obj/machinery/recharge_station/verb/move_eject()
	set category = "Object"
	set src in oview(1)
	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/recharge_station/verb/move_inside()
	set category = "Object"
	set src in oview(1)

	mob_enter(usr)
	return

/obj/machinery/recharge_station/proc/mob_enter(mob/living/R)
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE) || !anchored)
		return
	if (R.stat == 2)
		//Whoever had it so that a borg with a dead cell can't enter this thing should be shot. --NEO
		return
	if (src.occupant)
		to_chat(R, "<span class='notice'><B>The cell is already occupied!</B></span>")
		return
	R.stop_pulling()
	if(R && R.client)
		R.client.perspective = EYE_PERSPECTIVE
		R.client.eye = src
	R.forceMove(src)
	src.occupant = R
	src.add_fingerprint(R)
	build_icon()
	src.use_power = MACHINE_POWER_USE_ACTIVE
	if(isrobot(R))
		var/mob/living/silicon/robot/RR = R
		for(var/obj/O in upgrade_holder)
			if(istype(O, /obj/item/weapon/cell))
				var/obj/item/weapon/cell/some_cell = O
				if(!RR.cell)
					to_chat(usr, "<big><span class='notice'>Power Cell replacement available. You may opt in with the 'Apply Cell Upgrade' verb in the Object tab.</span></big>")
				else
					if(some_cell.maxcharge > RR.cell.maxcharge)
						to_chat(usr, "<span class='notice'>Power Cell upgrade available. You may opt in with the 'Apply Cell Upgrade' verb in the Object tab.</span></big>")
	else if(ishuman(R) && autoborger && !is_borging)
		do_autoborg()


/obj/machinery/recharge_station/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(occupant)
		to_chat(user, "<span class='notice'>You can't do that while this charger is occupied.</span>")
		return -1
	return ..()

/obj/machinery/recharge_station/crowbarDestroy(mob/user, obj/item/tool/crowbar/I)
	if(occupant)
		to_chat(user, "<span class='notice'>You can't do that while this charger is occupied.</span>")
		return 0
	return ..()

/obj/machinery/recharge_station/Bumped(atom/AM as mob|obj)
	if(!isliving(AM) || isAI(AM))
		return
	mob_enter(AM)

/obj/machinery/recharge_station/get_cell()
	if(occupant)
		return occupant.get_cell()
	return locate(/obj/item/weapon/cell) in upgrade_holder

/obj/machinery/recharge_station/proc/do_autoborg()
	if(!ishuman(occupant))
		return
	var/mob/living/carbon/human/H = occupant
	if(is_borging)
		return
	is_borging = TRUE

	var/limbs_to_ignore = list(/datum/organ/external/head, /datum/organ/external/chest, /datum/organ/external/groin)
	var/list/limbs = list()
	for(var/datum/organ/external/E in H.organs)
		if(!E.is_robotic() && !is_type_in_list(E, limbs_to_ignore))
			limbs += E

	build_icon()
	flick("borgchargerfuckstart", src)
	H.AdjustKnockdown(10)
	playsound(src, 'sound/machines/juicer.ogg', 80, 1)

	// Mangle their limbs!
	for(var/datum/organ/external/E in limbs)
		if(!src)
			return
		if(prob(25))
			spark(src)
		if(prob(50))
			H.audible_scream()
		shake(1, 3)
		E.explode()
		H.handle_regular_hud_updates()
		sleep(10)

	if(!src)
		return

	var/mob/living/silicon/robot/R
	if(make_mommis)
		R = H.MoMMIfy(TRUE, TRUE, aiowner)
	else
		R = H.Robotize(TRUE , TRUE , aiowner)

	occupant = R

	if(!R)
		visible_message("<span class='danger'>\The [src.name] throws an exception. Lifeform not compatible with factory.</span>")
		if (aiowner)
			var/datum/role/malfAI/my_malf = aiowner.mind?.GetRole(MALF)
			if (my_malf)
				my_malf.add_power(50)
				to_chat(aiowner, "<span class='good'>Incompatible lifeform biomass reprocessed into computing power.</span>")
		is_borging = FALSE
		return

	R.cell.maxcharge = 5000
	R.cell.charge = 5000
	R.SetKnockdown(3)

	R.custom_name = pick(autoborg_silly_names)
	R.namepick_uses = 1
	R.updateicon()
	R.updatename()
	flick("borgchargerfuckend", src)
	playsound(src, 'sound/machines/ding.ogg', 50, 0)
	spawn(5)
		build_icon()
		is_borging = FALSE
		go_out()


/obj/machinery/recharge_station/MouseDropFrom(atom/over_object, src_location, var/atom/over_location, src_control, over_control, params)
	if(!ishigherbeing(usr) && !isrobot(usr) || usr.incapacitated() || usr.lying)
		return
	if(!occupant)
		to_chat(usr, "<span class='warning'>\The [src] is unoccupied!</span>")
		return
	if(is_borging)
		to_chat(usr, "<span class='warning'>\The [src] won't budge!</span>")
		return
	var/turf/T = get_turf(over_location)
	if(!istype(T) || T.density)
		return
	if(!Adjacent(T) || !Adjacent(usr) || !usr.Adjacent(T))
		return
	for(var/atom/movable/A in T.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	go_out(T)


/obj/machinery/recharge_station/MouseDropTo(atom/movable/O as mob|obj, mob/user as mob)
	if(!isliving(O) || !isliving(user))
		return
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O))
		return
	if(user.incapacitated() || user.lying)
		return
	if(!Adjacent(user) || !user.Adjacent(src))
		return
	if(O.locked_to)
		return
	if(O.anchored)
		return
	if(!isrobot(O) && !ishuman(O))
		return
	if(!isrobot(user) && !ishuman(user))
		return
	var/mob/living/L = O
	if(L.stat == DEAD)
		to_chat(user, "<span class='warning'>[O] is already dead!</span>")
		return
	if(do_after(user, src, 20))
		mob_enter(O)
