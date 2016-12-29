/obj/item/mecha_parts/mecha_equipment/tool/jail
	name = "\improper Mounted Jail Cell"
	desc = "A Mounted Jail Cell, capable of holding up to two prisoners. (Can be attached to Gygax)"
	icon_state = "mecha_jail"
	origin_tech = Tc_BIOTECH + "=2;" + Tc_COMBAT + "=4"
	energy_drain = 20
	range = MELEE
	reliability = 1000
	equip_cooldown = 50 //very long time to actually load someone up
	var/list/cells = list("cell1" = null, "cell2" = null)
	var/datum/global_iterator/pr_mech_jail
	salvageable = 0

/obj/item/mecha_parts/mecha_equipment/tool/jail/can_attach(obj/mecha/combat/gygax/G)
	if(..())
		if(istype(G))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/jail/New()
	. = ..()
	pr_mech_jail = new /datum/global_iterator/mech_jail(list(src),0)
	pr_mech_jail.set_delay(equip_cooldown)
	return

/obj/item/mecha_parts/mecha_equipment/tool/jail/allow_drop()
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/jail/destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	for(var/cell in cells) //safety nets
		if(cells[cell])
			var/mob/living/carbon/occupant = cells[cell]
			occupant.forceMove(get_turf(src))
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/jail/Exit(atom/movable/O)
	return 0

//is there an open cell for a mob?
//returns the cell that's got a space
/obj/item/mecha_parts/mecha_equipment/tool/jail/proc/CellFree()
	for(var/cell in cells)
		if(!cells[cell])
			return cell
	return

//are all our cells empty?
/obj/item/mecha_parts/mecha_equipment/tool/jail/proc/AllFree()
	var/allfree = 1
	for(var/cell in cells)
		if(cells[cell])
			allfree = 0
			break
	return allfree

/obj/item/mecha_parts/mecha_equipment/tool/jail/action(var/mob/living/carbon/target)
	if(!action_checks(target))
		return
	if(!istype(target))
		return
	if(target.locked_to)
		occupant_message("[target] will not fit into the jail cell because they are buckled to [target.locked_to].")
		return
	if(!CellFree())
		occupant_message("The jail cells are already occupied")
		return
	if(!(target.handcuffed || target.legcuffed))
		occupant_message("[target] must be restrained before they can be properly placed in the holding cell.")
		return
	for(var/mob/living/carbon/slime/M in range(1,target))
		if(M.Victim == target)
			occupant_message("[target] will not fit into the jail cell because they have a slime latched onto their head.")
			return
	occupant_message("You start putting [target] into [src].")
	chassis.visible_message("[chassis] starts putting [target] into \the [src].")
	var/C = chassis.loc
	var/T = target.loc
	if(do_after_cooldown(target))
		if(chassis.loc!=C || target.loc!=T)
			return
		if(!CellFree())
			occupant_message("<font color=\"red\"><B>The jail cells are already occupied!</B></font>")
			return
		target.forceMove(src)
		var/chosencell = CellFree()
		cells[chosencell] = target
		if(!CellFree())
			set_ready_state(0)
		target.reset_view(src)
		if(CellFree()) //because the process can't have been already going if both cells were empty
			pr_mech_jail.start()
		occupant_message("<font color='blue'>[target] successfully loaded into [src].")
		chassis.visible_message("[chassis] loads [target] into [src].")
		log_message("[target] loaded.")
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/tool/jail/proc/go_out(var/cell)
	var/mob/living/ejected = cells[cell]
	if(!ejected)
		return
	ejected.forceMove(get_turf(src))
	occupant_message("[ejected] ejected.")
	log_message("[ejected] ejected.")
	ejected.reset_view()
	cells[cell] = null
	ejected = null
	if(CellFree())
		set_ready_state(1)
	if(AllFree())
		pr_mech_jail.stop()
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/jail/proc/subdue(var/cell)
	var/mob/living/prisoner = cells[cell]
	if(!prisoner)
		return
	prisoner.Stun(10)
	prisoner.Knockdown(10)
	prisoner.apply_effect(STUTTER, 10)
	chassis.use_power(energy_drain)
	playsound(chassis, 'sound/weapons/Egloves.ogg', 50, 1)
	occupant_message("[prisoner] has been subdued.")
	log_message("[prisoner] has been subdued.")
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/jail/detach()
	if(!AllFree())
		occupant_message("Unable to detach [src] - equipment occupied.")
		return
	pr_mech_jail.stop()
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/jail/get_equip_info()
	var/output = ..()
	if(output)
		var/temp = ""
		for(var/cell in cells)
			var/mob/living/carbon/occupant = cells[cell]
			temp += "<br />\[Occupant: [occupant ? "[occupant] (Health: [occupant.health]%)" : "none"]\]<br />|<a href='?src=\ref[src];subdue[cell]=1'>Subdue</a>|<a href='?src=\ref[src];eject[cell]=1'>Eject</a>|"
		return "[output] [temp]"
	return

/obj/item/mecha_parts/mecha_equipment/tool/jail/Topic(href,href_list)
	..()
	var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
	for(var/cell in cells)
		if(filter.get("eject[cell]"))
			go_out(cell)
		if(filter.get("subdue[cell]"))
			subdue(cell)
	return

/datum/global_iterator/mech_jail/process(var/obj/item/mecha_parts/mecha_equipment/tool/jail/J)
	if(!J.chassis)
		J.set_ready_state(1)
		return stop()
	if(!J.chassis.has_charge(J.energy_drain))
		J.set_ready_state(1)
		J.log_message("Deactivated.")
		J.occupant_message("[src] deactivated - no power.")
		for(var/cell in J.cells)
			J.go_out(cell)
		return stop()
	if(J.AllFree())
		return stop()
	J.chassis.use_power(J.energy_drain)
	J.update_equip_info()
	return

/obj/item/mecha_parts/mecha_equipment/tool/jail/proc/break_out(var/mob/M)
	if(!istype(M))
		return
	M.visible_message("<span class='danger'>\The [M] pops the lid off of \the [src] and climbs out!.</span>","<span class='notice'>You pop the lid off of \the [src] and climb out!</span>")
	M.forceMove(get_turf(src))