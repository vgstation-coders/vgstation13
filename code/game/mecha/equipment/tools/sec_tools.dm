/obj/item/mecha_parts/mecha_equipment/tool/jail
	name = "Mounted Jail Cell"
	desc = "Mounted Jail Cell, capable of holding up to two prisoners for a limited time. (Can be attached to Gygax)"
	icon_state = "mecha_jail"
	origin_tech = "biotech=2;magnets=3;combat=4;materials=3"
	energy_drain = 20
	range = MELEE
	construction_cost = list("iron"=7500,"glass"=10000)
	reliability = 1000
	equip_cooldown = 20
	var/mob/living/carbon/cell1 = null
	var/mob/living/carbon/cell2 = null
	var/timer1 = 0
	var/timer2 = 0
	var/datum/global_iterator/pr_mech_jail
	salvageable = 0

	can_attach(obj/mecha/combat/gygax/G)
		if(..())
			if(istype(G))
				return 1
		return 0

	New()
		..()
		pr_mech_jail = new /datum/global_iterator/mech_jail(list(src),0)
		pr_mech_jail.set_delay(equip_cooldown)
		return

	allow_drop()
		return 0

	destroy()
		for(var/atom/movable/AM in src)
			AM.forceMove(get_turf(src))
		return ..()

	Exit(atom/movable/O)
		return 0

	action(var/mob/living/carbon/target)
		if(!action_checks(target))
			return
		if(!istype(target))
			return
		if(target.buckled)
			occupant_message("[target] will not fit into the jail cell because they are buckled to [target.buckled].")
			return
		if(cell1 && cell2)
			occupant_message("The jail cells are already occupied")
			return
		for(var/mob/living/carbon/slime/M in range(1,target))
			if(M.Victim == target)
				occupant_message("[target] will not fit into the jail cell because they have a slime latched onto their head.")
				return
		occupant_message("You start putting [target] into [src].")
		chassis.visible_message("[chassis] starts putting [target] into the [src].")
		var/C = chassis.loc
		var/T = target.loc
		if(do_after_cooldown(target))
			if(chassis.loc!=C || target.loc!=T)
				return
			if(cell1 && cell2)
				occupant_message("<font color=\"red\"><B>The jail cells are already occupied!</B></font>")
				return
			target.forceMove(src)
			if(!cell1)
				cell1 = target
				timer1 = 90
			else if (!cell2)
				cell2 = target
				timer2 = 90
				set_ready_state(0)
			target.reset_view(src)
			/*
			if(target.client)
				target.client.perspective = EYE_PERSPECTIVE
				target.client.eye = chassis
			*/
			pr_mech_jail.start()
			occupant_message("<font color='blue'>[target] successfully loaded into [src].")
			chassis.visible_message("[chassis] loads [target] into [src].")
			log_message("[target] loaded.")
		return

	proc/go_out(var/mob/living/carbon/ejected, ejectedtimer)
		if(!ejected)
			return
		ejected.forceMove(get_turf(src))
		occupant_message("[ejected] ejected.")
		log_message("[ejected] ejected.")
		ejectedtimer = 0
		ejected.reset_view()
		/*
		if(occupant.client)
			occupant.client.eye = occupant.client.mob
			occupant.client.perspective = MOB_PERSPECTIVE
		*/
		if(cell1 == ejected) //I really don't know why these are necessary. Just accept that they are
			cell1 = null
		if(cell2 == ejected)
			cell2 = null
		ejected = null
		if(!cell1 && !cell2)
			pr_mech_jail.stop()
		set_ready_state(1)
		return

	detach()
		if(cell1 || cell2)
			occupant_message("Unable to detach [src] - equipment occupied.")
			return
		pr_mech_jail.stop()
		return ..()

	get_equip_info()
		var/output = ..()
		var/mob/living/occupant1 = cell1
		var/mob/living/occupant2 = cell2
		if(output)
			var/temp = ""
			if(occupant1)
				temp = "<br />\[Occupant: [occupant1] (Health: [occupant1.health]%)\]<br />|Time left: [timer1]|<a href='?src=\ref[src];ejectcell1=1'>Eject</a>"
			if(occupant2)
				temp = temp + "<br />\[Occupant: [occupant2] (Health: [occupant2.health]%)\]<br />|Time left: [timer2]|<a href='?src=\ref[src];ejectcell2=1'>Eject</a>"
			return "[output] [temp]"
		return

	Topic(href,href_list)
		..()
		var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
		if(filter.get("ejectcell1"))
			go_out(cell1, timer1)
		if(filter.get("ejectcell2"))
			go_out(cell2, timer2)
		return

/datum/global_iterator/mech_jail

	process(var/obj/item/mecha_parts/mecha_equipment/tool/jail/J)
		var/mob/living/carbon/M = J.cell1
		var/mob/living/carbon/N = J.cell2
		log_admin("Timer 1: [J.timer1], Timer 2: [J.timer2]")
		if(!J.chassis)
			J.set_ready_state(1)
			return stop()
		if(!J.chassis.has_charge(J.energy_drain))
			J.set_ready_state(1)
			J.log_message("Deactivated.")
			J.occupant_message("[src] deactivated - no power.")
			J.go_out(M, J.timer1)
			J.go_out(N, J.timer2)
			return stop()
		if(!M && !N)
			return
		if (M)
			J.timer1--
			if (J.timer1 <= 0)
				J.go_out(M, J.timer1)
		if (N)
			J.timer2--
			if (J.timer2 <= 0)
				J.go_out(N, J.timer2)
		//log_admin("Current cells of [M] and [N]")
		J.chassis.use_power(J.energy_drain)
		J.update_equip_info()
		return