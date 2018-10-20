// honk
#define DAMAGE			1
#define FIRE			2

/obj/spacepod
	name = "\improper space pod"
	desc = "A space pod meant for space travel."
	icon = 'icons/48x48/pods.dmi'
	density = 1 //Dense. To raise the heat.
	opacity = 0
	anchored = 1
	layer = ABOVE_DOOR_LAYER
	infra_luminosity = 15
	internal_gravity = 1 // Can move in 0-gravity
	var/mob/living/carbon/occupant //The pilot
	var/passenger_limit = 1 //Upper limit for how many passengers are allowed
	var/passengers_allowed = 1 //If the pilot allows people to jump in the side seats.
	var/list/passengers = list()
	var/datum/spacepod/equipment/equipment_system
	var/obj/item/weapon/cell/battery
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/effect/effect/system/trail/space_trail/ion_trail
	var/use_internal_tank = 0
	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_give_air //moves air from tank to cabin
	var/hatch_open = 0
	var/next_firetime = 0
	var/list/pod_overlays
	var/health = 400
	var/maxHealth = 400
	appearance_flags = LONG_GLIDE

	var/datum/delay_controller/move_delayer = new(0.1, ARBITRARILY_LARGE_NUMBER) //See setup.dm, 12
	var/passenger_fire = 0 //Whether or not a passenger can fire weapons attached to this pod
	var/movement_delay = 0.4 //Speed of the vehicle decreases as this value increases. Anything above 6 is slow, 1 is fast and 0 is very fast
	var/list/actions_types = list(
		/datum/action/spacepod/pilot/toggle_passengers,\
		/datum/action/spacepod/pilot/toggle_passenger_weaponry) //Actions to create and hold for the pilot
	var/list/actions_types_pilot = list(/datum/action/spacepod/fire_weapons) //Actions to create when a pilot boards, deleted upon leaving
	var/list/actions_types_passenger = list(
		/datum/action/spacepod/fire_weapons,\
		/datum/action/spacepod/passenger/assume_control) //Actions to create when a passenger boards, deleted upon leaving
	var/list/actions = list()

/obj/spacepod/get_cell()
	return battery

/obj/spacepod/New()
	. = ..()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="pod_damage")
		pod_overlays[FIRE] = image(icon, icon_state="pod_fire")
	bound_width = 2*WORLD_ICON_SIZE
	bound_height = 2*WORLD_ICON_SIZE
	dir = EAST
	battery = new /obj/item/weapon/cell/high()
	add_cabin()
	add_airtank()
	src.ion_trail = new /datum/effect/effect/system/trail/space_trail()
	src.ion_trail.set_up(src)
	src.ion_trail.start()
	src.use_internal_tank = 1
	pr_int_temp_processor = new /datum/global_iterator/pod_preserve_temp(list(src))
	pr_give_air = new /datum/global_iterator/pod_tank_give_air(list(src))
	equipment_system = new(src)
	for(var/path in actions_types)
		var/datum/action/A = new path(src)
		actions.Add(A)


/obj/spacepod/Destroy()
	if(src.occupant)
		move_pilot_outside(occupant)
		src.occupant.gib()
	if(passengers.len)
		for(var/mob/living/L in passengers)
			move_passenger_outside(L)
			L.gib()
	if(actions.len)
		for(var/datum/action/A in actions)
			actions.Remove(A)
			qdel(A)
	qdel(pr_int_temp_processor)
	pr_int_temp_processor = null
	qdel(pr_give_air)
	pr_give_air = null
	qdel(equipment_system)
	equipment_system = null
	qdel(battery)
	battery = null
	qdel(cabin_air)
	cabin_air = null
	qdel(ion_trail)
	ion_trail = null
	qdel(pod_overlays[DAMAGE])
	qdel(pod_overlays[FIRE])
	pod_overlays = null
	qdel(internal_tank)
	internal_tank = null
	..()

/obj/spacepod/proc/update_icons()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="pod_damage")
		pod_overlays[FIRE] = image(icon, icon_state="pod_fire")

	if(health <= round(initial(health)/2))
		overlays += pod_overlays[DAMAGE]
		if(health <= round(initial(health)/4))
			overlays += pod_overlays[FIRE]
		else
			overlays -= pod_overlays[FIRE]
	else
		overlays -= pod_overlays[DAMAGE]

/obj/spacepod/bullet_act(var/obj/item/projectile/P)
	if(P.damage && !P.nodamage)
		adjust_health(P.damage)

/obj/spacepod/proc/adjust_health(var/damage)
	var/oldhealth = health
	health = Clamp(health-damage,0, maxHealth)
	var/percentage = (health / initial(health)) * 100
	if(occupant && oldhealth > health && percentage <= 25 && percentage > 0)
		occupant.playsound_local(occupant, 'sound/effects/engine_alert2.ogg', 50, 0, 0, 0, 0)
	if(occupant && oldhealth > health && !health)
		occupant.playsound_local(occupant, 'sound/effects/engine_alert1.ogg', 50, 0, 0, 0, 0)
	if(health <= 0)
		spawn(0)
			if(occupant)
				to_chat(occupant, "<big><span class='warning'>Critical damage to the vessel detected, core explosion imminent!</span></big>")
			for(var/i = 10, i >= 0; --i)
				if(occupant)
					to_chat(occupant, "<span class='warning'>[i]</span>")
				if(i == 0)
					explosion(loc, 2, 4, 8)
				sleep(10)

	update_icons()

/obj/spacepod/ex_act(severity)
	switch(severity)
		if(1)
			var/mob/living/carbon/human/H = occupant
			if(H)
				move_pilot_outside(H, get_turf(src))
				H.ex_act(severity + 1)
				to_chat(H, "<span class='warning'>You are forcefully thrown from \the [src]!</span>")
			if(passengers.len)
				for(var/mob/living/L in passengers)
					move_passenger_outside(L, get_turf(src))
					L.ex_act(severity + 1)
					to_chat(L, "<span class='warning'>You are forcefully thrown from \the [src]!</span>")
					passengers.Remove(L)
			qdel(ion_trail)
			ion_trail = null // Should be nulled by qdel src in next line but OH WELL
			qdel(src)
		if(2)
			adjust_health(100)
		if(3)
			if(prob(40))
				adjust_health(50)

/obj/spacepod/attackby(obj/item/W, mob/user)
	if(iscrowbar(W))
		hatch_open = !hatch_open
		to_chat(user, "<span class='notice'>You [hatch_open ? "open" : "close"] the maintenance hatch.</span>")
		return
	if(health < maxHealth && iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.do_weld(user, src, 30, 5))
			to_chat(user, "<span class='notice'>You patch up \the [src].</span>")
			adjust_health(-rand(15,30))
			return

	if(istype(W, /obj/item/weapon/cell))
		if(!hatch_open)
			return ..()
		if(battery)
			to_chat(user, "<span class='notice'>The pod already has a battery.</span>")
			return
		if(user.drop_item(W, src))
			battery = W
			return
	if(istype(W, /obj/item/device/spacepod_equipment))
		if(!hatch_open)
			return ..()
		if(!equipment_system)
			to_chat(user, "<span class='warning'>The pod has no equipment datum, yell at pomf</span>")
			return
		if(istype(W, /obj/item/device/spacepod_equipment/weaponry))
			if(!equipment_system.weapons_allowed)
				to_chat(user, "<span class='notice'>The pod model does not allow for weapons to be installed.</span>")
				return
			if(equipment_system.weapon_system)
				to_chat(user, "<span class='notice'>The pod already has a weapon system, remove it first.</span>")
				return
			else
				if(user.drop_item(W, src))
					to_chat(user, "<span class='notice'>You insert \the [W] into the equipment system.</span>")
					equipment_system.weapon_system = W
					equipment_system.weapon_system.my_atom = src
					//new/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapon_system(src, equipment_system.weapon_system.verb_name, equipment_system.weapon_system.verb_desc) //Yes, it has to be referenced like that. W.verb_name/desc doesn't compile.
					return

	if(W.force)
		visible_message("<span class = 'warning'>\The [user] hits \the [src] with \the [W]</span>")
		adjust_health(W.force)
		W.on_attack(src, user)


/obj/spacepod/attack_hand(mob/user as mob)
	if(!hatch_open)
		return ..()
	if(!equipment_system || !istype(equipment_system))
		to_chat(user, "<span class='warning'>The pod has no equipment datum, or is the wrong type, yell at pomf.</span>")
		return
	var/list/possible = list()
	if(battery)
		possible.Add("Energy Cell")
	if(equipment_system.weapon_system)
		possible.Add("Weapon System")
	/* Not yet implemented
	if(equipment_system.engine_system)
		possible.Add("Engine System")
	if(equipment_system.shield_system)
		possible.Add("Shield System")
	*/
	var/obj/item/device/spacepod_equipment/SPE
	switch(input(user, "Remove which equipment?", null, null) as null|anything in possible)
		if("Energy Cell")
			if(user.put_in_any_hand_if_possible(battery))
				to_chat(user, "<span class='notice'>You remove \the [battery] from the space pod</span>")
				battery = null
		if("Weapon System")
			SPE = equipment_system.weapon_system
			if(user.put_in_any_hand_if_possible(SPE))
				to_chat(user, "<span class='notice'>You remove \the [SPE] from the equipment system.</span>")
				SPE.my_atom = null
				equipment_system.weapon_system = null
				verbs -= typesof(/obj/item/device/spacepod_equipment/weaponry/proc)
			else
				to_chat(user, "<span class='warning'>You need an open hand to do that.</span>")
		/*
		if("engine system")
			SPE = equipment_system.engine_system
			if(user.put_in_any_hand_if_possible(SPE))
				to_chat(user, "<span class='notice'>You remove \the [SPE] from the equipment system.</span>")
				equipment_system.engine_system = null
			else
				to_chat(user, "<span class='warning'>You need an open hand to do that.</span>")
		if("shield system")
			SPE = equipment_system.shield_system
			if(user.put_in_any_hand_if_possible(SPE))
				to_chat(user, "<span class='notice'>You remove \the [SPE] from the equipment system.</span>")
				equipment_system.shield_system = null
			else
				to_chat(user, "<span class='warning'>You need an open hand to do that.</span>")
		*/

/obj/spacepod/civilian
	icon_state = "pod_civ"
	desc = "A sleek civilian space pod."
/obj/spacepod/random
	icon_state = "pod_civ"
// placeholder
/obj/spacepod/random/New()
	..()
	icon_state = pick("pod_civ", "pod_black", "pod_mil", "pod_synd", "pod_gold", "pod_industrial")
	switch(icon_state)
		if("pod_civ")
			desc = "A sleek civilian space pod."
		if("pod_black")
			desc = "A plain black space pod without any distinctive markings."
		if("pod_mil")
			desc = "A dark grey space pod bearing the Nanotrasen military insignia."
		if("pod_synd")
			desc = "A menacing military space pod with \"Fuck NT\" stenciled onto the side."
		if("pod_gold")
			desc = "A civilian space pod with a gold body. It must have cost somebody a pretty penny."
		if("pod_industrial")
			desc = "A space pod with signs of wear on the plating. A spaceproof sticker designates it for performing industrial tasks."

/obj/spacepod/verb/toggle_internal_tank()
	set name = "Toggle internal airtank usage"
	set category = "Spacepod"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.occupant)
		return
	src.use_internal_tank = !src.use_internal_tank
	to_chat(src.occupant, "<span class='notice'>Now taking air from [use_internal_tank?"internal airtank":"environment"].</span>")
	return

/obj/spacepod/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.adjust_multi(
		GAS_OXYGEN, O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature),
		GAS_NITROGEN, N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature))
	return cabin_air

/obj/spacepod/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/spacepod/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()
	return

/obj/spacepod/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)
	return

/obj/spacepod/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/spacepod/proc/return_pressure()
	. = 0
	if(use_internal_tank)
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()
	return

/obj/spacepod/proc/return_temperature()
	. = 0
	if(use_internal_tank)
		. = cabin_air.return_temperature()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_temperature()
	return

/obj/spacepod/MouseDropTo(mob/M, mob/user)
	if(M != user)
		return
	if(!Adjacent(M) || !Adjacent(user))
		return
	move_inside(M, user)

/obj/spacepod/MouseDropFrom(atom/over)
	if(!usr || !over)
		return
	if(!Adjacent(usr) || !Adjacent(over))
		return
	if(occupant != usr && !passengers.Find(usr))
		return ..() //Handle mousedrop T
	var/turf/T = get_turf(over)
	if(!Adjacent(T) || T.density)
		return
	for(var/atom/movable/A in T.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	if(occupant == usr)
		move_pilot_outside(usr, T)
	else if(passengers.Find(usr))
		move_passenger_outside(usr, T)

/obj/spacepod/verb/move_inside()
	set category = "Spacepod"
	set name = "Enter / Exit Pod"
	set src in oview(1)

	if(occupant)
		if(occupant == usr)
			move_pilot_outside(usr)
			return
		else if(passengers.len && passengers.Find(usr))
			move_passenger_outside(usr)
			return
		else if (!passenger_limit || passengers.len > passenger_limit)
			to_chat(usr, "<span class='notice'><B>\The [src] is already occupied!</B></span>")
			return

	if(usr.incapacitated() || usr.lying) //are you cuffed, dying, lying, stunned or other
		return
	if (!ishigherbeing(usr))
		return
/*
	if (usr.abiotic())
		to_chat(usr, "<span class='notice'><B>Subject cannot have abiotic items on.</B></span>")
		return
*/
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting the life sucked out of you by \the [M]!")
			return
//	to_chat(usr, "You start climbing into [src.name]")

	visible_message("<span class='notice'>[usr] starts to climb into \the [src].</span>")

	if(enter_after(40,usr))
		if(!src.occupant)
			move_pilot_inside(usr)
		else if(src.occupant!=usr)
			if(passengers.len < passenger_limit)
				move_passenger_inside(usr)
				return
			to_chat(usr, "[src.occupant] was faster. Better luck next time, loser.")
	else
		to_chat(usr, "You stop entering the pod.")
	return

/obj/spacepod/proc/enter_after(delay as num, var/mob/user as mob, var/numticks = 5)
	var/delayfraction = delay/numticks

	var/turf/T = user.loc

	for(var/i = 0, i<numticks, i++)
		sleep(delayfraction)
		if(!src || !user || !user.canmove || !(user.loc == T))
			return 0

	return 1

/datum/global_iterator/pod_preserve_temp  //normalizing cabin air temperature to 20 degrees celsium
	delay = 20

	process(var/obj/spacepod/spacepod)
		if(spacepod.cabin_air && spacepod.cabin_air.return_volume() > 0)
			var/delta = spacepod.cabin_air.temperature - T20C
			spacepod.cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))
		return

/datum/global_iterator/pod_tank_give_air
	delay = 15

	process(var/obj/spacepod/spacepod)
		if(spacepod.internal_tank)
			var/datum/gas_mixture/tank_air = spacepod.internal_tank.return_air()
			var/datum/gas_mixture/cabin_air = spacepod.cabin_air

			var/release_pressure = ONE_ATMOSPHERE
			var/cabin_pressure = cabin_air.return_pressure()
			var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
			var/transfer_moles = 0
			if(pressure_delta > 0) //cabin pressure lower than release pressure
				if(tank_air.return_temperature() > 0)
					transfer_moles = pressure_delta * cabin_air.return_volume() / (cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
					cabin_air.merge(removed)
			else if(pressure_delta < 0) //cabin pressure higher than release pressure
				var/datum/gas_mixture/t_air = spacepod.get_turf_air()
				pressure_delta = cabin_pressure - release_pressure
				if(t_air)
					pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
				if(pressure_delta > 0) //if location pressure is lower than cabin pressure
					transfer_moles = pressure_delta * cabin_air.return_volume() / (cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
					if(t_air)
						t_air.merge(removed)
					else //just delete the cabin gas, we're in space or some shit
						qdel(removed)
		else
			return stop()
		return

/obj/spacepod/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	var/oldloc = loc
	. = ..()
	if(Dir && (oldloc != NewLoc))
		loc.Entered(src, oldloc)

/obj/spacepod/Process_Spacemove(var/check_drift = 0, mob/user)
	var/dense_object = 0
	if(!user)
		for(var/direction in list(NORTH, NORTHEAST, EAST))
			var/turf/cardinal = get_step(src, direction)
			if(istype(cardinal, /turf/space))
				continue
			dense_object++
			break
	if(!dense_object)
		return 0
	inertia_dir = 0
	return 1

/obj/spacepod/relaymove(mob/user, direction)
	if(user != occupant)
		return 0 //Stop hogging the wheel!
	if(move_delayer.blocked())
		return 0
	var/moveship = 1
	if(battery && battery.charge >= 3 && health)
		src.dir = direction

		if(inertia_dir == turn(direction, 180))
			inertia_dir = 0
			moveship = 0

		if(moveship)
			Move(get_step(src,direction), direction)
			if(istype(src.loc, /turf/space))
				inertia_dir = direction
	else
		if(!battery)
			to_chat(user, "<span class='warning'>No energy cell detected.</span>")
		else if(battery.charge < 3)
			to_chat(user, "<span class='warning'>Not enough charge left.</span>")
		else if(!health)
			to_chat(user, "<span class='warning'>She's dead, Jim</span>")
		else
			to_chat(user, "<span class='warning'>Unknown error has occurred, yell at pomf.</span>")
		return 0
	battery.charge = max(0, battery.charge - 3)
	move_delayer.delayNext(round(movement_delay,world.tick_lag))

/obj/spacepod/process_inertia(turf/start)
	set waitfor = 0

	if(Process_Spacemove(1))
		inertia_dir = 0
		return

	sleep(5)

	if(loc == start)
		if(inertia_dir)
			Move(get_step(src, inertia_dir), inertia_dir)
			return


/obj/effect/landmark/spacepod/random //One of these will be chosen from across all Z levels to receive a pod in gameticker.dm
	name = "spacepod spawner"
	invisibility = 101
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1

/obj/effect/landmark/spacepod/random/New()
	..()

/obj/effect/landmark/spacepod/guaranteed //We're not messing around: we want a guaranteed pod!
	name = "guaranteed spacepod spawner"
	invisibility = 101
	anchored = 1
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"

/obj/effect/landmark/spacepod/guaranteed/New()
	sleep(10)
	new /obj/spacepod/random(get_turf(src))
	qdel(src)

/obj/spacepod/acidable()
	return 0

/obj/spacepod/proc/move_into_pod(var/mob/living/L)
	if(L && L.client && L in range(1))
		L.reset_view(src)
		L.stop_pulling()
		L.forceMove(src)
		src.add_fingerprint(L)
		return 1
	return 0

/obj/spacepod/proc/move_pilot_inside(var/mob/living/carbon/human/H) //Person is becoming the pilot
	if(move_into_pod(H))
		occupant = H
		if(actions.len)
			for(var/datum/action/spacepod/pilot/P in actions)
				P.Grant(occupant)
			for(var/path in actions_types_pilot)
				var/datum/action/A = new path(src)
				actions.Add(A)
				A.Grant(occupant)

		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		return 1
	else
		return 0

/obj/spacepod/proc/move_pilot_outside(mob/living/user, turf/exit_loc = src.loc)
	if(occupant)
		inertia_dir = 0 // engage reverse thruster and power down pod
		occupant.forceMove(exit_loc)
		if(actions.len)
			for(var/datum/action/S in actions)
				if(istype (S, /datum/action/spacepod/pilot)) //Keep these
					S.Remove(occupant)
				else if(S.owner == occupant) //Remove these
					qdel(S)
					actions.Remove(S)
		occupant = null
		to_chat(usr, "<span class='notice'>You climb out of the pod.</span>")


/obj/spacepod/proc/move_passenger_inside(var/mob/living/carbon/human/H)
	if(!passengers_allowed)
		to_chat(H, "<span class='notice'>Error: Passengers forbidden.</span>")
		return 0
	if(move_into_pod(H))
		src.passengers.Add(H)
		//dir = dir_in
		to_chat(H, "<span class='notice'>You climb into a passenger seat within \the [src].</span>")
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		for(var/path in actions_types_passenger)
			var/datum/action/A = new path(src)
			actions.Add(A)
			A.Grant(H)
		return 1
	else
		return 0

/obj/spacepod/proc/move_passenger_outside(mob/living/user, turf/exit_loc = src.loc)
	if(passengers.len && passengers.Find(user))
		user.forceMove(exit_loc)
		passengers.Remove(user)
		for(var/datum/action/spacepod/S in actions)
			if(S.owner == user) //Remove these
				qdel(S)
				actions.Remove(S)
		to_chat(usr, "<span class='notice'>You climb out of the pod.</span>")

/obj/spacepod/proc/toggle_passengers()
	if(usr!=src.occupant)
		return
	src.passengers_allowed = !passengers_allowed
	to_chat(src.occupant, "<span class='notice'>Now [passengers_allowed?"allowing passengers":"disallowing passengers, and ejecting any current passengers"].</span>")
	if(!passengers_allowed && passengers.len)
		for(var/mob/living/L in passengers)
			to_chat(L, "<span class='warning'>Ejection sequence activated: Ejecting in 3 seconds</span>")
			spawn(30)
				if(passengers.Find(L) && L.loc == src)
					playsound(src, 'sound/weapons/rocket.ogg', 50, 1)
					var/turf/T = get_turf(src)
					var/turf/target_turf
					move_passenger_outside(L,T)
					target_turf = get_edge_target_turf(T, WEST)
					L.throw_at(target_turf,100,3)

/obj/spacepod/proc/toggle_passenger_guns()
	if(usr!=src.occupant)
		return
	src.passenger_fire = !passenger_fire
	to_chat(src.occupant, "<span class='notice'>Now [passenger_fire?"allowing passengers to fire spacepod weaponry":"disallowing passengers to fire spacepod weaponry"].</span>")
	playsound(src, 'sound/items/flashlight_on.ogg', 50, 1)

/obj/spacepod/taxi
	name = "taxi pod"
	icon_state = "pod_taxi"
	desc = "Brightly coloured to attract attention of potential passengers. Has room for multiple passengers at the expense of weapons"
	passenger_limit = 3
	actions_types = list(/datum/action/spacepod/pilot/toggle_passengers)
	actions_types_pilot = list()
	actions_types_passenger = list()

/obj/spacepod/taxi/New()
	..()
	equipment_system.weapons_allowed = 0

#undef DAMAGE
#undef FIRE
