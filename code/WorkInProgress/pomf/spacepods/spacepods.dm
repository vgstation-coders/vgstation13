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
	unacidable = 1
	layer = 3.9
	infra_luminosity = 15
	internal_gravity = 1 // Can move in 0-gravity
	var/mob/living/carbon/occupant
	var/datum/spacepod/equipment/equipment_system
	var/obj/item/weapon/cell/battery
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/effect/effect/system/trail/space_trail/ion_trail
	var/use_internal_tank = 0
	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_give_air //moves air from tank to cabin
	var/inertia_dir = 0
	var/hatch_open = 0
	var/next_firetime = 0
	var/list/pod_overlays
	var/health = 400
	appearance_flags = 0

/obj/spacepod/New()
	. = ..()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="pod_damage")
		pod_overlays[FIRE] = image(icon, icon_state="pod_fire")
	bound_width = 64
	bound_height = 64
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

/obj/spacepod/Destroy()
	if(src.occupant)
		src.occupant.loc = src.loc
		src.occupant.gib()
		src.occupant = null
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
		deal_damage(P.damage)

/obj/spacepod/proc/deal_damage(var/damage)
	var/oldhealth = health
	health = max(0, health - damage)
	var/percentage = (health / initial(health)) * 100
	if(occupant && oldhealth > health && percentage <= 25 && percentage > 0)
		var/sound/S = sound('sound/effects/engine_alert2.ogg')
		S.wait = 0 //No queue
		S.channel = 0 //Any channel
		S.volume = 50
		occupant << S
	if(occupant && oldhealth > health && !health)
		var/sound/S = sound('sound/effects/engine_alert1.ogg')
		S.wait = 0
		S.channel = 0
		S.volume = 50
		occupant << S
	if(!health)
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
				H.loc = get_turf(src)
				H.ex_act(severity + 1)
				to_chat(H, "<span class='warning'>You are forcefully thrown from \the [src]!</span>")
			del(ion_trail)
			del(src)
		if(2)
			deal_damage(100)
		if(3)
			if(prob(40))
				deal_damage(50)

/obj/spacepod/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		hatch_open = !hatch_open
		to_chat(user, "<span class='notice'>You [hatch_open ? "open" : "close"] the maintenance hatch.</span>")
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
			if(equipment_system.weapon_system)
				to_chat(user, "<span class='notice'>The pod already has a weapon system, remove it first.</span>")
				return
			else
				if(user.drop_item(W, src))
					to_chat(user, "<span class='notice'>You insert \the [W] into the equipment system.</span>")
					equipment_system.weapon_system = W
					equipment_system.weapon_system.my_atom = src
					new/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapon_system(src, equipment_system.weapon_system.verb_name, equipment_system.weapon_system.verb_desc) //Yes, it has to be referenced like that. W.verb_name/desc doesn't compile.
					return

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

	return

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
			desc = "An all black space pod with no insignias."
		if("pod_mil")
			desc = "A dark grey space pod brandishing the Nanotrasen Military insignia"
		if("pod_synd")
			desc = "A menacing military space pod with Fuck NT stenciled onto the side"
		if("pod_gold")
			desc = "A civilian space pod with a gold body, must have cost somebody a pretty penny"
		if("pod_industrial")
			desc = "A rough looking space pod meant for industrial work"

/obj/spacepod/verb/toggle_internal_tank()
	set name = "Toggle internal airtank usage"
	set category = "Object"
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
	cabin_air.oxygen = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.nitrogen = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
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

/obj/spacepod/proc/moved_inside(var/mob/living/carbon/human/H as mob)
	if(H && H.client && H in range(1))
		H.reset_view(src)
		/*
		H.client.perspective = EYE_PERSPECTIVE
		H.client.eye = src
		*/
		H.stop_pulling()
		H.forceMove(src)
		src.occupant = H
		src.add_fingerprint(H)
		src.forceMove(src.loc)
		//dir = dir_in
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		return 1
	else
		return 0

/obj/spacepod/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(M != user)
		return
	move_inside(M, user)

/obj/spacepod/MouseDrop(atom/over)
	if(!usr || !over)
		return
	if(!occupant == usr)
		return ..() //Handle mousedrop T
	var/turf/T = get_turf(over)
	if(!Adjacent(T) || T.density)
		return
	for(var/atom/movable/A in T.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	move_outside(usr, T)

/obj/spacepod/proc/move_outside(mob/living/user, turf/exit_loc = src.loc)
	if(occupant)
		inertia_dir = 0 // engage reverse thruster and power down pod
		occupant.forceMove(exit_loc)
		occupant = null
		to_chat(usr, "<span class='notice'>You climb out of the pod</span>")

/obj/spacepod/verb/move_inside()
	set category = "Object"
	set name = "Enter / Exit Pod"
	set src in oview(1)

	if(occupant)
		if(occupant == usr)
			move_outside(usr)
		else
			to_chat(usr, "<span class='notice'><B>The [src.name] is already occupied!</B></span>")
			return

	if(usr.incapacitated() || usr.lying) //are you cuffed, dying, lying, stunned or other
		return
	if (!ishuman(usr))
		return
/*
	if (usr.abiotic())
		to_chat(usr, "<span class='notice'><B>Subject cannot have abiotic items on.</B></span>")
		return
*/
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting your life sucked out of you.")
			return
//	to_chat(usr, "You start climbing into [src.name]")

	visible_message("<span class='notice'>[usr] starts to climb into [src.name]</span>")

	if(enter_after(40,usr))
		if(!src.occupant)
			moved_inside(usr)
		else if(src.occupant!=usr)
			to_chat(usr, "[src.occupant] was faster. Try better next time, loser.")
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
					transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
					cabin_air.merge(removed)
			else if(pressure_delta < 0) //cabin pressure higher than release pressure
				var/datum/gas_mixture/t_air = spacepod.get_turf_air()
				pressure_delta = cabin_pressure - release_pressure
				if(t_air)
					pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
				if(pressure_delta > 0) //if location pressure is lower than cabin pressure
					transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
					if(t_air)
						t_air.merge(removed)
					else //just delete the cabin gas, we're in space or some shit
						del(removed)
		else
			return stop()
		return

/obj/spacepod/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	var/oldloc = src.loc
	. = ..()
	if(dir && (oldloc != NewLoc))
		src.loc.Entered(src, oldloc)
/obj/spacepod/proc/Process_Spacemove(var/check_drift = 0, mob/user)
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
	var/moveship = 1
	if(battery && battery.charge >= 3 && health)
		src.dir = direction
		switch(direction)
			if(1)
				if(inertia_dir == 2)
					inertia_dir = 0
					moveship = 0
			if(2)
				if(inertia_dir == 1)
					inertia_dir = 0
					moveship = 0
			if(4)
				if(inertia_dir == 8)
					inertia_dir = 0
					moveship = 0
			if(8)
				if(inertia_dir == 4)
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

#undef DAMAGE
#undef FIRE
