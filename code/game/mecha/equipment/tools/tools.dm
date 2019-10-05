#define MECHDRILL_SAND_SPEED 2
#define MECHDRILL_ROCK_SPEED 3

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	name = "\improper Hydraulic Clamp"
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	var/dam_force = 20

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/can_attach(obj/mecha/working/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/attach(obj/mecha/M as obj)
	..()
	if(istype(chassis, /obj/mecha/working))
		var/obj/mecha/working/W = chassis
		W.hydraulic_clamp = src
	return

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/detach()
	..()
	if(istype(chassis, /obj/mecha/working))
		var/obj/mecha/working/W = chassis
		W.hydraulic_clamp = null
	return

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/action(atom/target)
	if(!action_checks(target))
		return
	if(!istype(chassis, /obj/mecha/working))
		return
	var/obj/mecha/working/W = chassis

	if(istype(target,/obj/machinery/power/supermatter))
		var/obj/machinery/power/supermatter/supermatter = target
		if(supermatter.damage) //is it overheating
			occupant_message("<span class='danger'>The supermatter is fluctuating too wildly to safely lift!</span>")
			return
	if(istype(target, /obj/structure/bed))
		occupant_message("<span class='warning'>Safety features prevent this action.</span>")
		return //no picking up rollerbeds
	var/list/living_in_target = target.search_contents_for(/mob/living)
	if(living_in_target.len) //no picking up lockers with people in them
		occupant_message("<span class='warning'>Safety features prevent this action.</span>")
		return

	if(istype(target,/obj))
		var/obj/O = target
		if (istype(O, /obj/machinery/door/firedoor))
			var/obj/machinery/door/firedoor/FD = O
			if (!FD.operating)
				FD.force_open(chassis.occupant, src)
			return
		if(!O.anchored)
			if(istype(O, /obj/item/stack/ore) && W.ore_box)
				var/count = 0
				for(var/obj/item/stack/ore/I in get_turf(target))
					if(I.material)
						W.ore_box.materials.addAmount(I.material, I.amount)
						returnToPool(I)
						count++
				if(count)
					log_message("Loaded [count] ore into compatible ore box.")
					occupant_message("<span class='notice'>[count] ore successfully loaded into cargo compartment.</span>")
					chassis.visible_message("[chassis] scoops up the ore from the ground and loads it into cargo compartment.")
			else if(W.cargo.len < W.cargo_capacity)
				occupant_message("You lift [target] and start to load it into cargo compartment.")
				chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
				set_ready_state(0)
				chassis.use_power(energy_drain)
				O.anchored = 1 //Why
				var/T = chassis.loc
				if(do_after_cooldown(target))
					var/list/oh_shit_new_living_in_target = target.search_contents_for(/mob/living)
					if(oh_shit_new_living_in_target.len)
						return
					if(T == chassis.loc && src == chassis.selected)
						W.cargo += O
						O.forceMove(chassis)
						if(!W.ore_box && istype(O, /obj/structure/ore_box))
							W.ore_box = O
						O.anchored = 0 //Why?
						occupant_message("<span class='notice'>[target] successfully loaded.</span>")
						log_message("Loaded [O]. Cargo compartment capacity: [W.cargo_capacity - W.cargo.len]")
					else
						occupant_message("<span class='red'>You must hold still while handling objects.</span>")
						O.anchored = initial(O.anchored) //WHY??
			else
				occupant_message("<span class='red'>Not enough room in cargo compartment.</span>")
		else
			occupant_message("<span class='red'>[target] is firmly secured.</span>")

	else if(istype(target,/mob/living))
		var/mob/living/M = target
		if(M.stat == DEAD)
			return
		if(chassis.occupant.a_intent == I_HURT)
			if(istype(chassis, /obj/mecha/working/clarke))
				to_chat(chassis.occupant, "<span class='warning'>WARNING: OSHA regulations prohibit use of \the [src] in that way.</span>")
				return
			M.take_overall_damage(dam_force)
			if(!M)
				return //we killed some sort of simple animal and the corpse was deleted.
			M.adjustOxyLoss(round(dam_force/2))
			M.updatehealth()
			occupant_message("<span class='warning'>You squeeze [target] with [src.name]. Something cracks.</span>")
			chassis.visible_message("<span class='warning'>[chassis] squeezes [target].</span>")
			M.attack_log +="\[[time_stamp()]\]<font color='orange'> Mech Squeezed by [chassis.occupant.name] ([chassis.occupant.ckey]) with [src.name]</font>"
			chassis.occupant.attack_log += "\[[time_stamp()]\]<font color='red'> Mech Squeezed [M.name] ([M.ckey]) with [src.name]</font>"
			log_attack("<font color='red'>[chassis.occupant.name] ([chassis.occupant.ckey]) mech squeezed [M.name] ([M.ckey]) with [src.name]</font>" )
		else
			step_away(M,chassis)
			occupant_message("You push [target] out of the way.")
			chassis.visible_message("[chassis] pushes [target] out of the way.")
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_after_cooldown()
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/drill
	name = "\improper Exosuit-Mounted Drill"
	desc = "This is the drill that'll pierce the heavens! (Can be attached to: Combat and Mining Exosuits)"
	icon_state = "mecha_drill"
	equip_cooldown = 45
	energy_drain = 10
	force = 15
	var/dig_walls = 0 //probably a better way to do this through bitflags but I don't really know how

/obj/item/mecha_parts/mecha_equipment/tool/drill/action(atom/target)
	if(!action_checks(target))
		return
	if(isobj(target))
		if(!target.can_mech_drill())
			return
	set_ready_state(0)
	chassis.visible_message("<span class='red'><b>[chassis] starts to drill [target]!</b></span>", "You hear a drill.")
	occupant_message("<span class='red'><b>You start to drill [target]!</b></span>")
	var/C = chassis.loc
	var/T = target.loc	//why were these backwards? we may never know -Pete & Bauds, years apart

	if(istype(target, /turf/simulated/wall/invulnerable))
		occupant_message("<span class='red'>[target] is too durable to drill through.</span>")

	else if(istype(target, /turf/simulated/wall))
		if(dig_walls)
			var/delay = istype(target, /turf/simulated/wall/r_wall) ? 10 : 2
			if(do_after_cooldown(target, delay) && C == chassis.loc && src == chassis.selected)
				log_message("Drilled through [target]")
				occupant_message("<span class='red'><b>Your powerful drill screeches as it tears through the last of \the [target], leaving nothing but a girder!</b></span>")
				chassis.visible_message("<span class='red'><b>[chassis] drills through \the [target]!</b></span>", "You hear a drill tearing through plating.")
				//target.ex_act(3) //Why
				target.mech_drill_act(3)
		else
			if(do_after_cooldown(target, 1) && C == chassis.loc && src == chassis.selected)
				occupant_message("<span class='red'>[target] is too durable to drill through.</span>")

	else if(istype(target, /obj/structure/girder))
		if(do_after_cooldown(target) && C == chassis.loc && src == chassis.selected)
			log_message("Drilled through [target]")
			occupant_message("<span class='red'><b>Your drill destroys \the [target]!</b></span>")
			chassis.visible_message("<span class='red'><b>[chassis] destroys \the [target]!</b></span>", "You hear a drill breaking something.")
			target.mech_drill_act(2)

	else if(istype(target, /turf/unsimulated/mineral))
		if(do_after_cooldown(target, 1/MECHDRILL_ROCK_SPEED) && C == chassis.loc && src == chassis.selected)
			for(var/turf/unsimulated/mineral/M in range(chassis,1))
				if(get_dir(chassis,M)&chassis.dir && M.mining_difficulty < MINE_DIFFICULTY_DENSE)
					M.GetDrilled(safety_override = TRUE, driller = src)
			log_message("Drilled through [target]")
			if(istype(chassis, /obj/mecha/working))
				var/obj/mecha/working/W = chassis
				if(W.hydraulic_clamp && W.ore_box)
					var/count = 0
					for(var/obj/item/stack/ore/ore in range(chassis,1))
						if(get_dir(chassis,ore)&chassis.dir && ore.material)
							W.ore_box.materials.addAmount(ore.material,ore.amount)
							returnToPool(ore)
							count++
					if(count)
						occupant_message("<span class='notice'>[count] ore successfully loaded into cargo compartment.</span>")

	else if(istype(target, /turf/unsimulated/floor/asteroid)) //Digging for sand
		if(do_after_cooldown(target, 1/MECHDRILL_SAND_SPEED) && C == chassis.loc && src == chassis.selected)
			var/count = 0
			var/obj/structure/ore_box/ore_box
			var/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/hydraulic_clamp
			if(istype(chassis, /obj/mecha/working))
				var/obj/mecha/working/W = chassis
				ore_box = W.ore_box
				hydraulic_clamp = W.hydraulic_clamp
			for(var/turf/unsimulated/floor/asteroid/M in range(chassis,1)) //Get a 3x3 area around the mech
				if(get_dir(chassis,M)&chassis.dir || istype(src, /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill)) //Only dig frontmost 1x3 unless the drill is diamond
					M.gets_dug()
					if(hydraulic_clamp && ore_box)
						for(var/obj/item/stack/ore/glass/sandore in get_turf(M))
							ore_box.materials.addAmount(sandore.material,sandore.amount)
							returnToPool(sandore)
							count++
			log_message("Drilled through [target]")
			if(count)
				occupant_message("<span class='notice'>[count] sand successfully loaded into cargo compartment.</span>")

	else
		if(do_after_cooldown(target, 1) && C == chassis.loc && src == chassis.selected && target.loc == T) //also check that our target hasn't moved
			if(istype(target, /mob/living))
				var/mob/living/M = target
				M.attack_log +="\[[time_stamp()]\]<font color='orange'> Mech Drilled by [chassis.occupant.name] ([chassis.occupant.ckey]) with [src.name]</font>"
				chassis.occupant.attack_log += "\[[time_stamp()]\]<font color='red'> Mech Drilled [M.name] ([M.ckey]) with [src.name]</font>"
				log_attack("<font color='red'>[chassis.occupant.name] ([chassis.occupant.ckey]) mech drilled [M.name] ([M.ckey]) with [src.name]</font>" )
				if(!iscarbon(chassis.occupant))
					M.LAssailant = null
				else
					M.LAssailant = chassis.occupant
			log_message("Drilled through [target]")
			occupant_message("<span class='red'><b>You drill into \the [target].</b></span>")
			chassis.visible_message("<span class='red'><b>[chassis] drills into \the [target]!</b></span>", "You hear a drill breaking something.")
			target.mech_drill_act(2)

	chassis.use_power(energy_drain)
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/drill/can_attach(obj/mecha/M as obj)
	if(..())
		if((istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat)) && !istype(M, /obj/mecha/working/clarke))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
	name = "\improper Exosuit-Mounted Diamond Drill"
	desc = "This is an upgraded version of the drill that'll pierce the heavens! (Can be attached to: Combat and Mining Exosuits)"
	icon_state = "mecha_diamond_drill"
	origin_tech = Tc_MATERIALS + "=4;" + Tc_ENGINEERING + "=3"
	equip_cooldown = 15
	force = 15
	dig_walls = 1

	//OBJECT
	//ORIENTED
	//PROGRAMMING

/obj/item/mecha_parts/mecha_equipment/tool/scythe
	name = "\improper Heavy Duty Pneumatic Scythe"
	desc = "An extremely heavy-duty pneumatic scythe. The \"giant robot\" approach to weed control. (Can be attached to: Maintenance Exosuits)"
	icon_state = "mecha_extremelylazyscythecopypaste"
	equip_cooldown = 20
	energy_drain = 15
	var/dam_force = 20

/obj/item/mecha_parts/mecha_equipment/tool/scythe/can_attach(obj/mecha/working/M as obj)
	if(..())
		if(istype(M) && !istype(M, /obj/mecha/working/clarke))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/scythe/action(atom/target)
	if(!action_checks(target))
		return

	if(istype(target, /obj/machinery/portable_atmospherics/hydroponics))
		set_ready_state(0)
		if(do_after_cooldown(target, 1/2))
			chassis.visible_message("<span class='red'><b>[chassis] smashes apart \the [target]!</b></span>", "You hear a pneumatic screeching and something being smashed apart.")
			occupant_message("<span class='red'><b>You smash apart \the [target]!</b></span>")
			log_message("Destroyed [target].")
			var/obj/machinery/portable_atmospherics/hydroponics/tray = target
			playsound(target, 'sound/mecha/mechsmash.ogg', 50, 1)
			tray.smashDestroy(50) //Just to really drive it home
	else if(istype(target, /obj/effect/plantsegment) || istype(target, /obj/effect/alien/weeds) || istype(target, /obj/effect/biomass)|| istype(target, /turf/simulated/floor) || istype(target, /obj/structure/cable/powercreeper))
		set_ready_state(0)
		var/olddir = chassis.dir
		var/eradicated = 0
		spawn for(var/i=1 to 4)
			chassis.mechturn(turn(olddir, 90*i))
			for(var/obj/effect/E in range(chassis,i == 4 ? 2 : 1))
				if(get_dir(chassis,E)&chassis.dir || E.loc == get_turf(chassis)) //This kills vines through windows, but ehhhh
					if(istype(E, /obj/effect/plantsegment))
						var/obj/effect/plantsegment/K = E
						K.die_off()
						eradicated++
					else if(istype(E, /obj/effect/alien/weeds) || istype(E, /obj/effect/biomass))
						qdel(E)
						eradicated++
			for(var/obj/structure/cable/powercreeper/C in range(chassis,i == 4 ? 2 : 1))
				if(get_dir(chassis,C)&chassis.dir || C.loc == get_turf(chassis))
					if(istype(C, /obj/structure/cable/powercreeper))
						C.die()
						eradicated++
			sleep(3)
		if(eradicated)
			occupant_message("<span class='notice'>[eradicated] weeds successfully eradicated.</span>")
			log_message("Culled [eradicated] weeds.")
		set_ready_state(1)
	else if(istype(target,/mob/living))
		var/mob/living/M = target
		if(M.stat == DEAD)
			return
		if(chassis.occupant.a_intent == I_HURT)
			set_ready_state(0)
			M.apply_damage(dam_force, BRUTE)
			occupant_message("<span class='danger'>You slash [target] with [src.name].</span>")
			chassis.visible_message("<span class='danger'>[chassis] slashes at [target] with [src.name]!</span>")
			M.attack_log +="\[[time_stamp()]\]<font color='orange'> Mech Scythed by [chassis.occupant.name] ([chassis.occupant.ckey]) with [src.name]</font>"
			chassis.occupant.attack_log += "\[[time_stamp()]\]<font color='red'> Slashed [M.name] ([M.ckey]) with [src.name]</font>"
			log_attack("<font color='red'>[chassis.occupant.name] ([chassis.occupant.ckey]) mech scythed [M.name] ([M.ckey]) with [src.name]</font>" )
			log_message("Slashed at [target] with [src.name].")
			do_after_cooldown()
	else
		return 0
	chassis.use_power(energy_drain)
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher
	name = "\improper Exosuit-Mounted Foam Extinguisher"
	desc = "A fire extinguisher module for an exosuit. (Can be attached to: Firefighting and Engineering exosuits)"
	icon_state = "mecha_exting"
	origin_tech = Tc_MATERIALS + "=1;" + Tc_ENGINEERING + "=2"
	equip_cooldown = 15
	energy_drain = 0
	range = MELEE|RANGED

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/can_attach(obj/mecha/working/M)
	if(..())
		if(istype(M, /obj/mecha/working/ripley/firefighter) || istype(M, /obj/mecha/working/clarke))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/action(atom/target) //copypasted from extinguisher. TODO: Rewrite from scratch.
	if(!action_checks(target) || get_dist(chassis, target)>5)
		return
	set_ready_state(0)
	if(do_after_cooldown(target))
		if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
			var/obj/o = target
			o.reagents.trans_to(src, 200)
			occupant_message("<span class='notice'>Extinguisher refilled.</span>")
			playsound(chassis, 'sound/effects/refill.ogg', 50, 1, -6)
		else
			if(src.reagents.total_volume > 0)
				playsound(chassis, 'sound/effects/extinguish.ogg', 75, 1, -3)
				var/direction = get_dir(chassis,target)
				var/turf/T = get_turf(target)
				var/turf/T1 = get_step(T,turn(direction, 90))
				var/turf/T2 = get_step(T,turn(direction, -90))

				var/list/the_targets = list(T,T1,T2)
				for(var/a=0, a<5, a++)
					spawn(0)
						var/datum/reagents/R = new/datum/reagents(5)
						R.my_atom = src
						reagents.trans_to_holder(R,1)
						var/obj/effect/effect/foam/fire/W = new /obj/effect/effect/foam/fire(get_turf(chassis), R)
						if(!W || !src)
							return
						var/turf/my_target = pick(the_targets)
						for(var/b=0, b<4, b++)
							var/turf/oldturf = get_turf(W)
							step_towards(W,my_target)
							if(!W || !W.reagents)
								return
							var/turf/W_turf = get_turf(W)
							W.reagents.reaction(W_turf, TOUCH)
							for(var/atom/atm in W_turf)
								if(!W || !W.reagents)
									return
								W.reagents.reaction(atm, TOUCH) // Touch, since we sprayed it.
								if(W.reagents.has_reagent(WATER))
									if(isliving(atm)) // For extinguishing mobs on fire
										var/mob/living/M = atm // Why isn't this handled by the reagent? - N3X
										M.ExtinguishMob()
									if(atm.on_fire) // For extinguishing objects on fire
										atm.extinguish()
									if(atm.molten) // Molten shit.
										atm.molten=0
										atm.solidify()

							var/obj/effect/effect/foam/fire/F = locate() in oldturf
							if(!istype(F) && oldturf != get_turf(src))
								F = new /obj/effect/effect/foam/fire( get_turf(oldturf) , W.reagents)

							if(W.loc == my_target)
								break
							sleep(2)
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/get_equip_info()
	return "[..()] \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/on_reagent_change()
	return

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/can_attach(obj/mecha/working/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/New()
	. = ..()
	create_reagents(200)
	reagents.add_reagent(WATER, 200)


/obj/item/mecha_parts/mecha_equipment/jetpack
	name = "\improper Exosuit-Mounted Jetpack"
	desc = "Using directed ion bursts and cunning solar wind reflection technique, this device enables controlled space flight."
	icon_state = "mecha_jetpack"
	origin_tech = Tc_MATERIALS + "=5;" + Tc_ENGINEERING + "=5;" + Tc_MAGNETS + "=4"
	equip_cooldown = 5
	energy_drain = 75
	var/wait = 0
	var/datum/effect/effect/system/trail/ion_trail


/obj/item/mecha_parts/mecha_equipment/jetpack/can_attach(obj/mecha/M as obj)
	if(!(locate(src.type) in M.equipment) && !M.proc_res["dyndomove"])
		return ..()

/obj/item/mecha_parts/mecha_equipment/jetpack/detach()
	..()
	chassis.proc_res["dyndomove"] = null
	return

/obj/item/mecha_parts/mecha_equipment/jetpack/attach(obj/mecha/M as obj)
	..()
	if(!ion_trail)
		ion_trail = new /datum/effect/effect/system/trail()
	ion_trail.set_up(chassis)
	return

/obj/item/mecha_parts/mecha_equipment/jetpack/proc/toggle()
	if(!chassis)
		return
	!equip_ready? turn_off() : turn_on()
	return equip_ready

/obj/item/mecha_parts/mecha_equipment/jetpack/attach(obj/mecha/M as obj)
	..()
	linked_spell = new /spell/mech/jetpack(M, src)

/obj/item/mecha_parts/mecha_equipment/jetpack/activate()
	toggle()

/spell/mech/jetpack/cast(list/targets, mob/user)
	linked_equipment.activate()

/obj/item/mecha_parts/mecha_equipment/jetpack/proc/turn_on()
	set_ready_state(0)
	chassis.proc_res["dyndomove"] = src
	ion_trail.start()
	occupant_message("Jetpack Activated.")
	log_message("Jetpack Activated.")

/obj/item/mecha_parts/mecha_equipment/jetpack/proc/turn_off()
	set_ready_state(1)
	chassis.proc_res["dyndomove"] = null
	ion_trail.stop()
	occupant_message("Jetpack Deactivated.")
	log_message("Jetpack Deactivated.")

/obj/item/mecha_parts/mecha_equipment/jetpack/proc/dyndomove(direction)
	if(!action_checks())
		return chassis.dyndomove(direction)
	var/move_result = 0
	if(chassis.hasInternalDamage(MECHA_INT_CONTROL_LOST))
		move_result = step_rand(chassis)
	else if(chassis.dir!=direction)
		chassis.dir = direction
		move_result = 1
	else
		move_result	= step(chassis,direction)
		if(chassis.occupant)
			for(var/obj/effect/speech_bubble/B in range(1, chassis))
				if(B.parent == chassis.occupant)
					B.forceMove(chassis.loc)
	if(move_result)
		wait = 1
		chassis.use_power(energy_drain)
		if(!chassis.pr_inertial_movement.active())
			chassis.pr_inertial_movement.start(list(chassis,direction))
		else
			chassis.pr_inertial_movement.set_process_args(list(chassis,direction))
		do_after_cooldown()
		return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/jetpack/action_checks()
	if(equip_ready || wait)
		return 0
	if(energy_drain && !chassis.has_charge(energy_drain))
		return 0
	if(crit_fail)
		return 0
	if(chassis.check_for_support())
		return 0
	return 1

/obj/item/mecha_parts/mecha_equipment/jetpack/get_equip_info()
	if(!chassis)
		return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] \[<a href=\"?src=\ref[src];toggle=1\">Toggle</a>\]"


/obj/item/mecha_parts/mecha_equipment/jetpack/Topic(href,href_list)
	if(..())
		return TRUE
	if(href_list["toggle"])
		toggle()

/obj/item/mecha_parts/mecha_equipment/jetpack/do_after_cooldown()
	sleep(equip_cooldown)
	wait = 0
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/red
	name = "\improper Exosuit-Mounted RED"
	desc = "An exosuit-mounted Rapid Engineering Device. (Can be attached to: Any exosuit)"
	icon_state = "mecha_rcd"
	origin_tech = Tc_MATERIALS + "=4;" + Tc_BLUESPACE + "=3;" + Tc_MAGNETS + "=4;" + Tc_POWERSTORAGE + "=4"
	equip_cooldown = 10
	energy_drain = 250
	range = MELEE|RANGED
	var/device = 0	//0 - RCD, 1 - RPD
	var/mode = 0 //0 - deconstruct, 1 - wall or floor, 2 - airlock.
	var/disabled = 0 //malf
	var/obj/item/device/rcd/rpd/mech/RPD
	var/obj/item/device/rcd/mech/RCD
	var/obj/item/weapon/wrench/socket/sock

/obj/item/mecha_parts/mecha_equipment/tool/red/New()
	..()
	RPD = new(src)
	RCD = new(src)
	sock = new(src)
	red_tool_list += src

/obj/item/mecha_parts/mecha_equipment/tool/red/Destroy()
	qdel(RPD)
	RPD = null
	qdel(RCD)
	RCD = null
	qdel(sock)
	sock = null
	red_tool_list -= src
	..()

/obj/item/mecha_parts/mecha_equipment/tool/red/action(atom/target)
	if(istype(target,/area/shuttle)||istype(target, /turf/space/transit))//>implying these are ever made -Sieve
		disabled = 1
	else
		disabled = 0
	if(!istype(target, /turf) && !istype(target, /obj/machinery/door/airlock) && !istype(target, /obj/machinery/atmospherics) && !istype(target, /obj/item/pipe))
		target = get_turf(target)
	if(!action_checks(target) || disabled || get_dist(chassis, target)>3)
		return
	var/obj/item/device/rcd/R = RCD
	if(device)
		R = RPD
		if((istype(target, /obj/machinery/atmospherics) && !istype(R.selected, /datum/rcd_schematic/paint_pipes)) || (istype(target, /obj/item/pipe) && !istype(R.selected, /datum/rcd_schematic/decon_pipes)))
			target.attackby(sock, chassis.occupant)
			return
	if(!R.selected)
		return
	R.busy  = TRUE // Busy to prevent switching schematic while it's in use.
	var/t = R.selected.attack(target, chassis.occupant)
	if(!t) // No errors
		if(device)
			chassis.use_power(energy_drain/5)
		else
			chassis.use_power(energy_drain)
	else
		occupant_message("<span class='warning'>\the [src]'s error light flickers[istext(t) ? ": [t]" : "."]</span>")

	R.busy = FALSE

/obj/item/mecha_parts/mecha_equipment/tool/red/Topic(href,href_list)
	if(..())
		return TRUE
	if(href_list["RCDmenu"])
		RCD.attack_self(chassis.occupant)
	if(href_list["RPDmenu"])
		RPD.attack_self(chassis.occupant)
	if(href_list["swap"])
		device = !device
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/tool/red/get_equip_info()
	if(device)
		return "[..()] \[<a href='?src=\ref[src];RPDmenu=0'>Open piping interface</a>\]\[<a href='?src=\ref[src];swap=0'>Switch to construction mode</a>\]"
	else
		return "[..()] \[<a href='?src=\ref[src];RCDmenu=0'>Open construction menu</a>\]\[<a href='?src=\ref[src];swap=0'>Switch to piping mode</a>\]"

/obj/item/mecha_parts/mecha_equipment/tool/red/alt_action()
	var/obj/item/device/rcd/activeDevice = device ? RPD : RCD
	activeDevice.attack_self(chassis.occupant)

/obj/item/mecha_parts/mecha_equipment/teleporter
	name = "\improper Exosuit-Mounted Teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	icon_state = "mecha_teleport"
	origin_tech = Tc_BLUESPACE + "=10"
	equip_cooldown = 150
	energy_drain = 1000
	range = RANGED

/obj/item/mecha_parts/mecha_equipment/teleporter/action(atom/target)
	if(!action_checks(target) || src.loc.z == map.zCentcomm)
		return
	var/turf/T = get_turf(target)
	if(T)
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_teleport(chassis, T, 4)
		do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/wormhole_generator
	name = "\improper Wormhole Generator"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	icon_state = "mecha_wholegen"
	origin_tech = Tc_BLUESPACE + "=3"
	equip_cooldown = 50
	energy_drain = 300
	range = RANGED


/obj/item/mecha_parts/mecha_equipment/wormhole_generator/action(atom/target)
	if(!action_checks(target) || src.loc.z == map.zCentcomm)
		return
	var/list/theareas = list()
	for(var/area/AR in orange(100, chassis))
		if(AR in theareas)
			continue
		theareas += AR
	if(!theareas.len)
		return
	var/area/thearea = pick(theareas)
	var/list/L = list()
	var/turf/pos = get_turf(src)
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density && pos.z == T.z)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(!L.len)
		return
	var/turf/target_turf = pick(L)
	if(!target_turf)
		return
	chassis.use_power(energy_drain)
	set_ready_state(0)
	var/obj/effect/portal/P = new /obj/effect/portal(get_turf(target))
	P.target = target_turf
	P.icon = 'icons/obj/objects.dmi'
	P.icon_state = "anom"
	P.name = "wormhole"
	do_after_cooldown()
	src = null
	spawn(rand(150,300))
		qdel(P)

/obj/item/mecha_parts/mecha_equipment/gravcatapult
	name = "\improper Gravitational Catapult"
	desc = "An exosuit mounted Gravitational Catapult."
	icon_state = "mecha_teleport"
	origin_tech = Tc_BLUESPACE + "=2;" + Tc_MAGNETS + "=3"
	equip_cooldown = 10
	energy_drain = 100
	range = MELEE|RANGED
	var/atom/movable/locked
	var/mode = 1 //1 - gravsling 2 - gravpush

	var/last_fired = 0  //Concept stolen from guns.
	var/fire_delay = 10 //Used to prevent spam-brute against humans.

/obj/item/mecha_parts/mecha_equipment/gravcatapult/action(atom/movable/target)

	if(world.time >= last_fired + fire_delay)
		last_fired = world.time
	else
		if (world.time % 3)
			occupant_message("<span class='warning'>[src] is not ready to fire again!")
		return 0

	switch(mode)
		if(1)
			if(!action_checks(target) && !locked)
				return
			if(!locked)
				if(!istype(target) || target.anchored)
					occupant_message("Unable to lock on [target]")
					return
				locked = target
				occupant_message("Locked on [target]")
				send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
				return
			else if(target!=locked)
				if(locked in view(chassis))
					locked.throw_at(target, 14, 1.5)
					locked = null
					send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
					set_ready_state(0)
					chassis.use_power(energy_drain)
					do_after_cooldown()
				else
					locked = null
					occupant_message("Lock on [locked] disengaged.")
					send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		if(2)
			if(!action_checks(target))
				return
			var/list/atoms = list()
			if(isturf(target))
				atoms = range(target,3)
			else
				atoms = orange(target,3)
			for(var/atom/movable/A in atoms)
				if(A.anchored)
					continue
				spawn(0)
					var/iter = 5-get_dist(A,target)
					for(var/i=0 to iter)
						step_away(A,target)
						sleep(2)
			set_ready_state(0)
			chassis.use_power(energy_drain)
			do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/gravcatapult/get_equip_info()
	return "[..()] [mode==1?"([locked||"Nothing"])":null] \[<a href='?src=\ref[src];mode=1'>S</a>|<a href='?src=\ref[src];mode=2'>P</a>\]"

/obj/item/mecha_parts/mecha_equipment/gravcatapult/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
	return

/obj/item/mecha_parts/mecha_equipment/gravcatapult/alt_action()
	if(mode == 1)
		mode = 2
		to_chat(chassis.occupant, "<span class='notice'>Push mode activated.</span>")
	else
		mode = 1
		to_chat(chassis.occupant, "<span class='notice'>Pull mode activated.</span>")

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster //what is that noise? A BAWWW from TK mutants.
	name = "\improper Armor Booster Module (Close Combat Weaponry)"
	desc = "Boosts exosuit armor against armed melee attacks. Requires energy to operate."
	icon_state = "mecha_abooster_ccw"
	origin_tech = Tc_MATERIALS + "=3"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8
	is_activateable = 0

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/can_attach(obj/mecha/M as obj)
	if(..())
		if(!istype(M, /obj/mecha/combat/honker) && !istype(M, /obj/mecha/working/clarke))
			if(!M.proc_res["dynattackby"])
				return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/attach(obj/mecha/M as obj)
	..()
	chassis.proc_res["dynattackby"] = src
	return

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/detach()
	chassis.proc_res["dynattackby"] = null
	..()
	return

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/get_equip_info()
	if(!chassis)
		return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name]"

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/proc/dynattackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!action_checks(user))
		return chassis.dynattackby(W,user)
	chassis.log_message("Attacked by [W]. Attacker - [user]")
	if(prob(chassis.deflect_chance*deflect_coeff))
		to_chat(user, "<span class='warning'>The [W] bounces off [chassis] armor.</span>")
		chassis.log_append_to_last("Armor saved.")
	else
		chassis.occupant_message("<span class='red'><b>[user] hits [chassis] with [W].</b></span>")
		user.visible_message("<span class='red'><b>[user] hits [chassis] with [W].</b></span>", "<span class='red'><b>You hit [src] with [W].</b></span>")
		chassis.take_damage(round(W.force*damage_coeff),W.damtype)
		chassis.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	set_ready_state(0)
	chassis.use_power(energy_drain)
	do_after_cooldown()
	return


/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	name = "\improper Armor Booster Module (Ranged Weaponry)"
	desc = "Boosts exosuit armor against ranged attacks. Completely blocks taser shots. Requires energy to operate."
	icon_state = "mecha_abooster_proj"
	origin_tech = Tc_MATERIALS + "=4"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8
	is_activateable = 0
	var/list/never_deflect = list(
		/obj/item/projectile/ion,
	)

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/can_attach(obj/mecha/M as obj)
	if(..())
		if(!istype(M, /obj/mecha/combat/honker) && !istype(M, /obj/mecha/working/clarke))
			if(!M.proc_res["dynbulletdamage"] && !M.proc_res["dynhitby"])
				return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/attach(obj/mecha/M as obj)
	..()
	chassis.proc_res["dynbulletdamage"] = src
	chassis.proc_res["dynhitby"] = src
	return

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/detach()
	chassis.proc_res["dynbulletdamage"] = null
	chassis.proc_res["dynhitby"] = null
	..()
	return

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/get_equip_info()
	if(!chassis)
		return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name]"

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/proc/dynbulletdamage(var/obj/item/projectile/Proj)
	if(!action_checks(src))
		return chassis.dynbulletdamage(Proj)
	if(prob(chassis.deflect_chance*deflect_coeff) && !is_type_in_list(Proj, never_deflect))
		chassis.occupant_message("<span class='notice'>The armor deflects incoming projectile.</span>")
		chassis.visible_message("<span class='warning'>\The [chassis.name] armor deflects the projectile!</span>")
		chassis.log_append_to_last("Armor saved.")
	else
		chassis.take_damage(round(Proj.damage*src.damage_coeff),Proj.flag)
		chassis.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		Proj.on_hit(chassis)
	set_ready_state(0)
	chassis.use_power(energy_drain)
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/proc/dynhitby(atom/movable/A)
	if(!action_checks(A))
		return chassis.dynhitby(A)
	if(prob(chassis.deflect_chance*deflect_coeff) || istype(A, /mob/living) || istype(A, /obj/item/mecha_parts/mecha_tracking))
		chassis.occupant_message("<span class='notice'>The [A] bounces off the armor.</span>")
		chassis.visible_message("The [A] bounces off the [chassis] armor")
		chassis.log_append_to_last("Armor saved.")
		if(istype(A, /mob/living))
			var/mob/living/M = A
			M.take_organ_damage(10)
	else if(istype(A, /obj))
		var/obj/O = A
		if(O.throwforce)
			chassis.take_damage(round(O.throwforce*damage_coeff))
			chassis.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	set_ready_state(0)
	chassis.use_power(energy_drain)
	do_after_cooldown()
	return


/obj/item/mecha_parts/mecha_equipment/repair_droid
	name = "\improper Repair Droid Module"
	desc = "Automated repair droid. Scans exosuit for damage and repairs it. Can fix almost all types of external or internal damage."
	icon_state = "repair_droid"
	origin_tech = Tc_MAGNETS + "=3;" + Tc_PROGRAMMING + "=3"
	equip_cooldown = 20
	energy_drain = 100
	range = 0
	var/health_boost = 2
	var/datum/global_iterator/pr_repair_droid
	var/icon/droid_overlay
	var/list/repairable_damage = list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH)

/obj/item/mecha_parts/mecha_equipment/repair_droid/New()
	..()
	pr_repair_droid = new /datum/global_iterator/mecha_repair_droid(list(src),0)
	pr_repair_droid.set_delay(equip_cooldown)
	return

/obj/item/mecha_parts/mecha_equipment/repair_droid/attach(obj/mecha/M as obj)
	..()
	droid_overlay = new(src.icon, icon_state = "repair_droid")
	M.overlays += droid_overlay
	linked_spell = new /spell/mech/repair(M, src)
	return

/obj/item/mecha_parts/mecha_equipment/repair_droid/Destroy()
	chassis.overlays -= droid_overlay
	qdel(pr_repair_droid)
	pr_repair_droid = null
	..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/detach()
	chassis.overlays -= droid_overlay
	pr_repair_droid.stop()
	..()
	return

/obj/item/mecha_parts/mecha_equipment/repair_droid/activate()
	chassis.overlays -= droid_overlay
	if(pr_repair_droid.toggle())
		droid_overlay = new(src.icon, icon_state = "repair_droid_a")
		log_message("Activated.")
	else
		droid_overlay = new(src.icon, icon_state = "repair_droid")
		log_message("Deactivated.")
		set_ready_state(1)
	chassis.overlays += droid_overlay

/obj/item/mecha_parts/mecha_equipment/repair_droid/get_equip_info()
	if(!chassis)
		return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] - <a href='?src=\ref[src];toggle_repairs=1'>[pr_repair_droid.active()?"Dea":"A"]ctivate</a>"

/obj/item/mecha_parts/mecha_equipment/repair_droid/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["toggle_repairs"])
		chassis.overlays -= droid_overlay
		if(pr_repair_droid.toggle())
			droid_overlay = new(src.icon, icon_state = "repair_droid_a")
			log_message("Activated.")
		else
			droid_overlay = new(src.icon, icon_state = "repair_droid")
			log_message("Deactivated.")
			set_ready_state(1)
		chassis.overlays += droid_overlay
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
	return

/datum/global_iterator/mecha_repair_droid/process(var/obj/item/mecha_parts/mecha_equipment/repair_droid/RD as obj)
	if(!RD.chassis)
		stop()
		RD.set_ready_state(1)
		return
	var/health_boost = RD.health_boost
	var/repaired = 0
	if(RD.chassis.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
		health_boost *= -2
	else if(RD.chassis.hasInternalDamage() && prob(15))
		for(var/int_dam_flag in RD.repairable_damage)
			if(RD.chassis.hasInternalDamage(int_dam_flag))
				RD.chassis.clearInternalDamage(int_dam_flag)
				repaired = 1
				break
	if(health_boost<0 || RD.chassis.health < initial(RD.chassis.health))
		RD.chassis.health += min(health_boost, initial(RD.chassis.health)-RD.chassis.health)
		repaired = 1
	if(repaired)
		if(RD.chassis.use_power(RD.energy_drain))
			RD.set_ready_state(0)
		else
			stop()
			RD.set_ready_state(1)
			return
	else
		RD.set_ready_state(1)
	return

/spell/mech/repair
	name = "Repair Droid Module"
	desc = "Automated repair droid. Scans exosuit for damage and repairs it. Can fix almost all types of external or internal damage."

/spell/mech/repair/cast(list/targets, mob/user)
	linked_equipment.activate()
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	name = "\improper Energy Relay Module"
	desc = "Wirelessly drains energy from any available power channel in area. The performance index is quite low."
	icon_state = "tesla"
	origin_tech = Tc_MAGNETS + "=4;" + Tc_SYNDICATE + "=2"
	equip_cooldown = 10
	energy_drain = 0
	range = 0
	var/datum/global_iterator/pr_energy_relay
	var/coeff = 100
	var/list/use_channels = list(EQUIP,ENVIRON,LIGHT)

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/New()
	..()
	pr_energy_relay = new /datum/global_iterator/mecha_energy_relay(list(src),0)
	pr_energy_relay.set_delay(equip_cooldown)
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Destroy()
	qdel(pr_energy_relay)
	pr_energy_relay = null
	..()

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/detach()
	pr_energy_relay.stop()
//		chassis.proc_res["dynusepower"] = null
	chassis.proc_res["dyngetcharge"] = null
	..()
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/attach(obj/mecha/M)
	..()
	chassis.proc_res["dyngetcharge"] = src
//		chassis.proc_res["dynusepower"] = src
	linked_spell = new /spell/mech/tesla(M, src)
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/can_attach(obj/mecha/M)
	if(..())
		if(!M.proc_res["dyngetcharge"])// && !M.proc_res["dynusepower"])
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/dyngetcharge()
	if(equip_ready) //disabled
		return chassis.dyngetcharge()
	var/area/A = get_area(chassis)
	var/pow_chan = get_power_channel(A)
	var/charge = 0
	if(pow_chan)
		charge = 1000 //making magic
	else
		return chassis.dyngetcharge()
	return charge

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/get_power_channel(var/area/A)
	var/pow_chan
	if(A)
		for(var/c in use_channels)
			if(A.powered(c))
				pow_chan = c
				break
	return pow_chan

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["toggle_relay"])
		activate()
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/get_equip_info()
	if(!chassis)
		return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] - <a href='?src=\ref[src];toggle_relay=1'>[pr_energy_relay.active()?"Dea":"A"]ctivate</a>"

/*
/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/dynusepower(amount)
	if(!equip_ready) //enabled
		var/area/A = get_area(chassis)
		var/pow_chan = get_power_channel(A)
		if(pow_chan)
			A.master.use_power(amount*coeff, pow_chan)
			return 1
	return chassis.dynusepower(amount)
*/

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/activate()
	if(pr_energy_relay.toggle())
		set_ready_state(0)
		log_message("Activated.")
		to_chat(chassis.occupant, "<span class='notice'>Relay enabled.</span>")
	else
		set_ready_state(1)
		log_message("Deactivated.")
		to_chat(chassis.occupant, "<span class='notice'>Relay disabled.</span>")

/spell/mech/tesla
	name = "Tesla Energy Relay"
	desc = "Wirelessly drains energy from any available power channel in area. The performance index is quite low."

/spell/mech/tesla/cast(list/targets, mob/user)
	linked_equipment.activate()

/datum/global_iterator/mecha_energy_relay/process(var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/ER)
	if(!ER.chassis || ER.chassis.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
		stop()
		ER.set_ready_state(1)
		return
	var/cur_charge = ER.chassis.get_charge()
	if(isnull(cur_charge) || !ER.chassis.cell)
		stop()
		ER.set_ready_state(1)
		ER.occupant_message("No powercell detected.")
		return
	if(cur_charge<ER.chassis.cell.maxcharge)
		var/area/A = get_area(ER.chassis)
		if(A)
			var/pow_chan
			for(var/c in list(EQUIP,ENVIRON,LIGHT))
				if(A.powered(c))
					pow_chan = c
					break
			if(pow_chan)
				var/delta = min(12, ER.chassis.cell.maxcharge-cur_charge)
				ER.chassis.give_power(delta)
				A.use_power(delta*ER.coeff, pow_chan)
	return


/obj/item/mecha_parts/mecha_equipment/generator
	name = "\improper Plasma Converter Module"
	desc = "Generates power using solid plasma as fuel. Pollutes the environment."
	icon_state = "tesla"
	origin_tech = Tc_PLASMATECH + "=2;" + Tc_POWERSTORAGE + "=2;" + Tc_ENGINEERING + "=1"
	equip_cooldown = 10
	energy_drain = 0
	range = MELEE
	var/datum/global_iterator/pr_mech_generator
	var/coeff = 100
	var/obj/item/stack/sheet/fuel
	var/max_fuel = 150000
	var/fuel_per_cycle_idle = 100
	var/fuel_per_cycle_active = 500
	var/power_per_cycle = 20
	reliability = 1000

/obj/item/mecha_parts/mecha_equipment/generator/New()
	..()
	init()
	return

/obj/item/mecha_parts/mecha_equipment/generator/Destroy()
	qdel(pr_mech_generator)
	pr_mech_generator = null
	..()

/obj/item/mecha_parts/mecha_equipment/generator/proc/init()
	fuel = new /obj/item/stack/sheet/mineral/plasma(src)
	fuel.amount = 0
	pr_mech_generator = new /datum/global_iterator/mecha_generator(list(src),0)
	pr_mech_generator.set_delay(equip_cooldown)
	return

/obj/item/mecha_parts/mecha_equipment/generator/detach()
	pr_mech_generator.stop()
	..()
	return

/obj/item/mecha_parts/mecha_equipment/generator/alt_action()
	if(pr_mech_generator.toggle())
		set_ready_state(0)
		log_message("Activated.")
	else
		set_ready_state(1)
		log_message("Deactivated.")

/obj/item/mecha_parts/mecha_equipment/generator/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["toggle"])
		if(pr_mech_generator.toggle())
			set_ready_state(0)
			log_message("Activated.")
		else
			set_ready_state(1)
			log_message("Deactivated.")
	return

/obj/item/mecha_parts/mecha_equipment/generator/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[[fuel]: [round(fuel.amount*fuel.perunit,0.1)] cm<sup>3</sup>\] - <a href='?src=\ref[src];toggle=1'>[pr_mech_generator.active()?"Dea":"A"]ctivate</a>"
	return

/obj/item/mecha_parts/mecha_equipment/generator/action(target)
	if(chassis)
		var/result = load_fuel(target)
		var/message
		if(isnull(result))
			message = "<span class='red'>[fuel] traces in target minimal. [target] cannot be used as fuel.</span>"
		else if(!result)
			message = "Unit is full."
		else
			message = "[result] unit\s of [fuel] successfully loaded."
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		occupant_message(message)
	return

/obj/item/mecha_parts/mecha_equipment/generator/proc/load_fuel(var/obj/item/stack/sheet/P)
	if(P.type == fuel.type && P.amount)
		var/to_load = max(max_fuel - fuel.amount*fuel.perunit,0)
		if(to_load)
			var/units = min(max(round(to_load / P.perunit),1),P.amount)
			if(units)
				fuel.amount += units
				P.use(units)
				return units
		else
			return 0
	return

/obj/item/mecha_parts/mecha_equipment/generator/attackby(weapon,mob/user)
	var/result = load_fuel(weapon)
	if(isnull(result))
		user.visible_message("[user] tries to shove [weapon] into [src]. What a dumb-ass.","<span class='red'>[fuel] traces minimal. [weapon] cannot be used as fuel.</span>")
	else if(!result)
		to_chat(user, "Unit is full.")
	else
		user.visible_message("[user] loads [src] with [fuel].","[result] unit\s of [fuel] successfully loaded.")
	return

/obj/item/mecha_parts/mecha_equipment/generator/critfail()
	..()
	var/turf/simulated/T = get_turf(src)
	if(!T)
		return
	var/datum/gas_mixture/GM = new
	if(prob(10))
		GM.temperature = 1500+T0C //should be enough to start a fire
		GM.adjust_gas(GAS_PLASMA, 100)
		T.visible_message("The [src] suddenly disgorges a cloud of heated plasma.")
		qdel(src)
	else
		GM.temperature = istype(T) ? T.air.temperature : T20C
		GM.adjust_gas(GAS_PLASMA, 5)
		T.visible_message("The [src] suddenly disgorges a cloud of plasma.")
	T.assume_air(GM)
	return

/datum/global_iterator/mecha_generator/process(var/obj/item/mecha_parts/mecha_equipment/generator/EG)
	if(!EG.chassis)
		stop()
		EG.set_ready_state(1)
		return 0
	if(EG.fuel.amount<=0)
		stop()
		EG.log_message("Deactivated - no fuel.")
		EG.set_ready_state(1)
		return 0
	if(anyprob(EG.reliability))
		EG.critfail()
		stop()
		return 0
	var/cur_charge = EG.chassis.get_charge()
	if(isnull(cur_charge))
		EG.set_ready_state(1)
		EG.occupant_message("No powercell detected.")
		EG.log_message("Deactivated.")
		stop()
		return 0
	var/use_fuel = EG.fuel_per_cycle_idle
	if(cur_charge<EG.chassis.cell.maxcharge)
		use_fuel = EG.fuel_per_cycle_active
		EG.chassis.give_power(EG.power_per_cycle)
	EG.fuel.amount -= min(use_fuel/EG.fuel.perunit,EG.fuel.amount)
	EG.update_equip_info()
	return 1

/obj/item/mecha_parts/mecha_equipment/generator/nuclear
	name = "\improper ExoNuclear Reactor"
	desc = "Generates power using uranium. Pollutes the environment."
	icon_state = "tesla"
	origin_tech = Tc_POWERSTORAGE + "=3;" + Tc_ENGINEERING + "=3"
	max_fuel = 50000
	fuel_per_cycle_idle = 10
	fuel_per_cycle_active = 30
	power_per_cycle = 50
	var/rad_per_cycle = 0.3
	reliability = 1000

/obj/item/mecha_parts/mecha_equipment/generator/nuclear/init()
	fuel = new /obj/item/stack/sheet/mineral/uranium(src)
	fuel.amount = 0
	pr_mech_generator = new /datum/global_iterator/mecha_generator/nuclear(list(src),0)
	pr_mech_generator.set_delay(equip_cooldown)
	return

/obj/item/mecha_parts/mecha_equipment/generator/nuclear/critfail()
	return

/datum/global_iterator/mecha_generator/nuclear/process(var/obj/item/mecha_parts/mecha_equipment/generator/nuclear/EG)
	if(..())
		for(var/mob/living/carbon/M in view(EG.chassis))
			M.apply_radiation(EG.rad_per_cycle*3, RAD_EXTERNAL)
	return 1

/spell/mech/generator
	name = "\improper Plasma Converter Module"
	desc = "Generates power using solid plasma as fuel. Pollutes the environment."

/spell/mech/generator/nuclear
	name = "\improper ExoNuclear Reactor"
	desc = "Generates power using uranium. Pollutes the environment."

/spell/mech/generator/New(var/obj/mecha/M, var/obj/item/mecha_parts/mecha_equipment/generator/ME)
	src.linked_mech = M
	charge_counter = charge_max
	name = ME.name

/spell/mech/generator/cast(list/targets, mob/user)
	linked_equipment.activate()

//This is pretty much just for the death-ripley so that it is harmless
/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp
	name = "\improper KILL CLAMP"
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 0
	var/dam_force = 0
	var/obj/mecha/working/ripley/cargo_holder

/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp/can_attach(obj/mecha/working/ripley/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp/attach(obj/mecha/M as obj)
	..()
	cargo_holder = M
	return

/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp/action(atom/target)
	//this whole thing is seriously fucking stupid and should be a child of the clamp
	if(!action_checks(target))
		return
	if(!cargo_holder)
		return
	if(istype(target,/obj))
		var/obj/O = target
		if(!O.anchored)
			if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
				chassis.occupant_message("You lift [target] and start to load it into cargo compartment.")
				chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
				set_ready_state(0)
				chassis.use_power(energy_drain)
				O.anchored = 1
				var/T = chassis.loc
				if(do_after_cooldown(target))
					if(T == chassis.loc && src == chassis.selected)
						cargo_holder.cargo += O
						O.forceMove(chassis)
						O.anchored = 0
						chassis.occupant_message("<span class='notice'>[target] successfully loaded.</span>")
						chassis.log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
					else
						chassis.occupant_message("<span class='red'>You must hold still while handling objects.</span>")
						O.anchored = initial(O.anchored)
			else
				chassis.occupant_message("<span class='red'>Not enough room in cargo compartment.</span>")
		else
			chassis.occupant_message("<span class='red'>[target] is firmly secured.</span>")

	else if(istype(target,/mob/living))
		var/mob/living/M = target
		if(M.stat>1)
			return
		if(chassis.occupant.a_intent == I_HURT)
			chassis.occupant_message("<span class='warning'>You obliterate [target] with [src.name], leaving blood and guts everywhere.</span>")
			chassis.visible_message("<span class='warning'>[chassis] destroys [target] in an unholy fury.</span>")
		if(chassis.occupant.a_intent == I_DISARM)
			chassis.occupant_message("<span class='warning'>You tear [target]'s limbs off with [src.name].</span>")
			chassis.visible_message("<span class='warning'>[chassis] rips [target]'s arms off.</span>")
		else
			step_away(M,chassis)
			chassis.occupant_message("You smash into [target], sending them flying.")
			chassis.visible_message("[chassis] tosses [target] like a piece of paper.")
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_after_cooldown()
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/switchtool
	name = "\improper Exosuit-Mounted Engineering Switchtool"
	desc = "An exosuit-mounted Engineering switchtool. (Can be attached to: Engineering exosuits)"
	icon_state = "mecha_switchtool"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_PROGRAMMING + "=3;" + Tc_POWERSTORAGE + "=2"
	equip_cooldown = 10
	energy_drain = 50
	range = MELEE|RANGED
	var/datum/global_iterator/pr_switchtool
	var/obj/item/weapon/switchtool/engineering/mech/switchtool

/obj/item/mecha_parts/mecha_equipment/tool/switchtool/can_attach(var/obj/mecha/working/clarke/M)
	if(..())
		if(istype(M))
			return 1

/obj/item/mecha_parts/mecha_equipment/tool/switchtool/New()
	..()
	switchtool = new(src)
	pr_switchtool = new /datum/global_iterator/mecha_switchtool(list(src),0)
	pr_switchtool.set_delay(equip_cooldown)
	pr_switchtool.toggle()

/obj/item/mecha_parts/mecha_equipment/tool/switchtool/Destroy()
	qdel(switchtool)
	switchtool = null
	qdel(pr_switchtool)
	pr_switchtool = null
	..()

/obj/item/mecha_parts/mecha_equipment/tool/switchtool/action(atom/target)
	if(switchtool.deployed)
		switchtool.preattack(target, chassis.occupant, chassis.Adjacent(target))
		chassis.use_power(energy_drain)

/obj/item/mecha_parts/mecha_equipment/tool/switchtool/Topic(href,href_list)
	if(..())
		return TRUE
	if(href_list["change"])
		if(switchtool.deployed)
			switchtool.attack_self(chassis.occupant)
		switchtool.attack_self(chassis.occupant)
	if(href_list["refill"])
		pr_switchtool.toggle()
		occupant_message("<span class='notice'>Automatic tool refilling activated.</span>")
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/tool/switchtool/alt_action()
	switchtool.attack_self(chassis.occupant)

/obj/item/mecha_parts/mecha_equipment/tool/switchtool/get_equip_info()
	return "[..()] Current tool: [switchtool.deployed ? "[switchtool.deployed]" : "None"] \[<a href='?src=\ref[src];change=0'>change</a>\] [pr_switchtool.active() ? "" : "\[<a href='?src=\ref[src];refill=0'>activate refilling</a>\]"]"

/datum/global_iterator/mecha_switchtool/process(var/obj/item/mecha_parts/mecha_equipment/tool/switchtool/mech_switchtool)
	if(!mech_switchtool.chassis || mech_switchtool.chassis.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
		if(mech_switchtool.chassis)
			mech_switchtool.occupant_message("<span class='warning'>Electrical systems compromised. Automatic tool refilling deactivated.</span>")
		stop()
		mech_switchtool.set_ready_state(1)
		return
	if(!mech_switchtool.chassis.get_charge())
		stop()
		mech_switchtool.set_ready_state(1)
		mech_switchtool.occupant_message("No powercell detected.")
		return
	for(var/obj/item/I in mech_switchtool.switchtool.stored_modules)
		if(iswelder(I))
			var/obj/item/weapon/weldingtool/W = I
			if(W.reagents.total_volume <= W.max_fuel-10)
				W.reagents.add_reagent(FUEL, 10)
				mech_switchtool.chassis.use_power(mech_switchtool.energy_drain/2)
		else if(iscablecoil(I))
			var/obj/item/stack/cable_coil/C = I
			if(C.amount <= C.max_amount-5)
				C.add(5)
				mech_switchtool.chassis.use_power(mech_switchtool.energy_drain/2)
		else if(issolder(I))
			var/obj/item/weapon/solder/S = I
			if(S.reagents.total_volume < S.max_fuel-5)
				S.reagents.add_reagent(SACID, 5)
				mech_switchtool.chassis.use_power(mech_switchtool.energy_drain)
		else if(issilicatesprayer(I))
			var/obj/item/device/silicate_sprayer/SI = I
			if(SI.reagents.total_volume < SI.max_silicate-5)
				SI.reagents.add_reagent(SILICATE, 5)
				mech_switchtool.chassis.use_power(mech_switchtool.energy_drain/2)

/obj/item/mecha_parts/mecha_equipment/tool/tiler
	name = "\improper Automatic Floor Tiler"
	desc = "An exosuit-mounted Automatic Floor Tiler. (Can be attached to: Any exosuit)"
	icon_state = "mecha_tiler"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=3;" + Tc_MAGNETS + "=2;" + Tc_POWERSTORAGE + "=2"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/plating_active = FALSE
	var/tiling_active = FALSE

/obj/item/mecha_parts/mecha_equipment/tool/tiler/Topic(href,href_list)
	if(..())
		return TRUE
	if(href_list["toggle_plating"])
		plating_active = !plating_active
	if(href_list["toggle_tiling"])
		tiling_active = !tiling_active
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/tool/tiler/alt_action()
	if(plating_active || tiling_active)
		plating_active = 0
		tiling_active = 0
	else
		plating_active = 1
		tiling_active = 1
	to_chat(chassis.occupant, "Plating and tiling modes [plating_active?"enabled":"disabled"]")
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/tool/tiler/get_equip_info()
	return "[..()] \[<a href='?src=\ref[src];toggle_plating=0'>[plating_active ? "Deactivate" : "Activate"] automatic plating</a>\]\[<a href='?src=\ref[src];toggle_tiling=0'>[tiling_active ? "Deactivate" : "Activate"] automatic tiling</a>\]"

/obj/item/mecha_parts/mecha_equipment/tool/tiler/on_mech_step()
	var/turf/T = get_turf(src)
	if(T.is_plating() && tiling_active)
		T.ChangeTurf(/turf/simulated/floor)
		playsound(T, 'sound/weapons/Genhit.ogg', 50, 1)
		return
	if(!plating_active)
		return
	var/canbuild = T.canBuildPlating()
	if(istype(T, /turf/simulated/floor/foamedmetal))
		canbuild = BUILD_IGNORE
	if(canbuild == BUILD_SUCCESS)
		var/obj/structure/lattice/L = locate(/obj/structure/lattice) in T
		if(!istype(L))
			return
		qdel(L)
	else if(canbuild != BUILD_IGNORE)
		return

	playsound(T, 'sound/weapons/Genhit.ogg', 50, 1)
	if(istype(T,/turf/space) || istype(T,/turf/unsimulated))
		T.ChangeTurf(/turf/simulated/floor/plating/airless)
	else
		T.ChangeTurf(/turf/simulated/floor/plating)

/obj/item/mecha_parts/mecha_equipment/tool/collector
	name = "\improper Exosuit-Mounted Radiation Collector Array"
	desc = "An exosuit-mounted Radiation Collector Array. (Can be attached to: Any exosuit)"
	icon_state = "mecha_collector"
	origin_tech = Tc_PLASMATECH + "=3;" + Tc_MAGNETS + "=2;" + Tc_POWERSTORAGE + "=4"
	equip_cooldown = 10
	energy_drain = 0
	range = MELEE
	var/active = FALSE
	var/obj/machinery/power/rad_collector/mech/collector

/obj/item/mecha_parts/mecha_equipment/tool/collector/New()
	..()
	collector = new(src)
	collector.connected_module = src

/obj/item/mecha_parts/mecha_equipment/tool/collector/Destroy()
	qdel(collector)
	collector = null
	..()

/obj/item/mecha_parts/mecha_equipment/tool/collector/action(atom/target)
	var/obj/item/weapon/tank/plasma/plas = target
	if(istype(plas))
		if(collector.P)
			occupant_message("There is already a tank in the radiation collector array.")
			return
		plas.forceMove(collector)
		collector.P = target
		occupant_message("You insert \the [target] into the radiation collector array.")
		update_equip_info()

/obj/item/mecha_parts/mecha_equipment/tool/collector/Topic(href,href_list)
	if(..())
		return TRUE
	if(href_list["toggle"])
		collector.toggle_power()
		occupant_message("Radiation collector array [collector.active ? "activated" : "deactivated"].")
	if(href_list["eject"])
		collector.eject()
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/tool/collector/get_equip_info()
	if(!collector.P)
		return "[..()] No tank loaded."
	if(collector.P.air_contents[GAS_PLASMA] <= 0)
		return "[..()] ERROR: Tank empty. \[<a href='?src=\ref[src];eject=0'>eject tank</a>\]"
	return "[..()] \[<a href='?src=\ref[src];toggle=0'>[collector.active ? "Deactivate" : "Activate"] radiation collector array</a>\]\[<a href='?src=\ref[src];eject=0'>eject tank</a>\]"

#undef MECHDRILL_SAND_SPEED
#undef MECHDRILL_ROCK_SPEED
